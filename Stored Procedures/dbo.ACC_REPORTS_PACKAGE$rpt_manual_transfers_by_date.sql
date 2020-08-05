SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_manual_transfers_by_date]
    @p_recordset VARCHAR(2000) OUTPUT,
    @p_startdate DATETIME2(6),
    @p_enddate DATETIME2(6)
AS
BEGIN

    SET @p_recordset = NULL;

    SELECT tr.TRANSACTION_TIME AS [Transaction Time],
           o.EXTERNAL_REF AS [Merchant ID],
           CASE
               WHEN tr.SOURCE_REF IS NULL THEN
                   CAST(ag.LEGACY_SOURCE_ID AS VARCHAR(2000))
               ELSE
                   tr.SOURCE_REF
           END AS [Profile ID],
           FORMAT(ag.ACCOUNT_NUMBER, '00000000#') AS [Account Number],
           FORMAT(ag.ACCOUNT_NUMBER, '00000000#') AS [Business Account],
           ag.CURRENCY_CODE_ALPHA3 AS Currency,
           from_act.NAME AS [From Account Name],
           to_act.NAME AS [To Account Name],
           CAST(tr.AMOUNT_MINOR_UNITS AS FLOAT(53)) / POWER(10, cur.DECIMAL_PLACES) AS Amount,
           tm.DESCRIPTION AS [Transfer Category],
           tr.DESCRIPTION AS [Transaction Reason]
    FROM dbo.ACC_TRANSACTIONS AS tr
        JOIN dbo.ACC_TRANSFERS AS from_tf
            ON tr.TRANSACTION_ID = from_tf.TRANSACTION_ID
               AND from_tf.AMOUNT_MINOR_UNITS < 0
        JOIN dbo.ACC_TRANSFERS AS to_tf
            ON tr.TRANSACTION_ID = to_tf.TRANSACTION_ID
               AND to_tf.AMOUNT_MINOR_UNITS > 0
        JOIN dbo.ACC_ACCOUNTS AS from_acc
            ON from_tf.ACCOUNT_ID = from_acc.ACCOUNT_ID
        JOIN dbo.ACC_ACCOUNTS AS to_acc
            ON to_tf.ACCOUNT_ID = to_acc.ACCOUNT_ID
        JOIN dbo.ACC_ACCOUNT_TYPES AS from_act
            ON from_acc.ACCOUNT_TYPE_ID = from_act.ACCOUNT_TYPE_ID
        JOIN dbo.ACC_ACCOUNT_TYPES AS to_act
            ON to_acc.ACCOUNT_TYPE_ID = to_act.ACCOUNT_TYPE_ID
        JOIN dbo.ACC_TRANSFER_METHODS AS tm
            ON from_tf.TRANSFER_METHOD_ID = tm.TRANSFER_METHOD_ID
        JOIN dbo.ACC_ACCOUNT_GROUPS AS ag
            ON tr.ACCOUNT_GROUP_ID = ag.ACCOUNT_GROUP_ID
        JOIN dbo.ACC_CURRENCIES AS cur
            ON cur.CURRENCY_CODE_ALPHA3 = ag.CURRENCY_CODE_ALPHA3
        JOIN dbo.ACC_OWNERS AS o
            ON ag.OWNER_ID = o.OWNER_ID
    WHERE tr.EVENT_TYPE_ID IN ( 23 )
          AND tr.TRANSACTION_TIME >= @p_startdate
          AND tr.TRANSACTION_TIME < @p_enddate
    ORDER BY tr.TRANSACTION_TIME,
             ag.ACCOUNT_NUMBER,
             from_tf.AMOUNT_MINOR_UNITS;

END;
GO
