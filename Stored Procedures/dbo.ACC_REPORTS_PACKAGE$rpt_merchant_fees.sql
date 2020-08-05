SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_merchant_fees] @p_recordset VARCHAR(2000) OUTPUT
AS
BEGIN

    SET @p_recordset = NULL;

    SELECT o.EXTERNAL_REF AS [Merchant ID],
           FORMAT(ag.ACCOUNT_NUMBER, '00000000#') AS [Account Number],
           ag.ACCOUNT_GROUP_NAME AS [MAG Name],
           ag.CURRENCY_CODE_ALPHA3 AS Currency,
           CASE
               WHEN ag.GROUP_STATUS = 'L' THEN
                   'LIVE'
               WHEN ag.GROUP_STATUS = '+' THEN
                   'LIVE+'
               WHEN ag.GROUP_STATUS = 'P' THEN
                   'PENDING_CLOSURE'
               WHEN ag.GROUP_STATUS = 'C' THEN
                   'CLOSED'
               ELSE
                   NULL
           END AS [Account Group Status],
           CASE
               WHEN SUM(a.BALANCE_MINOR_UNITS) > 0 THEN
                   'Y'
               ELSE
                   'N'
           END AS [Positive Balance],
           CASE
               WHEN t_setup.TRANSACTION_ID IS NOT NULL THEN
                   'Y'
               ELSE
                   'N'
           END AS [Setup Fee Charged],
           CASE
               WHEN t_month.TRANSACTION_ID IS NOT NULL THEN
                   'Y'
               ELSE
                   'N'
           END AS [Monthly Fee Charged],
           CASE
               WHEN t_month_e.TRANSACTION_ID IS NOT NULL THEN
                   'Y'
               ELSE
                   'N'
           END AS [E-Invoicing Fee Charged]
    FROM dbo.ACC_ACCOUNT_GROUPS AS ag
        JOIN dbo.ACC_ACCOUNTS AS a
            ON ag.ACCOUNT_GROUP_ID = a.ACCOUNT_GROUP_ID
        JOIN dbo.ACC_OWNERS AS o
            ON ag.OWNER_ID = o.OWNER_ID
        LEFT OUTER JOIN dbo.ACC_TRANSACTIONS AS t_setup
            ON (
                   ag.ACCOUNT_GROUP_ID = t_setup.ACCOUNT_GROUP_ID
                   AND t_setup.EVENT_TYPE_ID = 23 /* Manual Transfer*/
                   AND t_setup.DESCRIPTION LIKE 'SETUP_FEE%'
               )
        LEFT OUTER JOIN dbo.ACC_TRANSACTIONS AS t_month
            ON (
                   ag.ACCOUNT_GROUP_ID = t_month.ACCOUNT_GROUP_ID
                   AND t_month.EVENT_TYPE_ID = 16 /* Subscription*/
                   AND t_month.TRANSACTION_TIME > DATEADD(MONTH, -1, CAST(SYSDATETIME() AS DATE))
               )
        LEFT OUTER JOIN dbo.ACC_TRANSACTIONS AS t_month_e
            ON (
                   ag.ACCOUNT_GROUP_ID = t_month_e.ACCOUNT_GROUP_ID
                   AND t_month_e.EVENT_TYPE_ID = 30 /* E-Invoicing fees*/
                   AND t_month_e.TRANSACTION_TIME > DATEADD(MONTH, -1, CAST(SYSDATETIME() AS DATE))
               )
    WHERE a.ACCOUNT_TYPE_ID IN ( 0, 2, 3 )
          AND ag.ACCOUNT_GROUP_TYPE = 'A' /* merchant account group*/
    GROUP BY o.EXTERNAL_REF,
             ag.ACCOUNT_NUMBER,
             ag.ACCOUNT_GROUP_NAME,
             ag.CURRENCY_CODE_ALPHA3,
             ag.GROUP_STATUS,
             CASE
                 WHEN t_setup.TRANSACTION_ID IS NOT NULL THEN
                     'Y'
                 ELSE
                     'N'
             END,
             CASE
                 WHEN t_month.TRANSACTION_ID IS NOT NULL THEN
                     'Y'
                 ELSE
                     'N'
             END,
             CASE
                 WHEN t_month_e.TRANSACTION_ID IS NOT NULL THEN
                     'Y'
                 ELSE
                     'N'
             END
    ORDER BY o.EXTERNAL_REF,
             ag.ACCOUNT_NUMBER,
             ag.CURRENCY_CODE_ALPHA3;

END;
GO
