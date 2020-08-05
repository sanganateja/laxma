SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ================================================================================
--  Author:       Mat
--  Create date: 28/02/2019
--  Description:
--      Sends a messgae back to Core containing the Tran_ref (to remove from tblCAMPostedTransactions),
--		the Merchant balance (for tblMerchantBalance), and the IRD for Mastercard CHP transactions
--
--  Return:			
--      Nothing
--
--  Change history
--		19/06/2019	- Mat		 - Tweaked to send CNP for all Visa or MC non-CHP transactions
--		14/06/2019	- Mat		 - Include the Interchnage Rate Tier in the message.
--      12/06/2019  - Andy Ayres - Added Cardholder Present parameters
--		28/05/2019	- Mat		 - Sends an empty message back to Core if the transaction
--								   does not exist and has not errored
--      24/04/2019  - Andy Ayres - Converted to update procedure and tabs removed
--      28/02/2019  - Mat        - First version (based on Alliance)
--
-- ================================================================================
CREATE   PROCEDURE [dbo].[spReplyToCore]
    @AccGrp                           NVARCHAR(50),
    @AcquirerId                       BIGINT,
    @Amount                           BIGINT,
    @CardType                         BIGINT,
    @CartId                           NVARCHAR(50),
    @ChargingClass                    BIGINT,
    @CimAccFundingSource              NVARCHAR(1),
    @CimApprovalCode                  NVARCHAR(100),
    @CimCabProgram                    NVARCHAR(100),
    @CimCardDataInputMode             NVARCHAR(1),
    @CimCardPresentData               INTEGER,
    @CimCardProgIdentifier            NVARCHAR(3),
    @CimCardholderAuthCapability      INTEGER,
    @CimCardholderAuthMethod          INTEGER,
    @CimCardholderPresentData         INTEGER,
    @CimCorporateCardCommonData       NVARCHAR(100),
    @CimCorporateLineItemDetail       NVARCHAR(100),
    @CimFunctionCode                  NVARCHAR(3),
    @CimGcmsProductIdentifier         NVARCHAR(3),
    @CimIcc                           NVARCHAR(100),
    @CimIrd                           NVARCHAR(3), -- Must be 3 to accommodate 'CNP' when required.
    @CimIssuerCountry                 NVARCHAR(2),
    @CimMcc                           NVARCHAR(4),
    @CimMerchantCountry               NVARCHAR(2),
    @CimMti                           NVARCHAR(4),
    @CimPosTerminalCapability         NVARCHAR(1),
    @CimProcessingCode                NVARCHAR(2),
    @CimProductType                   NVARCHAR(100),
    @CimServiceCode                   NVARCHAR(1),
    @CimTimelinessDays                BIGINT,
    @CivAfs                           NVARCHAR(1),
    @CivAti                           NVARCHAR(100),
    @CivAuthCharac                    NVARCHAR(100),
    @CivAuthCode                      NVARCHAR(100),
    @CivAuthRespCode                  NVARCHAR(2),
    @CivBusinessApplicationIdentifier NVARCHAR(100),
    @CivCardCapabilityFlag            NVARCHAR(1),
    @CivCardholderIdMethod            NVARCHAR(1),
    @CivChipTerminalDeploymentFlag    NVARCHAR(1),
    @CivCvvResult                     NVARCHAR(100),
    @CivDcci                          NVARCHAR(100),
    @CivFeeScenario                   NVARCHAR(50),
    @CivFpi                           NVARCHAR(100),
    @CivIssuerCountry                 NVARCHAR(2),
    @CivMcc                           NVARCHAR(4),
    @CivMerchantCountry               NVARCHAR(2),
    @CivMotoEci                       NVARCHAR(100),
    @CivPid                           NVARCHAR(2),
    @CivPosEntryMode                  NVARCHAR(2),
    @CivPosEnvCode                    NVARCHAR(100),
    @CivPosTerminalCapability         NVARCHAR(1),
    @CivProductSubtype                NVARCHAR(50),
    @CivProductType                   NVARCHAR(50),
    @CivReimbAttr                     NVARCHAR(1),
    @CivRequestedPaymentService       NVARCHAR(100),
    @CivTimelinessDays                BIGINT,
    @CsmIssuerCountry                 NVARCHAR(2),
    @CsmMerchantCountry               NVARCHAR(2),    
    @CsvCardType                      NVARCHAR(50),
    @CsvIssuerCountry                 NVARCHAR(2),
    @CsvMerchantCountry               NVARCHAR(2),
    @Currency                         NVARCHAR(3),
    @EventTime                        BIGINT,
    @EventType                        BIGINT,
    @FirstTranRef                     NVARCHAR(50),
    @IntchgDescription                NVARCHAR(50),
    @IntchgFeeProgram                 NVARCHAR(50),
    @IntchgRateTier                   NVARCHAR(50),
    @Region                           BIGINT,
    @Store_id                         BIGINT,
    @TxncstDescription                NVARCHAR(50),
    @TxncstFeeProgram                 NVARCHAR(50),
    @TxncstRateTier                   NVARCHAR(50),
    @TranRef                          NVARCHAR(50)
