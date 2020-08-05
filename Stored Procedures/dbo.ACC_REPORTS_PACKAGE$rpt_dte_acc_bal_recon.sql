SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_dte_acc_bal_recon]
    @p_recordset VARCHAR(2000) OUTPUT,
    @p_startdate DATETIME2(6),
    @p_enddate DATETIME2(6),
    @p_crm_id NVARCHAR(2000) = NULL
AS
BEGIN

    SET @p_recordset = NULL;

	IF LEN(@p_crm_id) = 0
	    SET @p_crm_id = NULL;
	  
	      SELECT o.EXTERNAL_REF AS [Merchant Id],
           o.OWNER_NAME AS [Merchant Name],
           mtype.MERCHANT_TYPE_NAME AS [Merchant Type],
           FORMAT(main.account_number, '00000000#') AS [Account Number],
           main.currency AS Currency,
           act.NAME AS [Group],
           evt.EVENT_NAME AS [Tran Type],
           main.total_count AS Count,
           cast(cast(main.total_amount_minor as decimal(18,2)) / POWER(10, cur.DECIMAL_PLACES) as decimal(18,2)) AS Amount,
           CASE main.regionality
               WHEN 'D' THEN
                   'Domestic'
               WHEN 'R' THEN
                   'Regional'
               WHEN 'I' THEN
                   'International'
               WHEN 'U' THEN
                   'Unknown'
               ELSE
                   ' '
           END AS Regionality,
           CASE main.sale_class_id
               WHEN 0 THEN
                   'MOTO'
               WHEN 1 THEN
                   'continuous authority - repeat billing'
               WHEN 2 THEN
                   'e-commerce'
               WHEN 3 THEN
                   'e-commerce'
               WHEN 4 THEN
                   'cardholder present'
               WHEN 5 THEN
                   'credit transfer'
               ELSE
                   ' '
           END AS [Tran Class],
           ctype.NAME AS [Card Type],
           CASE
               WHEN main.sale_class_id = 2 THEN
                   'Yes' /* E-comm with 3DS*/
               WHEN main.sale_class_id = 3 THEN
                   'No'  /*  E-comm without 3DS*/
               ELSE
                   NULL
           END AS [3DS],
           main.percentage AS [Cost Percentage],
           cast(cast(main.fixed as decimal(18,2)) / POWER(10, cur.DECIMAL_PLACES) as decimal(18,2)) AS [Cost Fixed],
           CASE
               WHEN main.group_status = 'L' THEN
                   'LIVE'
               WHEN main.group_status = '+' THEN
                   'LIVE+'
               WHEN main.group_status = 'P' THEN
                   'PENDING_CLOSURE'
               WHEN main.group_status = 'C' THEN
                   'CLOSED'
               ELSE
                   NULL
           END AS [Account Group Status],
           par.PARTNER_NAME AS [Partner Name]
    FROM
    (
        /* main data extraction logic*/
        SELECT o.OWNER_ID AS owner_id,
               accgrp.ACCOUNT_NUMBER AS account_number,
               accgrp.CURRENCY_CODE_ALPHA3 AS currency,
               acc.ACCOUNT_ID,
               acc.ACCOUNT_TYPE_ID AS account_type_id,
               trans.EVENT_TYPE_ID,
               COUNT_BIG(*) AS total_count,
               SUM(trf.AMOUNT_MINOR_UNITS) AS total_amount_minor,
               acc_other.ACCOUNT_TYPE_ID AS other_account_type,
               sc.SALE_CLASS_ID AS sale_class_id,
               ct.CARD_TYPE_ID AS card_type_id,
               sd.REGIONALITY AS regionality,
               /* Display variable percentage pricing, according to type of transaction, type of card and pricing policy (blended or interchange+)*/
               CASE
                   WHEN /* non-sale transaction*/ trans.EVENT_TYPE_ID != 0 THEN
                       af.PERCENTAGE
                   WHEN /* sale, interchange pricing*/ trans.EVENT_TYPE_ID = 0
                                                       AND accgrp.PRICING_POLICY_ID = 0 THEN
                       afic.PERCENTAGE
                   ELSE /* Blended pricing*/
                       afbl.PERCENTAGE
               END AS percentage,
               /* Display fixed amount pricing, according to type of transaction, type of card and pricing policy (blended or interchange+)*/
               CASE
                   WHEN /* non-sale transaction*/ trans.EVENT_TYPE_ID != 0 THEN
                       af.AMOUNT_MINOR_UNITS
                   WHEN /* Amex sale, interchange pricing*/ trans.EVENT_TYPE_ID = 0
                                                            AND accgrp.PRICING_POLICY_ID = 0 THEN
                       afic.AMOUNT_MINOR_UNITS
                   ELSE /* Sale, blended pricing*/
                       afbl.AMOUNT_MINOR_UNITS
               END AS fixed,
               accgrp.GROUP_STATUS AS group_status,
               o.CRM_ID AS crm_id
        FROM dbo.ACC_TRANSFERS AS trf
            JOIN dbo.ACC_TRANSACTIONS AS trans
                LEFT OUTER JOIN dbo.ACC_TRANSACTIONS AS origtxn
                    JOIN dbo.ACC_SALE_DETAILS AS sd
                        LEFT JOIN dbo.ACC_CARD_TYPES AS ct
                            ON ct.CARD_TYPE_ID = sd.CARD_TYPE_ID
                        LEFT JOIN dbo.ACC_SALE_CLASSES AS sc
                            ON sc.SALE_CLASS_ID = sd.SALE_CLASS_ID
                        ON sd.TRANSACTION_ID = origtxn.TRANSACTION_ID
                    ON origtxn.TRANSACTION_ID = trans.TXN_FIRST_ID
                       AND origtxn.EVENT_TYPE_ID IN ( 0, 58 )
                ON /* Sale, Credit Transfer*/ trans.TRANSACTION_ID = trf.TRANSACTION_ID
            JOIN dbo.ACC_ACCOUNTS AS acc
                JOIN dbo.ACC_ACCOUNT_GROUPS AS accgrp
                    JOIN dbo.ACC_OWNERS AS o
                        ON accgrp.OWNER_ID = o.OWNER_ID
                    ON accgrp.ACCOUNT_GROUP_ID = acc.ACCOUNT_GROUP_ID
                       AND accgrp.ACCOUNT_GROUP_TYPE IN ( 'A' )
                ON acc.ACCOUNT_ID = trf.ACCOUNT_ID
            JOIN dbo.ACC_TRANSFERS AS trf_other
                JOIN dbo.ACC_ACCOUNTS AS acc_other
                    ON acc_other.ACCOUNT_ID = trf_other.ACCOUNT_ID
                       AND acc_other.ACCOUNT_TYPE_ID NOT IN ( 0, 2, 3 )
                ON trf_other.TRANSACTION_ID = trf.TRANSACTION_ID
                   AND trf_other.TRANSFER_TYPE_ID = trf.TRANSFER_TYPE_ID
                   AND trf_other.TRANSFER_ID != trf.TRANSFER_ID
            LEFT OUTER JOIN /* This join ONLY recovers pricing for non-sales*/ dbo.ACC_ACQUIRING_FEES AS af
                ON trans.EVENT_TYPE_ID IN ( 58, 8, 53, 11, 54, 61, 62, 7, 55, 71, 74 )
                   AND
                /* Credit Transfer, High Risk, HR Fee, Chargeback, CB Fee, 2nd CB, 2nd CB Fee, Copy Request, CR Fee, Dispute, Dispute Pre-Arb*/ af.ACCOUNT_GROUP_ID = accgrp.ACCOUNT_GROUP_ID
                   AND trans.EVENT_TYPE_ID = af.EVENT_TYPE_ID
            LEFT OUTER JOIN /* This join ONLY recovers IC pricing for sales*/ dbo.ACC_ACQUIRING_FEES_IC AS afic
                ON trans.EVENT_TYPE_ID IN ( 0 )
                   AND accgrp.PRICING_POLICY_ID = 0
                   AND afic.ACCOUNT_GROUP_ID = accgrp.ACCOUNT_GROUP_ID
                   AND
                   (
                       (
                           ct.CARD_TYPE_ID IN ( 7, 12 )
                           AND afic.FEE_DISTINGUISHER = 'AMEX'
                       )
                       OR
                       (
                           ct.CARD_TYPE_ID IN ( 0, 1, 2, 3, 8, 10, 11 )
                           AND afic.FEE_DISTINGUISHER = 'VISA'
                       )
                       OR
                       (
                           ct.CARD_TYPE_ID IN ( 4, 5, 6, 9, 13, 14, 15 )
                           AND afic.FEE_DISTINGUISHER = 'MASTER_CARD'
                       )
                   )
            LEFT OUTER JOIN /* This join ONLY recovers blended pricing for sales*/ dbo.ACC_ACQUIRING_FEES_BLENDED AS afbl
                ON trans.EVENT_TYPE_ID IN ( 0 )
                   AND accgrp.PRICING_POLICY_ID = 1
                   AND afbl.ACCOUNT_GROUP_ID = accgrp.ACCOUNT_GROUP_ID
                   AND afbl.TRANSACTION_CATEGORY_CODE = sc.TRANSACTION_CATEGORY_CODE
                   AND afbl.CARD_CATEGORY_CODE = ct.CARD_CATEGORY_CODE
                   AND afbl.REGION = sd.REGIONALITY
        WHERE acc.ACCOUNT_TYPE_ID IN ( 0, 2, 3 )
              AND trf.TRANSFER_TIME >= @p_startdate
              AND trf.TRANSFER_TIME < @p_enddate
              AND (o.CRM_ID = ISNULL(@p_crm_id, o.CRM_ID))
        GROUP BY o.OWNER_ID,
                 accgrp.ACCOUNT_NUMBER,
                 accgrp.PRICING_POLICY_ID,
                 acc.ACCOUNT_ID,
                 acc.ACCOUNT_TYPE_ID,
                 trans.EVENT_TYPE_ID,
                 accgrp.CURRENCY_CODE_ALPHA3,
                 acc_other.ACCOUNT_TYPE_ID,
                 sc.SALE_CLASS_ID,
                 ct.CARD_TYPE_ID,
                 sd.REGIONALITY,
                 ct.CARD_CATEGORY_CODE,
                 sc.TRANSACTION_CATEGORY_CODE,
                 af.PERCENTAGE,
                 afic.PERCENTAGE,
                 afbl.PERCENTAGE,
                 af.AMOUNT_MINOR_UNITS,
                 afic.AMOUNT_MINOR_UNITS,
                 afbl.AMOUNT_MINOR_UNITS,
                 accgrp.GROUP_STATUS,
                 o.CRM_ID
    ) AS main
        JOIN /* the following is essentially static data added into the report at the end*/ dbo.ACC_ACCOUNT_TYPES AS act
            ON act.ACCOUNT_TYPE_ID = main.other_account_type
        JOIN dbo.ACC_EVENT_TYPES AS evt
            ON evt.EVENT_TYPE_ID = main.EVENT_TYPE_ID
        LEFT JOIN dbo.ACC_CARD_TYPES AS ctype
            ON ctype.CARD_TYPE_ID = main.card_type_id
        JOIN dbo.ACC_OWNERS AS o
            LEFT JOIN dbo.ACC_MERCHANT_TYPES AS mtype
                ON mtype.MERCHANT_TYPE_ID = o.BUSINESS_TYPE
            ON o.OWNER_ID = main.owner_id
        LEFT JOIN dbo.ACC_PARTNERS AS par
            ON par.CRM_ID = main.crm_id
        JOIN dbo.ACC_CURRENCIES AS cur
            ON cur.CURRENCY_CODE_ALPHA3 = main.currency
    ORDER BY main.owner_id,
             main.account_number,
             main.currency,
             main.regionality,
             main.account_type_id,
             main.EVENT_TYPE_ID,
             main.sale_class_id,
             main.card_type_id;

END;
GO
