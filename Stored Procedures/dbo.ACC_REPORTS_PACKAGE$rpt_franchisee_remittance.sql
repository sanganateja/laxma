SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_franchisee_remittance] @p_recordset VARCHAR(2000) OUTPUT
AS
BEGIN

    SET @p_recordset = NULL;

    SELECT CONVERT(VARCHAR(10), CAST(SYSDATETIME() AS DATE), 101) AS [Date of Report],
           o.EXTERNAL_REF AS [Business Id],
           o.OWNER_NAME AS [Merchant Name],
           bag.CURRENCY_CODE_ALPHA3 AS Currency,
           CAST(curracc.BALANCE_MINOR_UNITS AS FLOAT(53)) / POWER(10, cur.DECIMAL_PLACES) AS Amount
    FROM dbo.ACC_OWNERS AS o
        JOIN dbo.ACC_FRANCHISEES AS f
            ON f.OWNER_ID = o.OWNER_ID
        JOIN dbo.ACC_ACCOUNT_GROUPS AS bag
            ON bag.OWNER_ID = o.OWNER_ID
        JOIN dbo.ACC_ACCOUNT_GROUPS AS mag
            ON mag.PAYMENT_ACCOUNT_GROUP_ID = bag.ACCOUNT_GROUP_ID
        JOIN dbo.ACC_ACCOUNTS AS curracc
            ON curracc.ACCOUNT_GROUP_ID = bag.ACCOUNT_GROUP_ID
               AND curracc.ACCOUNT_TYPE_ID = 9
        JOIN dbo.ACC_ACCOUNTS AS tradacc
            ON tradacc.ACCOUNT_GROUP_ID = mag.ACCOUNT_GROUP_ID
               AND tradacc.ACCOUNT_TYPE_ID = 0
        JOIN dbo.ACC_CURRENCIES AS cur
            ON cur.CURRENCY_CODE_ALPHA3 = bag.CURRENCY_CODE_ALPHA3
    ORDER BY o.EXTERNAL_REF,
             bag.CURRENCY_CODE_ALPHA3,
             bag.ACCOUNT_GROUP_ID,
             mag.ACCOUNT_GROUP_ID,
             curracc.ACCOUNT_ID;

END;
GO
