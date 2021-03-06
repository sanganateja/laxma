SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_monthly_accounting_pricing] @p_recordset VARCHAR(2000) OUTPUT
AS
BEGIN

    SET @p_recordset = NULL;

    DECLARE @p_startdate DATETIME2(6),
            @p_enddate DATETIME2(6);


    SELECT @p_enddate = DATEFROMPARTS(DATEPART(YEAR, SYSDATETIME()), DATEPART(MONTH, SYSDATETIME()), 01); /* First day of this month*/

    SELECT @p_startdate = DATEADD(MONTH, -1, @p_enddate); /* Go back a month*/

    EXECUTE dbo.ACC_REPORTS_PACKAGE$rpt_period_accounting_pricing @p_recordset = @p_recordset OUTPUT,
                                                                  @p_startdate = @p_startdate,
                                                                  @p_enddate = @p_enddate;

END;
GO
