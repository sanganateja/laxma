SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_hsbc_daily_reconciliation]
(
    @p_recordset VARCHAR(2000) OUTPUT,
    @p_stmntdate DATETIME2(6),
    @p_account_number NVARCHAR(35)
)
AS
BEGIN
    SET NOCOUNT ON;

    SET @p_recordset = NULL;

    -- Create the complete list of eligible transfers, ready to be grouped as required. The rows to be included are first generated
    -- and then the rows to exclude are removed. The inclusion / exclusion criteria are maintained in the mapping table.
    WITH transfer_list
    AS (SELECT CASE
                   WHEN tt.NAME LIKE 'Fee%' THEN
                       1
                   ELSE
                       0
               END AS [group_indicator],
               CASE
                   WHEN tt.NAME LIKE 'Fee%' THEN
                       tt.NAME + '_' + FORMAT(sat.TRANSFER_TIME, 'yyyyMMdd') + '_' + tm.PAYMENT_TYPE_MNEMONIC
                   ELSE
                       CAST(sat.TRANSFER_ID AS VARCHAR(18))
               END AS [group_ident],
               sat.AMOUNT_MINOR_UNITS AS [amount_minor_units],
               COALESCE(pmo.PAYMENT_OR_RETURN, pmi.PAYMENT_OR_RETURN, 'INTERNAL') AS [returned_payment],
               CAST(sat.TRANSFER_TIME AS DATE) AS [book_date],
               CAST(sat.TRANSFER_TIME AS DATE) AS [value_date],
               COALESCE(pmo.HEADER_MESSAGE_ID, pmi.HEADER_MESSAGE_ID, '') AS [instr_id],
               COALESCE(pmo.END_TO_END_ID, pmi.END_TO_END_ID, '') AS [endtoend_id],
               COALESCE(pmo.MESSAGE_TRANSACTION_ID, pmi.MESSAGE_TRANSACTION_ID, REPLACE(tt.NAME, '_', '')) AS [transaction_id],
               '/ID/' + CAST(sat.TRANSACTION_ID AS VARCHAR(18)) AS [addtnl_info],
               COALESCE(pmo.PAYMENT_TYPE, pmi.PAYMENT_TYPE, 'INTERNAL') AS [payment_type],
               CASE
                   WHEN sat.AMOUNT_MINOR_UNITS < 0 THEN
                       'OUT'
                   ELSE
                       'IN'
               END AS [direction],
               CASE
                   WHEN
                   (
                       pmo.END_TO_END_ID IS NOT NULL
                       OR pmi.END_TO_END_ID IS NOT NULL
                   ) THEN
                       'EXTERNAL'
                   ELSE
                       'INTERNAL'
               END AS [acct_svcr_ref],
               CASE
                   WHEN COALESCE(pmo.END_TO_END_ID, pmi.END_TO_END_ID) IS NOT NULL THEN
                       NULL
                   ELSE
                       SUBSTRING(tx.DESCRIPTION, 1, 34)
               END AS [suppl_details]
        -- BottomLine have advised that AddtlTxInf (suppl_details) should be restricted to 34 chars, despite schema type definition being "Max500Text"
        FROM
        (
            SELECT tf.*
            FROM ACC_ACCOUNT_GROUPS ag
                JOIN ACC_ACCOUNTS ac
                    ON ag.ACCOUNT_GROUP_ID = ac.ACCOUNT_GROUP_ID
                JOIN ACC_TRANSACTIONS tr
                    ON ag.ACCOUNT_GROUP_ID = tr.ACCOUNT_GROUP_ID
                JOIN ACC_TRANSFERS tf
                    ON tr.TRANSACTION_ID = tf.TRANSACTION_ID
                       AND tf.ACCOUNT_ID = ac.ACCOUNT_ID
                JOIN ACC_HSBC_ACCOUNT_MAPPINGS m
                    ON m.INCL_EXCL = 'I'
                       AND (m.CURRENCY_CODE_ALPHA3 = ag.CURRENCY_CODE_ALPHA3)
                       AND
                       (
                           m.SORT_CODE = '406080'
                           OR m.SORT_CODE IS NULL
                       ) -- Currently all CFA accounts are 406080
                       AND
                       (
                           m.TRANSFER_TYPE_ID = tf.TRANSFER_TYPE_ID
                           OR m.TRANSFER_TYPE_ID IS NULL
                       )
                       AND
                       (
                           m.TRANSFER_METHOD_ID = tf.TRANSFER_METHOD_ID
                           OR m.TRANSFER_METHOD_ID IS NULL
                       )
                JOIN ACC_HSBC_ACCOUNTS a
                    ON a.ACCOUNT_ID = m.ACCOUNT_ID
            WHERE ac.ACCOUNT_TYPE_ID = 9 --CURRENT ACCOUNT
                  AND tf.TRANSFER_TIME >= @p_stmntdate
                  AND tf.TRANSFER_TIME < DATEADD(DAY, 1, @p_stmntdate)
                  AND a.ACCOUNT_NUMBER = @p_account_number
            EXCEPT
            SELECT tf.*
            FROM ACC_ACCOUNT_GROUPS ag
                JOIN ACC_ACCOUNTS ac
                    ON ag.ACCOUNT_GROUP_ID = ac.ACCOUNT_GROUP_ID
                JOIN ACC_TRANSACTIONS tr
                    ON ag.ACCOUNT_GROUP_ID = tr.ACCOUNT_GROUP_ID
                JOIN ACC_TRANSFERS tf
                    ON tr.TRANSACTION_ID = tf.TRANSACTION_ID
                       AND tf.ACCOUNT_ID = ac.ACCOUNT_ID
                JOIN ACC_HSBC_ACCOUNT_MAPPINGS m
                    ON m.INCL_EXCL = 'E'
                       AND (m.CURRENCY_CODE_ALPHA3 = ag.CURRENCY_CODE_ALPHA3)
                       AND
                       (
                           m.SORT_CODE = '406080'
                           OR m.SORT_CODE IS NULL
                       ) -- Currently all CFA accounts are 406080
                       AND
                       (
                           m.TRANSFER_TYPE_ID = tf.TRANSFER_TYPE_ID
                           OR m.TRANSFER_TYPE_ID IS NULL
                       )
                       AND
                       (
                           m.TRANSFER_METHOD_ID = tf.TRANSFER_METHOD_ID
                           OR m.TRANSFER_METHOD_ID IS NULL
                       )
                JOIN ACC_HSBC_ACCOUNTS a
                    ON a.ACCOUNT_ID = m.ACCOUNT_ID
            WHERE ac.ACCOUNT_TYPE_ID = 9 --CURRENT ACCOUNT
                  AND tf.TRANSFER_TIME >= @p_stmntdate
                  AND tf.TRANSFER_TIME < DATEADD(DAY, 1, @p_stmntdate)
                  AND a.ACCOUNT_NUMBER = @p_account_number
        ) sat
            LEFT JOIN ACC_PAYMENT_MESSAGES_OUT pmo
                ON sat.TRANSACTION_ID = pmo.TRANSACTION_ID
                   AND sat.TRANSFER_TYPE_ID IN ( 39, 46 )
            LEFT JOIN ACC_PAYMENT_MESSAGES_IN pmi
                ON sat.TRANSACTION_ID = pmi.TRANSACTION_ID
                   AND sat.TRANSFER_TYPE_ID IN ( 38, 43 )
            JOIN ACC_TRANSACTIONS tx
                ON sat.TRANSACTION_ID = tx.TRANSACTION_ID
            JOIN ACC_TRANSFER_TYPES tt
                ON sat.TRANSFER_TYPE_ID = tt.TRANSFER_TYPE_ID
            JOIN ACC_TRANSFER_METHODS tm
                ON sat.TRANSFER_METHOD_ID = tm.TRANSFER_METHOD_ID)
    -- Return the list of non-grouped transfers (actual payments and manual transfers)
    SELECT ABS(amount_minor_units) AS [amount_minor_units],
           returned_payment,
           book_date,
           value_date,
           instr_id,
           endtoend_id,
           transaction_id,
           addtnl_info,
           payment_type,
           direction,
           acct_svcr_ref,
           suppl_details
    FROM transfer_list
    WHERE group_indicator = 0
    UNION ALL -- Any duplicates should not be ignored.
    -- Return the list of grouped fees (by date / fee type / payment method)
    SELECT ABS(SUM(amount_minor_units)),
           returned_payment,
           book_date,
           value_date,
           instr_id,
           endtoend_id,
           transaction_id,
           '',                          -- Empty field for addtnl_info
           payment_type,
           direction,
           acct_svcr_ref,
           group_ident AS suppl_details -- suppl_details is the fee description based on the grouping
    FROM transfer_list
    WHERE group_indicator = 1
    GROUP BY group_ident,
             returned_payment,
             book_date,
             value_date,
             instr_id,
             endtoend_id,
             transaction_id,
             payment_type,
             direction,
             acct_svcr_ref
    ORDER BY book_date;

    RETURN;

END;
GO
