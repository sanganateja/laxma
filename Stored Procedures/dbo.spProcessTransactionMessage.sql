SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ================================================================================
--    Author:           Mat
--    Create date:      24/07/2019
--    Description:      
--		Pick up the new Transaction replication messages and populate the
--		tblTransactionxxxxx structures.
--		**** CURRENTLY ONLY tblTransaction and TransactionSearch ****
--		**** Other tables to follow later. ****
--
--    Return:                 
--		Nothing
--
--  Change history
--      24/07/2019  - Mat	- First version
--		16/01/2020	- Greg		- Changes to support service broker and MAPI using separate sproc
--		28/02/2020	- MA		- added channel decision making, based on transaction class
--
-- ================================================================================
CREATE PROCEDURE [dbo].[spProcessTransactionMessage]
	  @MessageXML XML
AS
BEGIN
	SET NOCOUNT ON

	-- Grab all the message details into local paramaters
	DECLARE
		@TransactionId nvarchar(20),
		@MerchantReference nvarchar(255),
		@TransactionType bigint,
		@TransactionClass int,
		@AuthAmount decimal(12,2),
		@AuthCurrency char(3),
		@AuthAmountGBP decimal(12,2),
		@AuthFxRate float,
		@StartTime datetime2,
		@EndTime datetime2,
		@Duration float,
		@AcquirerId smallint,
		@BusinessId int,
		@MerchantId int,
		@TerminalId int,
		@ARN nvarchar(32),
		@CustomerName nvarchar(340),
		@TxStatus smallint,
		@SearchString nvarchar(max)

	SELECT @TransactionId=@MessageXML.value('(/CAMPostingDetails/TransactionId)[1]','nvarchar(20)')
	SELECT @MerchantReference=@MessageXML.value('(/CAMPostingDetails/MerchantReference)[1]','nvarchar(255)')
	SELECT @TransactionType=@MessageXML.value('(/CAMPostingDetails/TransactionType)[1]','bigint')
	SELECT @TransactionClass=@MessageXML.value('(/CAMPostingDetails/TransactionClass)[1]','int')
	SELECT @AuthAmount=@MessageXML.value('(/CAMPostingDetails/AuthAmount)[1]','decimal(12,2)')
	SELECT @AuthCurrency=@MessageXML.value('(/CAMPostingDetails/AuthCurrency)[1]','char(3)')
	SELECT @AuthAmountGBP=@MessageXML.value('(/CAMPostingDetails/AuthAmountGBP)[1]','decimal(12,2)')
	SELECT @AuthFxRate=@MessageXML.value('(/CAMPostingDetails/AuthFxRate)[1]','float')
	SELECT @StartTime=@MessageXML.value('(/CAMPostingDetails/StartTime)[1]','datetime2')
	SELECT @EndTime=@MessageXML.value('(/CAMPostingDetails/EndTime)[1]','datetime2')
	SELECT @Duration=@MessageXML.value('(/CAMPostingDetails/Duration)[1]','float')
	SELECT @AcquirerId=@MessageXML.value('(/CAMPostingDetails/AcquirerId)[1]','smallint')
	SELECT @BusinessId=@MessageXML.value('(/CAMPostingDetails/BusinessId)[1]','int')
	SELECT @MerchantId=@MessageXML.value('(/CAMPostingDetails/MerchantId)[1]','int')
	SELECT @TerminalId=@MessageXML.value('(/CAMPostingDetails/TerminalId)[1]','int')
	SELECT @ARN=@MessageXML.value('(/CAMPostingDetails/ARN)[1]','nvarchar(32)')
	SELECT @CustomerName=@MessageXML.value('(/CAMPostingDetails/CustomerName)[1]','nvarchar(340)')
	SELECT @TxStatus=@MessageXML.value('(/CAMPostingDetails/TxStatus)[1]','smallint')
	SELECT @SearchString=@MessageXML.value('(/CAMPostingDetails/SearchString)[1]','nvarchar(max)')

	-- Right, first check if this transaction already exists in tblTransaction.
	-- If it doesn't insert it.  If it does, update it.
	DECLARE @PrincipalId bigint

	SELECT @PrincipalId=PrincipalId FROM tblTransaction WHERE TransactionId=@TransactionId

	IF @PrincipalId is null
	BEGIN
		-- This is all new.
		INSERT INTO [dbo].[tblTransaction]
				   ([TransactionId]
				   ,[MerchantReference]
				   ,[TransactionType]
				   ,[TransactionClass]
				   ,[AuthAmount]
				   ,[AuthCurrency]
				   ,[AuthAmountGBP]
				   ,[AuthFxRate]
				   ,[StartTime]
				   ,[EndTime]
				   ,[Duration]
				   ,[AcquirerId]
				   ,[BusinessId]
				   ,[MerchantId]
				   ,[TerminalId]
				   ,[BillingAddress]
				   ,[CardId])
			 VALUES
				   (@TransactionId,
				   @MerchantReference,
				   @TransactionType,
				   @TransactionClass,
				   @AuthAmount,
				   @AuthCurrency,
				   @AuthAmountGBP,
				   @AuthFxRate,
				   @StartTime,
				   @EndTime,
				   @Duration,
				   @AcquirerId,
				   @BusinessId,
				   @MerchantId,
				   @TerminalId,
				   null, -- Placeholder
				   null) -- Placeholder

		-- Grab this Principal id
		SELECT @PrincipalId=SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
		-- We recognise this transaction, so update it.
		UPDATE [dbo].[tblTransaction]
		   SET [TransactionId] = @TransactionId
			  ,[MerchantReference] = @MerchantReference
			  ,[TransactionType] = @TransactionType
			  ,[TransactionClass] = @TransactionClass
			  ,[AuthAmount] = @AuthAmount
			  ,[AuthCurrency] = @AuthCurrency
			  ,[AuthAmountGBP] = @AuthAmountGBP
			  ,[AuthFxRate] = @AuthFxRate
			  ,[StartTime] = @StartTime
			  ,[EndTime] = @EndTime
			  ,[Duration] = @Duration
			  ,[AcquirerId] = @AcquirerId
			  ,[BusinessId] = @BusinessId
			  ,[MerchantId] = @MerchantId
			  ,[TerminalId] = @TerminalId
			  --,[BillingAddress] = @BillingAddress
			  --,[CardId] = @CardId
		 WHERE PrincipalId=@PrincipalId

	END

	-- Now populate, or update, the Omnichannel search tables, passing in the transaction id
	DECLARE	@PaymentMethodList [ttPaymentMethodList] 
	INSERT INTO @PaymentMethodList VALUES('Card',@TransactionId,1)

	-- Work out the correct channel based on the transaction class. CHP is currently 7-13
	DECLARE @channel [char](1)
	SELECT @channel=CASE WHEN @TransactionClass>=7 AND @TransactionClass <=13 THEN 'C' ELSE 'A' END

	exec spPopulateTransactionSearch @PrincipalId,@BusinessId,@MerchantId,null,@StartTime,@MerchantReference,null,
				@ARN,@CustomerName,@AuthAmount,@AuthAmount,@AuthCurrency,@TxStatus,@TransactionType,@channel,null,@SearchString,@PaymentMethodList

END

GO
GRANT EXECUTE ON  [dbo].[spProcessTransactionMessage] TO [ServiceBrokerUser]
GO
