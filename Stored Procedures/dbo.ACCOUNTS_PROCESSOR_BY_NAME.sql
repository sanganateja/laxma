SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACCOUNTS_PROCESSOR_BY_NAME]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_processor_name NVARCHAR(2000)
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT ACC_PROCESSORS.ACC_PROCESSOR_ID,
           ACC_PROCESSORS.PROCESSOR_NAME,
           ACC_PROCESSORS.CRON_CHANGE_USERNAME,
           ACC_PROCESSORS.CRON_CHANGE_TIMESTAMP,
           ACC_PROCESSORS.CRON_STRING,
           ACC_PROCESSORS.CRON_ENABLED,
           ACC_PROCESSORS.LAST_RUN_USERNAME,
           ACC_PROCESSORS.LAST_RUN_TIMESTAMP
    FROM dbo.ACC_PROCESSORS
    WHERE ACC_PROCESSORS.PROCESSOR_NAME = @p_processor_name;

    RETURN;

END;
GO