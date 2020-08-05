SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_mthly_payments_compl]
    @p_recordset VARCHAR(2000) OUTPUT,
    @p_report_type NVARCHAR(2000)
AS
BEGIN

    SET @p_recordset = NULL;

    SELECT CAST(o.OWNER_NAME AS VARCHAR(2000)) AS [Business name],
           CAST(o.EXTERNAL_REF AS VARCHAR(2000)) AS [Business ID],
           FORMAT(aag.ACCOUNT_NUMBER, '00000000#') AS [Account Number],
           CAST(apmi.TRANSACTION_ID AS VARCHAR(2000)) AS [Transaction reference],
           CAST(apmi.AMOUNT_MINOR_UNITS * POWER(10, -ac.DECIMAL_PLACES) AS VARCHAR(2000)) AS [Receipt Amount],
           CAST(AT.AMOUNT_MINOR_UNITS * POWER(10, -ac.DECIMAL_PLACES) AS VARCHAR(2000)) AS [Credit Amount],
           ac.CURRENCY_CODE_ALPHA3 AS Currency,
           CONVERT(VARCHAR(2000), apmi.MESSAGE_TIMESTAMP, 106) AS [Date of receipt],
           CONVERT(NVARCHAR(8), apmi.MESSAGE_TIMESTAMP, 8) AS [Time of receipt],
           CONVERT(VARCHAR(2000), AT.TRANSACTION_TIME, 106) AS [Date of credit],
           CONVERT(NVARCHAR(8), AT.TRANSACTION_TIME, 8) AS [Time of credit],
           CASE
               WHEN DATEDIFF(HOUR, apmi.MESSAGE_TIMESTAMP, AT.TRANSACTION_TIME) > 2 THEN
                   'Y'
               ELSE
                   'N'
           END AS [Non-Compliant],
           ' ' AS [Total Faster Payments],
           ' ' AS [Total Non-Compliant],
           ' ' AS [Percentage Non-Compliant]
    FROM dbo.ACC_PAYMENT_MESSAGES_IN AS apmi
        JOIN dbo.ACC_TRANSACTIONS AS AT
            ON apmi.TRANSACTION_ID = AT.TRANSACTION_ID
        JOIN dbo.ACC_CURRENCIES AS ac
            ON apmi.CURRENCY_CODE_ALPHA3 = ac.CURRENCY_CODE_ALPHA3
        JOIN dbo.ACC_ACCOUNT_GROUPS AS aag
            ON AT.ACCOUNT_GROUP_ID = aag.ACCOUNT_GROUP_ID
               AND aag.ACCOUNT_GROUP_TYPE IN ( 'C', 'D' ) /* account_group is business*/
        JOIN dbo.ACC_OWNERS AS o
            ON aag.OWNER_ID = o.OWNER_ID
    WHERE apmi.PAYMENT_TYPE = @p_report_type
          AND apmi.MESSAGE_TIMESTAMP
          BETWEEN DATEFROMPARTS(
                                   DATEPART(YEAR, DATEADD(MONTH, -1, SYSDATETIME())),
                                   DATEPART(MONTH, DATEADD(MONTH, -1, SYSDATETIME())),
                                   01
                               ) AND DATEFROMPARTS(DATEPART(YEAR, SYSDATETIME()), DATEPART(MONTH, SYSDATETIME()), 01)
          AND AT.TRANSACTION_TIME
          BETWEEN DATEFROMPARTS(
                                   DATEPART(YEAR, DATEADD(MONTH, -1, SYSDATETIME())),
                                   DATEPART(MONTH, DATEADD(MONTH, -1, SYSDATETIME())),
                                   01
                               ) AND DATEFROMPARTS(DATEPART(YEAR, SYSDATETIME()), DATEPART(MONTH, SYSDATETIME()), 01)
    UNION ALL
    SELECT ' ' AS [Business name],
           ' ' AS [Business ID],
           ' ' AS [Account Number],
           ' ' AS [Transaction reference],
           ' ' AS [Receipt Amount],
           ' ' AS [Credit Amount],
           ' ' AS Currency,
           ' ' AS [Date of receipt],
           ' ' AS [Time of receipt],
           ' ' AS [Date of credit],
           ' ' AS [Time of credit],
           ' ' AS [Non-Compliant],
           CAST(q1.total_payments AS VARCHAR(2000)) AS [Total Faster Payments],
           CAST(q2.total_compliant AS VARCHAR(2000)) AS [Total Non-Compliant],
           ISNULL(   CAST(CASE
                              WHEN q1.total_payments = 0 THEN
                                  0
                              ELSE
                                  ROUND((q2.total_compliant / q1.total_payments) * 100, 2)
                          END AS VARCHAR(2000)),
                     ''
                 ) + '%' AS [Percentage Non-Compliant]
    FROM
    (
        SELECT COUNT_BIG(apmi.MESSAGE_ID) AS total_payments
        FROM dbo.ACC_PAYMENT_MESSAGES_IN AS apmi
            JOIN dbo.ACC_TRANSACTIONS AS AT
                ON apmi.TRANSACTION_ID = AT.TRANSACTION_ID
        WHERE apmi.PAYMENT_TYPE = @p_report_type
              AND apmi.MESSAGE_TIMESTAMP
              BETWEEN DATEFROMPARTS(
                                       DATEPART(YEAR, DATEADD(MONTH, -1, SYSDATETIME())),
                                       DATEPART(MONTH, DATEADD(MONTH, -1, SYSDATETIME())),
                                       01
                                   ) AND DATEFROMPARTS(
                                                          DATEPART(YEAR, SYSDATETIME()),
                                                          DATEPART(MONTH, SYSDATETIME()),
                                                          01
                                                      )
              AND AT.TRANSACTION_TIME
              BETWEEN DATEFROMPARTS(
                                       DATEPART(YEAR, DATEADD(MONTH, -1, SYSDATETIME())),
                                       DATEPART(MONTH, DATEADD(MONTH, -1, SYSDATETIME())),
                                       01
                                   ) AND DATEFROMPARTS(
                                                          DATEPART(YEAR, SYSDATETIME()),
                                                          DATEPART(MONTH, SYSDATETIME()),
                                                          01
                                                      )
    ) AS q1
        LEFT JOIN
        (
            SELECT COUNT_BIG(apmi.MESSAGE_ID) AS total_compliant
            FROM dbo.ACC_PAYMENT_MESSAGES_IN AS apmi
                JOIN dbo.ACC_TRANSACTIONS AS AT
                    ON apmi.TRANSACTION_ID = AT.TRANSACTION_ID
            WHERE apmi.PAYMENT_TYPE = @p_report_type
                  AND apmi.MESSAGE_TIMESTAMP
                  BETWEEN DATEFROMPARTS(
                                           DATEPART(YEAR, DATEADD(MONTH, -1, SYSDATETIME())),
                                           DATEPART(MONTH, DATEADD(MONTH, -1, SYSDATETIME())),
                                           01
                                       ) AND DATEFROMPARTS(
                                                              DATEPART(YEAR, SYSDATETIME()),
                                                              DATEPART(MONTH, SYSDATETIME()),
                                                              01
                                                          )
                  AND AT.TRANSACTION_TIME
                  BETWEEN DATEFROMPARTS(
                                           DATEPART(YEAR, DATEADD(MONTH, -1, SYSDATETIME())),
                                           DATEPART(MONTH, DATEADD(MONTH, -1, SYSDATETIME())),
                                           01
                                       ) AND DATEFROMPARTS(
                                                              DATEPART(YEAR, SYSDATETIME()),
                                                              DATEPART(MONTH, SYSDATETIME()),
                                                              01
                                                          )
                  AND DATEDIFF(HOUR, apmi.MESSAGE_TIMESTAMP, AT.TRANSACTION_TIME) > 2
        ) AS q2
            ON 1 = 1;

END;
GO
