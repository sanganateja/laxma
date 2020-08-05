SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_maturity_details]
(@p_recordset VARCHAR(2000) OUTPUT)
AS
BEGIN

    SET NOCOUNT ON;

    SET @p_recordset = NULL;

/*		WITH acc_group_calculated AS (
		    SELECT	ag.account_group_id,
		        MAX(CASE WHEN
		                    ab.matured_time IS NULL
		                    AND  aa.account_type_id = 0
		                    AND  tr.transfer_type_id = 0
		                    AND  tr.transfer_time >= DATEADD(DAY,-3,CAST(GETDATE() AS DATE))
		                THEN 1
		                ELSE 0 END) as [recent_sales],
		        MAX(ag.sales_sum) as [sales_sum],
		        COALESCE(CAST(MAX(ag.day_since_last_sale) as varchar(10)),'No sales') as [day_since_last_sale],
		        CASE WHEN
		                MAX(ag.sales_count) = 0
		            THEN 'No sales'
		            ELSE CONCAT(CAST(100*MAX(ag.chargeback_count)/MAX(ag.sales_count) as numeric(10,2)), '%') END as [cb_last_30],
		        CASE WHEN
		                MAX(ag.sales_sum) = 0
		            THEN 'No sales'
		            ELSE CONCAT(CAST(100*MAX(ag.high_risk_sum)/MAX(ag.sales_sum) as numeric(10,2)), '%') END as [fraud_last_30],
		        CASE WHEN
		                MAX(ag.sales_count) = 0
		            THEN 'No sales'
		            ELSE CONCAT(CAST(100*MAX(ag.dispute_count)/MAX(ag.sales_count) as numeric(10,2)), '%') END as [dispute_last_30]
		    FROM (
		        SELECT
		            ag.account_group_id as [account_group_id],
		            SUM(
		                CASE WHEN
		                        tr.transfer_type_id = 0  -- sale
		                        AND aa.account_type_id = 0 -- trading account
		                        AND tr.transfer_time >= DATEADD(DAY,-30,CAST(GETDATE() AS DATE))
		                    THEN tr.amount_minor_units
		                    ELSE 0 END) as [sales_sum],
		            SUM(
		                CASE WHEN
		                        tr.transfer_type_id = 0 -- sale
		                        AND aa.account_type_id = 0 -- trading account
		                        AND tr.transfer_time >= DATEADD(DAY,-30,CAST(GETDATE() AS DATE))
		                    THEN 1
		                    ELSE 0 END) as [sales_count],
		            MIN(
		                CASE WHEN
		                        tr.transfer_type_id = 0 -- sale
		                        AND aa.account_type_id = 0 -- trading account
		                    THEN DATEDIFF(DAY,CAST(tr.transfer_time AS DATE),CAST(GETDATE() AS DATE))-1
		                    ELSE null END) AS [day_since_last_sale],
		            SUM(
		                CASE WHEN
		                        tr.transfer_type_id = 7 -- chargeback
		                        AND aa.account_type_id = 5 -- external account
		                        AND tr.transfer_time >= DATEADD(DAY,-30,CAST(GETDATE() AS DATE))
		                THEN 1
		                ELSE 0 END) as [chargeback_count],
		            SUM(
		                CASE WHEN
		                        (tr.transfer_type_id = 7 OR tr.transfer_type_id = 66) -- chargeback or dispute
		                        AND aa.account_type_id = 0 -- trading account
		                        AND tr.transfer_time >= DATEADD(DAY,-30,CAST(GETDATE() AS DATE))
		                    THEN -tr.amount_minor_units
		                    ELSE 0 END) as [high_risk_sum],
		            SUM(
		                CASE WHEN
		                        tr.transfer_type_id = 66 -- dispute
		                        AND aa.account_type_id = 5 -- external account
		                        AND tr.transfer_time >= DATEADD(DAY,-30,CAST(GETDATE() AS DATE))
		                THEN 1
		                ELSE 0 END) as [dispute_count]
		        FROM acc_account_groups ag
		        JOIN acc_accounts aa ON aa.account_group_id = ag.account_group_id
		        JOIN acc_transfers tr ON aa.account_id = tr.account_id
		        GROUP BY ag.account_group_id) ag
		    JOIN acc_accounts aa  ON ag.account_group_id = aa.account_group_id
		    JOIN acc_batches ab ON ab.account_id = aa.account_id
		    JOIN acc_transfers tr ON tr.batch_id = ab.batch_id
		    GROUP BY ag.account_group_id)

		SELECT o.external_ref       AS [business_id],
		       v.owner_name         AS [business_name],
		       ISNULL(p.partner_name, 'No partner')  AS [partner_name],
		       FORMAT(ag.account_number, '0000000#') AS [account_number],
		       v.total_remittance / POWER(10, c.decimal_places) AS [amount_due],
		       v.currency,
		       v.trading_account_balance / POWER(10, c.decimal_places) AS [merchant_account_balance],
		       v.reserve_account_balance / POWER(10, c.decimal_places) AS [reserve_balance],
		       v.security_account_balance / POWER(10, c.decimal_places) AS [security_balance],
		       agc.sales_sum  / POWER(10, c.decimal_places) AS [SALES £ LAST 30 DAYS],
		       agc.day_since_last_sale AS [DAYS SINCE LAST SALE],
		       agc.cb_last_30 AS [CB%# LAST 30 DAYS],
		       agc.dispute_last_30 AS [DISPUTE%# LAST 30 DAYS],
		       agc.fraud_last_30 AS [FRAUD %£ LAST 30 DAYS],
		       CASE WHEN v.total_remittance > (v.trading_account_balance + v.reserve_account_balance + v.security_account_balance)/2 THEN 'Yes' ELSE 'No' END AS [paying_too_much],
		       CASE WHEN (v.total_remittance - v.trading_account_balance) / POWER(10, c.decimal_places) > -500 THEN 'Yes' ELSE 'No' END AS [stopped_trading_1],
		       CASE WHEN agc.recent_sales != 1 AND v.total_remittance / POWER(10, c.decimal_places) > 500 THEN 'Yes' ELSE 'No' END AS [stopped_trading_2],
		       CASE WHEN v.total_remittance > v.total_pending AND v.total_remittance / POWER(10, c.decimal_places) > 500 THEN 'Yes' ELSE 'No' END AS [stopped_trading_3],
		       CASE WHEN (o.merch_flags % 2) = 0 THEN 'N' ELSE 'Y' END AS [auto_remittance],
		       CASE v.on_hold WHEN 'Y' THEN 'Held' WHEN 'T' THEN 'Temporarily Held' WHEN 'D' THEN 'Daily Held' ELSE ' ' END AS [hold_status],
		       CASE WHEN v.on_hold IN ('Y','T') THEN v.on_hold_reason END AS [hold_reason]
		FROM   view_remittance_details v 
		JOIN acc_currencies c ON v.currency = c.currency_code_alpha3
		                                  JOIN acc_account_groups ag ON v.account_group_id = ag.account_group_id and ag.account_group_type in ('A')
		                                  JOIN acc_owners o ON ag.owner_id = o.owner_id
		                                  LEFT JOIN acc_partners p ON p.crm_id = o.crm_id
		                                  JOIN acc_group_calculated agc ON agc.account_group_id = ag.account_group_id
		                                  WHERE v.total_remittance <>0
		ORDER BY v.total_remittance DESC;
		*/
END;
GO
