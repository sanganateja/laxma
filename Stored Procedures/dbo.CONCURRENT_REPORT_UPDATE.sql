SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[CONCURRENT_REPORT_UPDATE]
    @p_time_added DATETIME2(6),
    @p_report_name NVARCHAR(2000)
AS
BEGIN
    UPDATE dbo.ACC_CONCURRENT_REPORTS
    SET TIME_ADDED = CAST(@p_time_added AS DATE)
    WHERE ACC_CONCURRENT_REPORTS.REPORT_NAME = @p_report_name;
END;
GO
