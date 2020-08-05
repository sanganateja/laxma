SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACCOUNTS_PROCESSOR_CREATE]
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
    INSERT dbo.ACC_PROCESSORS
    (
        CRON_CHANGE_TIMESTAMP,
        CRON_CHANGE_USERNAME,
        CRON_ENABLED,
        CRON_STRING,
        LAST_RUN_TIMESTAMP,
        LAST_RUN_USERNAME,
        PROCESSOR_NAME,
        ACC_PROCESSOR_ID
    )
    VALUES
    (@p_cron_change_timestamp,
     @p_cron_change_username,
     @p_cron_enabled,
     @p_cron_string,
     @p_last_run_timestamp,
     @p_last_run_username,
     @p_processor_name,
     @p_acc_processor_id);
END;
GO
