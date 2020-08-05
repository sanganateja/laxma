SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ================================================================================
--	Author:			Mat
--	Create date:	28/02/2019
--	Description:	
--		Reports on queue statuses in the database (enabled, activation, processing on/off
--
--	Return:			
--		Either OK or a message listing which queues are down
--
--  Change history
--		28/02/2019	- Mat	- First version (based on Alliance)
--
-- ================================================================================
CREATE PROCEDURE [dbo].[spCheckQueues]
	@Threshold int
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE 
		@Receive bit,@Enabled bit,@Activated bit,@ActivatedSproc varchar(100),@QueueName varchar(50),
		@Result varchar(1000),@ThisCount int
		
	DECLARE	@QueueCount TABLE(ThisCount int)

	-- Start with the header
	select @Result='<Queues>'

	DECLARE QueueCursor CURSOR FOR  
	SELECT name,is_receive_enabled as 'Receive',is_enqueue_enabled as 'Enabled',
		is_activation_enabled as 'Activated',activation_procedure as 'ActivationSproc'
	FROM sys.service_queues
	WHERE is_ms_shipped=0

	-- Step through each Queue and check what's happening
	OPEN QueueCursor   
	FETCH NEXT FROM QueueCursor INTO @QueueName,@Receive,@Enabled,@Activated,@ActivatedSproc   

	WHILE @@FETCH_STATUS = 0   
	BEGIN
		-- First, is the queue enabled
		IF (@Receive=0 or @Enabled=0)
			SELECT @Result=@Result+'<'+@QueueName+'>DOWN</'+@QueueName+'>' 
		
		IF (@Activated=0 and LEN(@ActivatedSproc)>0)
			SELECT @Result=@Result+'<'+@QueueName+'>DEACTIVATED</'+@QueueName+'>' 
		
		IF (@QueueName not in ('InitiatorQueue','QueueMonitorQueue'))
			IF NOT EXISTS(SELECT SettingValue FROM tblGlobalSetting WITH (nolock) WHERE SettingName=@QueueName+'_Process' and SettingValue='Yes')
				SELECT @Result=@Result+'<'+@QueueName+'>STACKING</'+@QueueName+'>' 

		DELETE FROM @QueueCount
		INSERT INTO @QueueCount
			EXEC('SELECT COUNT(*) as ''ThisCount'' FROM '+@QueueName+' WITH (NOLOCK)')

		-- Report the queue size if greater than the passed parameter
		SELECT @ThisCount=ThisCount FROM @QueueCount
			
		IF (@ThisCount>=@Threshold)
			SELECT @Result=@Result+'<'+@QueueName+'>'+cast(@ThisCount as varchar(20))+'</'+@QueueName+'>'
			
		FETCH NEXT FROM QueueCursor INTO @QueueName,@Receive,@Enabled,@Activated,@ActivatedSproc   
	END   

	CLOSE QueueCursor   
	DEALLOCATE QueueCursor

	-- Add the closing footer
	select @Result=@Result+'</Queues>'

	-- If no issues, just return OK
	IF @Result='<Queues></Queues>'
		SELECT cast('<Queues>OK</Queues>' as xml) as 'status'
	ELSE
		SELECT cast(@Result as xml) as 'status'

END
GO
