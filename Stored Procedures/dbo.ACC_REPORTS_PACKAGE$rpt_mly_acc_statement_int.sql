SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_mly_acc_statement_int]
    @p_recordset VARCHAR(2000) OUTPUT,
    @p_crm_id NVARCHAR(2000) = NULL
AS
BEGIN

    SET @p_recordset = NULL;

    DECLARE @p_startdate DATETIME2(6),
            @p_enddate DATETIME2(6);

    SELECT @p_enddate = DATEFROMPARTS(DATEPART(YEAR, SYSDATETIME()), DATEPART(MONTH, SYSDATETIME()), 01); /* First day of this month*/

    SELECT @p_startdate = DATEADD(MONTH, -1, @p_enddate); /* Go back a month*/

    EXECUTE dbo.ACC_REPORTS_PACKAGE$rpt_acc_statement_int @p_recordset = @p_recordset OUTPUT,
                                                          @p_startdate = @p_startdate,
                                                          @p_enddate = @p_enddate,
                                                          @p_crm_id = @p_crm_id; /* report for all businesses*/

END;
GO
