SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[PROCESSOR_RECORD_CREATE]
    @p_process_log NVARCHAR(2000),
    @p_processor_name NVARCHAR(2000),
    @p_process_timestamp DATETIME2(6),
    @p_username NVARCHAR(2000),
    @p_acc_processor_id NUMERIC /* ID*/
AS
BEGIN
    INSERT dbo.ACC_PROCESSOR_RECORDS
    (
        PROCESS_LOG,
        PROCESSOR_NAME,
        PROCESS_TIMESTAMP,
        USERNAME,
        ACC_PROCESSOR_ID
    )
    VALUES
    (@p_process_log, @p_processor_name, @p_process_timestamp, @p_username, @p_acc_processor_id);
END;
GO