AS
BEGIN
    SET XACT_ABORT ON;

    DECLARE @RateDate datetime2
    DECLARE @AccountGroupID bigint
    DECLARE @OwnerId bigint
    DECLARE @MessageToSend xml
    DECLARE @ConversationHandle uniqueidentifier

    -- First look up the ACCOUNT GROUP ID from the Transaction Reference
    SELECT TOP 1 @AccountGroupId=ACCOUNT_GROUP_ID FROM ACC_TRANSACTIONS WHERE EXTERNAL_REF=@TranRef
    SELECT TOP 1 @OwnerID=OWNER_ID FROM ACC_ACCOUNT_GROUPS WHERE ACCOUNT_GROUP_ID=@AccountGroupID

	IF @OwnerId IS NOT NULL
	BEGIN
		-- Now get the latest FX rates, so we can convert everything to GBP equivalent.
		SELECT @RateDate=MAX(RATE_DATE) FROM FX_RATES WITH (NOLOCK)
		IF OBJECT_ID('tempdb..#FxRates') IS NOT NULL DROP TABLE #FxRates
		CREATE TABLE #FxRates(Currency char(3),Rate numeric(12,5))
		INSERT INTO #FXRates SELECT FROM_CURRENCY,RATE FROM FX_RATES WHERE RATE_DATE=@RateDate AND TO_CURRENCY='GBP'

		-- Double check we won't mess up CNP transactions bu clearing the CHP Mastercard field if unitentionally populated
		IF (ISNULL(@IntchgFeeProgram,'CHP')<>'CHP') SET @CimIrd=null

		-- Build the message to send back to Core, including GBP equivalent total value and (for CHP) the IRD value for Mastercard
		SELECT @MessageToSend=
			(SELECT 1 as Tag, 0 as Parent,
					@TranRef as [FromAccounts!1!TransactionReference!Element],
					'AccountsData' as [FromAccounts!1!Status!Element],
					ow.EXTERNAL_REF AS [FromAccounts!1!MerchantId!Element],
					SUM(CAST((CAST(a.BALANCE_MINOR_UNITS AS FLOAT(53)) *fx.Rate)/ POWER(10, c.DECIMAL_PLACES) as decimal(12,2))) AS [FromAccounts!1!TotalBalanceGBP!Element],
					ISNULL(@CimIrd ,'CNP') AS [FromAccounts!1!InterchangeRateTier!Element]
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
	IF @MessageToSend is null
	BEGIN
		SELECT @MessageToSend = 
			(SELECT 1 as Tag, 0 as Parent,
					@TranRef as [FromAccounts!1!TransactionReference!Element],
					'AccountsData' as [FromAccounts!1!Status!Element],
					0 AS [FromAccounts!1!MerchantId!Element],
					0.00 AS [FromAccounts!1!TotalBalanceGBP!Element],
					ISNULL(@CimIrd,'CNP') AS [FromAccounts!1!InterchangeRateTier!Element]
			FOR XML EXPLICIT)
		
	END

    -- Send the message back to Core via the existing queues
    BEGIN DIALOG @ConversationHandle
    FROM SERVICE AccountsInboundService
    TO SERVICE 'CoreOutboundService'
    ON CONTRACT InterDBContract;

    SEND 
        ON CONVERSATION @ConversationHandle
        MESSAGE TYPE ForOtherDBMessage(@MessageToSend);

END
GO
