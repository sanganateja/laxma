SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[MSC_STATEMENT]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_from_date DATETIME2(6),
    @p_to_date DATETIME2(6),
    @p_currency VARCHAR(2000),
    @p_owner_id NUMERIC,
    @p_hedge_multiplier NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT tf.TRANSACTION_ID AS transactionId,
           CEILING(ISNULL(m.VAR_AMOUNT_MINOR_UNITS, 0)
                   + ISNULL(
                               m.FIXED_AMOUNT_MINOR_UNITS
                               * CASE
                                     WHEN m.FIXED_CURRENCY_CODE_ALPHA3 = ag.CURRENCY_CODE_ALPHA3 THEN
                                         1
                                     ELSE
                                         m.FX_RATE_APPLIED_PRICING * @p_hedge_multiplier
                                         * POWER(10, agc.DECIMAL_PLACES - mc.DECIMAL_PLACES)
                                 END,
                               0
                           )
                  ) AS processingCost,
           CEILING(ISNULL(i.VARIABLE_AMOUNT_MINOR_UNITS, 0)
                   + ISNULL(
                               i.FIXED_AMOUNT_MINOR_UNITS
                               * CASE
                                     WHEN i.FIXED_CURRENCY_CODE_ALPHA3 = ag.CURRENCY_CODE_ALPHA3 THEN
                                         1
                                     ELSE
                                         i.FX_RATE_APPLIED_PRICING * @p_hedge_multiplier
                                         * POWER(10, agc.DECIMAL_PLACES - ic.DECIMAL_PLACES)
                                 END,
                               0
                           )
                  ) AS interchange,
           CEILING(ISNULL(sc.VARIABLE_AMOUNT_MINOR_UNITS, 0)
                   + ISNULL(
                               sc.FIXED_AMOUNT_MINOR_UNITS
                               * CASE
                                     WHEN sc.FIXED_CURRENCY_CODE_ALPHA3 = ag.CURRENCY_CODE_ALPHA3 THEN
                                         1
                                     ELSE
                                         sc.FX_RATE_APPLIED_PRICING * @p_hedge_multiplier
                                         * POWER(10, agc.DECIMAL_PLACES - scc.DECIMAL_PLACES)
                                 END,
                               0
                           )
                  ) AS schemeCost,
           sd.CARD_TYPE_ID AS cardTypeId
    FROM dbo.ACC_TRANSFERS AS tf
        JOIN dbo.ACC_SALE_DETAILS AS sd
            ON tf.TRANSACTION_ID = sd.TRANSACTION_ID
        JOIN dbo.ACC_ACCOUNTS AS a
            ON a.ACCOUNT_ID = tf.ACCOUNT_ID
               AND a.ACCOUNT_TYPE_ID = 1 /*costs*/
        JOIN dbo.ACC_ACCOUNT_GROUPS AS ag
            ON a.ACCOUNT_GROUP_ID = ag.ACCOUNT_GROUP_ID
               AND ag.OWNER_ID = @p_owner_id
               AND ag.CURRENCY_CODE_ALPHA3 = @p_currency
               AND ag.ACCOUNT_GROUP_TYPE = 'A'
        LEFT JOIN dbo.ACC_CURRENCIES AS agc
            ON agc.CURRENCY_CODE_ALPHA3 = ag.CURRENCY_CODE_ALPHA3
        LEFT JOIN dbo.ACC_TRANSACTION_MARGINS AS m
            ON m.TRANSACTION_ID = tf.TRANSACTION_ID
        LEFT JOIN dbo.ACC_CURRENCIES AS mc
            ON mc.CURRENCY_CODE_ALPHA3 = m.FIXED_CURRENCY_CODE_ALPHA3
        LEFT JOIN dbo.ACC_TRANSACTION_COSTS AS i
            ON i.TRANSACTION_ID = tf.TRANSACTION_ID
               AND i.TYPE_ID = 2
        LEFT JOIN dbo.ACC_CURRENCIES AS ic
            ON ic.CURRENCY_CODE_ALPHA3 = i.FIXED_CURRENCY_CODE_ALPHA3
        LEFT JOIN dbo.ACC_TRANSACTION_COSTS AS sc
            ON sc.TRANSACTION_ID = tf.TRANSACTION_ID
               AND sc.TYPE_ID = 3
        LEFT JOIN dbo.ACC_CURRENCIES AS scc
            ON scc.CURRENCY_CODE_ALPHA3 = sc.FIXED_CURRENCY_CODE_ALPHA3
    WHERE tf.TRANSFER_TYPE_ID = 4 /*MSC*/
          AND tf.TRANSFER_TIME
          BETWEEN @p_from_date AND @p_to_date;

    RETURN;

END;
GO
