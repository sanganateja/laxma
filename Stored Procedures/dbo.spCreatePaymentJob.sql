SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
--  Author:			Greg 
--  Create date:	24/01/2020
--  Description:
--      If no record of the sent transaction exists, a new record will be created.  If the transaction
--		is already present boom, return error code
--
--  Return:			
--      Nothing
--
--  Change history
--      24/01/2020  - Greg       - First version
--
-- =============================================
CREATE PROCEDURE [dbo].[spCreatePaymentJob] 
	@BusinessId [int], 
	@MerchantId [int]=NULL,
	@GatewayTerminalId [nvarchar](50)=NULL, 
	@StartTime [datetime2], 
	@MerchantReference [nvarchar](255)=NULL, 
	@PaymentJobReference [nvarchar](255)=NULL, 
	@CustomerName [nvarchar](340)=NULL, 
	@AmountRequested [decimal](12,2),
	@AmountReceived [decimal](12,2)=NULL,
	@Currency [char](3),
	@TxStatus smallint, 
	@TxType smallint, 
	@Channel [char](1),
	@GatewayDetailsEndpoint [nvarchar](400)=NULL, 
	@SearchString [nvarchar] (max)=NULL, 
	@PaymentMethodList [ttPaymentMethodList] NULL READONLY 
AS
BEGIN
	SET NOCOUNT ON
    -- First determine if we already know about this transaction.
	-- We should only ever have one copy of each transaction, whether Gateway, Acquiring or both.
	-- Use the three main ids to search.
	DECLARE @TransactionSearchId bigint=NULL,
			@ErrorCodeExistingTransaction INT = 1,
			@CardPaymentMethod nvarchar(20) = 'Card'

	-- Set AmountReceived if necessary
	IF (@AmountReceived is null) SET @AmountReceived=@AmountRequested

	-- Find by Gateway primary key
	IF (@TransactionSearchId is null) and (@PaymentJobReference is not null) 
		SELECT @TransactionSearchId=TransactionSearchId 
		FROM tblTransactionSearch ts
		WHERE ts.PaymentJobReference=@PaymentJobReference AND ts.Channel = 'G' 

	-- If we have a TransactionSearchId at this point, this is an existing transaction return error code
	IF(@TransactionSearchId IS NOT NULL)
	BEGIN
		RAISERROR(50001, 11, @ErrorCodeExistingTransaction)
		RETURN;
	END;

	-- Generate the payment method references as a coalesced space separated list
	DECLARE @PaymentReferenceList nvarchar(max)=null
	SELECT @PaymentReferenceList=COALESCE(@PaymentReferenceList + ' ', '') + PaymentMethodReference
	FROM @PaymentMethodList

	-- Extend the Search string to contain all the Reference fields from the feed
	SELECT @SearchString=TRIM(ISNULL(@SearchString,'')+' '+ISNULL(@MerchantReference,'')+' '+ISNULL(@PaymentJobReference,'')+' '+ISNULL(@CustomerName,'')+' '+ISNULL(@PaymentReferenceList,''))


	IF @SearchString='' SELECT @SearchString=null

	

	BEGIN
		INSERT INTO tblTransactionSearch
				   ([PrincipalId]
				   ,[BusinessId]
				   ,[MerchantId]
				   ,[GatewayTerminalId]
				   ,[StartTime]
				   ,[MerchantReference]
				   ,[PaymentJobReference]
				   ,[ARN]
				   ,[CustomerName]
				   ,[AmountRequested]
				   ,[AmountReceived]
				   ,[Currency]
				   ,[TxStatus]
				   ,[TxType]
				   ,[Channel]
				   ,[GatewayDetailsEndpoint]
				   ,[SearchString])
			 VALUES
				   (NULL,
				   @BusinessId,
				   @MerchantId,
				   @GatewayTerminalId,
				   @StartTime,
				   @MerchantReference,
				   @PaymentJobReference,
				   NULL,
				   @CustomerName,
				   @AmountRequested,
				   @AmountReceived,
				   @Currency,
				   @TxStatus,
				   @TxType,
				   @Channel,
				   @GatewayDetailsEndpoint,
				   @SearchString)

		SELECT @TransactionSearchId=SCOPE_IDENTITY()

		INSERT INTO tblTransactionSearchPaymentMethods(TransactionSearchId,[PaymentMethod],[PaymentMethodReference],[Priority])
			SELECT @TransactionSearchId,PaymentMethod,PaymentMethodReference,[Priority] FROM @PaymentMethodList

	END

END
GO
GRANT EXECUTE ON  [dbo].[spCreatePaymentJob] TO [DataServiceUser]
GO
