SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[CONCURRENT_REPORT_FIND]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_report_name NVARCHAR(2000)
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT c.REPORT_NAME,
           c.TIME_ADDED
    FROM dbo.ACC_CONCURRENT_REPORTS AS c
    WHERE c.REPORT_NAME = @p_report_name;

    RETURN;

END;
GO
