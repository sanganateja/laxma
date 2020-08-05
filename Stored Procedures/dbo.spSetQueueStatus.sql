SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ================================================================================
--	Author:			Mat
--	Create date:	28/02/2019
--	Description:	
--		Operator command - Allows a QUEUE to be PROCESSING or STACKING 
--			(Use our GlobalSettings overide on transaction Processing)
--
--	Return:			
--		Nothing
--
--  Change history
--		28/02/2019	- Mat	- First version (based on Alliance)
-- ================================================================================
CREATE PROCEDURE [dbo].[spSetQueueStatus]
	@QueueName varchar(50),
	@QueueStatus varchar(50)
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @SQL varchar(1000)

	IF NOT EXISTS(SELECT name FROM sys.service_queues WHERE name=@QueueName)
		PRINT 'Queue does not exist.'
	ELSE IF (@QueueStatus not in ('PROCESSING','STACKING'))
		PRINT 'Not a valid status for the queue.'
	ELSE
	BEGIN
		IF (@QueueStatus='STACKING')
		BEGIN
			UPDATE tblGlobalSetting set SettingValue='No' WHERE SettingName=@QueueName+'_Process'
			SELECT @SQL='ALTER QUEUE '+@QueueName+' WITH STATUS=ON, ACTIVATION (STATUS=OFF)'
			EXEC(@SQL)
		END
		ELSE 
		BEGIN
			UPDATE tblGlobalSetting set SettingValue='Yes' WHERE SettingName=@QueueName+'_Process'
			IF @QueueName<>'CoreMessageQueue'
			BEGIN
				SELECT @SQL='ALTER QUEUE '+@QueueName+' WITH STATUS=ON, ACTIVATION (STATUS=ON)'
				EXEC(@SQL)
			END
		END
	END

END
GO
