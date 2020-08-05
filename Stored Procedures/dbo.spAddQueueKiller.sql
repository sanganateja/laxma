SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ================================================================================
--	Author:			Mat
--	Create date:	28/02/2019
--	Description:	
--		Adds a message to the QueueKiller table to ensure that the next receive
--		simply deletes the message and saves the queue from poisoning.
--
--	Return:			
--		None
--
--  Change history
--		28/02/2019	- Mat	- First version (based on Alliance)
--
-- ================================================================================
CREATE PROCEDURE [dbo].[spAddQueueKiller]
	@QueueName varchar(50),
	@conversationHandle uniqueidentifier,
	@MessageSproc varchar(100), 
	@messageXML XML
AS
BEGIN
	IF (NOT EXISTS(SELECT QueueName from tblQueueKiller WITH (NOLOCK) 
		where QueueName=@QueueName and
		Conversation_Handle=@conversationhandle))
		INSERT INTO tblQueueKiller(QueueName,Conversation_Handle)
				VALUES(@QueueName,@conversationhandle)
	
	DECLARE @MessageBody nvarchar(max)
	SELECT @MessageBody=CONVERT(nvarchar(max),@MessageXML)
		
	exec spLogError @MessageSproc,'ERROR',@conversationhandle,null,'DOOMED transaction!  Added conversation ID to QueueKiller',@messagebody
	
END
GO
GRANT EXECUTE ON  [dbo].[spAddQueueKiller] TO [ServiceBrokerUser]
GO
