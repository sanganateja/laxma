SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE     PROCEDURE [dbo].[COST_STATEMENT]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_start_date DATETIME2(6),
    @p_end_date DATETIME2(6),
    @p_transfer_type_id NUMERIC,
    @p_from_amount NUMERIC,
    @p_to_amount NUMERIC,
    @p_transaction_id NUMERIC,
    @p_description NVARCHAR(2000),
    @p_cart_id NVARCHAR(2000),
    @p_source_ref NVARCHAR(2000),
    @p_account_id NUMERIC
AS
BEGIN

	/*
	Changes to paramter handling to improve performance
	*/

    SET @cv_1 = NULL;
	SET @p_start_date = ISNULL(@p_start_date, CAST(DATEADD(dd , -3, cast (GETDATE() AS DATE)) AS DATETIME))
	SET @p_end_date = ISNULL(@p_end_date, CAST(DATEADD(dd , 1, cast (GETDATE() AS DATE)) AS DATETIME))


    /*
      *   
      *
      *    All input parameters are optional.
      *    A single query including all parameters takes a considerable time to run.
      *    The vast majority of the time only a fixed subset of input parameters are provided.
      *    Three queries are provided below. The first two are optimised for common sets of input parameters and run considerably faster than the general purpose query, which appears last.
      *   
      *
      */
    IF (
           (@p_description IS NULL)
           AND (@p_cart_id IS NULL)
           AND (@p_transaction_id IS NULL)
           AND (@p_to_amount IS NULL)
           AND (@p_from_amount IS NULL)
           AND (@p_transfer_type_id IS NULL)
           AND (@p_transaction_id IS NULL)
           AND (@p_source_ref IS NULL)
       )
    BEGIN

        SELECT t.TRANSFER_ID,
               t.AMOUNT_MINOR_UNITS,
               t.BALANCE_AFTER_MINOR_UNITS,
               t.BATCH_ID,
               s.CART_ID,
               x.DESCRIPTION,
               tt.NAME,
               t.TRANSACTION_ID,
               t.TRANSFER_TIME,
               tt.TRANSFER_TYPE_ID,
               xx.TRANSACTION_ID AS FIRST_TXN_ID,
               xx.EXTERNAL_REF AS FIRST_TXN_EXTERNAL_REF,
               x.AMOUNT_MINOR_UNITS AS SALE_AMOUNT,
               ds.DESCRIPTION AS COST_TYPE,
               CEILING(tc1.VARIABLE_AMOUNT_MINOR_UNITS) AS INTER_VAR,
               tc1.FIXED_AMOUNT_MINOR_UNITS AS INTER_FIXED,
               tc1.FIXED_CURRENCY_CODE_ALPHA3 AS INTER_FIXED_CUR,
               tc1.FX_RATE_APPLIED_PRICING AS INTER_FX_RATE,
               CEILING(tc2.VARIABLE_AMOUNT_MINOR_UNITS) AS SCHEME_FEE_VAR,
               tc2.FIXED_AMOUNT_MINOR_UNITS AS SCHEME_FEE_FIX,
               tc2.FIXED_CURRENCY_CODE_ALPHA3 AS SCHEME_FEE_FIX_CUR,
               tc2.FX_RATE_APPLIED_PRICING AS SCHEME_FX_RATE
        FROM dbo.ACC_TRANSFERS AS t
            LEFT JOIN dbo.ACC_TRANSACTIONS AS x
                LEFT JOIN dbo.ACC_TRANSACTIONS AS xx
                    ON x.TXN_FIRST_ID = xx.TRANSACTION_ID
                ON x.TRANSACTION_ID = t.TRANSACTION_ID
            LEFT OUTER JOIN dbo.ACC_SALE_DETAILS AS s
                ON s.TRANSACTION_ID = t.TRANSACTION_ID
            LEFT JOIN dbo.ACC_TRANSFER_TYPES AS tt
                ON tt.TRANSFER_TYPE_ID = t.TRANSFER_TYPE_ID
            LEFT JOIN dbo.ACC_TRANSACTION_MARGINS AS tmg
                ON t.TRANSACTION_ID = tmg.TRANSACTION_ID
            LEFT JOIN dbo.ACC_TRANSACTION_COSTS AS tc1
                ON t.TRANSACTION_ID = tc1.TRANSACTION_ID
                   AND tc1.TYPE_ID = 2
            LEFT JOIN dbo.CST_DESIGNATORS AS ds
                ON ds.DESIGNATOR_ID = tc1.DESIGNATOR_ID
            LEFT JOIN dbo.ACC_TRANSACTION_COSTS AS tc2
                ON t.TRANSACTION_ID = tc2.TRANSACTION_ID
                   AND tc2.TYPE_ID = 3
        WHERE t.ACCOUNT_ID = @p_account_id
              AND (t.TRANSFER_TIME
              BETWEEN @p_start_date AND @p_end_date
                  )
              AND t.TRANSFER_TYPE_ID IN ( 4, 19, 85 ) /* MSC, Refund, MSC Void */
        ORDER BY t.TRANSFER_ID;

        RETURN;

    END;
    ELSE IF (
                (@p_description IS NULL)
                AND (@p_cart_id IS NULL)
                AND (@p_source_ref IS NULL)
                AND (@p_transaction_id IS NULL)
            )
    BEGIN

        SELECT t.TRANSFER_ID,
               t.AMOUNT_MINOR_UNITS,
               t.BALANCE_AFTER_MINOR_UNITS,
               t.BATCH_ID,
               s.CART_ID,
               x.DESCRIPTION,
               tt.NAME,
               t.TRANSACTION_ID,
               t.TRANSFER_TIME,
               tt.TRANSFER_TYPE_ID,
               xx.TRANSACTION_ID AS FIRST_TXN_ID,
               xx.EXTERNAL_REF AS FIRST_TXN_EXTERNAL_REF,
               x.AMOUNT_MINOR_UNITS AS SALE_AMOUNT,
               ds.DESCRIPTION AS COST_TYPE,
               CEILING(tc1.VARIABLE_AMOUNT_MINOR_UNITS) AS INTER_VAR,
               tc1.FIXED_AMOUNT_MINOR_UNITS AS INTER_FIXED,
               tc1.FIXED_CURRENCY_CODE_ALPHA3 AS INTER_FIXED_CUR,
               tc1.FX_RATE_APPLIED_PRICING AS INTER_FX_RATE,
               CEILING(tc2.VARIABLE_AMOUNT_MINOR_UNITS) AS SCHEME_FEE_VAR,
               tc2.FIXED_AMOUNT_MINOR_UNITS AS SCHEME_FEE_FIX,
               tc2.FIXED_CURRENCY_CODE_ALPHA3 AS SCHEME_FEE_FIX_CUR,
               tc2.FX_RATE_APPLIED_PRICING AS SCHEME_FX_RATE
        FROM dbo.ACC_TRANSFERS AS t
            LEFT JOIN dbo.ACC_TRANSACTIONS AS x
                LEFT JOIN dbo.ACC_TRANSACTIONS AS xx
                    ON x.TXN_FIRST_ID = xx.TRANSACTION_ID
                ON x.TRANSACTION_ID = t.TRANSACTION_ID
            LEFT OUTER JOIN dbo.ACC_SALE_DETAILS AS s
                ON s.TRANSACTION_ID = t.TRANSACTION_ID
            LEFT JOIN dbo.ACC_TRANSFER_TYPES AS tt
                ON tt.TRANSFER_TYPE_ID = t.TRANSFER_TYPE_ID
            LEFT JOIN dbo.ACC_TRANSACTION_MARGINS AS tmg
                ON t.TRANSACTION_ID = tmg.TRANSACTION_ID
            LEFT JOIN dbo.ACC_TRANSACTION_COSTS AS tc1
                ON t.TRANSACTION_ID = tc1.TRANSACTION_ID
                   AND tc1.TYPE_ID = 2
            LEFT JOIN dbo.CST_DESIGNATORS AS ds
                ON ds.DESIGNATOR_ID = tc1.DESIGNATOR_ID
            LEFT JOIN dbo.ACC_TRANSACTION_COSTS AS tc2
                ON t.TRANSACTION_ID = tc2.TRANSACTION_ID
                   AND tc2.TYPE_ID = 3
        WHERE t.ACCOUNT_ID = @p_account_id
              AND (t.TRANSFER_TIME
              BETWEEN @p_start_date AND @p_end_date
                  )
              AND t.TRANSFER_TYPE_ID = ISNULL(@p_transfer_type_id, t.TRANSFER_TYPE_ID)
              AND t.TRANSFER_TYPE_ID IN ( 4, 19, 85 ) /* MSC, Refund, MSC Void */
              AND ABS(t.AMOUNT_MINOR_UNITS)
              BETWEEN ISNULL(@p_from_amount, ABS(t.AMOUNT_MINOR_UNITS)) AND ISNULL(
                                                                                      @p_to_amount,
                                                                                      ABS(t.AMOUNT_MINOR_UNITS)
                                                                                  )
        ORDER BY t.TRANSFER_ID;

        RETURN;

    END;
    ELSE
    BEGIN

        SELECT t.TRANSFER_ID,
               t.AMOUNT_MINOR_UNITS,
               t.BALANCE_AFTER_MINOR_UNITS,
               t.BATCH_ID,
               s.CART_ID,
               x.DESCRIPTION,
               tt.NAME,
               t.TRANSACTION_ID,
               t.TRANSFER_TIME,
               tt.TRANSFER_TYPE_ID,
               xx.TRANSACTION_ID AS FIRST_TXN_ID,
               xx.EXTERNAL_REF AS FIRST_TXN_EXTERNAL_REF,
               x.AMOUNT_MINOR_UNITS AS SALE_AMOUNT,
               ds.DESCRIPTION AS COST_TYPE,
               CEILING(tc1.VARIABLE_AMOUNT_MINOR_UNITS) AS INTER_VAR,
               tc1.FIXED_AMOUNT_MINOR_UNITS AS INTER_FIXED,
               tc1.FIXED_CURRENCY_CODE_ALPHA3 AS INTER_FIXED_CUR,
               tc1.FX_RATE_APPLIED_PRICING AS INTER_FX_RATE,
               CEILING(tc2.VARIABLE_AMOUNT_MINOR_UNITS) AS SCHEME_FEE_VAR,
               tc2.FIXED_AMOUNT_MINOR_UNITS AS SCHEME_FEE_FIX,
               tc2.FIXED_CURRENCY_CODE_ALPHA3 AS SCHEME_FEE_FIX_CUR,
               tc2.FX_RATE_APPLIED_PRICING AS SCHEME_FX_RATE
        FROM dbo.ACC_TRANSFERS AS t
            LEFT JOIN dbo.ACC_TRANSACTIONS AS x
                LEFT JOIN dbo.ACC_TRANSACTIONS AS xx
                    ON x.TXN_FIRST_ID = xx.TRANSACTION_ID
                ON x.TRANSACTION_ID = t.TRANSACTION_ID
            LEFT OUTER JOIN dbo.ACC_SALE_DETAILS AS s
                ON s.TRANSACTION_ID = t.TRANSACTION_ID
            LEFT JOIN dbo.ACC_TRANSFER_TYPES AS tt
                ON tt.TRANSFER_TYPE_ID = t.TRANSFER_TYPE_ID
            LEFT JOIN dbo.ACC_TRANSACTION_MARGINS AS tmg
                ON t.TRANSACTION_ID = tmg.TRANSACTION_ID
            LEFT JOIN dbo.ACC_TRANSACTION_COSTS AS tc1
                ON t.TRANSACTION_ID = tc1.TRANSACTION_ID
                   AND tc1.TYPE_ID = 2
            LEFT JOIN dbo.CST_DESIGNATORS AS ds
                ON ds.DESIGNATOR_ID = tc1.DESIGNATOR_ID
            LEFT JOIN dbo.ACC_TRANSACTION_COSTS AS tc2
                ON t.TRANSACTION_ID = tc2.TRANSACTION_ID
                   AND tc2.TYPE_ID = 3
        WHERE t.ACCOUNT_ID = @p_account_id
              AND (t.TRANSFER_TIME
              BETWEEN @p_start_date AND @p_end_date
                  )
              AND t.TRANSFER_TYPE_ID = ISNULL(@p_transfer_type_id, t.TRANSFER_TYPE_ID)
              AND t.TRANSFER_TYPE_ID IN ( 4, 19, 85 ) /* MSC, Refund, MSC Void */
              AND ABS(t.AMOUNT_MINOR_UNITS)
              BETWEEN ISNULL(@p_from_amount, ABS(t.AMOUNT_MINOR_UNITS)) AND ISNULL(
                                                                                      @p_to_amount,
                                                                                      ABS(t.AMOUNT_MINOR_UNITS)
                                                                                  )
              AND t.TRANSACTION_ID = ISNULL(@p_transaction_id, t.TRANSACTION_ID)
              AND
              (
                  @p_cart_id IS NULL
                  OR s.CART_ID LIKE '%' + ISNULL(@p_cart_id, '') + '%'
              )
              AND
              (
                  @p_source_ref IS NULL
                  OR x.SOURCE_REF = @p_source_ref
              )
              AND
              (
                  @p_description IS NULL
                  OR x.DESCRIPTION LIKE '%' + ISNULL(@p_description, '') + '%'
              )
        ORDER BY t.TRANSFER_ID;

        RETURN;

    END;

END;
GO
