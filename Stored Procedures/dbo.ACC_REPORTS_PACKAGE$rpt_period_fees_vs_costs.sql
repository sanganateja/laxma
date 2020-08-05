SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_period_fees_vs_costs]
    @p_recordset VARCHAR(2000) OUTPUT,
    @p_startdate DATETIME2(6),
    @p_enddate DATETIME2(6),
    @p_ownerid NUMERIC
AS
BEGIN
    SET NOCOUNT ON;
    SET @p_recordset = NULL;

    /*
     * designator direction : Determine which of the banking cost designators are incoming or outgoing
     * fee_summary : For the given business and period specified, determine the number of monthly fees charged to the customer in
     *   that period. it also determines when the previous monthly fee was paid prior to the reporting period, to restrict the
     *   transaction summary to only report on those transactions between the previous monthly fee payment and the last monthly fee paid
     *   in the reporting window. The monthly_fees inline view is required to bring back the whole set of monthly fees for the business
     *   so that the previous fee payment date can be determined. This is then restricted by the outer query to only include the previous
     *   payment date.
     * tx_summary : For the business_id(s), and transaction validity period determined from the fee_summary processing, summarize the
     *   transactions on a business by business basis, grouping by cost designator, transaction currency, cost currency, and whether the
     *   transaction was part of a free bundle or not.
     * split_tx_summary : takes the output produced by tx_summary, and uses the free/charged status and incoming/outgoing flag to
     *   report in seperate columns for the incoming and ougoing transactions, and thoe that were free.
     *
     * The final select brings together the previous subqueries to produce the report.
     *
     * NOTE, the usually the report will be run scheduled on a monthly basis for the previous month - i.e. reporting on any
     * businesses that made a monthly fee payment in the previous month. It is possible to run the report adhoc, specifying a
     * specific business_id. It is also possible to specify a longer period, where all monthly fees paid in the period will be
     * summarized together, and all transaction made since the previous fee payment prior to the reporting period will be included
     * in the transaction summary.
     */

    WITH designator_direction
    AS (SELECT DESIGNATOR_ID,
               CASE
                   WHEN DESCRIPTION LIKE '%In' THEN
                       'IN'
                   ELSE
                       'OUT'
               END AS direction
        FROM CST_DESIGNATORS
        WHERE CATEGORY_ID = 1 --Banking
    ),
         fee_summary
    AS (SELECT monthly_fees.owner_id AS owner_id,
               MAX(monthly_fees.monthly_fee_paid_date) AS fee_paid_date,
               MAX(monthly_fees.current_pricing_tier) AS current_pricing_tier,
               MAX(monthly_fees.monthly_fee_currency) AS fee_currency,
               SUM(monthly_fees.monthly_fee_amount) AS fee_paid_amount,
               MIN(monthly_fees.monthly_fee_prev_paid_date) AS fee_paid_prev_date
        FROM
        (
            SELECT o.OWNER_ID AS owner_id,
                   tr.TRANSFER_TIME AS monthly_fee_paid_date,
                   tr.TRANSACTION_ID AS monthly_fee_tx_id,
                   tt.NAME AS monthly_fee_tx_type,
                   'CUSTOM' AS current_pricing_tier,
                   ag.CURRENCY_CODE_ALPHA3 AS monthly_fee_currency,
                   tr.AMOUNT_MINOR_UNITS / POWER(10, cu.DECIMAL_PLACES) AS monthly_fee_amount,
                   LAG(tr.TRANSFER_TIME, 1, '2000-01-01') OVER (PARTITION BY o.OWNER_ID ORDER BY tr.TRANSFER_ID) AS monthly_fee_prev_paid_date
            FROM ACC_TRANSFERS tr
                JOIN ACC_ACCOUNTS ac
                    ON ac.ACCOUNT_ID = tr.ACCOUNT_ID
                JOIN ACC_ACCOUNT_GROUPS ag
                    ON ag.ACCOUNT_GROUP_ID = ac.ACCOUNT_GROUP_ID
                       AND ag.ACCOUNT_GROUP_TYPE IN ( 'C', 'D' )
                JOIN ACC_OWNERS o
                    ON o.OWNER_ID = ag.OWNER_ID
                JOIN ACC_TRANSFER_TYPES tt
                    ON tt.TRANSFER_TYPE_ID = tr.TRANSFER_TYPE_ID
                JOIN ACC_CURRENCIES cu
                    ON ag.CURRENCY_CODE_ALPHA3 = cu.CURRENCY_CODE_ALPHA3
            WHERE tr.TRANSFER_TYPE_ID = 45 -- Fee_Monthly_Fee
                  AND ac.ACCOUNT_TYPE_ID = 1 -- Costs Account
                  AND
                  (
                      o.OWNER_ID = @p_ownerid
                      OR ISNULL(@p_ownerid, 0) = 0
                  )
                  AND tr.TRANSFER_TIME < @p_enddate
        --                 ORDER BY o.owner_id, tr.transfer_id
        ) monthly_fees
        WHERE monthly_fees.monthly_fee_paid_date >= @p_startdate
              AND monthly_fees.monthly_fee_paid_date < @p_enddate
        GROUP BY monthly_fees.owner_id),
         tx_summary
    AS (SELECT o1.OWNER_ID AS owner_id,
               tc1.DESIGNATOR_ID AS designator_id,
               CASE
                   WHEN (ISNULL(tr1.AMOUNT_MINOR_UNITS, 0) = 0) THEN
                       'FREE'
                   ELSE
                       'CHARGED'
               END AS status,
               ag1.CURRENCY_CODE_ALPHA3 AS tx_currency,
               COUNT(DISTINCT tx1.TRANSACTION_ID) AS tx_count,
               SUM(tx1.AMOUNT_MINOR_UNITS / POWER(10, cu2.DECIMAL_PLACES)) AS tx_amount,
               tc1.FIXED_CURRENCY_CODE_ALPHA3 AS cost_currency,
               SUM(tc1.FIXED_AMOUNT_MINOR_UNITS / POWER(10, cu1.DECIMAL_PLACES)) AS cost_amount,
               SUM(ISNULL(tr1.AMOUNT_MINOR_UNITS, 0) / POWER(10, cu2.DECIMAL_PLACES)) AS revenue_amount
        FROM ACC_TRANSACTIONS tx1
            JOIN ACC_ACCOUNT_GROUPS ag1
                ON ag1.ACCOUNT_GROUP_ID = tx1.ACCOUNT_GROUP_ID
            JOIN ACC_ACCOUNTS ac1
                ON ac1.ACCOUNT_GROUP_ID = ag1.ACCOUNT_GROUP_ID
                   AND ac1.ACCOUNT_TYPE_ID = 1
            JOIN ACC_OWNERS o1
                ON o1.OWNER_ID = ag1.OWNER_ID
                   AND ag1.ACCOUNT_GROUP_TYPE IN ( 'C', 'D' )
            JOIN fee_summary fs
                ON fs.owner_id = o1.OWNER_ID
            LEFT JOIN ACC_TRANSFERS tr1
                ON tr1.TRANSACTION_ID = tx1.TRANSACTION_ID
                   AND ISNULL(tr1.TRANSFER_TYPE_ID, 42) = 42
                   AND tr1.ACCOUNT_ID = ac1.ACCOUNT_ID
            JOIN ACC_TRANSACTION_COSTS tc1
                ON tc1.TRANSACTION_ID = tx1.TRANSACTION_ID
            JOIN ACC_CURRENCIES cu1
                ON tc1.FIXED_CURRENCY_CODE_ALPHA3 = cu1.CURRENCY_CODE_ALPHA3
            JOIN ACC_CURRENCIES cu2
                ON ag1.CURRENCY_CODE_ALPHA3 = cu2.CURRENCY_CODE_ALPHA3
        WHERE tx1.TRANSACTION_TIME >= fs.fee_paid_prev_date
              AND tx1.TRANSACTION_TIME < fs.fee_paid_date
              AND ac1.ACCOUNT_TYPE_ID = 1
        GROUP BY o1.OWNER_ID,
                 tc1.DESIGNATOR_ID,
                 CASE
                     WHEN (ISNULL(tr1.AMOUNT_MINOR_UNITS, 0) = 0) THEN
                         'FREE'
                     ELSE
                         'CHARGED'
                 END,
                 ag1.CURRENCY_CODE_ALPHA3,
                 tc1.FIXED_CURRENCY_CODE_ALPHA3),
         split_tx_summary
    AS (SELECT tx_summary.owner_id,
               tx_summary.designator_id,
               tx_summary.tx_currency,
               tx_summary.cost_currency,
               SUM(   CASE
                          WHEN dd.direction = 'OUT' THEN
                              tx_summary.tx_count
                          ELSE
                              0
                      END
                  ) AS tx_out_count,
               SUM(   CASE
                          WHEN dd.direction = 'OUT' THEN
                              tx_summary.tx_amount
                          ELSE
                              0
                      END
                  ) AS tx_out_amount,
               SUM(   CASE
                          WHEN dd.direction = 'IN' THEN
                              tx_summary.tx_count
                          ELSE
                              0
                      END
                  ) AS tx_in_count,
               SUM(   CASE
                          WHEN dd.direction = 'IN' THEN
                              tx_summary.tx_amount
                          ELSE
                              0
                      END
                  ) AS tx_in_amount,
               SUM(cost_amount) AS total_cost_amount,
               SUM(revenue_amount) AS total_revenue_amount,
               SUM(   CASE
                          WHEN dd.direction = 'OUT'
                               AND tx_summary.status = 'FREE' THEN
                              tx_summary.tx_count
                          ELSE
                              0
                      END
                  ) AS tx_free_out_count,
               SUM(   CASE
                          WHEN dd.direction = 'OUT'
                               AND tx_summary.status = 'FREE' THEN
                              tx_summary.tx_amount
                          ELSE
                              0
                      END
                  ) AS tx_free_out_amount,
               SUM(   CASE
                          WHEN dd.direction = 'IN'
                               AND tx_summary.status = 'FREE' THEN
                              tx_summary.tx_count
                          ELSE
                              0
                      END
                  ) AS tx_free_in_count,
               SUM(   CASE
                          WHEN dd.direction = 'IN'
                               AND tx_summary.status = 'FREE' THEN
                              tx_summary.tx_amount
                          ELSE
                              0
                      END
                  ) AS tx_free_in_amount,
               SUM(   CASE
                          WHEN tx_summary.status = 'FREE' THEN
                              tx_summary.cost_amount
                          ELSE
                              0
                      END
                  ) AS tx_free_cost_amount
        FROM tx_summary
            JOIN designator_direction dd
                ON dd.DESIGNATOR_ID = tx_summary.designator_id
        GROUP BY tx_summary.owner_id,
                 tx_summary.designator_id,
                 tx_summary.tx_currency,
                 tx_summary.cost_currency)
    SELECT o2.EXTERNAL_REF AS business_id,
           fee_summary.fee_paid_date,
           fee_summary.current_pricing_tier,
           fee_summary.fee_currency,
           fee_summary.fee_paid_amount,
           fee_summary.fee_paid_prev_date,
           cd.DESCRIPTION AS cost_designator,
           split_tx_summary.tx_currency,
           split_tx_summary.tx_out_count,
           split_tx_summary.tx_out_amount,
           split_tx_summary.tx_in_count,
           split_tx_summary.tx_in_amount,
           split_tx_summary.cost_currency,
           split_tx_summary.total_cost_amount,
           split_tx_summary.total_revenue_amount,
           split_tx_summary.tx_free_out_count,
           split_tx_summary.tx_free_out_amount,
           split_tx_summary.tx_free_in_count,
           split_tx_summary.tx_free_in_amount,
           split_tx_summary.tx_free_cost_amount
    FROM fee_summary
        JOIN split_tx_summary
            ON fee_summary.owner_id = split_tx_summary.owner_id
        JOIN designator_direction dd
            ON dd.DESIGNATOR_ID = split_tx_summary.designator_id
        JOIN CST_DESIGNATORS cd
            ON cd.DESIGNATOR_ID = split_tx_summary.designator_id
        JOIN ACC_OWNERS o2
            ON fee_summary.owner_id = o2.OWNER_ID
    ORDER BY fee_summary.owner_id,
             dd.direction,
             cd.DESCRIPTION,
             split_tx_summary.tx_currency;



END;
GO
