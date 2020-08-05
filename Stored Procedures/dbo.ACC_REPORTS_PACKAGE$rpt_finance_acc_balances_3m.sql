SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_finance_acc_balances_3m]
(@p_recordset VARCHAR(2000) OUTPUT)
AS
BEGIN
    SET NOCOUNT ON;

    SET @p_recordset = NULL;

    WITH credit_debit
    AS (SELECT a.ACCOUNT_ID,
               SUM(   CASE
                          WHEN (t.AMOUNT_MINOR_UNITS > 0) THEN
                              t.AMOUNT_MINOR_UNITS
                          ELSE
                              0
                      END
                  ) AS credit,
               SUM(   CASE
                          WHEN (t.AMOUNT_MINOR_UNITS < 0) THEN
                              -t.AMOUNT_MINOR_UNITS
                          ELSE
                              0
                      END
                  ) AS debit
        FROM ACC_ACCOUNTS a
            LEFT JOIN ACC_TRANSFERS t
                ON a.ACCOUNT_ID = t.ACCOUNT_ID
        WHERE a.ACCOUNT_TYPE_ID = 9 --Account type name 'Current'
              AND t.AMOUNT_MINOR_UNITS <> 0
              AND t.TRANSFER_TIME >= DATEADD(DAY, -90, GETDATE())
        GROUP BY a.ACCOUNT_ID)
    SELECT o.OWNER_NAME AS [Business Name],
           o.EXTERNAL_REF AS [Business ID],
           FORMAT(ag.ACCOUNT_NUMBER, '0000000#') AS [Account Number],
           ag.CURRENCY_CODE_ALPHA3 AS [Currency],
           ISNULL(cd.credit / POWER(10, cu.DECIMAL_PLACES), 0) AS [Credits],
           ISNULL(cd.debit / POWER(10, cu.DECIMAL_PLACES), 0) AS [Debits],
           a.BALANCE_MINOR_UNITS / POWER(10, cu.DECIMAL_PLACES) AS [Current balance],
           CASE
               WHEN (ISNULL(cd.debit, 0) < ISNULL(balance_before.open_balance, 0)) THEN
                   'Y'
               ELSE
                   ' '
           END AS [Insufficient turnover]
    FROM ACC_ACCOUNTS a
        LEFT JOIN ACC_ACCOUNT_GROUPS ag
            ON a.ACCOUNT_GROUP_ID = ag.ACCOUNT_GROUP_ID
               AND ag.ACCOUNT_GROUP_TYPE IN ( 'C', 'D' ) -- account_group is business
        LEFT JOIN ACC_OWNERS o
            ON o.OWNER_ID = ag.OWNER_ID
        JOIN ACC_CURRENCIES cu
            ON ag.CURRENCY_CODE_ALPHA3 = cu.CURRENCY_CODE_ALPHA3
        LEFT JOIN credit_debit cd
            ON cd.ACCOUNT_ID = a.ACCOUNT_ID
        LEFT JOIN
        (
            SELECT max_time.ACCOUNT_ID,
                   t.BALANCE_AFTER_MINOR_UNITS open_balance --open balance before 90 days
            FROM
            (
                SELECT a.ACCOUNT_ID,
                       MAX(t.TRANSFER_TIME) max_time --last transfer time before 90 days
                FROM ACC_ACCOUNTS a
                    LEFT JOIN ACC_TRANSFERS t
                        ON a.ACCOUNT_ID = t.ACCOUNT_ID
                WHERE a.ACCOUNT_TYPE_ID = 9 --Account type name 'Current'
                      AND t.TRANSFER_TIME < DATEADD(DAY, -90, GETDATE())
                GROUP BY a.ACCOUNT_ID
            ) max_time
                LEFT JOIN ACC_TRANSFERS t
                    ON max_time.ACCOUNT_ID = t.ACCOUNT_ID
            WHERE max_time.max_time = t.TRANSFER_TIME
        ) balance_before
            ON balance_before.ACCOUNT_ID = a.ACCOUNT_ID
    WHERE a.ACCOUNT_TYPE_ID = 9;
END;
GO
