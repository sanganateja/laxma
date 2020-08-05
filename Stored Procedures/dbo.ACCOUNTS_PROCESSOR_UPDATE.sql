SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACCOUNTS_PROCESSOR_UPDATE]
    @p_cron_change_timestamp DATETIME2(6),
    @p_cron_enabled VARCHAR(2000),
    @p_cron_string NVARCHAR(2000),
    @p_cron_change_username NVARCHAR(2000),
    @p_last_run_timestamp DATETIME2(6),
    @p_last_run_username NVARCHAR(2000),
    @p_processor_name NVARCHAR(2000),
    @p_acc_processor_id NUMERIC /* ID*/
AS
BEGIN
    UPDATE dbo.ACC_PROCESSORS
    SET CRON_CHANGE_TIMESTAMP = @p_cron_change_timestamp,
        CRON_CHANGE_USERNAME = @p_cron_change_username,
        CRON_ENABLED = @p_cron_enabled,
        CRON_STRING = @p_cron_string,
        LAST_RUN_TIMESTAMP = @p_last_run_timestamp,
        LAST_RUN_USERNAME = @p_last_run_username,
        PROCESSOR_NAME = @p_processor_name
    WHERE ACC_PROCESSORS.ACC_PROCESSOR_ID = @p_acc_processor_id;
END;
GO
