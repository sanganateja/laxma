SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[TRANSFER_STATEMENT]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_start_date DATETIME2(6),
    @p_end_date DATETIME2(6),
    @p_transfer_type_id NUMERIC,
    @p_from_amount NUMERIC,
    @p_to_amount NUMERIC,
    @p_transaction_id NUMERIC,
    @p_description NVARCHAR(2000),
    @p_cart_id NVARCHAR(2000),
    @p_source_ref NVARCHAR(2000),
    @p_account_id NUMERIC
AS
BEGIN
    -- And Awesome piece of SQL Query overloading!  At some point we'll need ot break this into separate queries.
    -- Probably the most frequently run query in AMS, so needs to be fast and non-locking.
    --    The vast majority of the time only a fixed subset of input parameters are provided.
    --    Three queries are provided below. The first two are optimised for common sets of input parameters and run considerably faster than the general purpose query, which appears last.

    SET @cv_1 = NULL;

    -- CLean up parameters
    IF @p_start_date IS NULL
        SET @p_start_date = CAST(DATEADD(YEAR, -2, GETUTCDATE()) AS DATE);
    IF @p_end_date IS NULL
        SET @p_end_date = CAST(DATEADD(DAY, 1, GETUTCDATE()) AS DATE);
    IF @p_from_amount IS NOT NULL
       AND @p_to_amount IS NULL
        SET @p_to_amount = @p_from_amount;
    IF @p_to_amount IS NOT NULL
       AND @p_from_amount IS NULL
        SET @p_from_amount = @p_to_amount;

    -- Start by selecting at the most general level.  We'll then join tables and delete as necessary.
    DECLARE @ResultSet AS TABLE
    (
        [TRANSFER_ID] [BIGINT] NOT NULL PRIMARY KEY CLUSTERED,
        [TRANSFER_TYPE_ID] [BIGINT] NOT NULL,
        [AMOUNT_MINOR_UNITS] [BIGINT] NOT NULL,
        [TRANSACTION_ID] [BIGINT] NOT NULL,
        [TRANSFER_METHOD_ID] [BIGINT] NOT NULL
    );

    INSERT INTO @ResultSet
    SELECT TRANSFER_ID,
           TRANSFER_TYPE_ID,
           ABS(AMOUNT_MINOR_UNITS),
           TRANSACTION_ID,
           TRANSFER_METHOD_ID
    FROM dbo.ACC_TRANSFERS
    WHERE ACCOUNT_ID = @p_account_id
          AND TRANSFER_TIME
          BETWEEN @p_start_date AND @p_end_date;

    -- Now select dwon the transaction list by parameter
    IF @p_transaction_id IS NOT NULL
        DELETE FROM @ResultSet
        WHERE TRANSACTION_ID <> @p_transaction_id;
    IF @p_transfer_type_id IS NOT NULL
        DELETE FROM @ResultSet
        WHERE TRANSFER_TYPE_ID <> @p_transfer_type_id;
    IF @p_from_amount IS NOT NULL
        DELETE FROM @ResultSet
        WHERE AMOUNT_MINOR_UNITS < @p_from_amount
              OR AMOUNT_MINOR_UNITS > @p_to_amount;


    -- Now look in related tables via key lookup and delete as appropriate - Nasty non-index scans last
    IF @p_source_ref IS NOT NULL
        DELETE FROM @ResultSet
        WHERE TRANSACTION_ID NOT IN
              (
                  SELECT a.TRANSACTION_ID
                  FROM ACC_TRANSACTIONS a
                      INNER JOIN @ResultSet r
                          ON a.TRANSACTION_ID = r.TRANSACTION_ID
                  WHERE a.SOURCE_REF = @p_source_ref
              );

    IF @p_cart_id IS NOT NULL
        DELETE FROM @ResultSet
        WHERE TRANSACTION_ID NOT IN
              (
                  SELECT a.TRANSACTION_ID
                  FROM ACC_SALE_DETAILS a
                      INNER JOIN @ResultSet r
                          ON a.TRANSACTION_ID = r.TRANSACTION_ID
                  WHERE a.CART_ID LIKE '%' + @p_cart_id + '%'
              );

    IF @p_description IS NOT NULL
        DELETE FROM @ResultSet
        WHERE TRANSACTION_ID NOT IN
              (
                  SELECT a.TRANSACTION_ID
                  FROM ACC_TRANSACTIONS a
                      INNER JOIN @ResultSet r
                          ON a.TRANSACTION_ID = r.TRANSACTION_ID
                  WHERE a.DESCRIPTION LIKE '%' + @p_description + '%'
              );

    SELECT t.TRANSFER_ID,
           t.AMOUNT_MINOR_UNITS,
           t.BALANCE_AFTER_MINOR_UNITS,
           s.CART_ID,
           x.DESCRIPTION,
           t.MATURITY_TIME,
           xxx.TRANSACTION_TIME AS MATURED_TIME,
           tt.NAME,
           t.TRANSACTION_ID,
           ISNULL(xx.SOURCE_REF, CAST(ag.LEGACY_SOURCE_ID AS NVARCHAR(200))) AS PROFILE_ID,
           t.TRANSFER_TIME,
           a.ACCOUNT_TYPE_ID,
           tt.TRANSFER_TYPE_ID,
           tm.TRANSFER_METHOD_ID,
           tm.DESCRIPTION AS TRANSFER_METHOD_NAME,
           xx.TRANSACTION_ID AS FIRST_TXN_ID,
           xx.EXTERNAL_REF AS FIRST_TXN_EXTERNAL_REF,
           ag.CURRENCY_CODE_ALPHA3
    FROM @ResultSet r
        INNER JOIN dbo.ACC_TRANSFERS t WITH (NOLOCK)
            ON r.TRANSFER_ID = t.TRANSFER_ID
        LEFT JOIN dbo.ACC_TRANSACTIONS x WITH (NOLOCK)
            ON x.TRANSACTION_ID = t.TRANSACTION_ID
        LEFT JOIN dbo.ACC_TRANSACTIONS xx WITH (NOLOCK)
            ON x.TXN_FIRST_ID = xx.TRANSACTION_ID
        LEFT OUTER JOIN dbo.ACC_TRANSACTIONS xxx WITH (NOLOCK)
            ON t.MATURITY_TRANSACTION_ID = xxx.TRANSACTION_ID
        LEFT OUTER JOIN dbo.ACC_SALE_DETAILS s WITH (NOLOCK)
            ON s.TRANSACTION_ID = t.TRANSACTION_ID
        LEFT JOIN dbo.ACC_TRANSFER_TYPES tt WITH (NOLOCK)
            ON tt.TRANSFER_TYPE_ID = t.TRANSFER_TYPE_ID
        LEFT JOIN dbo.ACC_TRANSFER_METHODS tm WITH (NOLOCK)
            ON tm.TRANSFER_METHOD_ID = t.TRANSFER_METHOD_ID
        LEFT JOIN dbo.ACC_ACCOUNTS a WITH (NOLOCK)
            ON a.ACCOUNT_ID = t.ACCOUNT_ID
        LEFT JOIN dbo.ACC_ACCOUNT_GROUPS ag WITH (NOLOCK)
            ON ag.ACCOUNT_GROUP_ID = a.ACCOUNT_GROUP_ID
    ORDER BY t.TRANSFER_ID;

END;
GO
