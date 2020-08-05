SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_period_remittance]
    @p_recordset VARCHAR(2000) OUTPUT,
    @p_startdate DATETIME2(6),
    @p_enddate DATETIME2(6)
AS
BEGIN

    SET @p_recordset = NULL;

    SELECT tr.TRANSACTION_ID AS ID,
           CONVERT(VARCHAR(2000), ft.TRANSFER_TIME, 106) AS Date,
           CONVERT(NVARCHAR(8), ft.TRANSFER_TIME, 8) AS Time,
           CASE
               WHEN ag.ACCOUNT_GROUP_TYPE IN ( 'A' ) THEN
                   o.EXTERNAL_REF
               ELSE
                   NULL
           END /* type 'A' Merchant AccountGroup*/ AS Merchant,
           CASE
               WHEN ag.ACCOUNT_GROUP_TYPE IN ( 'A' ) THEN
                   FORMAT(ag.ACCOUNT_NUMBER, '00000000#')
               ELSE
                   NULL
           END /* type 'A' Merchant AccountGroup*/ AS [Account Number],
           CASE
               WHEN ag.ACCOUNT_GROUP_TYPE IN ( 'C', 'D' ) THEN
                   o.EXTERNAL_REF
               ELSE
                   NULL
           END /* type 'C', 'D' Business AccountGroup*/ AS Business,
           CASE
               WHEN ag.ACCOUNT_GROUP_TYPE IN ( 'C', 'D' ) THEN
                   FORMAT(ag.ACCOUNT_NUMBER, '00000000#')
               ELSE
                   NULL
           END /* type 'C', 'D' Business AccountGroup*/ AS [Account Number$2],
           ag.CURRENCY_CODE_ALPHA3 AS Currency,
           CAST(tt.AMOUNT_MINOR_UNITS AS FLOAT(53)) / POWER(10, cu.DECIMAL_PLACES) AS Amount,
           fat.NAME AS [From],
           tat.NAME AS [To],
           tr.DESCRIPTION AS Description
    FROM dbo.ACC_TRANSFERS /* Transfer From*/ AS ft
        JOIN dbo.ACC_ACCOUNTS AS fa
            ON fa.ACCOUNT_ID = ft.ACCOUNT_ID /* From Account*/
        JOIN dbo.ACC_ACCOUNT_TYPES AS fat
            ON fat.ACCOUNT_TYPE_ID = fa.ACCOUNT_TYPE_ID /* From Account type*/
        JOIN dbo.ACC_TRANSFERS AS tt
            ON tt.TRANSACTION_ID = ft.TRANSACTION_ID /* Transfer To*/
               AND tt.TRANSFER_ID <> ft.TRANSFER_ID
               AND tt.TRANSFER_TYPE_ID = ft.TRANSFER_TYPE_ID
        JOIN dbo.ACC_ACCOUNTS AS ta
            ON ta.ACCOUNT_ID = tt.ACCOUNT_ID /* To Account*/
        JOIN dbo.ACC_ACCOUNT_TYPES AS tat
            ON tat.ACCOUNT_TYPE_ID = ta.ACCOUNT_TYPE_ID /* To Account type*/
        JOIN dbo.ACC_ACCOUNT_GROUPS AS ag
            ON ag.ACCOUNT_GROUP_ID = fa.ACCOUNT_GROUP_ID /* AccountGroup*/
        JOIN dbo.ACC_TRANSACTIONS AS tr
            ON tr.TRANSACTION_ID = ft.TRANSACTION_ID /* Driving Transaction*/
        JOIN dbo.ACC_CURRENCIES AS cu
            ON cu.CURRENCY_CODE_ALPHA3 = ag.CURRENCY_CODE_ALPHA3
        JOIN dbo.ACC_OWNERS AS o
            ON ag.OWNER_ID = o.OWNER_ID
    WHERE (
              fa.ACCOUNT_TYPE_ID = 5
              OR ta.ACCOUNT_TYPE_ID = 5
          )
          AND ft.TRANSFER_TYPE_ID != 0
          AND tt.TRANSFER_TYPE_ID != 0 /* Except Clearing (Sales) transfers*/
          AND tt.AMOUNT_MINOR_UNITS > 0
          AND ft.TRANSFER_TIME >= @p_startdate
          AND ft.TRANSFER_TIME < @p_enddate
    ORDER BY ft.TRANSFER_ID;

END;
GO
