SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_finance_acc_balances] @p_recordset VARCHAR(2000) OUTPUT
AS
BEGIN

    SET @p_recordset = NULL;

    DECLARE @p_datetime DATETIME2(6);

    SELECT @p_datetime = CAST(SYSDATETIME() AS DATE); /* Until midnight today (00:00:00)*/

    EXECUTE dbo.ACC_REPORTS_PACKAGE$rpt_period_fin_acc_balances @p_recordset = @p_recordset OUTPUT,
                                                                @p_dateTime = @p_datetime;

END;
GO
