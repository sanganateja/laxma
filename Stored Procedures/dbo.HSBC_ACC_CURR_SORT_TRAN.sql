SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[HSBC_ACC_CURR_SORT_TRAN]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_currency VARCHAR(2000),
    @p_sort_code NVARCHAR(2000),
    @p_tran_type_id NUMERIC,
    @p_tran_met_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT a.ACCOUNT_ID,
           a.CURRENCY_CODE_ALPHA3,
           a.ACCOUNT_NUMBER,
           a.DESCRIPTION,
           a.STATEMENT_ENABLED
    FROM dbo.ACC_HSBC_ACCOUNTS AS a
        JOIN dbo.ACC_HSBC_ACCOUNT_MAPPINGS AS m
            ON a.ACCOUNT_ID = m.ACCOUNT_ID
    WHERE m.INCL_EXCL = 'I'
          AND (m.CURRENCY_CODE_ALPHA3 = @p_currency)
          AND
          (
              m.SORT_CODE = @p_sort_code
              OR m.SORT_CODE IS NULL
          )
          AND
          (
              m.TRANSFER_TYPE_ID = @p_tran_type_id
              OR m.TRANSFER_TYPE_ID IS NULL
          )
          AND
          (
              m.TRANSFER_METHOD_ID = @p_tran_met_id
              OR m.TRANSFER_METHOD_ID IS NULL
          )
    EXCEPT
    SELECT a.ACCOUNT_ID,
           a.CURRENCY_CODE_ALPHA3,
           a.ACCOUNT_NUMBER,
           a.DESCRIPTION,
           a.STATEMENT_ENABLED
    FROM dbo.ACC_HSBC_ACCOUNTS AS a
        JOIN dbo.ACC_HSBC_ACCOUNT_MAPPINGS AS m
            ON a.ACCOUNT_ID = m.ACCOUNT_ID
    WHERE m.INCL_EXCL = 'E'
          AND (m.CURRENCY_CODE_ALPHA3 = @p_currency)
          AND
          (
              m.SORT_CODE = @p_sort_code
              OR m.SORT_CODE IS NULL
          )
          AND
          (
              m.TRANSFER_TYPE_ID = @p_tran_type_id
              OR m.TRANSFER_TYPE_ID IS NULL
          )
          AND
          (
              m.TRANSFER_METHOD_ID = @p_tran_met_id
              OR m.TRANSFER_METHOD_ID IS NULL
          );

    RETURN;

END;
GO
