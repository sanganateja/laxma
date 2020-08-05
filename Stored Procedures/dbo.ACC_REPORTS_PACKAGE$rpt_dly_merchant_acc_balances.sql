SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_dly_merchant_acc_balances]
    @p_recordset VARCHAR(2000) OUTPUT,
    @p_crm_id NVARCHAR(2000) = NULL
AS
BEGIN

    SET @p_recordset = NULL;

    DECLARE @p_enddate DATETIME2(6);

    SELECT @p_enddate = CAST(SYSDATETIME() AS DATE); /* Midnight just gone*/

    EXECUTE dbo.ACC_REPORTS_PACKAGE$rpt_dte_merchant_acc_balances @p_recordset = @p_recordset OUTPUT,
                                                                  @p_enddate = @p_enddate,
                                                                  @p_crm_id = @p_crm_id;

END;
GO
