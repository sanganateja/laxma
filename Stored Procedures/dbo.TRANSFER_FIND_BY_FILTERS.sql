SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[TRANSFER_FIND_BY_FILTERS]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_start_date DATETIME2(6),
    @p_end_date DATETIME2(6),
    @p_transfer_type_id NUMERIC,
    @p_from_amount NUMERIC,
    @p_to_amount NUMERIC,
    @p_transaction_id NUMERIC,
    @p_description NVARCHAR(2000),
    @p_cart_id NVARCHAR(2000),
    @p_account_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT t.TRANSFER_ID,
           t.TRANSFER_TIME,
           t.ACCOUNT_ID,
           t.TRANSFER_TYPE_ID,
           t.AMOUNT_MINOR_UNITS,
           t.BALANCE_AFTER_MINOR_UNITS,
           t.BATCH_ID,
           t.TRANSACTION_ID,
           t.TRANSFER_METHOD_ID,
           t.MATURITY_TIME,
           t.MATURITY_TRANSACTION_ID
    FROM dbo.ACC_TRANSFERS AS t
        LEFT JOIN dbo.ACC_TRANSACTIONS AS x
            ON x.TRANSACTION_ID = t.TRANSACTION_ID
        LEFT OUTER JOIN dbo.ACC_SALE_DETAILS AS s
            ON s.TRANSACTION_ID = t.TRANSACTION_ID
    WHERE t.ACCOUNT_ID = ISNULL(@p_account_id, t.ACCOUNT_ID)
          AND (t.TRANSFER_TIME
          BETWEEN ISNULL(@p_start_date, t.TRANSFER_TIME) AND ISNULL(@p_end_date, t.TRANSFER_TIME)
              )
          AND t.TRANSFER_TYPE_ID = ISNULL(@p_transfer_type_id, t.TRANSFER_TYPE_ID)
          AND (ABS(t.AMOUNT_MINOR_UNITS)
          BETWEEN ISNULL(@p_from_amount, ABS(t.AMOUNT_MINOR_UNITS)) AND ISNULL(@p_to_amount, ABS(t.AMOUNT_MINOR_UNITS))
              )
          AND t.TRANSACTION_ID = ISNULL(@p_transaction_id, t.TRANSACTION_ID)
          AND x.DESCRIPTION LIKE '%' + ISNULL(ISNULL(@p_description, NULL), '') + '%'
          AND
          (
              @p_cart_id IS NULL
              OR s.CART_ID LIKE '%' + ISNULL(@p_cart_id, '') + '%'
          )
    ORDER BY t.TRANSFER_ID;

    RETURN;

END;
GO
