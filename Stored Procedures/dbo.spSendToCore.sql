SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ================================================================================
--  Author:       Mat
--  Create date: 28/02/2019
--  Description:
--      Sends a message back to Core containing the merchant balance.
--		Called by the Event Posting sprocs when an outbound payment is made.
--
--  Return:			
--      Nothing
--
--  Change history
--      20/06/2019  - Mat        - First version (based on spReplyToCore)
--
-- ================================================================================
CREATE   PROCEDURE [dbo].[spSendToCore]
	@OwnerId bigint
AS
BEGIN
    SET XACT_ABORT ON;

    DECLARE @RateDate datetime2
    DECLARE @MessageToSend xml
    DECLARE @ConversationHandle uniqueidentifier

	IF @OwnerId IS NOT NULL
	BEGIN
		-- Now get the latest FX rates, so we can convert everything to GBP equivalent.
		SELECT @RateDate=MAX(RATE_DATE) FROM FX_RATES WITH (NOLOCK)
		IF OBJECT_ID('tempdb..#FxRates') IS NOT NULL DROP TABLE #FxRates
		CREATE TABLE #FxRates(Currency char(3),Rate numeric(12,5))
		INSERT INTO #FXRates SELECT FROM_CURRENCY,RATE FROM FX_RATES WHERE RATE_DATE=@RateDate AND TO_CURRENCY='GBP'

		-- Build the message to send back to Core, containing GBP equivalent total value.
		SELECT @MessageToSend=
			(SELECT 1 as Tag, 0 as Parent,
					'BalanceUpdate' as [FromAccounts!1!Status!Element],
					ow.EXTERNAL_REF AS [FromAccounts!1!MerchantId!Element],
					SUM(CAST((CAST(a.BALANCE_MINOR_UNITS AS FLOAT(53)) *fx.Rate)/ POWER(10, c.DECIMAL_PLACES) as decimal(12,2))) AS [FromAccounts!1!TotalBalanceGBP!Element]
			FROM dbo.ACC_OWNERS AS ow
				INNER JOIN dbo.ACC_ACCOUNT_GROUPS AS ag ON ow.OWNER_ID = ag.OWNER_ID AND ag.ACCOUNT_GROUP_TYPE IN ('A','C')
				INNER JOIN dbo.ACC_CURRENCIES AS c ON ag.CURRENCY_CODE_ALPHA3 = c.CURRENCY_CODE_ALPHA3
				INNER JOIN dbo.ACC_ACCOUNTS AS a ON ag.ACCOUNT_GROUP_ID = a.ACCOUNT_GROUP_ID
				INNER JOIN dbo.ACC_ACCOUNT_TYPES AS AT ON a.ACCOUNT_TYPE_ID = AT.ACCOUNT_TYPE_ID
				INNER JOIN #FxRates fx on fx.Currency=c.CURRENCY_CODE_ALPHA3
		WHERE 
				a.ACCOUNT_TYPE_ID in (0,9) AND
				ow.OWNER_ID=@OwnerId
			GROUP BY OW.EXTERNAL_REF
			FOR XML EXPLICIT)

		IF OBJECT_ID('tempdb..#FxRates') IS NOT NULL DROP TABLE #FxRates
	END

	-- Build the empty message correctly, rather than by string casting.
	IF @MessageToSend is not null
	BEGIN
		-- Send the message back to Core via the existing queues
		BEGIN DIALOG @ConversationHandle
		FROM SERVICE AccountsInboundService
		TO SERVICE 'CoreOutboundService'
		ON CONTRACT InterDBContract;

		SEND 
			ON CONVERSATION @ConversationHandle
			MESSAGE TYPE ForOtherDBMessage(@MessageToSend);
	END

END
GO
