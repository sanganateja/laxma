SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_finance_acc_payments]
    @p_recordset VARCHAR(2000) OUTPUT,
    @p_dateTimeFrom DATETIME2(6),
    @p_dateTimeTo DATETIME2(6),
    @p_currency VARCHAR(2000) = NULL
AS
BEGIN

    SET @p_recordset = NULL;

    SELECT t.TRANSFER_ID,
           CONVERT(VARCHAR(20), t.TRANSFER_TIME, 106) AS PAYMENT_DATE,
           CONVERT(NVARCHAR(8), t.TRANSFER_TIME, 8) AS PAYMENT_TIME,
           o.EXTERNAL_REF AS business_id,
           o.OWNER_NAME AS business_name,
           o.BUSINESS_COUNTRY,
           g.ACCOUNT_GROUP_NAME,
           g.ACCOUNT_GROUP_TYPE,
           AT.NAME AS account_type,
           tt.DESCRIPTION AS transfer_type,
           m.DESCRIPTION AS payment_method,
           tr.DESCRIPTION,
           FORMAT(g.ACCOUNT_NUMBER, '00000000#') AS account_number,
           g.CURRENCY_CODE_ALPHA3 AS ccy,
           CAST(t.AMOUNT_MINOR_UNITS AS FLOAT(53)) / POWER(10, c.DECIMAL_PLACES) AS payment_amount,
           CAST(t.BALANCE_AFTER_MINOR_UNITS AS FLOAT(53)) / POWER(10, c.DECIMAL_PLACES) AS balance_after
    FROM dbo.ACC_TRANSFERS AS t
        JOIN dbo.ACC_TRANSACTIONS AS tr
            ON t.TRANSACTION_ID = tr.TRANSACTION_ID
        JOIN dbo.ACC_ACCOUNTS AS a
            ON t.ACCOUNT_ID = a.ACCOUNT_ID
        JOIN dbo.ACC_ACCOUNT_TYPES AS AT
            ON a.ACCOUNT_TYPE_ID = AT.ACCOUNT_TYPE_ID
        JOIN dbo.ACC_ACCOUNT_GROUPS AS g
            ON a.ACCOUNT_GROUP_ID = g.ACCOUNT_GROUP_ID
        JOIN dbo.ACC_OWNERS AS o
            ON g.OWNER_ID = o.OWNER_ID
        JOIN dbo.ACC_CURRENCIES AS c
            ON g.CURRENCY_CODE_ALPHA3 = c.CURRENCY_CODE_ALPHA3
        JOIN dbo.ACC_TRANSFER_TYPES AS tt
            ON t.TRANSFER_TYPE_ID = tt.TRANSFER_TYPE_ID
        JOIN dbo.ACC_TRANSFER_METHODS AS m
            ON t.TRANSFER_METHOD_ID = m.TRANSFER_METHOD_ID
    WHERE AT.ACCOUNT_TYPE_ID = 9 /* Current*/
          AND
          (
              t.TRANSFER_TYPE_ID IN ( 24, 27, 28, 36, 38, 42, 43, 46 )
              OR /*Deposit,Manual_Transfer, Withdrawal, Bank_Payment_Request, Bank_Payment_Received, Fee_Bank_Transfer, Bank_Payment_Reversal, Bank_Payment*/
              (
                  t.TRANSFER_TYPE_ID = 40
                  AND t.TRANSFER_ID IN
                      (
                          SELECT DISTINCT
                                 tfr.TRANSFER_ID
                          FROM dbo.ACC_TRANSFERS AS tfr
                              JOIN dbo.ACC_TRANSACTIONS AS txn
                                  ON tfr.TRANSACTION_ID = txn.TRANSACTION_ID
                              JOIN dbo.ACC_TRANSACTIONS AS txn2
                                  ON txn.TXN_GROUP_ID = txn2.TXN_GROUP_ID
                              JOIN dbo.ACC_TRANSFERS AS tfr2
                                  ON tfr2.TRANSACTION_ID = txn2.TRANSACTION_ID
                              JOIN dbo.ACC_ACCOUNT_GROUPS AS grp
                                  ON txn.ACCOUNT_GROUP_ID = grp.ACCOUNT_GROUP_ID
                              JOIN dbo.ACC_OWNERS AS o
                                  ON o.OWNER_ID = grp.OWNER_ID
                              JOIN dbo.ACC_ACCOUNT_GROUPS AS grp2
                                  ON txn2.ACCOUNT_GROUP_ID = grp2.ACCOUNT_GROUP_ID
                              JOIN dbo.ACC_OWNERS AS o2
                                  ON o2.OWNER_ID = grp2.OWNER_ID
                          WHERE (
                                    (
                                        o.BUSINESS_COUNTRY = 'GB'
                                        AND o2.BUSINESS_COUNTRY != 'GB'
                                    )
                                    OR
                                    (
                                        o.BUSINESS_COUNTRY != 'GB'
                                        AND o2.BUSINESS_COUNTRY = 'GB'
                                    )
                                )
                                AND grp.ACCOUNT_GROUP_TYPE IN ( 'C', 'D' ) /* account_group is business*/
                                AND grp2.ACCOUNT_GROUP_TYPE IN ( 'C', 'D' )
                      )
              )
          )
          AND
          (
              @p_currency IS NULL
              OR g.CURRENCY_CODE_ALPHA3 = @p_currency
          )
          AND t.TRANSFER_TIME > (NULL)
          AND t.TRANSFER_TIME <= (NULL)
          AND g.ACCOUNT_GROUP_TYPE IN ( 'C', 'D' ) /* account_group is business*/
    ORDER BY t.TRANSFER_ID;
END;
GO
