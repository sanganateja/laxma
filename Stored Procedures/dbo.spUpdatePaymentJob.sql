SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
--  Author:			Mary
--  Create date:	15/01/2020
--  Description:
--      Updates data in the tblTransactionSearch table. This wil be called from Management API.
--		If the requested transaction is not found then return an error code.
--		If the requested transaction is found but no transaction search payment methods
--		WITH the requested reference are found then return an error code.
--		If the transaction is already present, the record will be augmented.
--
--  Return:			
--      Nothing
--
--  Change history
--		27/02/2020	- MA		- added ISNULL check on setting SearchTerms
--		13/02/2020	- MA		- Insert into @TransactionSearchIds should only look for channel<>G entries
--		16/01/2020  - TR		- Payment method 'CashFlows' cahanged to 'Card'
--								- Now updates 'A' and 'C' payment job reference
--								- Added return error code
--		15/01/2020  - Mary		- Created this sproc with duplicate of spPopulateTransactionSearch (ACQ-3152)
--
-- =============================================
CREATE PROCEDURE [dbo].[spUpdatePaymentJob] 
	@BusinessId [int], -- @ MANDATORY: OWNER_ID in old structure
	@MerchantId [int]=NULL, -- @MID if known
	@GatewayTerminalId [nvarchar](50)=NULL, -- Always populated for Gateway transactions. 
	@StartTime [datetime2], -- MANDATORY: TRAN_TIME in old structure
	@MerchantReference [nvarchar](255)=NULL, -- TRAN_CART_ID in old structure.  Merchants own ref.
	@PaymentJobReference [nvarchar](255)=NULL, -- Gateway paymentjob reference.
	@CustomerName [nvarchar](340)=NULL, -- Should be aggregated (where necessary) with spaces.
	@AmountRequested [decimal](12,2), -- MANDATORY: Should be in major units with minor as decimal
	@AmountReceived [decimal](12,2)=NULL, -- If not provided, assumed to match @AmountRequested
	@Currency [char](3), -- MANDATORY: Was TRAN_CURRENCY
	@TxStatus smallint, -- MANDATORY: One of a set of defined Transaction Status values.  Could be enum?
	@TxType smallint, -- MANDATORY: What type of transaction is this?  SALES, REFUND, VOID etc.
	@Channel [char](1), -- “G” Gateway, “A” Acquiring, “C” Cardholder Present
	@GatewayDetailsEndpoint [nvarchar](400)=NULL, -- URL from which Gateway tx details can be retrieved.
	@SearchString [nvarchar] (max)=NULL, -- Additional fields to search.  DO NOT include above fields, this sproc does that for you.
	@PaymentMethodList [ttPaymentMethodList] NULL READONLY -- A list of methods and references for this transaction.
