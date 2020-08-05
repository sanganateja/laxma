SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_monthly_cashflows_activity]
(@p_recordset VARCHAR(2000) OUTPUT)
AS
BEGIN
    SET NOCOUNT ON;

    SET @p_recordset = NULL;

    DECLARE @p_enddate DATE;

    SELECT @p_enddate = DATEFROMPARTS(DATEPART(YEAR, GETDATE()), DATEPART(MONTH, GETDATE()), 01); -- First day of this month
    EXEC dbo.ACC_REPORTS_PACKAGE$rpt_period_cashflows_activity @p_recordset,
                                                               @p_enddate,
                                                               0; -- report for all businesses
END;
GO
