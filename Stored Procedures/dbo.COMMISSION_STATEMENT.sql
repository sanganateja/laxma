SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[COMMISSION_STATEMENT]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_start_date DATETIME2(6),
    @p_end_date DATETIME2(6),
    @p_from_amount NUMERIC,
    @p_to_amount NUMERIC,
    @p_transaction_id NUMERIC,
    @p_profile_id NUMERIC,
    @p_description NVARCHAR(2000),
    @p_account_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;


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
           AND (@p_transaction_id IS NULL)
           AND (@p_to_amount IS NULL)
           AND (@p_from_amount IS NULL)
           AND (@p_profile_id IS NULL)
       )
    BEGIN

        SELECT t.TRANSFER_ID,
               t.AMOUNT_MINOR_UNITS,
               t.BALANCE_AFTER_MINOR_UNITS,
               t.BATCH_ID,
               s.CART_ID,
               s.CARD_TYPE_ID AS TRANS_CARD_TYPE_ID,
               x.DESCRIPTION,
               tt.NAME,
               t.TRANSACTION_ID,
               t.TRANSFER_TIME,
               tt.TRANSFER_TYPE_ID,
               xx.TRANSACTION_ID AS FIRST_TXN_ID,
               xx.EXTERNAL_REF AS FIRST_TXN_EXTERNAL_REF,
               x.SOURCE_REF AS PROFILE_ID,
               magOwner.OWNER_NAME AS MERCHANT_NAME,
               magTrans.EVENT_TYPE_ID AS TRANSACTION_TYPE_ID,
               magTrans.AMOUNT_MINOR_UNITS AS TRANSACTION_AMOUNT,
               magAG.CURRENCY_CODE_ALPHA3 AS TRANSACTION_CURRENCY,
               pagAG.CURRENCY_CODE_ALPHA3 AS COMMISSION_CURRENCY,
               x.EXCHANGE_RATE AS FX_RATE,
               x.BUY_FIXED_AMOUNT_MINOR_UNIT,
               x.BUY_VARIABLE_PERCENTAGE,
               x.SELL_FIXED_AMOUNT_MINOR_UNIT,
               x.SELL_VARIABLE_PERCENTAGE,
               commPlan.PLAN_NAME
        FROM dbo.ACC_TRANSFERS AS t
            LEFT JOIN dbo.ACC_TRANSACTIONS AS x
                LEFT JOIN dbo.ACC_TRANSACTIONS AS xx
                    ON x.TXN_FIRST_ID = xx.TRANSACTION_ID
                ON x.TRANSACTION_ID = t.TRANSACTION_ID
            LEFT JOIN dbo.ACC_TRANSACTIONS AS magTrans
                ON magTrans.TXN_ASSOCIATION_ID = x.TXN_ASSOCIATION_ID
                   AND magTrans.TRANSACTION_ID <> x.TRANSACTION_ID
            LEFT OUTER JOIN dbo.ACC_SALE_DETAILS AS s
                ON s.TRANSACTION_ID = magTrans.TRANSACTION_ID
            LEFT JOIN dbo.ACC_TRANSFER_TYPES AS tt
                ON tt.TRANSFER_TYPE_ID = t.TRANSFER_TYPE_ID
            LEFT JOIN dbo.ACC_ACCOUNT_GROUPS AS magAG
                ON magAG.ACCOUNT_GROUP_ID = magTrans.ACCOUNT_GROUP_ID
            LEFT JOIN dbo.ACC_ACCOUNT_GROUPS AS pagAG
                ON pagAG.ACCOUNT_GROUP_ID = x.ACCOUNT_GROUP_ID
            LEFT JOIN dbo.ACC_OWNERS AS magOwner
                ON magOwner.OWNER_ID = magAG.OWNER_ID
            LEFT JOIN dbo.ACC_COMMISSION_PLANS AS commPlan
                ON magAG.COMMISSION_PLAN_ID = commPlan.PLAN_ID
        WHERE t.ACCOUNT_ID = ISNULL(@p_account_id, t.ACCOUNT_ID)
              AND (t.TRANSFER_TIME
              BETWEEN ISNULL(@p_start_date, t.TRANSFER_TIME) AND ISNULL(@p_end_date, t.TRANSFER_TIME)
                  )
              AND t.TRANSFER_TYPE_ID IN ( 46, 69, 71, 88, 89 ) /* Bank_Payment, Commission, Negative_Commission, Commission_Void, Negative_Commission_Void */
        ORDER BY t.TRANSFER_ID;

        RETURN;

    END;
    ELSE IF (
                (@p_description IS NULL)
                AND (@p_transaction_id IS NULL)
                AND (@p_profile_id IS NULL)
            )
    BEGIN

        SELECT t.TRANSFER_ID,
               t.AMOUNT_MINOR_UNITS,
               t.BALANCE_AFTER_MINOR_UNITS,
               t.BATCH_ID,
               s.CART_ID,
               s.CARD_TYPE_ID AS TRANS_CARD_TYPE_ID,
               x.DESCRIPTION,
               tt.NAME,
               t.TRANSACTION_ID,
               t.TRANSFER_TIME,
               tt.TRANSFER_TYPE_ID,
               xx.TRANSACTION_ID AS FIRST_TXN_ID,
               xx.EXTERNAL_REF AS FIRST_TXN_EXTERNAL_REF,
               x.SOURCE_REF AS PROFILE_ID,
               magOwner.OWNER_NAME AS MERCHANT_NAME,
               magTrans.EVENT_TYPE_ID AS TRANSACTION_TYPE_ID,
               magTrans.AMOUNT_MINOR_UNITS AS TRANSACTION_AMOUNT,
               magAG.CURRENCY_CODE_ALPHA3 AS TRANSACTION_CURRENCY,
               pagAG.CURRENCY_CODE_ALPHA3 AS COMMISSION_CURRENCY,
               x.EXCHANGE_RATE AS FX_RATE,
               x.BUY_FIXED_AMOUNT_MINOR_UNIT,
               x.BUY_VARIABLE_PERCENTAGE,
               x.SELL_FIXED_AMOUNT_MINOR_UNIT,
               x.SELL_VARIABLE_PERCENTAGE,
               commPlan.PLAN_NAME
        FROM dbo.ACC_TRANSFERS AS t
            LEFT JOIN dbo.ACC_TRANSACTIONS AS x
                LEFT JOIN dbo.ACC_TRANSACTIONS AS xx
                    ON x.TXN_FIRST_ID = xx.TRANSACTION_ID
                ON x.TRANSACTION_ID = t.TRANSACTION_ID
            LEFT JOIN dbo.ACC_TRANSACTIONS AS magTrans
                ON magTrans.TXN_ASSOCIATION_ID = x.TXN_ASSOCIATION_ID
                   AND magTrans.TRANSACTION_ID <> x.TRANSACTION_ID
            LEFT OUTER JOIN dbo.ACC_SALE_DETAILS AS s
                ON s.TRANSACTION_ID = magTrans.TRANSACTION_ID
            LEFT JOIN dbo.ACC_TRANSFER_TYPES AS tt
                ON tt.TRANSFER_TYPE_ID = t.TRANSFER_TYPE_ID
            LEFT JOIN dbo.ACC_ACCOUNT_GROUPS AS magAG
                ON magAG.ACCOUNT_GROUP_ID = magTrans.ACCOUNT_GROUP_ID
            LEFT JOIN dbo.ACC_ACCOUNT_GROUPS AS pagAG
                ON pagAG.ACCOUNT_GROUP_ID = x.ACCOUNT_GROUP_ID
            LEFT JOIN dbo.ACC_OWNERS AS magOwner
                ON magOwner.OWNER_ID = magAG.OWNER_ID
            LEFT JOIN dbo.ACC_COMMISSION_PLANS AS commPlan
                ON magAG.COMMISSION_PLAN_ID = commPlan.PLAN_ID
        WHERE t.ACCOUNT_ID = ISNULL(@p_account_id, t.ACCOUNT_ID)
              AND (t.TRANSFER_TIME
              BETWEEN ISNULL(@p_start_date, t.TRANSFER_TIME) AND ISNULL(@p_end_date, t.TRANSFER_TIME)
                  )
              AND t.TRANSFER_TYPE_ID IN ( 46, 69, 71, 88, 89 ) /* Bank_Payment, Commission, Negative_Commission, Commission_Void, Negative_Commission_Void */ 
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
               s.CARD_TYPE_ID AS TRANS_CARD_TYPE_ID,
               x.DESCRIPTION,
               tt.NAME,
               t.TRANSACTION_ID,
               t.TRANSFER_TIME,
               tt.TRANSFER_TYPE_ID,
               xx.TRANSACTION_ID AS FIRST_TXN_ID,
               xx.EXTERNAL_REF AS FIRST_TXN_EXTERNAL_REF,
               x.SOURCE_REF AS PROFILE_ID,
               magOwner.OWNER_NAME AS MERCHANT_NAME,
               magTrans.EVENT_TYPE_ID AS TRANSACTION_TYPE_ID,
               magTrans.AMOUNT_MINOR_UNITS AS TRANSACTION_AMOUNT,
               magAG.CURRENCY_CODE_ALPHA3 AS TRANSACTION_CURRENCY,
               pagAG.CURRENCY_CODE_ALPHA3 AS COMMISSION_CURRENCY,
               x.EXCHANGE_RATE AS FX_RATE,
               x.BUY_FIXED_AMOUNT_MINOR_UNIT,
               x.BUY_VARIABLE_PERCENTAGE,
               x.SELL_FIXED_AMOUNT_MINOR_UNIT,
               x.SELL_VARIABLE_PERCENTAGE,
               commPlan.PLAN_NAME
        FROM dbo.ACC_TRANSFERS AS t
            LEFT JOIN dbo.ACC_TRANSACTIONS AS x
                LEFT JOIN dbo.ACC_TRANSACTIONS AS xx
                    ON x.TXN_FIRST_ID = xx.TRANSACTION_ID
                ON x.TRANSACTION_ID = t.TRANSACTION_ID
            LEFT JOIN dbo.ACC_TRANSACTIONS AS magTrans
                ON magTrans.TXN_ASSOCIATION_ID = x.TXN_ASSOCIATION_ID
                   AND magTrans.TRANSACTION_ID <> x.TRANSACTION_ID
            LEFT OUTER JOIN dbo.ACC_SALE_DETAILS AS s
                ON s.TRANSACTION_ID = magTrans.TRANSACTION_ID
            LEFT JOIN dbo.ACC_TRANSFER_TYPES AS tt
                ON tt.TRANSFER_TYPE_ID = t.TRANSFER_TYPE_ID
            LEFT JOIN dbo.ACC_ACCOUNT_GROUPS AS magAG
                ON magAG.ACCOUNT_GROUP_ID = magTrans.ACCOUNT_GROUP_ID
            LEFT JOIN dbo.ACC_ACCOUNT_GROUPS AS pagAG
                ON pagAG.ACCOUNT_GROUP_ID = x.ACCOUNT_GROUP_ID
            LEFT JOIN dbo.ACC_OWNERS AS magOwner
                ON magOwner.OWNER_ID = magAG.OWNER_ID
            LEFT JOIN dbo.ACC_COMMISSION_PLANS AS commPlan
                ON magAG.COMMISSION_PLAN_ID = commPlan.PLAN_ID
        WHERE t.ACCOUNT_ID = ISNULL(@p_account_id, t.ACCOUNT_ID)
              AND (t.TRANSFER_TIME
              BETWEEN ISNULL(@p_start_date, t.TRANSFER_TIME) AND ISNULL(@p_end_date, t.TRANSFER_TIME)
                  )
              AND t.TRANSFER_TYPE_ID IN (46, 69, 71, 88, 89 ) /* Bank_Payment, Commission, Negative_Commission, Commission_Void, Negative_Commission_Void */ 
              AND ABS(t.AMOUNT_MINOR_UNITS)
              BETWEEN ISNULL(@p_from_amount, ABS(t.AMOUNT_MINOR_UNITS)) AND ISNULL(
                                                                                      @p_to_amount,
                                                                                      ABS(t.AMOUNT_MINOR_UNITS)
                                                                                  )
              AND t.TRANSACTION_ID = ISNULL(@p_transaction_id, t.TRANSACTION_ID)
              AND x.SOURCE_REF = ISNULL(CAST(@p_profile_id AS nvarchar), x.SOURCE_REF)
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
