SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ================================================================================
--  Author:			Mat
--  Create date:	02/07/2019
--  Description:
--      Adds data to the tblTransactionSearch table.  This wil be called from the
--		Core->Account service broker process.  If no record
--		of the sent transaction exists, a new record will be created.  If the transaction
--		is already present, the record will be augmented (normally with Gateway data).
--
--  Return:			
--      Nothing
--
--  Change history
--		24/01/2020	- Greg		- Changes to magic string and now solely used for the service broker process
--		25/07/2019	- Mat		- Removed duplicated MerchantReference in Search String
--		17/07/2019	- Mat		- Now requires TxStatus and TxType as smallints
--								- to match the values in the tlkpTables
--      02/07/2019  - Mat       - First version
--
-- ================================================================================
CREATE PROCEDURE [dbo].[spPopulateTransactionSearch]
	@PrincipalId [bigint]=NULL, -- tblTransaction primary key if known
	@BusinessId [int], -- @ MANDATORY: OWNER_ID in old structure
	@MerchantId [int]=NULL, -- @MID if known
	@GatewayTerminalId [nvarchar](50)=NULL, -- Always populated for Gateway transactions. 
	@StartTime [datetime2], -- MANDATORY: TRAN_TIME in old structure
	@MerchantReference [nvarchar](255)=NULL, -- TRAN_CART_ID in old structure.  Merchants own ref.
	@PaymentJobReference [nvarchar](255)=NULL, -- Gateway paymentjob reference.
	@ARN [nvarchar](32)=NULL, -- Acquirer Reference Number for Acquiring transactions
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
	-- Use the three main ids to search.
	DECLARE @TransactionSearchId bigint=null
	DECLARE @TransactionId nvarchar(20)=null, 
	@CardPaymentMethod nvarchar(20) = 'Card';

	-- First see if we have a TransactionId (TRAN_REF) in this payment methods record set
	SELECT @TransactionId=LEFT(PaymentMethodReference,20) FROM @PaymentMethodList WHERE PaymentMethod=@CardPaymentMethod

	-- Set AmountReceived if necessary
	IF (@AmountReceived is null) SET @AmountReceived=@AmountRequested

	-- Find by Acquiring primary key
	IF (@PrincipalId is not null) 
		SELECT @TransactionSearchId=TransactionSearchId 
		FROM tblTransactionSearch 
		WHERE PrincipalId=@PrincipalId

	-- Find by Gateway primary key
	IF (@TransactionSearchId is null) and (@PaymentJobReference is not null) 
		SELECT @TransactionSearchId=TransactionSearchId 
		FROM tblTransactionSearch 
		WHERE PaymentJobReference=@PaymentJobReference

	-- Find by a Card TransactionId if one is in the payment methods.
	IF (@TransactionSearchId is null) and (@TransactionId is not null)
		SELECT @TransactionSearchId=TransactionSearchId 
		FROM tblTransactionSearchPaymentMethods
		WHERE PaymentMethod=@CardPaymentMethod and PaymentMethodReference=@TransactionId

	-- Build the serach string from existing (if existing), the porvided string and the main paramaters
	DECLARE @ExistingSearch nvarchar(max)
	IF (@TransactionSearchId is not null) 
		SELECT @ExistingSearch=SearchString FROM tblTransactionSearch WHERE TransactionSearchId=@TransactionSearchId

	-- Generate the payment method references as a coalesced space separated list
	DECLARE @PaymentReferenceList nvarchar(max)=null
	SELECT @PaymentReferenceList=COALESCE(@PaymentReferenceList + ' ', '') + PaymentMethodReference
	FROM @PaymentMethodList

	-- Extend the Search string to contain all the Reference fields from the feed
	SELECT @SearchString=TRIM(ISNULL(@ExistingSearch,'')+' '+ISNULL(@SearchString,'')+' '+ISNULL(@MerchantReference,'')+' '+ISNULL(@PaymentJobReference,'')+' '+
							ISNULL(@ARN,'')+' '+ISNULL(@CustomerName,'')+' '+ISNULL(@PaymentReferenceList,''))

	-- No point in inserting an empty string in to the search field.  Not that this is likely to happen often.
	IF @SearchString='' SELECT @SearchString=null

	-- If we have a TransactionSearchId at this point, then we know of this transaction.  Otherwise, it's new to us.
	IF (@TransactionSearchId is null)
	BEGIN
		-- **** TO DO: Cannot do this step yet, until the new tblTransaction is in place *****
		--IF (@PrincipalId is null) and (@TransactionId is not null) 
		--	SELECT @PrincipalId=PrincipalID FROM tblTransaction WHERE TransactionId=@TransactionID

		-- This is a brand new transaction.  Simply insert it
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
				   (@PrincipalId,
				   @BusinessId,
				   @MerchantId,
				   @GatewayTerminalId,
				   @StartTime,
				   @MerchantReference,
				   @PaymentJobReference,
				   @ARN,
				   @CustomerName,
				   @AmountRequested,
				   @AmountReceived,
				   @Currency,
				   @TxStatus,
				   @TxType,
				   @Channel,
				   @GatewayDetailsEndpoint,
				   @SearchString)

		-- Grab the IDENTITY value and create the Payment Method entries
		SELECT @TransactionSearchId=SCOPE_IDENTITY()

		INSERT INTO tblTransactionSearchPaymentMethods(TransactionSearchId,[PaymentMethod],[PaymentMethodReference],[Priority])
			SELECT @TransactionSearchId,PaymentMethod,PaymentMethodReference,[Priority] FROM @PaymentMethodList

	END
	ELSE
	BEGIN
		-- We know about this transaction already.  Update it based on old and new Channel.
		-- 'G' Gateway transactions augment what is already there.
		-- 'A' or 'C' should only update non-null table fields.
		UPDATE tblTransactionSearch
		   SET [PrincipalId] = ISNULL(PrincipalId,@PrincipalId)
			  ,[MerchantId] = ISNULL(MerchantId,@MerchantId)
			  ,[GatewayTerminalId] = ISNULL(GatewayTerminalId,@GatewayTerminalId)
			  ,[MerchantReference] = ISNULL(MerchantReference,@MerchantReference)
			  ,[PaymentJobReference] = ISNULL(PaymentJobReference,@PaymentJobReference)
			  ,[StartTime] = ISNULL(StartTime,@StartTime)
			  ,[ARN] = ISNULL(ARN,@ARN)
			  ,[CustomerName] = ISNULL(CustomerName,@CustomerName)
			  ,[AmountRequested] = ISNULL(AmountRequested,@AmountRequested)
			  ,[AmountReceived] = ISNULL(AmountReceived,@AmountReceived)
			  ,[TxStatus] = ISNULL(@TxStatus,TxStatus) -- This column overwrites by default, since statuses update e.g. Authorised to Voided
			  ,[Channel] = ISNULL(Channel,@Channel)
			  ,[GatewayDetailsEndpoint] = ISNULL(GatewayDetailsEndpoint,@GatewayDetailsEndpoint)
			  ,[SearchString] = @SearchString -- Always update with any new data
		WHERE TransactionSearchId=@TransactionSearchId

	END

END
GO
GRANT EXECUTE ON  [dbo].[spPopulateTransactionSearch] TO [DataServiceUser]
GO
