SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_ST_FETCH_FOR_PERIOD]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_statement_month DATETIME2(6),
    @p_account_group_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT acs.ACCOUNT_STATEMENT_ID,
           acs.STATEMENT_MONTH,
           acs.TRANSFER_TYPE_ID,
           acs.QUANTITY,
           acs.TOTAL_MINOR_UNITS,
           acs.ACCOUNT_GROUP_ID,
           ag.CURRENCY_CODE_ALPHA3 AS CURRENCY_CODE
    FROM dbo.ACC_ACCOUNT_STATEMENTS AS acs
        INNER JOIN dbo.ACC_ACCOUNT_GROUPS ag
            ON ag.ACCOUNT_GROUP_ID = @p_account_group_id
    WHERE acs.STATEMENT_MONTH = @p_statement_month
          AND acs.ACCOUNT_GROUP_ID = @p_account_group_id;

    RETURN;

END;
GO
