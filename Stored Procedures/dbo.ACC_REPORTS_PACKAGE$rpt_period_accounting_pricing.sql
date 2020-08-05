SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_period_accounting_pricing]
    @p_recordset VARCHAR(2000) OUTPUT,
    @p_startdate DATETIME2(6),
    @p_enddate DATETIME2(6)
AS
BEGIN

    SET @p_recordset = NULL;


    SELECT trn.MerchantId AS MerchantId,
           trn.OwnerName AS MerchantName,
           FORMAT(trn.MAGAccNum, '00000000#') AS AccountNumber,
           trn.Currency,
           trn.TransactionType,
           trn.CardType,
           trn.Country,
           SUM(trn.TransactionCount) AS TransactionCount,
           SUM(trn.TransactionAmount) AS TransactionAmount,
           SUM(trn.ChargeCount) AS ChargeCount,
           SUM(trn.ChargeAmount) AS ChargeAmount,
           trn.Partnername AS PartnerName,
           trn.PartnerOverride AS PartnerOverride
    FROM
    (
        SELECT ow.EXTERNAL_REF AS MerchantId,
               ow.OWNER_NAME AS OwnerName,
               ag.ACCOUNT_NUMBER AS MAGAccNum,
               cu.CURRENCY_CODE_ALPHA3 AS Currency,
               CASE et.EVENT_NAME
                   WHEN 'Merchant_Service_Charge' THEN
                       'Sale'
                   WHEN 'Gateway_Charge' THEN
                       'Sale'
                   ELSE
                       et.EVENT_NAME
               END AS TransactionType,
               ct.NAME AS CardType,
               ow.BUSINESS_COUNTRY AS Country,
               MIN(pa.PARTNER_NAME) AS Partnername,
               MIN(pa.PARTNER_OVERRIDE) AS PartnerOverride,
               0 AS TransactionCount,
               0.0 AS TransactionAmount,
               COUNT_BIG(*) AS ChargeCount,
               CAST(SUM(tf.AMOUNT_MINOR_UNITS) AS FLOAT(53)) / POWER(10, MIN(cu.DECIMAL_PLACES)) AS ChargeAmount
        FROM dbo.ACC_OWNERS AS ow
            LEFT JOIN dbo.ACC_PARTNERS AS pa
                ON ow.CRM_ID = pa.CRM_ID
            JOIN dbo.ACC_ACCOUNT_GROUPS AS ag
                ON ow.OWNER_ID = ag.OWNER_ID
                   AND ag.ACCOUNT_GROUP_TYPE = 'A' /*merchant account group*/
            JOIN dbo.ACC_ACCOUNTS AS ac
                ON ag.ACCOUNT_GROUP_ID = ac.ACCOUNT_GROUP_ID
            JOIN dbo.ACC_TRANSACTIONS AS tr
                ON ag.ACCOUNT_GROUP_ID = tr.ACCOUNT_GROUP_ID
            JOIN dbo.ACC_TRANSACTIONS AS tr2
                ON tr.TXN_FIRST_ID = tr2.TRANSACTION_ID
            LEFT JOIN dbo.ACC_SALE_DETAILS AS sd
                ON tr2.TRANSACTION_ID = sd.TRANSACTION_ID
            LEFT JOIN dbo.ACC_CARD_TYPES AS ct
                ON sd.CARD_TYPE_ID = ct.CARD_TYPE_ID
            JOIN dbo.ACC_TRANSFERS AS tf
                ON ac.ACCOUNT_ID = tf.ACCOUNT_ID
                   AND tr.TRANSACTION_ID = tf.TRANSACTION_ID
            JOIN dbo.ACC_TRANSFER_TYPES AS tt
                ON tf.TRANSFER_TYPE_ID = tt.TRANSFER_TYPE_ID
            JOIN dbo.ACC_EVENT_TYPES AS et
                ON tr.EVENT_TYPE_ID = et.EVENT_TYPE_ID
            JOIN dbo.ACC_CURRENCIES AS cu
                ON ag.CURRENCY_CODE_ALPHA3 = cu.CURRENCY_CODE_ALPHA3
        WHERE ac.ACCOUNT_TYPE_ID = 1 /* COSTS*/
              AND tf.TRANSFER_TYPE_ID IN ( 4, 10, 19, 20, 21, 22, 49, 53, 67, 75, 81 ) /* MSC, Fee_ChBkRv, Fee_Refund, Fee_CpRq, Fee_Gateway, Fee_ChBk, Fee_High_Rish, Fee_Second_Chargeback, Fee_Dispute, Fee_Dispute_Pre_Arb, Fee_Dispute_Reversal*/
              AND tr.TRANSACTION_TIME >= @p_startdate
              AND tr.TRANSACTION_TIME < @p_enddate
        GROUP BY ow.EXTERNAL_REF,
                 ow.OWNER_NAME,
                 ag.ACCOUNT_NUMBER,
                 cu.CURRENCY_CODE_ALPHA3,
                 CASE et.EVENT_NAME
                     WHEN 'Merchant_Service_Charge' THEN
                         'Sale'
                     WHEN 'Gateway_Charge' THEN
                         'Sale'
                     ELSE
                         et.EVENT_NAME
                 END,
                 ct.NAME,
                 ow.BUSINESS_COUNTRY
        UNION ALL
        SELECT ow.EXTERNAL_REF AS MerchantId,
               ow.OWNER_NAME AS OwnerName,
               ag.ACCOUNT_NUMBER AS MAGAccNum,
               cu.CURRENCY_CODE_ALPHA3 AS Currency,
               et.EVENT_NAME AS TransactionType,
               ct.NAME AS CardType,
               ow.BUSINESS_COUNTRY AS Country,
               MIN(pa.PARTNER_NAME) AS PartnerName,
               MIN(pa.PARTNER_OVERRIDE) AS PartnerOverride,
               COUNT_BIG(*) AS TransactionCount,
               CAST(SUM(tf.AMOUNT_MINOR_UNITS) AS FLOAT(53)) / POWER(10, MIN(cu.DECIMAL_PLACES)) AS TransactionAmount,
               0 AS ChargeCount,
               0.0 AS ChargeAmount
        FROM dbo.ACC_OWNERS AS ow
            LEFT JOIN dbo.ACC_PARTNERS AS pa
                ON ow.CRM_ID = pa.CRM_ID
            JOIN dbo.ACC_ACCOUNT_GROUPS AS ag
                ON ow.OWNER_ID = ag.OWNER_ID
                   AND ag.ACCOUNT_GROUP_TYPE = 'A' /*merchant account group*/
            JOIN dbo.ACC_ACCOUNTS AS ac
                ON ag.ACCOUNT_GROUP_ID = ac.ACCOUNT_GROUP_ID
            JOIN dbo.ACC_TRANSACTIONS AS tr
                ON ag.ACCOUNT_GROUP_ID = tr.ACCOUNT_GROUP_ID
            JOIN dbo.ACC_TRANSACTIONS AS tr2
                ON tr.TXN_FIRST_ID = tr2.TRANSACTION_ID
            LEFT JOIN dbo.ACC_SALE_DETAILS AS sd
                ON tr2.TRANSACTION_ID = sd.TRANSACTION_ID
            LEFT JOIN dbo.ACC_CARD_TYPES AS ct
                ON sd.CARD_TYPE_ID = ct.CARD_TYPE_ID
            JOIN dbo.ACC_TRANSFERS AS tf
                ON ac.ACCOUNT_ID = tf.ACCOUNT_ID
                   AND tr.TRANSACTION_ID = tf.TRANSACTION_ID
            JOIN dbo.ACC_TRANSFER_TYPES AS tt
                ON tf.TRANSFER_TYPE_ID = tt.TRANSFER_TYPE_ID
            JOIN dbo.ACC_EVENT_TYPES AS et
                ON tr.EVENT_TYPE_ID = et.EVENT_TYPE_ID
            JOIN dbo.ACC_CURRENCIES AS cu
                ON ag.CURRENCY_CODE_ALPHA3 = cu.CURRENCY_CODE_ALPHA3
        WHERE ac.ACCOUNT_TYPE_ID = 0 /* TRADING*/
              AND tf.TRANSFER_TYPE_ID IN ( 0, 1, 6, 7, 8, 9, 52, 66, 80, 72, 74 ) /* Clearing, Security, Refund, Chargeback, ChargebackReversal, Representment, Second Chargeback, Dispute, Dispute Reversal, Dispute Response, Dispute Pre-Arb,*/
              AND tr.TRANSACTION_TIME >= @p_startdate
              AND tr.TRANSACTION_TIME < @p_enddate
        GROUP BY ow.EXTERNAL_REF,
                 ow.OWNER_NAME,
                 ag.ACCOUNT_NUMBER,
                 cu.CURRENCY_CODE_ALPHA3,
                 et.EVENT_NAME,
                 ct.NAME,
                 ow.BUSINESS_COUNTRY
    ) AS trn
    GROUP BY trn.MerchantId,
             trn.OwnerName,
             trn.MAGAccNum,
             trn.Currency,
             trn.TransactionType,
             trn.CardType,
             trn.Country,
             trn.Partnername,
             trn.PartnerOverride
    ORDER BY 1,
             2,
             3,
             4,
             5,
             6,
             7;

END;
GO
