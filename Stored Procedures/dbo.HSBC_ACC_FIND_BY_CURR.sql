SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[HSBC_ACC_FIND_BY_CURR]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_currency VARCHAR(2000)
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT ac.ACCOUNT_ID,
           ac.CURRENCY_CODE_ALPHA3,
           ac.ACCOUNT_NUMBER,
           ac.DESCRIPTION,
           ac.STATEMENT_ENABLED
    FROM dbo.ACC_HSBC_ACCOUNTS AS ac
        JOIN dbo.ACC_HSBC_ACCOUNT_MAPPINGS AS am
            ON (ac.ACCOUNT_ID = am.ACCOUNT_ID)
    WHERE am.CURRENCY_CODE_ALPHA3 = @p_currency
          AND am.SORT_CODE IS NULL
          AND am.TRANSFER_TYPE_ID IS NULL
          AND am.TRANSFER_METHOD_ID IS NULL;

    RETURN;

END;
GO