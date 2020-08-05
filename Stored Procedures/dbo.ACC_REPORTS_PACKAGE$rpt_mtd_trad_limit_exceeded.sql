SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_mtd_trad_limit_exceeded]
(@p_recordset VARCHAR(2000) OUTPUT)
AS
BEGIN
    SET NOCOUNT ON;

    SET @p_recordset = NULL;

    WITH fx_rate
    AS (SELECT a.FROM_CURRENCY,
               a.RATE
        FROM
        (
            SELECT FROM_CURRENCY,
                   TO_CURRENCY,
                   RATE,
                   RANK() OVER (PARTITION BY FROM_CURRENCY, TO_CURRENCY ORDER BY RATE_DATE DESC) dest_rank
            FROM FX_RATES
        ) a
        WHERE a.dest_rank = 1
              AND a.TO_CURRENCY = 'GBP')
    SELECT c.[Id],
           c.[Business],
           c.[Trading Limit],
           c.[Trade In GBP],
           (c.[Trade In GBP] - c.[Trading Limit]) AS [Excess],
           ROUND(((c.[Trade In GBP] - c.[Trading Limit]) / c.[Trading Limit] * 100), 2) AS [Excess %age]
    FROM
    (
        SELECT b.EXTERNAL_REF AS [Id],
               b.OWNER_NAME AS [Business],
               (b.BUSINESS_TRADING_LIMIT_GBP / 100) AS [Trading Limit],
               (
                   SELECT ROUND(SUM((tr.AMOUNT_MINOR_UNITS * rates.RATE) / POWER(10, curr.DECIMAL_PLACES)), 2)
                   FROM ACC_OWNERS m
                       JOIN ACC_ACCOUNT_GROUPS ag
                           ON ag.OWNER_ID = m.OWNER_ID
                       JOIN fx_rate rates
                           JOIN ACC_CURRENCIES curr
                               ON curr.CURRENCY_CODE_ALPHA3 = rates.FROM_CURRENCY
                           ON rates.FROM_CURRENCY = ag.CURRENCY_CODE_ALPHA3
                       JOIN ACC_ACCOUNTS ac
                           ON ac.ACCOUNT_GROUP_ID = ag.ACCOUNT_GROUP_ID
                              AND ac.ACCOUNT_TYPE_ID = 0
                       -- Trading
                       JOIN ACC_TRANSFERS tr
                           ON tr.ACCOUNT_ID = ac.ACCOUNT_ID
                              AND tr.TRANSFER_TYPE_ID = 0 -- Clearing (sale) event
                              AND tr.TRANSFER_TIME
                              BETWEEN DATEFROMPARTS(DATEPART(YEAR, GETDATE()), DATEPART(MONTH, GETDATE()), 01) AND GETDATE() -- First day of current month to current date and time
                   WHERE m.OWNER_ID = b.OWNER_ID
                         AND ag.ACCOUNT_GROUP_TYPE = 'A' -- merchant account group
               ) AS [Trade In GBP]
        FROM ACC_OWNERS b
    ) AS c
    WHERE c.[Trade In GBP] > c.[Trading Limit]
    ORDER BY [Excess],
             [Excess %age],
             [Business];
END;
GO
