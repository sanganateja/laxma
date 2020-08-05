SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_finance_acc_transactions]
    @p_recordset VARCHAR(2000) OUTPUT,
    @p_dateTimeFrom DATETIME2(6),
    @p_dateTimeTo DATETIME2(6)
AS
BEGIN
    SET NOCOUNT ON;

    SET @p_recordset = NULL;

    DECLARE @ACCG AS TABLE
    (
        ACCOUNT_GROUP_ID BIGINT NOT NULL
    );
    DECLARE @TX AS TABLE
    (
        TRANSACTION_ID BIGINT NOT NULL
    );

    INSERT INTO @ACCG
    SELECT ACCOUNT_GROUP_ID
    FROM ACC_ACCOUNT_GROUPS WITH (NOLOCK)
    WHERE ACCOUNT_GROUP_TYPE IN ( 'C', 'D' );

    INSERT INTO @TX
    SELECT TRANSACTION_ID
    FROM ACC_TRANSACTIONS t WITH (NOLOCK)
        INNER JOIN @ACCG a
            ON t.ACCOUNT_GROUP_ID = a.ACCOUNT_GROUP_ID
    WHERE TXN_GROUP_ID IS NOT NULL;

    SELECT t.TRANSACTION_ID,
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
           CAST(t.BALANCE_AFTER_MINOR_UNITS AS FLOAT(53)) / POWER(10, c.DECIMAL_PLACES) AS balance_after,
           ISNULL(pmo.MESSAGE_TRANSACTION_ID, pmi.MESSAGE_TRANSACTION_ID) AS payment_msg_transaction_id,
           ISNULL(pmo.END_TO_END_ID, pmi.END_TO_END_ID) AS payment_msg_end_to_end_id
    FROM ACC_TRANSFERS t WITH (NOLOCK)
        INNER JOIN ACC_TRANSACTIONS AS tr WITH (NOLOCK)
            ON t.TRANSACTION_ID = tr.TRANSACTION_ID
        JOIN dbo.ACC_ACCOUNTS AS a
            ON t.ACCOUNT_ID = a.ACCOUNT_ID
        JOIN dbo.ACC_ACCOUNT_TYPES AS AT
            ON a.ACCOUNT_TYPE_ID = AT.ACCOUNT_TYPE_ID
        JOIN dbo.ACC_ACCOUNT_GROUPS AS g
            ON a.ACCOUNT_GROUP_ID = g.ACCOUNT_GROUP_ID
        JOIN dbo.ACC_CURRENCIES AS c
            ON g.CURRENCY_CODE_ALPHA3 = c.CURRENCY_CODE_ALPHA3
        JOIN dbo.ACC_OWNERS AS o
            ON g.OWNER_ID = o.OWNER_ID
        JOIN dbo.ACC_TRANSFER_TYPES AS tt
            ON t.TRANSFER_TYPE_ID = tt.TRANSFER_TYPE_ID
        JOIN dbo.ACC_TRANSFER_METHODS AS m
            ON t.TRANSFER_METHOD_ID = m.TRANSFER_METHOD_ID
        LEFT OUTER JOIN dbo.ACC_PAYMENT_MESSAGES_OUT AS pmo
            ON t.TRANSACTION_ID = pmo.TRANSACTION_ID
        LEFT OUTER JOIN dbo.ACC_PAYMENT_MESSAGES_IN AS pmi
            ON t.TRANSACTION_ID = pmi.TRANSACTION_ID
    WHERE AT.ACCOUNT_TYPE_ID = 9
          AND
          (
              t.TRANSFER_TYPE_ID IN ( 24, 27, 28, 36, 38, 42, 43, 45, 46, 47 )
              OR
              (
                  t.TRANSFER_TYPE_ID = 40
                  AND t.TRANSFER_ID IN
                      (
                          SELECT TRANSFER_ID
                          FROM ACC_TRANSFERS tf
                              INNER JOIN @TX t
                                  ON tf.TRANSACTION_ID = t.TRANSACTION_ID
                      )
              )
          )
          AND t.TRANSFER_TIME > @p_dateTimeFrom
          AND t.TRANSFER_TIME < DATEADD(day,1,@p_dateTimeTo)
          AND g.ACCOUNT_GROUP_TYPE IN ( 'C', 'D' )
    ORDER BY g.CURRENCY_CODE_ALPHA3,
             o.EXTERNAL_REF,
             t.TRANSFER_TIME;
END;
GO
