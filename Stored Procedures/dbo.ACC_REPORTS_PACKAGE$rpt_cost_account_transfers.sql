SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_cost_account_transfers] @p_recordset VARCHAR(2000) OUTPUT
AS
BEGIN

    SET @p_recordset = NULL;

    DECLARE @temp DATETIME;

    SET @temp = DATEFROMPARTS(DATEPART(YEAR, SYSDATETIME()), DATEPART(MONTH, SYSDATETIME()), 01);

    DECLARE @temp$2 DATETIME;

    SET @temp$2 = CAST(SYSDATETIME() AS DATE);

    /* From beginning of current month up to but not including today*/
    EXECUTE dbo.ACC_REPORTS_PACKAGE$rpt_cost_acc_transfers_dates @p_recordset = @p_recordset OUTPUT,
                                                                 @p_startdate = @temp,
                                                                 @p_enddate = @temp$2;

END;
GO
