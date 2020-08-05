SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_monthly_fees_due] @p_recordset VARCHAR(2000) OUTPUT
AS
BEGIN

    SET @p_recordset = NULL;

    DECLARE @p_duedate DATETIME2(6);

    SELECT @p_duedate = SYSDATETIME(); /* Current date*/

    EXECUTE dbo.ACC_REPORTS_PACKAGE$rpt_monthly_fees_due_for_date @p_recordset = @p_recordset OUTPUT,
                                                                  @p_duedate = @p_duedate;

END;
GO
