SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_gross_settlement_invoice] @p_recordset VARCHAR(2000) OUTPUT
AS
BEGIN

    SET @p_recordset = NULL;


    SELECT o.OWNER_NAME AS [Business Name],
           o.EXTERNAL_REF AS [Business ID],
           ag.ACCOUNT_GROUP_NAME AS [Merchant Account Name],
           ag.ACCOUNT_NUMBER AS [Account Number],
           ag.CURRENCY_CODE_ALPHA3 AS Currency,
           ABS(SUM(CAST(f.AMOUNT_MINOR_UNITS AS FLOAT(53)) / POWER(10, c.DECIMAL_PLACES))) AS Total
    FROM dbo.ACC_TRANSFERS AS f
        JOIN dbo.ACC_ACCOUNTS AS a
            ON f.ACCOUNT_ID = a.ACCOUNT_ID
               AND a.ACCOUNT_TYPE_ID = 12 /* INVOICE*/
        JOIN dbo.ACC_ACCOUNT_GROUPS AS ag
            ON a.ACCOUNT_GROUP_ID = ag.ACCOUNT_GROUP_ID
        JOIN dbo.ACC_OWNERS AS o
            ON ag.OWNER_ID = o.OWNER_ID
        JOIN dbo.ACC_CURRENCIES AS c
            ON ag.CURRENCY_CODE_ALPHA3 = c.CURRENCY_CODE_ALPHA3
    WHERE f.TRANSFER_TYPE_ID = 65 /* INVOICE_CREDIT*/
          AND f.TRANSFER_TIME
          BETWEEN DATEADD(DAY, 1, EOMONTH(DATEADD(MONTH, -2, SYSDATETIME()))) AND EOMONTH(DATEADD(
                                                                                                     MONTH,
                                                                                                     -1,
                                                                                                     SYSDATETIME()
                                                                                                 )
                                                                                         ) /* First and last last day of previous month*/
    GROUP BY o.OWNER_NAME,
             o.EXTERNAL_REF,
             ag.ACCOUNT_GROUP_NAME,
             ag.ACCOUNT_NUMBER,
             ag.CURRENCY_CODE_ALPHA3
    ORDER BY o.OWNER_NAME,
             o.EXTERNAL_REF,
             ag.ACCOUNT_GROUP_NAME,
             ag.ACCOUNT_NUMBER,
             ag.CURRENCY_CODE_ALPHA3;

END;
GO
