SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_fin_dly_acc_statement]
    @p_recordset VARCHAR(2000) OUTPUT,
    @p_owner_id NUMERIC
AS
BEGIN

    SET @p_recordset = NULL;


    DECLARE @p_startdate DATETIME2(6),
            @p_enddate DATETIME2(6);

    SELECT @p_enddate = CAST(SYSDATETIME() AS DATE); /* Midnight just gone*/

    SELECT @p_startdate = DATEADD(DAY, -1, @p_enddate); /* Go back a day*/

    EXECUTE dbo.ACC_REPORTS_PACKAGE$rpt_finance_acc_statement @p_recordset,
                                                              @p_startdate,
                                                              @p_enddate,
                                                              @p_owner_id;
END;
GO
