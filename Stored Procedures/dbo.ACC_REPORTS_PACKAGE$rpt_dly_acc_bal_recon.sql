SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_dly_acc_bal_recon]
    @p_recordset VARCHAR(2000) OUTPUT,
    @p_crm_id NVARCHAR(2000) = NULL
AS
BEGIN

    SET @p_recordset = NULL;

    DECLARE @v_startdate DATETIME2(6),
            @v_enddate DATETIME2(6);


    /*
      *    FOR EASY TESTING...
      *   SELECT TO_DATE('01-JUN-2012', 'DD-MON-YYYY') INTO p_startdate FROM DUAL;
      *   SELECT TO_DATE(SYSDATE, 'DD-MON-YYYY') INTO p_enddate FROM DUAL;
      */
    SELECT @v_enddate = CAST(SYSDATETIME() AS DATE); /* Midnight just gone*/

    SELECT @v_startdate = DATEADD(DAY, -1, CAST(SYSDATETIME() AS DATE)); /* Go back a day*/

    EXECUTE dbo.ACC_REPORTS_PACKAGE$rpt_dte_acc_bal_recon @p_recordset = @p_recordset OUTPUT,
                                                          @p_startdate = @v_startdate,
                                                          @p_enddate = @v_enddate,
                                                          @p_crm_id = @p_crm_id;

END;
GO
