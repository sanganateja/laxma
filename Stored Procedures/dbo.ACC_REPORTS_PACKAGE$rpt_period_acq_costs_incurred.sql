SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_period_acq_costs_incurred]
(
    @p_recordset VARCHAR(2000) OUTPUT,
    @p_startdate DATE,
    @p_enddate DATE,
    @p_ownerid BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET @p_recordset = NULL;

    WITH grouped_charges
    AS (SELECT o.OWNER_ID,
               CASE
                   WHEN tr.SOURCE_REF IS NULL THEN
                       CAST(ag.LEGACY_SOURCE_ID AS VARCHAR(18))
                   ELSE
                       tr.SOURCE_REF
               END profile_id,
               ag.ACCOUNT_NUMBER,
               ag.ACCOUNT_GROUP_NAME,
               tr.TXN_FIRST_ID,
               ag.CURRENCY_CODE_ALPHA3,
               SUM(   CASE
                          WHEN tr.EVENT_TYPE_ID NOT IN ( 10, 26 ) THEN
                              tr.AMOUNT_MINOR_UNITS
                          ELSE
                              0.0
                      END
                  ) transaction_amount,
               SUM(   CASE
                          WHEN tr.EVENT_TYPE_ID = 10 THEN
                              tr.AMOUNT_MINOR_UNITS
                          ELSE
                              0.0
                      END
                  ) gateway_fee,
               SUM(   CASE
                          WHEN tr.EVENT_TYPE_ID = 26 THEN
                              tr.AMOUNT_MINOR_UNITS
                          ELSE
                              0.0
                      END
                  ) msc
        FROM ACC_ACCOUNT_GROUPS ag
            JOIN ACC_TRANSACTIONS tr
                ON tr.ACCOUNT_GROUP_ID = ag.ACCOUNT_GROUP_ID
            JOIN ACC_OWNERS o
                ON ag.OWNER_ID = o.OWNER_ID
        WHERE ag.ACCOUNT_GROUP_TYPE IN ( 'A' )
              AND tr.TRANSACTION_TIME >= @p_startdate
              AND tr.TRANSACTION_TIME < @p_enddate
              AND
              (
                  (ag.OWNER_ID = @p_ownerid)
                  OR (@p_ownerid = 0)
              )
        GROUP BY o.OWNER_ID,
                 (CASE
                      WHEN tr.SOURCE_REF IS NULL THEN
                          CAST(ag.LEGACY_SOURCE_ID AS VARCHAR(18))
                      ELSE
                          tr.SOURCE_REF
                  END
                 ),
                 ag.ACCOUNT_NUMBER,
                 ag.ACCOUNT_GROUP_NAME,
                 tr.TXN_FIRST_ID,
                 ag.CURRENCY_CODE_ALPHA3
        HAVING SUM(   CASE
                          WHEN tr.EVENT_TYPE_ID NOT IN ( 10, 26 ) THEN
                              tr.AMOUNT_MINOR_UNITS
                          ELSE
                              0.0
                      END
                  ) <> 0) -- TransactionAmnt <> 0

    SELECT o.EXTERNAL_REF AS business_id,
           o.OWNER_NAME AS business_name,
           o.BUSINESS_COUNTRY AS business_country,
           o.CRA_NAME AS cra,
           pa.PARTNER_NAME AS partner_name,
           pa.PARTNER_OVERRIDE AS partner_override,
           gc.profile_id AS profile_id,
           FORMAT(gc.ACCOUNT_NUMBER, '0000000#') AS account_number,
           gc.ACCOUNT_GROUP_NAME AS account_group_name,
           tr.TXN_FIRST_ID AS transaction_id,
           tr.TRANSACTION_TIME AS transaction_time,
           et.EVENT_NAME AS event,
           tr.DESCRIPTION AS transaction_description,
           dc.DESCRIPTION AS category,
           dt.DESCRIPTION AS type,
           ds.DESCRIPTION AS cost_designator,
           gc.CURRENCY_CODE_ALPHA3 AS transaction_currency,
           gc.transaction_amount / POWER(10, cutr.DECIMAL_PLACES) AS transaction_amount,
           gc.msc / POWER(10, cutr.DECIMAL_PLACES) AS msc_amount,
           gc.gateway_fee / POWER(10, cutr.DECIMAL_PLACES) AS gateway_fee_amount,
           tc.FIXED_CURRENCY_CODE_ALPHA3 AS fixed_cost_currency,
           tc.FIXED_AMOUNT_MINOR_UNITS / POWER(10, cutr.DECIMAL_PLACES) AS fixed_cost_amount,
           tc.VARIABLE_CURRENCY_CODE_ALPHA3 AS variable_cost_currency,
           tc.VARIABLE_AMOUNT_MINOR_UNITS AS variable_cost_amount
    FROM grouped_charges gc
        JOIN ACC_OWNERS o
            ON gc.OWNER_ID = o.OWNER_ID
        LEFT JOIN ACC_PARTNERS pa
            ON pa.CRM_ID = o.CRM_ID
        JOIN ACC_TRANSACTIONS tr
            ON gc.TXN_FIRST_ID = tr.TRANSACTION_ID
        LEFT JOIN ACC_TRANSACTION_COSTS tc
            ON tr.TRANSACTION_ID = tc.TRANSACTION_ID
        LEFT JOIN CST_DESIGNATORS ds
            ON tc.DESIGNATOR_ID = ds.DESIGNATOR_ID
        LEFT JOIN CST_DESIGNATOR_TYPES dt
            ON ds.TYPE_ID = dt.TYPE_ID
        LEFT JOIN CST_DESIGNATOR_CATEGORIES dc
            ON ds.CATEGORY_ID = dc.CATEGORY_ID
        JOIN ACC_EVENT_TYPES et
            ON tr.EVENT_TYPE_ID = et.EVENT_TYPE_ID
        JOIN ACC_CURRENCIES cutr
            ON gc.CURRENCY_CODE_ALPHA3 = cutr.CURRENCY_CODE_ALPHA3
        LEFT JOIN ACC_CURRENCIES cufx
            ON tc.FIXED_CURRENCY_CODE_ALPHA3 = cufx.CURRENCY_CODE_ALPHA3
        LEFT JOIN ACC_CURRENCIES cuvr
            ON tc.VARIABLE_CURRENCY_CODE_ALPHA3 = cuvr.CURRENCY_CODE_ALPHA3
    ORDER BY o.EXTERNAL_REF,
             gc.ACCOUNT_NUMBER,
             gc.ACCOUNT_GROUP_NAME,
             tr.TXN_FIRST_ID;
END;
GO
