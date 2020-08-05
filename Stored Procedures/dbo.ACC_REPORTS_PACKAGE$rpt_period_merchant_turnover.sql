SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_period_merchant_turnover]
    @p_recordset VARCHAR(2000) OUTPUT,
    @p_startdate DATETIME2(6),
    @p_enddate DATETIME2(6)
AS
DECLARE @FLAG_GrossSettlement BIGINT = 0x100000000;
BEGIN
    SET NOCOUNT ON;
    SET @p_recordset = NULL;

    SELECT ow.EXTERNAL_REF AS [Merchant ID],
           ow.OWNER_NAME AS [Merchant Name],
           CASE
               WHEN t.SOURCE_REF IS NULL THEN
                   CAST(ag.LEGACY_SOURCE_ID AS VARCHAR(2000))
               ELSE
                   t.SOURCE_REF
           END AS [Profile ID],
           ow.BUSINESS_COUNTRY AS [Merchant Country],
           ow.CRA_NAME AS [Merchant CRA],
           ow.INDUSTRY_CODE AS [Industry Code],
           CASE
               WHEN ow.MERCH_FLAGS&@FLAG_GrossSettlement = @FLAG_GrossSettlement THEN
                   'Yes'
               ELSE
                   'No'
           END AS [Gross Settlement],
           CASE
               WHEN LEN(ag.ACCOUNT_NUMBER) < 8 THEN
                   RIGHT('00000000' + CAST(ag.ACCOUNT_NUMBER AS VARCHAR(8)), 8)
               ELSE
                   ag.ACCOUNT_NUMBER
           END AS [Account Number],
           p.PARTNER_OVERRIDE AS [Partner Override],
           p.PARTNER_NAME AS [Partner Name],
           p.CRM_ID AS [CRM Id],
           c.CURRENCY_CODE_ALPHA3 AS Currency,
           CASE
               WHEN tt.TRANSFER_TYPE_ID = 7 THEN
                   CAST(afic.AMOUNT_MINOR_UNITS AS FLOAT(53)) / POWER(10, MIN(c.DECIMAL_PLACES))
               ELSE
                   0
           END AS [Chargeback fixed cost],
           CASE
               WHEN tt.TRANSFER_TYPE_ID = 66 THEN
                   CAST(afic.AMOUNT_MINOR_UNITS AS FLOAT(53)) / POWER(10, MIN(c.DECIMAL_PLACES))
               ELSE
                   0
           END AS [Dispute fixed cost],
           tt.DESCRIPTION AS [Transfer Type],
           CASE sd.REGIONALITY
               WHEN 'D' THEN
                   'Domestic'
               WHEN 'R' THEN
                   'Regional'
               WHEN 'I' THEN
                   'International'
               WHEN 'U' THEN
                   'Unknown'
               ELSE
                   sd.REGIONALITY
           END AS Region,
           ct.NAME AS [Card Type],
           sc.NAME AS [Transaction Class],
           aq.ACQUIRER_SHORT_NAME AS Acquirer,
           CASE
               WHEN ag.PRICING_POLICY_ID = 1
                    AND tt.TRANSFER_TYPE_ID IN ( 0, 4 ) THEN
                   CONCAT(ISNULL(MIN(afb.PERCENTAGE), 0), '%')
               WHEN ag.PRICING_POLICY_ID = 0
                    AND tt.TRANSFER_TYPE_ID IN ( 0, 4 ) THEN
                   CONCAT(ISNULL(MIN(afic.PERCENTAGE), 0), '%')
               ELSE
                   CONCAT(0, '%')
           END AS [Sale Percentage Cost],
           CASE
               WHEN ag.PRICING_POLICY_ID = 1
                    AND tt.TRANSFER_TYPE_ID IN ( 0, 4 ) THEN
                   CAST(afb.AMOUNT_MINOR_UNITS AS FLOAT(53)) / POWER(10, MIN(c.DECIMAL_PLACES))
               WHEN ag.PRICING_POLICY_ID = 0
                    AND tt.TRANSFER_TYPE_ID IN ( 0, 4 ) THEN
                   CAST(afic.AMOUNT_MINOR_UNITS AS FLOAT(53)) / POWER(10, MIN(c.DECIMAL_PLACES))
               ELSE
                   0
           END AS [Sale Fixed Cost],
           CAST(tgf.AMOUNT_MINOR_UNITS AS FLOAT(53)) / POWER(10, MIN(c.DECIMAL_PLACES)) AS [Gateway Fee],
           COUNT_BIG(t.TRANSACTION_ID) AS [Transaction Count],
           CAST(SUM(tr.AMOUNT_MINOR_UNITS) AS FLOAT(53)) / POWER(10, MIN(c.DECIMAL_PLACES)) AS [Value Of Transactions]
    FROM dbo.ACC_TRANSACTIONS AS t
        JOIN dbo.ACC_ACCOUNT_GROUPS AS ag
            ON t.ACCOUNT_GROUP_ID = ag.ACCOUNT_GROUP_ID
               AND ag.ACCOUNT_GROUP_TYPE = 'A' /* Merchant Account Group*/
        LEFT JOIN dbo.ACC_TRANSACTIONS AS tgf
            ON t.TXN_FIRST_ID = tgf.TXN_FIRST_ID
               AND tgf.EVENT_TYPE_ID = 10
        JOIN dbo.ACC_CURRENCIES AS c
            ON ag.CURRENCY_CODE_ALPHA3 = c.CURRENCY_CODE_ALPHA3
        JOIN dbo.ACC_TRANSFERS AS tr
            ON tr.TRANSACTION_ID = t.TRANSACTION_ID
        JOIN dbo.ACC_TRANSFER_TYPES AS tt
            ON tr.TRANSFER_TYPE_ID = tt.TRANSFER_TYPE_ID
        JOIN dbo.ACC_OWNERS AS ow
            ON ow.OWNER_ID = ag.OWNER_ID
        LEFT OUTER JOIN dbo.ACC_PARTNERS AS p
            ON ow.CRM_ID = p.CRM_ID
        LEFT OUTER JOIN dbo.ACC_SALE_DETAILS AS sd
            ON t.TXN_FIRST_ID = sd.TRANSACTION_ID
        LEFT OUTER JOIN dbo.ACC_SALE_CLASSES AS sc
            ON sd.SALE_CLASS_ID = sc.SALE_CLASS_ID
        LEFT OUTER JOIN dbo.ACC_CARD_TYPES AS ct
            ON sd.CARD_TYPE_ID = ct.CARD_TYPE_ID
        LEFT OUTER JOIN dbo.ACC_ACQUIRERS AS aq
            ON sd.ACQUIRER_ID = aq.ACQUIRER_ID
        LEFT OUTER JOIN dbo.ACC_ACQUIRING_FEES_IC AS afic
            ON ag.ACCOUNT_GROUP_ID = afic.ACCOUNT_GROUP_ID
               AND t.EVENT_TYPE_ID = 0
               AND ag.PRICING_POLICY_ID = 0
               AND
               (
                   (
                       afic.FEE_DISTINGUISHER = 'VISA'
                       AND ct.CARD_TYPE_ID IN ( 0, 1, 2, 3, 8, 10, 11 )
                   )
                   OR
                   (
                       afic.FEE_DISTINGUISHER = 'MASTER_CARD'
                       AND ct.CARD_TYPE_ID IN ( 4, 5, 6, 9, 13, 14, 15 )
                   )
                   OR
                   (
                       afic.FEE_DISTINGUISHER = 'AMEX'
                       AND ct.CARD_TYPE_ID IN ( 7, 12 )
                   )
               )
        LEFT OUTER JOIN dbo.ACC_ACQUIRING_FEES_BLENDED AS afb
            ON ag.ACCOUNT_GROUP_ID = afb.ACCOUNT_GROUP_ID
               AND t.EVENT_TYPE_ID = 0
               AND ag.PRICING_POLICY_ID = 1
               AND afb.CARD_CATEGORY_CODE = ct.CARD_CATEGORY_CODE
               AND afb.TRANSACTION_CATEGORY_CODE = sc.TRANSACTION_CATEGORY_CODE
               AND afb.REGION = sd.REGIONALITY
    WHERE t.TRANSACTION_TIME >= @p_startdate
          AND t.TRANSACTION_TIME < @p_enddate
          AND tr.TRANSFER_TYPE_ID IN ( 0, 4, 6, 7, 8, 9, 19, 20, 21, 22, 23, 30, 31, 32, 33, 49, 50, 51, 52, 53, 54,
                                       55, 56, 57, 66, 67, 72, 74, 75, 76, 77, 78, 79, 80, 81
                                     )
          AND
        /* Clearing, Merchant Service Charge, Refund, Chargeback, Chargeback Reversal, Representment, Fee Refund, Fee Copy Request, Fee Gateway,   Fee Chargeback, Fee Subscription, Refund Chargeback, Refund Reversal, Fee Refund Chargeback, Fee Refund Reversal, Fee High Risk,   Credit Transfer, Credit Transfer Fee, Second Chargeback, Fee Second Chargeback, Credit Chargeback, Fee Credit Chargeback,   Credit Transfer Void, Credit Transfer Void Charge, Dispute, Dispute Fee, Dispute Response, Dispute Pre-Arb, Fee Dispute Pre-Arb   Refund Dispute, Fee Refund Dispute, Credit Dispute, Fee Cedit Dispute, Dispute Reversal, Fee Dispute Reversal*/
        tr.AMOUNT_MINOR_UNITS > 0
    GROUP BY ow.EXTERNAL_REF,
             ow.OWNER_NAME,
             ow.BUSINESS_COUNTRY,
             ow.CRA_NAME,
             ow.INDUSTRY_CODE,
             ow.MERCH_FLAGS,
             ag.ACCOUNT_NUMBER,
             p.PARTNER_OVERRIDE,
             p.PARTNER_NAME,
             p.CRM_ID,
             c.CURRENCY_CODE_ALPHA3,
             CASE
                 WHEN t.SOURCE_REF IS NULL THEN
                     CAST(ag.LEGACY_SOURCE_ID AS VARCHAR(2000))
                 ELSE
                     t.SOURCE_REF
             END,
             tt.DESCRIPTION,
             tt.TRANSFER_TYPE_ID,
             CASE sd.REGIONALITY
                 WHEN 'D' THEN
                     'Domestic'
                 WHEN 'R' THEN
                     'Regional'
                 WHEN 'I' THEN
                     'International'
                 WHEN 'U' THEN
                     'Unknown'
                 ELSE
                     sd.REGIONALITY
             END,
             ct.CARD_TYPE_ID,
             ct.NAME,
             sc.NAME,
             aq.ACQUIRER_SHORT_NAME,
             tgf.AMOUNT_MINOR_UNITS,
             afic.AMOUNT_MINOR_UNITS,
             afb.AMOUNT_MINOR_UNITS,
             ag.PRICING_POLICY_ID
    UNION
    SELECT ow.EXTERNAL_REF AS [Merchant ID],
           ow.OWNER_NAME AS [Merchant Name],
           (CASE
                WHEN t.SOURCE_REF IS NULL THEN
                    CAST(ag.LEGACY_SOURCE_ID AS VARCHAR(2000))
                ELSE
                    t.SOURCE_REF
            END
           ) AS [Profile ID],
           ow.BUSINESS_COUNTRY AS [Merchant Country],
           ow.CRA_NAME AS [Merchant CRA],
           ow.INDUSTRY_CODE AS [Industry Code],
           CASE
               WHEN ow.MERCH_FLAGS&@FLAG_GrossSettlement = @FLAG_GrossSettlement THEN
                   'Yes'
               ELSE
                   'No'
           END AS [Gross Settlement],
           CASE
               WHEN LEN(ag.ACCOUNT_NUMBER) < 8 THEN
                   RIGHT('00000000' + CAST(ag.ACCOUNT_NUMBER AS VARCHAR(8)), 8)
               ELSE
                   ag.ACCOUNT_NUMBER
           END AS [Account Number],
           p.PARTNER_OVERRIDE AS [Partner Override],
           p.PARTNER_NAME AS [Partner Name],
           p.CRM_ID AS [CRM Id],
           c.CURRENCY_CODE_ALPHA3 AS Currency,
           0.0 AS [Chargeback fixed cost],
           0.0 AS [Dispute fixed cost],
           tt.DESCRIPTION AS [Transfer Type],
           NULL AS Region,
           NULL AS [Card Type],
           NULL AS [Transaction Class],
           NULL AS Acquirer,
           CONCAT(0, '%') AS [Sale Percentage Cost],
           0 AS [Sale Fixed Cost],
           0 AS [Gateway Fee],
           SUM(dbo.EMBEDDED_NUMBER(t.DESCRIPTION)) /* Sum up the Decline count in the description field*/ AS [Transaction Count],
           CAST(SUM(tr.AMOUNT_MINOR_UNITS) AS FLOAT(53)) / POWER(10, MIN(c.DECIMAL_PLACES)) AS [Value Of Transactions]
    FROM dbo.ACC_TRANSACTIONS AS t
        JOIN dbo.ACC_ACCOUNT_GROUPS AS ag
            ON t.ACCOUNT_GROUP_ID = ag.ACCOUNT_GROUP_ID
               AND ag.ACCOUNT_GROUP_TYPE = 'A' /* Merchant Account Group*/
        JOIN dbo.ACC_CURRENCIES AS c
            ON ag.CURRENCY_CODE_ALPHA3 = c.CURRENCY_CODE_ALPHA3
        JOIN dbo.ACC_TRANSFERS AS tr
            ON tr.TRANSACTION_ID = t.TRANSACTION_ID
        JOIN dbo.ACC_TRANSFER_TYPES AS tt
            ON tr.TRANSFER_TYPE_ID = tt.TRANSFER_TYPE_ID
        JOIN dbo.ACC_OWNERS AS ow
            ON ow.OWNER_ID = ag.OWNER_ID
        LEFT OUTER JOIN dbo.ACC_PARTNERS AS p
            ON ow.CRM_ID = p.CRM_ID
    WHERE t.TRANSACTION_TIME >= @p_startdate
          AND t.TRANSACTION_TIME < @p_enddate
          AND tr.TRANSFER_TYPE_ID = 44 /* Fee_Decline*/
          AND tr.AMOUNT_MINOR_UNITS > 0
    GROUP BY ow.EXTERNAL_REF,
             ow.OWNER_NAME,
             ow.BUSINESS_COUNTRY,
             ow.CRA_NAME,
             ow.INDUSTRY_CODE,
             ow.MERCH_FLAGS,
             ag.ACCOUNT_NUMBER,
             p.PARTNER_NAME,
             p.CRM_ID,
             p.PARTNER_OVERRIDE,
             c.CURRENCY_CODE_ALPHA3,
             (CASE
                  WHEN t.SOURCE_REF IS NULL THEN
                      CAST(ag.LEGACY_SOURCE_ID AS VARCHAR(2000))
                  ELSE
                      t.SOURCE_REF
              END
             ),
             tt.DESCRIPTION
    UNION
    SELECT ow.EXTERNAL_REF AS [Merchant ID],
           ow.OWNER_NAME AS [Merchant Name],
           (CASE
                WHEN t.SOURCE_REF IS NULL THEN
                    CAST(ag.LEGACY_SOURCE_ID AS VARCHAR(2000))
                ELSE
                    t.SOURCE_REF
            END
           ) AS [Profile ID],
           ow.BUSINESS_COUNTRY AS [Merchant Country],
           ow.CRA_NAME AS [Merchant CRA],
           ow.INDUSTRY_CODE AS [Industry Code],
           CASE
               WHEN ow.MERCH_FLAGS&@FLAG_GrossSettlement = @FLAG_GrossSettlement THEN
                   'Yes'
               ELSE
                   'No'
           END AS [Gross Settlement],
           CASE
               WHEN LEN(ag.ACCOUNT_NUMBER) < 8 THEN
                   RIGHT('00000000' + CAST(ag.ACCOUNT_NUMBER AS VARCHAR(8)), 8)
               ELSE
                   ag.ACCOUNT_NUMBER
           END AS [Account Number],
           p.PARTNER_OVERRIDE AS [Partner Override],
           p.PARTNER_NAME AS [Partner Name],
           p.CRM_ID AS [CRM Id],
           c.CURRENCY_CODE_ALPHA3 AS Currency,
           0.0 AS [Chargeback fixed cost],
           0.0 AS [Dispute fixed cost],
           tt.DESCRIPTION AS [Transfer Type],
           NULL AS Region,
           NULL AS [Card Type],
           NULL AS [Transaction Class],
           NULL AS Acquirer,
           CONCAT(0, '%') AS [Sale Percentage Cost],
           0 AS [Sale Fixed Cost],
           0 AS [Gateway Fee],
           SUM(dbo.EMBEDDED_NUMBER(t.DESCRIPTION)) /* Sum up the Decline count in the description field*/ AS [Transaction Count],
           CAST(SUM(tr.AMOUNT_MINOR_UNITS) AS FLOAT(53)) / POWER(10, MIN(c.DECIMAL_PLACES)) AS [Value Of Transactions]
    FROM dbo.ACC_TRANSACTIONS AS t
        JOIN dbo.ACC_ACCOUNT_GROUPS AS ag
            ON t.ACCOUNT_GROUP_ID = ag.ACCOUNT_GROUP_ID
               AND ag.ACCOUNT_GROUP_TYPE = 'A' /* Merchant Account Group*/
        JOIN dbo.ACC_CURRENCIES AS c
            ON ag.CURRENCY_CODE_ALPHA3 = c.CURRENCY_CODE_ALPHA3
        JOIN dbo.ACC_TRANSFERS AS tr
            ON tr.TRANSACTION_ID = t.TRANSACTION_ID
        JOIN dbo.ACC_TRANSFER_TYPES AS tt
            ON tr.TRANSFER_TYPE_ID = tt.TRANSFER_TYPE_ID
        JOIN dbo.ACC_OWNERS AS ow
            ON ow.OWNER_ID = ag.OWNER_ID
        LEFT OUTER JOIN dbo.ACC_PARTNERS AS p
            ON ow.CRM_ID = p.CRM_ID
    WHERE t.TRANSACTION_TIME >= @p_startdate
          AND t.TRANSACTION_TIME < @p_enddate
          AND tr.TRANSFER_TYPE_ID = 48 /* Fee_Authorisation*/
          AND tr.AMOUNT_MINOR_UNITS > 0
    GROUP BY ow.EXTERNAL_REF,
             ow.OWNER_NAME,
             ow.BUSINESS_COUNTRY,
             ow.CRA_NAME,
             ow.INDUSTRY_CODE,
             ow.MERCH_FLAGS,
             ag.ACCOUNT_NUMBER,
             p.PARTNER_NAME,
             p.CRM_ID,
             p.PARTNER_OVERRIDE,
             c.CURRENCY_CODE_ALPHA3,
             (CASE
                  WHEN t.SOURCE_REF IS NULL THEN
                      CAST(ag.LEGACY_SOURCE_ID AS VARCHAR(2000))
                  ELSE
                      t.SOURCE_REF
              END
             ),
             tt.DESCRIPTION
    ORDER BY [Merchant ID],
             [Industry Code];

END;
GO
