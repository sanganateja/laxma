SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ================================================================================
--	Author:			Mat
--	Create date:	28/02/2019
--	Description:	
--		Handles the messages sent out when a queue is disabled.  Calls Fix Queue to
--		restart the stalled queue after removing the top message
--
--	Return:			
--		None		
--
--  Change history
--		28/02/2019	- Mat	- First version (based on Alliance)
--
-- ================================================================================
CREATE PROCEDURE [dbo].[spMessageProcessorQueueMonitorQueue]
WITH EXECUTE AS OWNER
AS
BEGIN
      SET NOCOUNT ON;

	  DECLARE @queuingorder bigint;
	  DECLARE @conversationhandle uniqueidentifier;
	  DECLARE @conversationgroupid uniqueidentifier;
	  DECLARE @messagetypename sysname;
	  DECLARE @messagebody xml;
	  DECLARE @messagesequencenumber bigint;
	  DECLARE @message nvarchar(max)

	  DECLARE @QueueName varchar(50);
	  DECLARE @ServiceName varchar(50);
	  DECLARE @Details varchar(200)

	  -- Do until there are no messages left on the queue.
      WHILE (1=1)
      BEGIN
            BEGIN TRANSACTION;

            -- Grab the top message
			WAITFOR(RECEIVE TOP (1)
			  @queuingorder=queuing_order,
			  @conversationhandle=conversation_handle,
			  @conversationgroupid=conversation_group_id,
			  @messagesequencenumber=message_sequence_number,
			  @messagetypename=message_type_name,
			  @message=message_body
			  FROM QueueMonitorQueue), TIMEOUT 1000;

            -- If there are none, then break out of the Message Processor SPROC
			IF (@@ROWCOUNT = 0)
            BEGIN
                  COMMIT;
                  RETURN;
            END			

			SELECT @messagebody=CONVERT(xml,@Message)

			BEGIN TRY
				IF N'http://schemas.microsoft.com/SQL/Notifications/EventNotification' = @messagetypename
				BEGIN	
					-- This is a notification that a queue is out.  Which queue?
					SELECT @QueueName=@messagebody.value('(/EVENT_INSTANCE/ObjectName)[1]', 'varchar(100)' );
					SELECT @ServiceName=LEFT(@QueueName,len(@QueueName)-5)+'Service'
					SELECT @Details='Restarting the '+@QueueName+' after Service Broker DEATH!'
					
					EXEC spLogError 'spMessageProcessorQueueMonitorQueue','INFO',@conversationhandle,null,@Details,@message

					EXEC spProcessQueueMonitorMessage @QueueName,@ServiceName
				END
								
				COMMIT TRANSACTION

			END TRY

			-- Otherwise there has been an error in the conversation.  Log it in PoisonMessage and Database Log
			BEGIN CATCH

				-- Now roll back the message retrieval to put the message back on the queue
				ROLLBACK TRANSACTION

				EXEC spLogError 'up_MessageProcessor_QueueMonitor','WARN',@conversationhandle,null,'Bombed out in Queue Monitor Notification Handling',@message
				
				INSERT tblPoisonMessage(conversation_handle,messagerecorded,count,originationqueue,messagetype,[message])
					VALUES(@conversationhandle,GetDate(),1,'QueueMonitor',@messagetypename,cast(@messagebody as varchar(max)))

			END CATCH

      END
	
END
GO
GRANT EXECUTE ON  [dbo].[spMessageProcessorQueueMonitorQueue] TO [ServiceBrokerUser]
GO