AS
BEGIN
	SET NOCOUNT ON
	-- First determine if we already know about this transaction.
	-- We should only ever have one copy of each transaction, whether Gateway, Acquiring or both.
	DECLARE @TransactionSearchId bigint=NULL,
		@ErrorCodeTransactionNotFound INT = 1,
		@ErrorCodeTransactionSearchPaymentNotFound INT = 2,
		@CardPaymentMethod nvarchar(20) = 'Card'

	-- Set AmountReceived if necessary
	IF (@AmountReceived IS NULL) SET @AmountReceived=@AmountRequested

	-- Find by Gateway primary key
	IF (@TransactionSearchId IS NULL) AND (@PaymentJobReference IS NOT NULL) 
		SELECT @TransactionSearchId=TransactionSearchId 
		FROM tblTransactionSearch 
		WHERE PaymentJobReference=@PaymentJobReference
		AND tblTransactionSearch.Channel = @Channel

	-- If the requested transaction is not found then return an error code
	IF (@TransactionSearchId IS NULL)
		BEGIN
			RAISERROR(50001, 11, @ErrorCodeTransactionNotFound)
			RETURN;
		END;

	-- Is there any matches on payment method references
	DECLARE @PaymentMethodCardTransactionIds TABLE(
	TransactionId nvarchar(20) NULL)

	INSERT INTO @PaymentMethodCardTransactionIds (TransactionId)
	SELECT LEFT(PaymentMethodReference,20) 
	FROM @PaymentMethodList 
	WHERE PaymentMethod=@CardPaymentMethod
	
	DECLARE @TransactionSearchIds TABLE(
	TransactionId BIGINT NOT NULL)

	INSERT INTO @TransactionSearchIds (TransactionId)
		SELECT tspm.TransactionSearchId
		FROM @PaymentMethodCardTransactionIds pmct
		LEFT JOIN tblTransactionSearchPaymentMethods tspm
		ON pmct.TransactionId = tspm.PaymentMethodReference
		LEFT JOIN tblTransactionSearch ts
		ON ts.TransactionSearchId=tspm.TransactionSearchId
		WHERE tspm.PaymentMethod = @CardPaymentMethod AND ts.Channel<>'G'

	IF EXISTS(SELECT * FROM @PaymentMethodCardTransactionIds)
	BEGIN
	    IF (NOT EXISTS (SELECT 1 FROM @TransactionSearchIds)
		OR (SELECT count(*) FROM @TransactionSearchIds)<>(SELECT count(*) FROM @PaymentMethodCardTransactionIds))
		BEGIN
			RAISERROR(50001, 11, @ErrorCodeTransactionSearchPaymentNotFound)
			RETURN;
		END;

		-- 'A' or 'C' update payment job reference if a matched on the payment method reference (TransactionId) that match the joined tblTransactionSearchPaymentMethods PaymentReference for ‘Card’ PaymentMethods
		UPDATE tblTransactionSearch
			SET [PaymentJobReference] = @PaymentJobReference
			WHERE TransactionSearchId IN 
		(
			SELECT TransactionSearchId
			FROM @TransactionSearchIds tsids
			LEFT JOIN dbo.tblTransactionSearch ts
			ON tsids.TransactionId = ts.TransactionSearchId
			WHERE ts.Channel IN ('A','C')
		)
	END
	-- If the requested transaction is found but no transaction search payment methods with the requested references are found then return an error code
	

	-- 'G' Gateway transactions augment what is already there.	
	UPDATE tblTransactionSearch
		SET [MerchantId] = ISNULL(MerchantId,@MerchantId)
			,[GatewayTerminalId] = CASE WHEN @Channel='G' THEN @GatewayTerminalId ELSE ISNULL(GatewayTerminalId,@GatewayTerminalId) END
			,[MerchantReference] = ISNULL(MerchantReference,@MerchantReference)
			,[PaymentJobReference] = CASE WHEN @Channel='G' THEN @PaymentJobReference ELSE ISNULL(PaymentJobReference,@PaymentJobReference) END
			,[StartTime] = CASE WHEN @Channel='G' THEN @StartTime ELSE ISNULL(StartTime,@StartTime) END
			,[CustomerName] = CASE WHEN @Channel='G' THEN @CustomerName ELSE ISNULL(CustomerName,@CustomerName) END
			,[AmountRequested] = CASE WHEN @Channel='G' THEN @AmountRequested ELSE ISNULL(AmountRequested,@AmountRequested) END
			,[AmountReceived] = CASE WHEN @Channel='G' THEN @AmountReceived ELSE ISNULL(AmountReceived,@AmountReceived) END
			,[TxStatus] = ISNULL(@TxStatus,TxStatus) -- This column overwrites by default, since statuses update e.g. Authorised to Voided
			,[Channel] = CASE WHEN @Channel='G' THEN @Channel ELSE ISNULL(Channel,@Channel) END
			,[GatewayDetailsEndpoint] = CASE WHEN @Channel='G' THEN @GatewayDetailsEndpoint ELSE ISNULL(GatewayDetailsEndpoint,@GatewayDetailsEndpoint) END
			,[SearchString] = ISNULL(@SearchString,SearchString)
	WHERE TransactionSearchId = @TransactionSearchId

	-- Only update the payment methods if this is a Gateway update
	IF (@Channel='G') AND EXISTS(SELECT * FROM @PaymentMethodList)
	BEGIN
		-- Remove old entries
		DELETE FROM tblTransactionSearchPaymentMethods WHERE TransactionSearchId=@TransactionSearchId

		-- Add the updated ones
		INSERT INTO tblTransactionSearchPaymentMethods(TransactionSearchId,[PaymentMethod],[PaymentMethodReference],[Priority])
			SELECT @TransactionSearchId,PaymentMethod,PaymentMethodReference,[Priority] FROM @PaymentMethodList
		
	END
END
GO
GRANT EXECUTE ON  [dbo].[spUpdatePaymentJob] TO [DataServiceUser]
GO
