SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[HSBC_ACC_FIND_CRITERIA]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_currency VARCHAR(2000),
    @p_sort_code NVARCHAR(2000),
    @p_tran_type_id NUMERIC,
    @p_tran_met_id NUMERIC
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
          AND
          (
              (
                  am.SORT_CODE IS NULL
                  AND @p_sort_code IS NULL
              )
              OR am.SORT_CODE = @p_sort_code
          )
          AND
          (
              (
                  am.TRANSFER_TYPE_ID IS NULL
                  AND @p_tran_type_id IS NULL
              )
              OR am.TRANSFER_TYPE_ID = @p_tran_type_id
          )
          AND
          (
              (
                  am.TRANSFER_METHOD_ID IS NULL
                  AND @p_tran_met_id IS NULL
              )
              OR am.TRANSFER_METHOD_ID = @p_tran_met_id
          );

    RETURN;

END;
GO
