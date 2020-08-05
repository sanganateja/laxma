SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_finance_acc_statement]
    @p_recordset VARCHAR(2000) OUTPUT,
    @p_dateTimeFrom DATETIME2(6),
    @p_dateTimeTo DATETIME2(6),
    @p_owner_id NUMERIC
AS
BEGIN

    SET @p_recordset = NULL;

    SELECT ag.CURRENCY_CODE_ALPHA3 AS Currency,
           FORMAT(ag.ACCOUNT_NUMBER, '00000000#') AS [Account #],
           t.TRANSACTION_ID AS Ref,
           CONVERT(VARCHAR(20), t.TRANSFER_TIME, 106) AS Date,
           CONVERT(NVARCHAR(8), t.TRANSFER_TIME, 8) AS Time,
           t.TRANSFER_TIME AS [Date Time],
           x.DESCRIPTION AS Description,
           tt.DESCRIPTION AS Type,
           CASE
               WHEN (t.AMOUNT_MINOR_UNITS < 0) THEN
                   CAST(-t.AMOUNT_MINOR_UNITS AS FLOAT(53)) / POWER(10, cu.DECIMAL_PLACES)
               ELSE
                   NULL
           END AS Debit,
           CASE
               WHEN (t.AMOUNT_MINOR_UNITS > 0) THEN
                   CAST(t.AMOUNT_MINOR_UNITS AS FLOAT(53)) / POWER(10, cu.DECIMAL_PLACES)
               ELSE
                   NULL
           END AS Credit,
           CAST(t.BALANCE_AFTER_MINOR_UNITS AS FLOAT(53)) / POWER(10, cu.DECIMAL_PLACES) AS Balance
    FROM dbo.ACC_TRANSFERS AS t
        LEFT JOIN dbo.ACC_TRANSACTIONS AS x
            ON x.TRANSACTION_ID = t.TRANSACTION_ID
        LEFT JOIN dbo.ACC_TRANSFER_TYPES AS tt
            ON tt.TRANSFER_TYPE_ID = t.TRANSFER_TYPE_ID
        LEFT JOIN dbo.ACC_ACCOUNTS AS a
            ON a.ACCOUNT_ID = t.ACCOUNT_ID
        LEFT JOIN dbo.ACC_ACCOUNT_GROUPS AS ag
            ON a.ACCOUNT_GROUP_ID = ag.ACCOUNT_GROUP_ID
        JOIN dbo.ACC_CURRENCIES AS cu
            ON ag.CURRENCY_CODE_ALPHA3 = cu.CURRENCY_CODE_ALPHA3
    WHERE ag.OWNER_ID = @p_owner_id
          AND a.ACCOUNT_TYPE_ID = 9 /*Account type name 'Current'*/
          AND t.AMOUNT_MINOR_UNITS <> 0
          AND t.TRANSFER_TIME > (NULL)
          AND t.TRANSFER_TIME <= (NULL)
          AND ag.ACCOUNT_GROUP_TYPE IN ( 'C', 'D' ) /* account_group is business*/
    ORDER BY ag.CURRENCY_CODE_ALPHA3,
             ag.ACCOUNT_NUMBER,
             t.TRANSFER_ID;



END;
GO
