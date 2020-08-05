SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ================================================================================
--	Author:			Mat
--	Create date:	28/02/2019
--	Description:	
--		Called by spMessageProcessorQueueMonitorQueue to fix a specified queue/service
--
--	Return:			
--		None
--
--  Change history
--		28/02/2019	- Mat	- First version (based on Alliance)
--
-- ================================================================================
CREATE PROCEDURE [dbo].[spProcessQueueMonitorMessage]
	@QueueName varchar(50),@ServiceName varchar(50)
AS
BEGIN
	DECLARE @receive_enabled bit;
	DECLARE	@enqueue_enabled bit;
	DECLARE @activation_enabled bit;
	DECLARE @CMD varchar(1000)
	DECLARE @MSG varchar(1000)
	DECLARE @HandleTable TABLE(conversationhandle uniqueidentifier)
	DECLARE @conversationhandle uniqueidentifier
	DECLARE @ProcessState varchar(3)

	SET NOCOUNT ON

	-- First check if we WANT this queue to perform automatically
	SELECT @ProcessState=null
	SELECT @ProcessState=SettingValue from tblGlobalSetting with (nolock) where SettingName=@QueueName+'_Process'
		
	-- If there is no setting for this queue, set it to Yes by default
	IF (@ProcessState is null)
	BEGIN
		SET @ProcessState='Yes'
		INSERT INTO tblGlobalSetting(SettingName,SettingValue) VALUES(@QueueName+'_Process','Yes')
	END

	-- Just double check that the queue really is off before we mess with it
	SELECT	@receive_enabled= is_receive_enabled,
			@activation_enabled = is_activation_enabled,
			@enqueue_enabled = is_enqueue_enabled
	FROM	sys.service_queues 
	WHERE	name=@QueueName
		
	IF (@receive_enabled = 0 or @enqueue_enabled = 0 or (@activation_enabled = 0 and @ProcessState='Yes'))
	BEGIN
		-- enable the queue but don't activate it yet
		select @CMD='ALTER QUEUE '+@QueueName+' WITH STATUS = ON, ACTIVATION (STATUS=OFF)'
		exec(@CMD)

		-- Grab the top message into a temporary table, and grab the conversation handle so we can end gracefully
		delete from @HandleTable
		select @CMD='DECLARE @conversationhandle uniqueidentifier; '+
			'WAITFOR(RECEIVE TOP (1) @conversationhandle=conversation_handle FROM '+@QueueName+'), TIMEOUT 1000;'+
			' SELECT @conversationhandle'
		INSERT INTO @HandleTable EXEC(@CMD)
		
		SELECT TOP 1 @conversationhandle=conversationhandle from @HandleTable
		
		IF (@conversationhandle is not null) END CONVERSATION @conversationhandle;

		-- Now try to reactivate the queue, assuming we want it active
		IF @ProcessState='Yes' and @QueueName<>'CoreMessageQueue'
		BEGIN
			SELECT @CMD='ALTER QUEUE '+@QueueName+' WITH STATUS = ON, ACTIVATION (STATUS=ON)'
			EXEC(@CMD)
		END
	
	END

END
GO
GRANT EXECUTE ON  [dbo].[spProcessQueueMonitorMessage] TO [ServiceBrokerUser]
GO
