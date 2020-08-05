SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_cost_acc_transfers_dates]
    @p_recordset VARCHAR(2000) OUTPUT,
    @p_startdate DATETIME2(6),
    @p_enddate DATETIME2(6)
AS
BEGIN

    SET @p_recordset = NULL;


    SELECT tr.TRANSACTION_ID AS ID,
           CONVERT(VARCHAR(10), ft.TRANSFER_TIME, 103) AS Date,
           CONVERT(VARCHAR(8), ft.TRANSFER_TIME, 108) AS Time,
           tr.TXN_FIRST_ID AS [Transaction Reference],
           et.EVENT_NAME AS [Transaction Type],
           ct.NAME AS [Card Type],
           sd.ACQUIRER_ID AS Acquirer,
           ow.EXTERNAL_REF AS Merchant,
           CASE
               WHEN tr.SOURCE_REF IS NULL THEN
                   CAST(ag.LEGACY_SOURCE_ID AS VARCHAR(2000))
               ELSE
                   tr.SOURCE_REF
           END AS [Profile ID],
           FORMAT(ag.ACCOUNT_NUMBER, '0000000#') AS [Account Number],
           ow.CRA_NAME AS CRA,
           p.CRM_ID AS [CRM ID],
           p.PARTNER_NAME AS [Partner Name],
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
           cu.CURRENCY_CODE_ALPHA3 AS Currency,
           CAST(tt.AMOUNT_MINOR_UNITS AS FLOAT(53)) / POWER(10, cu.DECIMAL_PLACES) AS [Transaction Amount],
           fat.NAME AS [From],
           tat.NAME AS [To],
           tr.DESCRIPTION AS Description
    FROM dbo.ACC_TRANSACTIONS AS tr
        JOIN dbo.ACC_TRANSFERS AS ft
            ON ft.TRANSACTION_ID = tr.TRANSACTION_ID
               AND ft.AMOUNT_MINOR_UNITS < 0
        JOIN dbo.ACC_ACCOUNTS AS fa
            ON fa.ACCOUNT_ID = ft.ACCOUNT_ID
        JOIN dbo.ACC_ACCOUNT_TYPES AS fat
            ON fat.ACCOUNT_TYPE_ID = fa.ACCOUNT_TYPE_ID
        JOIN dbo.ACC_TRANSFERS AS tt
            ON tt.TRANSACTION_ID = tr.TRANSACTION_ID
               AND tt.AMOUNT_MINOR_UNITS > 0
               AND tt.TRANSFER_TYPE_ID = ft.TRANSFER_TYPE_ID
               AND tt.TRANSFER_ID <> ft.TRANSFER_ID
        JOIN dbo.ACC_ACCOUNTS AS ta
            ON ta.ACCOUNT_ID = tt.ACCOUNT_ID
        JOIN dbo.ACC_ACCOUNT_TYPES AS tat
            ON tat.ACCOUNT_TYPE_ID = ta.ACCOUNT_TYPE_ID
        JOIN dbo.ACC_ACCOUNT_GROUPS AS ag
            ON ag.ACCOUNT_GROUP_ID = fa.ACCOUNT_GROUP_ID
        LEFT OUTER JOIN dbo.ACC_OWNERS AS ow
            ON ow.OWNER_ID = ag.OWNER_ID
        LEFT OUTER JOIN dbo.ACC_PARTNERS AS p
            ON p.CRM_ID = ow.CRM_ID
        JOIN dbo.ACC_CURRENCIES AS cu
            ON cu.CURRENCY_CODE_ALPHA3 = ag.CURRENCY_CODE_ALPHA3
        LEFT OUTER JOIN dbo.ACC_SALE_DETAILS AS sd
            ON tr.TXN_FIRST_ID = sd.TRANSACTION_ID
        LEFT OUTER JOIN dbo.ACC_CARD_TYPES AS ct
            ON sd.CARD_TYPE_ID = ct.CARD_TYPE_ID
        JOIN dbo.ACC_EVENT_TYPES AS et
            ON tr.EVENT_TYPE_ID = et.EVENT_TYPE_ID
    WHERE ft.TRANSFER_TIME >= @p_startdate
          AND ft.TRANSFER_TIME < @p_enddate
          AND
          (
              fa.ACCOUNT_TYPE_ID = 1
              OR ta.ACCOUNT_TYPE_ID = 1
          )
    ORDER BY tr.TRANSACTION_ID,
             ft.TRANSFER_TIME;

END;
GO
