SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ================================================================================
--	Author:			Mat
--	Create date:	28/02/2019
--	Description:	
--		Activated when a message hits the Initiator Queue.  This manages the
--		process of conversation closures for locally sent messages
--
--	Return:			
--		None		
--
--  Change history
--		28/02/2019	- Mat	- First version (based on Alliance)
--
-- ================================================================================
CREATE PROCEDURE [dbo].[spMessageProcessorInitiatorQueue]
AS
BEGIN
	SET NOCOUNT ON
	SET XACT_ABORT ON

	DECLARE @ConversationHandle uniqueidentifier

	-- Do until the message retrieval sproc returns empty.
	WHILE (1=1)
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION;

			-- Grab the top message using the Queue processing Sproc
			WAITFOR(RECEIVE TOP(1) @conversationhandle=conversation_handle 
				FROM InitiatorQueue), TIMEOUT 100;
				
			-- Empty message means we're all done
			IF (@@ROWCOUNT = 0)
			BEGIN
				IF (XACT_STATE()=1) COMMIT TRANSACTION
				RETURN
			END

			-- We have a message, so simply end the conversation, since all messages
			-- received by this queue are end conversations or errors only.
			END CONVERSATION @conversationhandle;
			IF (XACT_STATE()=1) COMMIT TRANSACTION
			
		END TRY

		-- Otherwise there has been an error in the conversation.
		BEGIN CATCH
			-- Don't rollback the message receive, simply continue
			END CONVERSATION @conversationhandle WITH CLEANUP;
			IF (XACT_STATE()=1) COMMIT TRANSACTION
		END CATCH
	END
END
GO
GRANT EXECUTE ON  [dbo].[spMessageProcessorInitiatorQueue] TO [ServiceBrokerUser]
GO
