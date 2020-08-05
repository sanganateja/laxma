SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ================================================================================
--	Author:			Mat
--	Create date:	28/02/2019
--	Description:	
--		Called from the CATCH block of the message handlers.  Standardises error
--		message logging and poison message/queue killer handling
--
--		NOTE: No ROLLBACKs are performed in this catch block.  They MUST be handled
--		by the calling sproc.
--
--	Return:			
--		Nothing
--
--  Change history
--		28/02/2019	- Mat	- First version (based on Alliance)
--
-- ================================================================================
CREATE PROCEDURE [dbo].[spMessageCatchProcessor]
	@QueueName varchar(50),
	@conversationhandle uniqueidentifier,
	@MessageType sysname,
	@MessageXML XML
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @MessageSproc varchar(100); 
	DECLARE @count INT ; 
	DECLARE @messagebody nvarchar(max)

	BEGIN TRY 
		-- Get a VARCHAR copy of the message and calling sproc for logging
		SELECT @messagebody=CONVERT(nvarchar(max),@messageXML)
		SELECT @MessageSproc='spMessageProcessor'+@QueueName
	
		-- How many times have we tried this?
		SELECT @count=NULL
		SELECT @count=count FROM tblPoisonMessage WITH (NOLOCK) WHERE conversation_handle = @conversationhandle; 

		-- If this is our first failed attempt then log the message and roll back the receive
		IF (@count = 0 or @count IS NULL) 
		BEGIN
			exec spLogError @MessageSproc,'WARN',@conversationhandle,null,'Received message but processing failed.  1st try.',@messagebody

			INSERT tblPoisonMessage(conversation_handle,messagerecorded,count,originationqueue,messagetype,[message])
				VALUES(@conversationhandle,GetDate(),1,@QueueName,@messagetype,@messagebody)
		END
		-- If this is our third attempt, give up trying to process but add this instead to the Queue Killer
		-- So rollback to the receive, then commit
		ELSE IF (@count >= 2) 
		BEGIN 
			exec spAddQueueKiller @QueueName,@ConversationHandle,@MessageSproc,@MessageXML
			END CONVERSATION @conversationhandle; 
		END 
		ELSE 
		BEGIN 
			-- On our 2nd and 3rd attempts, simply rollback and increment the error count
			exec spLogError @MessageSproc,'WARN',@conversationhandle,null,'Received message but processing failed.  Subsequent attempt.',@messagebody
			UPDATE tblPoisonMessage SET count=count+1 WHERE conversation_handle = @conversationhandle ; 
		END 

	END TRY 

	BEGIN CATCH 
		-- If we cannot even process the catch block, we're in trouble, so kill the message.
		exec spAddQueueKiller @QueueName,@ConversationHandle,@MessageSproc,@MessageXML
		END CONVERSATION @conversationhandle; 
	END CATCH 

END
GO
GRANT EXECUTE ON  [dbo].[spMessageCatchProcessor] TO [ServiceBrokerUser]
GO
