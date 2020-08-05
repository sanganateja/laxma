SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_acc_statement_int]
    @p_recordset VARCHAR(2000) OUTPUT,
    @p_startdate DATETIME2(6),
    @p_enddate DATETIME2(6),
    @p_crm_id NVARCHAR(2000) = NULL
AS
BEGIN

    SET @p_recordset = NULL;


    SELECT o.EXTERNAL_REF AS [Business ID],
           ISNULL(xx.SOURCE_REF, ag.LEGACY_SOURCE_ID) AS [Profile ID],
           t.TRANSFER_ID AS Ref,
           CONVERT(VARCHAR(10), t.TRANSFER_TIME, 103) AS Date,
           CONVERT(NVARCHAR(8), t.TRANSFER_TIME, 8) AS Time,
           x.DESCRIPTION AS Description,
           s.CART_ID AS [Cart ID],
           tt.DESCRIPTION AS Type,
           CONVERT(VARCHAR(2000), b.MATURITY_DATE, 103) AS Batch,
           CONVERT(VARCHAR(2000), b.MATURED_TIME, 103) AS Matured,
           CASE
               WHEN (t.AMOUNT_MINOR_UNITS < 0) THEN
                   CAST(-t.AMOUNT_MINOR_UNITS AS FLOAT(53)) / POWER(10, agc.DECIMAL_PLACES)
               ELSE
                   NULL
           END AS Debit,
           CASE
               WHEN (t.AMOUNT_MINOR_UNITS > 0) THEN
                   CAST(t.AMOUNT_MINOR_UNITS AS FLOAT(53)) / POWER(10, agc.DECIMAL_PLACES)
               ELSE
                   NULL
           END AS Credit,
           CAST(t.BALANCE_AFTER_MINOR_UNITS AS FLOAT(53)) / POWER(10, agc.DECIMAL_PLACES) AS Balance,
           ds.DESCRIPTION AS [Cost Type],
           CEILING(tmg.VAR_AMOUNT_MINOR_UNITS) / POWER(10, agc.DECIMAL_PLACES) /* now equals account group currency*/ AS [Processing Cost Var],
           tmg.FIXED_AMOUNT_MINOR_UNITS / POWER(10, mfc.DECIMAL_PLACES) /* now always 'GBP'*/ AS [Processing Cost Fixed],
           tmg.FX_RATE_APPLIED_PRICING AS [Cost FX Rate],
           CEILING(tc1.VARIABLE_AMOUNT_MINOR_UNITS) / POWER(10, agc.DECIMAL_PLACES) /* now equals account group currency*/ AS [Interchange Var],
           tc1.FIXED_AMOUNT_MINOR_UNITS / POWER(10, tc1c.DECIMAL_PLACES) /* tc1.FIXED_CURRENCY_CODE_ALPHA3*/ AS [Interchange Fixed],
           tc1.FIXED_CURRENCY_CODE_ALPHA3 AS [Interchange Fixed Currency],
           tc1.FX_RATE_APPLIED_PRICING AS [Interchange FX Rate],
           CEILING(tc2.VARIABLE_AMOUNT_MINOR_UNITS) / POWER(10, agc.DECIMAL_PLACES) /* now equals account group currency*/ AS [Scheme Fee Var],
           tc2.FIXED_AMOUNT_MINOR_UNITS / POWER(10, tc2c.DECIMAL_PLACES) /*tc2.FIXED_CURRENCY_CODE_ALPHA3*/ AS [Scheme Fee Fixed],
           tc2.FIXED_CURRENCY_CODE_ALPHA3 AS [Scheme Fee Fixed Currency],
           tc2.FX_RATE_APPLIED_PRICING AS [Scheme FX Rate]
    FROM dbo.ACC_TRANSFERS AS t
        LEFT JOIN dbo.ACC_TRANSACTIONS AS x
            ON x.TRANSACTION_ID = t.TRANSACTION_ID
        LEFT JOIN dbo.ACC_TRANSACTIONS AS xx
            ON x.TXN_FIRST_ID = xx.TRANSACTION_ID
        LEFT OUTER JOIN dbo.ACC_SALE_DETAILS AS s
            ON s.TRANSACTION_ID = t.TRANSACTION_ID
        LEFT OUTER JOIN dbo.ACC_BATCHES AS b
            ON b.BATCH_ID = t.BATCH_ID
        LEFT JOIN dbo.ACC_TRANSFER_TYPES AS tt
            ON tt.TRANSFER_TYPE_ID = t.TRANSFER_TYPE_ID
        LEFT JOIN dbo.ACC_TRANSFER_METHODS AS tm
            ON tm.TRANSFER_METHOD_ID = t.TRANSFER_METHOD_ID
        LEFT JOIN dbo.ACC_ACCOUNTS AS a
            ON a.ACCOUNT_ID = t.ACCOUNT_ID
        LEFT JOIN dbo.ACC_ACCOUNT_GROUPS AS ag
            ON a.ACCOUNT_GROUP_ID = ag.ACCOUNT_GROUP_ID
        LEFT JOIN dbo.ACC_CURRENCIES AS agc
            ON ag.CURRENCY_CODE_ALPHA3 = agc.CURRENCY_CODE_ALPHA3
        LEFT JOIN dbo.ACC_OWNERS AS o
            ON o.OWNER_ID = ag.OWNER_ID
               AND
               (
                   (
                       @p_crm_id IS NULL
                       AND o.CRM_ID IS NULL
                   )
                   OR o.CRM_ID = @p_crm_id
               )
        LEFT JOIN dbo.ACC_TRANSACTION_MARGINS AS tmg
            ON t.TRANSACTION_ID = tmg.TRANSACTION_ID
               AND t.TRANSFER_TYPE_ID IN ( 0, 6 )
        LEFT JOIN dbo.ACC_CURRENCIES AS mfc
            ON tmg.FIXED_CURRENCY_CODE_ALPHA3 = mfc.CURRENCY_CODE_ALPHA3
        LEFT JOIN dbo.ACC_TRANSACTION_COSTS AS tc1
            ON t.TRANSACTION_ID = tc1.TRANSACTION_ID
               AND tc1.TYPE_ID = 2
               AND t.TRANSFER_TYPE_ID IN ( 0, 6 )
        LEFT JOIN dbo.ACC_CURRENCIES AS tc1c
            ON tc1.FIXED_CURRENCY_CODE_ALPHA3 = tc1c.CURRENCY_CODE_ALPHA3
        LEFT JOIN dbo.CST_DESIGNATORS AS ds
            ON ds.DESIGNATOR_ID = tc1.DESIGNATOR_ID
        LEFT JOIN dbo.ACC_TRANSACTION_COSTS AS tc2
            ON t.TRANSACTION_ID = tc2.TRANSACTION_ID
               AND tc2.TYPE_ID = 3
               AND t.TRANSFER_TYPE_ID IN ( 0, 6 )
        LEFT JOIN dbo.ACC_CURRENCIES AS tc2c
            ON tc2.FIXED_CURRENCY_CODE_ALPHA3 = tc2c.CURRENCY_CODE_ALPHA3
    WHERE a.ACCOUNT_TYPE_ID = 0 /* trading*/
          AND t.TRANSFER_TIME
          BETWEEN @p_startdate AND @p_enddate
    ORDER BY o.EXTERNAL_REF,
             ISNULL(xx.SOURCE_REF, ag.LEGACY_SOURCE_ID),
             t.TRANSFER_ID;

END;
GO
