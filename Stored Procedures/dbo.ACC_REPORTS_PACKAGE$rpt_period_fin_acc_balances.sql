SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_period_fin_acc_balances]
    @p_recordset VARCHAR(2000) OUTPUT,
    @p_dateTime DATETIME2(6),
    @p_currency VARCHAR(2000) = NULL
AS
BEGIN

    SET @p_recordset = NULL;

    SELECT o.EXTERNAL_REF AS business_id,
           o.OWNER_NAME AS business_name,
           o.BUSINESS_COUNTRY,
           g.ACCOUNT_GROUP_NAME,
           g.ACCOUNT_GROUP_TYPE,
           FORMAT(g.ACCOUNT_NUMBER, '00000000#') AS account_number,
           AT.NAME AS account_type,
           g.CURRENCY_CODE_ALPHA3 AS CCY,
           CAST(t.BALANCE_AFTER_MINOR_UNITS AS FLOAT(53)) / POWER(10, c.DECIMAL_PLACES) AS balance,
           CONVERT(VARCHAR(20), @p_dateTime, 106) AS DATE,
           CONVERT(NVARCHAR(8), @p_dateTime, 8) AS TIME
    FROM dbo.ACC_TRANSFERS AS t
        INNER JOIN dbo.ACC_TRANSFER_TYPES AS tt
            ON t.TRANSFER_TYPE_ID = tt.TRANSFER_TYPE_ID
        INNER JOIN dbo.ACC_ACCOUNTS AS a
            ON t.ACCOUNT_ID = a.ACCOUNT_ID
        INNER JOIN dbo.ACC_ACCOUNT_GROUPS AS g
            ON a.ACCOUNT_GROUP_ID = g.ACCOUNT_GROUP_ID
        INNER JOIN dbo.ACC_OWNERS AS o
            ON g.OWNER_ID = o.OWNER_ID
        INNER JOIN dbo.ACC_CURRENCIES AS c
            ON g.CURRENCY_CODE_ALPHA3 = c.CURRENCY_CODE_ALPHA3
        INNER JOIN dbo.ACC_ACCOUNT_TYPES AS AT
            ON a.ACCOUNT_TYPE_ID = AT.ACCOUNT_TYPE_ID
        INNER JOIN
        (
            SELECT ACC_TRANSFERS.ACCOUNT_ID,
                   MAX(ACC_TRANSFERS.TRANSFER_ID) AS max_transfer_id
            FROM dbo.ACC_TRANSFERS
            WHERE ACC_TRANSFERS.TRANSFER_TIME <= @p_dateTime
            GROUP BY ACC_TRANSFERS.ACCOUNT_ID
        ) AS latest
            ON t.ACCOUNT_ID = latest.ACCOUNT_ID
               AND t.TRANSFER_ID = latest.max_transfer_id
    WHERE a.ACCOUNT_TYPE_ID IN ( 9, 1, 5, 10 ) /* Current, Costs, Internal, External*/
          AND
          (
              @p_currency IS NULL
              OR g.CURRENCY_CODE_ALPHA3 = @p_currency
          )
          AND g.ACCOUNT_GROUP_TYPE IN ( 'C', 'D' ) /* account_group is business*/
    ORDER BY o.OWNER_NAME,
             g.ACCOUNT_GROUP_NAME,
             g.ACCOUNT_NUMBER;
END;
GO
