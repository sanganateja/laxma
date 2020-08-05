SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_finance_merchant_turnover] @p_recordset VARCHAR(2000) OUTPUT
AS
BEGIN

    SET @p_recordset = NULL;

    DECLARE @p_startdate DATETIME2(6),
            @p_enddate DATETIME2(6);


    SELECT @p_startdate
        = DATEFROMPARTS(
                           DATEPART(YEAR, DATEADD(D, -1, SYSDATETIME())),
                           DATEPART(MONTH, DATEADD(D, -1, SYSDATETIME())),
                           01
                       ); /* Start of the month that yesterday was in*/

    SELECT @p_enddate = CAST(SYSDATETIME() AS DATE); /* Until midnight today (00:00:00)*/

    EXECUTE dbo.ACC_REPORTS_PACKAGE$rpt_period_merchant_turnover @p_recordset = @p_recordset OUTPUT,
                                                                 @p_startdate = @p_startdate,
                                                                 @p_enddate = @p_enddate;

END;
GO
