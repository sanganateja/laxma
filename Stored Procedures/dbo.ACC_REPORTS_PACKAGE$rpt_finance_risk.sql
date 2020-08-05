SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_finance_risk]	
    @p_recordset VARCHAR(2000) OUTPUT,	
    @p_startdate DATETIME2(6),	
    @p_enddate DATETIME2(6)	
AS	
BEGIN	

    SET @p_recordset = NULL;	

    SELECT o.EXTERNAL_REF AS [Merchant ID],	
           o.OWNER_NAME AS [Merchant Name],	
           CASE	
               WHEN t.SOURCE_REF IS NULL THEN	
                   CAST(ag.LEGACY_SOURCE_ID AS VARCHAR(2000))	
               ELSE	
                   t.SOURCE_REF	
           END AS [Profile ID],	
           mt.MERCHANT_TYPE_NAME AS [Merchant Type],	
           FORMAT(ag.ACCOUNT_NUMBER, '00000000#') AS [Account Number],	
           o.BUSINESS_COUNTRY AS [Merchant Country],	
           p.PARTNER_NAME AS [Partner Name],	
           p.PARTNER_OVERRIDE AS [Partner Override],	
           et.EVENT_NAME AS [Transaction Type],	
           sd.REGIONALITY AS Region,	
           sc.NAME AS [Transaction Class],	
           ct.NAME AS [Card Type],	
           aq.ACQUIRER_SHORT_NAME AS Acquirer,	
           o.INDUSTRY_CODE AS [Industry Code],	
           COUNT_BIG(t.TRANSACTION_ID) AS [Transaction Count],	
           CAST(SUM(t.AMOUNT_MINOR_UNITS) AS FLOAT(53)) / POWER(10, MIN(c.DECIMAL_PLACES)) AS [Value Of Transactions],	
           c.CURRENCY_CODE_ALPHA3 AS Currency,	
           CAST(a_t.BALANCE_MINOR_UNITS AS FLOAT(53)) / POWER(10, c.DECIMAL_PLACES) AS [Trading Balance],	
           CAST(a_s.BALANCE_MINOR_UNITS AS FLOAT(53)) / POWER(10, c.DECIMAL_PLACES) AS [Security Balance],	
           CAST(a_r.BALANCE_MINOR_UNITS AS FLOAT(53)) / POWER(10, c.DECIMAL_PLACES) AS [Reserves Balance]	
    FROM dbo.ACC_TRANSACTIONS AS t WITH (NOLOCK)	
        JOIN dbo.ACC_ACCOUNT_GROUPS AS ag WITH (NOLOCK)	
            ON t.ACCOUNT_GROUP_ID = ag.ACCOUNT_GROUP_ID	
        JOIN dbo.ACC_CURRENCIES AS c WITH (NOLOCK)	
            ON ag.CURRENCY_CODE_ALPHA3 = c.CURRENCY_CODE_ALPHA3	
        JOIN dbo.ACC_EVENT_TYPES AS et WITH (NOLOCK)	
            ON t.EVENT_TYPE_ID = et.EVENT_TYPE_ID	
        JOIN dbo.ACC_OWNERS AS o WITH (NOLOCK)	
            ON o.OWNER_ID = ag.OWNER_ID	
        LEFT OUTER JOIN dbo.ACC_PARTNERS AS p WITH (NOLOCK)	
            ON o.CRM_ID = p.CRM_ID	
        LEFT OUTER JOIN dbo.ACC_ACCOUNTS AS a_t WITH (NOLOCK)	
            ON ag.ACCOUNT_GROUP_ID = a_t.ACCOUNT_GROUP_ID	
               AND a_t.ACCOUNT_TYPE_ID = 0 /* Trading*/	
        LEFT OUTER JOIN dbo.ACC_ACCOUNTS AS a_s WITH (NOLOCK)	
            ON ag.ACCOUNT_GROUP_ID = a_s.ACCOUNT_GROUP_ID	
               AND a_s.ACCOUNT_TYPE_ID = 2 /* Security*/	
        LEFT OUTER JOIN dbo.ACC_ACCOUNTS AS a_r WITH (NOLOCK)	
            ON ag.ACCOUNT_GROUP_ID = a_r.ACCOUNT_GROUP_ID	
               AND a_r.ACCOUNT_TYPE_ID = 3 /* Reserves*/	
        LEFT OUTER JOIN dbo.ACC_MERCHANT_TYPES AS mt WITH (NOLOCK)	
            ON o.BUSINESS_TYPE = mt.MERCHANT_TYPE_ID	
        LEFT OUTER JOIN dbo.ACC_SALE_DETAILS AS sd WITH (NOLOCK)	
            ON t.TXN_FIRST_ID = sd.TRANSACTION_ID	
        LEFT OUTER JOIN dbo.ACC_SALE_CLASSES AS sc WITH (NOLOCK)	
            ON sd.SALE_CLASS_ID = sc.SALE_CLASS_ID	
        LEFT OUTER JOIN dbo.ACC_CARD_TYPES AS ct WITH (NOLOCK)	
            ON sd.CARD_TYPE_ID = ct.CARD_TYPE_ID	
        LEFT OUTER JOIN dbo.ACC_ACQUIRERS AS aq WITH (NOLOCK)	
            ON sd.ACQUIRER_ID = aq.ACQUIRER_ID	
    WHERE t.TRANSACTION_TIME	
          BETWEEN @p_startdate AND @p_enddate	
          AND ag.ACCOUNT_GROUP_TYPE = 'A' /* merchant account group*/	
    GROUP BY o.EXTERNAL_REF,	
             o.OWNER_NAME,	
             mt.MERCHANT_TYPE_NAME,	
             o.BUSINESS_COUNTRY,	
             ag.ACCOUNT_NUMBER,	
             p.PARTNER_NAME,	
             p.PARTNER_OVERRIDE,	
             et.EVENT_NAME,	
             sd.REGIONALITY,	
             sc.NAME,	
             ct.NAME,	
             aq.ACQUIRER_SHORT_NAME,	
             o.INDUSTRY_CODE,	
             c.CURRENCY_CODE_ALPHA3,	
             CASE	
                 WHEN t.SOURCE_REF IS NULL THEN	
                     CAST(ag.LEGACY_SOURCE_ID AS VARCHAR(2000))	
                 ELSE	
                     t.SOURCE_REF	
             END,	
             CAST(a_t.BALANCE_MINOR_UNITS AS FLOAT(53)) / POWER(10, c.DECIMAL_PLACES),	
             CAST(a_s.BALANCE_MINOR_UNITS AS FLOAT(53)) / POWER(10, c.DECIMAL_PLACES),	
             CAST(a_r.BALANCE_MINOR_UNITS AS FLOAT(53)) / POWER(10, c.DECIMAL_PLACES)	
    ORDER BY o.EXTERNAL_REF;	

END;
GO
