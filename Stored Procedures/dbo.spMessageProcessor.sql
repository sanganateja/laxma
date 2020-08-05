SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ================================================================================
--	Author:			Mat
--	Create date:	28/02/2019
--	Description:	
--		Receives the top message from the specified queue, handling manual deactivation
--		via tblGlobalSetting, Queue Killers and standard Service Broker end messages
--
--		NOTE: No transactional commits or rollback occur within this sproc.  This MUST
--		be handled by the calling sproc.  All clean returns from this Sproc should be
--		COMMITed, but this should be called from a TRY-CATCH block to handle errors
--
--	Return:			
--		MessageXML, MessageType and ConversationHandle
--
--  Change history
--		28/02/2019	- Mat	- First version (based on Alliance)
--
-- ================================================================================
CREATE PROCEDURE [dbo].[spMessageProcessor]
	@QueueName varchar(50),
	@MessageXML xml output,
	@MessageType sysname output,
	@ConversationHandle uniqueidentifier output
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @ProcessState varchar(3)
	DECLARE @messagebody nvarchar(max)
	DECLARE @MessageSproc varchar(100)

	-- Work out calling sproc for logging purposes
	SELECT @MessageSproc='spMessageProcessor'+@QueueName

	-- Work within a loop to process messages until either a custom message is returned,
	-- there are no messages left, or the queue is manually overriden by tblGlobalSetting
	WHILE (1=1)
	BEGIN
		-- First check if we WANT this queue to perform automatically
		SELECT @ProcessState=null
		SELECT @ProcessState=SettingValue from tblGlobalSetting with (nolock) where SettingName=@QueueName+'_Process'
		
		-- If there is no setting for this queue, set it to Yes by default
		IF (@ProcessState is null)
		BEGIN
			SET @ProcessState='Yes'
			INSERT INTO tblGlobalSetting(SettingName,SettingValue) VALUES(@QueueName+'_Process','Yes')
		END
			
		IF (@ProcessState='Yes')
		BEGIN		    
			-- Grab the top message from the chosen activated queue
			IF @QueueName='AccountsInboundQueue'
				WAITFOR(RECEIVE TOP(1) @conversationhandle=conversation_handle, @messagetype=message_type_name,
				  @messagebody=message_body FROM AccountsInboundQueue), TIMEOUT 1000;
			ELSE IF @QueueName='CoreMessageQueue'
				WAITFOR(RECEIVE TOP(1) @conversationhandle=conversation_handle, @messagetype=message_type_name,
				  @messagebody=message_body FROM CoreMessageQueue), TIMEOUT 1000;


			-- If there are none, then break out of the Message Processor SPROC
			IF (@@ROWCOUNT = 0)
			BEGIN
				SELECT @MessageType=null, @MessageXML=null, @ConversationHandle=null
				RETURN;
			END
			
			-- We have a message!
			-- First check if this is a Service Broker message.  If so, handle and loop
			IF N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog' = @messagetype
				END CONVERSATION @conversationhandle;
			ELSE IF N'http://schemas.microsoft.com/SQL/ServiceBroker/Error' = @messagetype
			BEGIN		
				exec spLogError @MessageSproc,'ERROR',@conversationhandle,null,'Service Broker ERROR Raised',@messagebody
				END CONVERSATION @conversationhandle;
			END
			ELSE
			BEGIN
				-- Now check if this conversation is a Queue Killer
				IF (EXISTS(SELECT QueueName from tblQueueKiller with (nolock)
							where QueueName=@QueueName and
							Conversation_Handle=@conversationhandle))
				BEGIN
					-- Yikes, it's poisonous.  Kill it by simply ending the conversation and looping on
					END CONVERSATION @conversationhandle; 
					DELETE FROM tblQueueKiller where QueueName=@QueueName and Conversation_Handle=@conversationhandle
				END
				ELSE
				BEGIN
					-- SUCCESS.  Message received and ready to return to calling Sproc
					-- Convert our message to XML and drop out leaving transaction open
					SELECT @messageXML=CONVERT(xml,@Messagebody)
					RETURN
				END
			END
		END
		ELSE
		BEGIN
			-- Queue has been manually deactivated, so return nothing so calling sproc can COMMIT any open transaction
			SELECT @MessageType=null, @MessageXML=null, @ConversationHandle=null
			RETURN			
		END
	END
END
GO
GRANT EXECUTE ON  [dbo].[spMessageProcessor] TO [ServiceBrokerUser]
GO
