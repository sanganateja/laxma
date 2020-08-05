SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_mthly_chaps_payments_compl] @p_recordset VARCHAR(2000) OUTPUT
AS
BEGIN

    SET @p_recordset = NULL;

    EXECUTE dbo.ACC_REPORTS_PACKAGE$rpt_mthly_payments_compl @p_recordset = @p_recordset OUTPUT,
                                                             @p_report_type = 'CH';

END;
GO
