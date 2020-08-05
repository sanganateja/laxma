SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ================================================================================
--	Author:			Mat
--	Create date:	28/02/2019
--	Description:	
--		Process Messages sent from Core to the AccountsInboundQueue.
--		"Accounting" messages are send to the CoreMessageQueue
--		"Transaction" messages are processed into the new tblTransaction structure.
--
--	Return:			
--		None
--
--  Change history
--		24/07/2019	- Mat	- Extended to handle transaction replication.
--		28/02/2019	- Mat	- First version (based on Alliance)
--
-- ================================================================================
CREATE PROCEDURE [dbo].[spMessageProcessorAccountsInboundQueue]
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @ConversationHandle uniqueidentifier,@NewConversation uniqueidentifier;
	DECLARE @MessageType sysname;
	DECLARE @messageXML xml;
	DECLARE @messageToSend XML;

	DECLARE @TransactionReference nvarchar(50);
	DECLARE @PostType nvarchar(50);

	-- Do until there are no messages left on the queue.
	WHILE (1=1)
	BEGIN
		BEGIN TRY
		
			BEGIN TRANSACTION;
			
			-- Grab the top message using the Queue processing Sproc
			EXEC spMessageProcessor 'AccountsInboundQueue',@MessageXML output,@MessageType output,@ConversationHandle output

			-- Empty message means we're all done
			IF (@messagetype is null)
			BEGIN
				IF (XACT_STATE()=1) COMMIT TRANSACTION
				RETURN
			END

			-- We have a message, so deal with it			
			IF N'ForOtherDBMessage' = @messagetype
			BEGIN
				-- Get some informatiuon from the posted message
				SELECT @TransactionReference=@MessageXML.value('(/CAMPostingDetails/tran_ref)[1]', 'nvarchar(50)')
				SELECT @PostType=@MessageXML.value('(/CAMPostingDetails/PostType)[1]', 'nvarchar(50)' );

				IF @PostType=N'Accounting'
				BEGIN

					-- If this is an Account message, simply forward this inbound message to the CoreMessageQueue
					BEGIN DIALOG @NewConversation
					FROM SERVICE InitiatorService
					TO SERVICE 'CoreMessageService'
					ON CONTRACT CoreMessageContract;

					SEND 
					ON CONVERSATION @NewConversation
					MESSAGE TYPE CoreMessageMessage(@MessageXML);

					-- Then reply to the original message
					SELECT @MessageToSend='<FromAccounts><TransactionReference>'+cast(@TransactionReference as varchar(50))+'</TransactionReference><Status>Received</Status></FromAccounts>';

					SEND 
						ON CONVERSATION @ConversationHandle
						MESSAGE TYPE FromOtherDBMessage(@MessageToSend);
				END

				IF @PostType=N'Transaction'
					EXEC spProcessTransactionMessage @MessageXML

			END

			END CONVERSATION @conversationhandle;
			IF (XACT_STATE()=1) COMMIT TRANSACTION

		END TRY

		-- Otherwise there has been an error in the processing of the conversation.
		-- Use the CATCH handler to deal with it
		BEGIN CATCH
			-- Always rollback to put the message back on the queue
			IF (XACT_STATE()<>0) ROLLBACK TRANSACTION

			-- Now deal with the mess.  Incrementing count in DBLog or use QueueKiller on 3rd attempt
			EXEC spMessageCatchProcessor 'AccountsInboundQueue',@ConversationHandle,@MessageType,@MessageXML

		END CATCH
	END

END
GO
GRANT EXECUTE ON  [dbo].[spMessageProcessorAccountsInboundQueue] TO [ServiceBrokerUser]
GO
