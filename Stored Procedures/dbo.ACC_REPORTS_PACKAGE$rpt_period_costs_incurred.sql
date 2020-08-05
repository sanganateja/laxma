SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_period_costs_incurred]
    @p_recordset VARCHAR(2000) OUTPUT,
    @p_startdate DATETIME2(6),
    @p_enddate DATETIME2(6),
    @p_owner_id NUMERIC
AS
BEGIN

    SET @p_recordset = NULL;

    SELECT o.EXTERNAL_REF AS business_id,
           o.OWNER_NAME AS business_name,
           o.BUSINESS_COUNTRY AS business_country,
           o.CRA_NAME AS cra,
           pa.PARTNER_NAME AS partner_name,
           pa.PARTNER_OVERRIDE AS partner_override,
           FORMAT(ag.ACCOUNT_NUMBER, '00000000#') AS account_number,
           tr.TRANSACTION_ID AS transaction_id,
           tr.TRANSACTION_TIME AS transaction_time,
           et.EVENT_NAME AS event,
           tr.DESCRIPTION AS transaction_description,
           dc.DESCRIPTION AS category,
           dt.DESCRIPTION AS TYPE,
           ds.DESCRIPTION AS cost_designator,
           cu.CURRENCY_CODE_ALPHA3 AS transaction_currency,
           CAST(tr.AMOUNT_MINOR_UNITS AS FLOAT(53)) / POWER(10, cu.DECIMAL_PLACES) AS transaction_amount,
           (
               SELECT CAST(tf.AMOUNT_MINOR_UNITS AS FLOAT(53)) / POWER(10, cu.DECIMAL_PLACES) AS expr
               FROM dbo.ACC_TRANSFERS AS tf
                   JOIN dbo.ACC_ACCOUNTS AS ac
                       ON tf.ACCOUNT_ID = ac.ACCOUNT_ID
               WHERE tf.TRANSACTION_ID = tr.TRANSACTION_ID
                     AND ac.ACCOUNT_TYPE_ID = 1
           ) AS price_charged,
           tc.FIXED_CURRENCY_CODE_ALPHA3 AS fixed_cost_currency,
           tc.FIXED_AMOUNT_MINOR_UNITS / POWER(10, cu.DECIMAL_PLACES) AS fixed_cost_amount,
           tc.VARIABLE_CURRENCY_CODE_ALPHA3 AS variable_cost_currency,
           tc.VARIABLE_AMOUNT_MINOR_UNITS / POWER(10, cu.DECIMAL_PLACES) AS variable_cost_amount
    FROM dbo.ACC_OWNERS AS o
        LEFT JOIN dbo.ACC_PARTNERS AS pa
            ON o.CRM_ID = pa.CRM_ID
        JOIN dbo.ACC_ACCOUNT_GROUPS AS ag
            ON o.OWNER_ID = ag.OWNER_ID
        JOIN dbo.ACC_TRANSACTIONS AS tr
            ON ag.ACCOUNT_GROUP_ID = tr.ACCOUNT_GROUP_ID
        LEFT JOIN dbo.ACC_TRANSACTION_COSTS AS tc
            ON tr.TRANSACTION_ID = tc.TRANSACTION_ID
        LEFT JOIN dbo.CST_DESIGNATORS AS ds
            ON tc.DESIGNATOR_ID = ds.DESIGNATOR_ID
        LEFT JOIN dbo.CST_DESIGNATOR_TYPES AS dt
            ON ds.TYPE_ID = dt.TYPE_ID
        LEFT JOIN dbo.CST_DESIGNATOR_CATEGORIES AS dc
            ON ds.CATEGORY_ID = dc.CATEGORY_ID
        JOIN dbo.ACC_EVENT_TYPES AS et
            ON tr.EVENT_TYPE_ID = et.EVENT_TYPE_ID
        JOIN dbo.ACC_CURRENCIES AS cu
            ON ag.CURRENCY_CODE_ALPHA3 = cu.CURRENCY_CODE_ALPHA3
    WHERE tr.TRANSACTION_TIME >= @p_startdate
          AND tr.TRANSACTION_TIME < @p_enddate
          AND
          (
              (o.OWNER_ID = @p_owner_id)
              OR (@p_owner_id = 0)
          )
          AND tr.AMOUNT_MINOR_UNITS <> 0
          AND ag.ACCOUNT_GROUP_TYPE IN ( 'C', 'D' ) /* account_group is business*/
    ORDER BY o.EXTERNAL_REF,
             account_number,
             transaction_id;

END;
GO
