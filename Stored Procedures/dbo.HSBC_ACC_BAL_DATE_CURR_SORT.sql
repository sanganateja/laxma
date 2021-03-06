SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[HSBC_ACC_BAL_DATE_CURR_SORT]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_balance_date DATETIME2(6),
    @p_currency VARCHAR(2000),
    @p_sort_code NVARCHAR(2000)
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT ab.BALANCE_ID,
           ab.ACCOUNT_ID,
           ab.BALANCE_DATE,
           ab.OPENING_BALANCE_MINOR_UNITS,
           ab.CLOSING_BALANCE_MINOR_UNITS
    FROM dbo.ACC_HSBC_ACCOUNT_BALANCES AS ab
        JOIN dbo.ACC_HSBC_ACCOUNT_MAPPINGS AS am
            ON (ab.ACCOUNT_ID = am.ACCOUNT_ID)
    WHERE CAST(ab.BALANCE_DATE AS DATE) = CAST(@p_balance_date AS DATE)
          AND am.CURRENCY_CODE_ALPHA3 = @p_currency
          AND am.SORT_CODE = @p_sort_code;

    RETURN;

END;
GO
