SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_daily_payments_monitoring] @p_recordset VARCHAR(2000) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @v_start_date DATETIME2(6);
    DECLARE @v_end_date DATETIME2(6);

    SET @p_recordset = NULL;
    SET @v_start_date = DATEADD(DAY, -1, CAST(SYSDATETIME() AS DATE));
    SET @v_end_date = CAST(SYSDATETIME() AS DATE);

    EXEC [dbo].[ACC_REPORTS_PACKAGE$rpt_daily_payments_monitoring_with_dates] @p_recordset = @p_recordset OUTPUT,
                                                                              @p_start_date = @v_start_date,
                                                                              @p_end_date = @v_end_date;

                                                                              
END;
GO
