SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ================================================================================
--  Author:			Mark
--  Create date:	09/10/2019
--  Description:
--     Returns transfers between merchant account groups. This is a slightly modified
--		version of TRANSFER_STATEMENT that adds pagination and renames a number of 
--		parameters and response properties
--
--  Return:			
--      The selected page of transfer data, or an empty recordset
--
--  Change history
--		09/10/2019	- MA		- First version
--
-- ================================================================================
CREATE   PROCEDURE [dbo].[spGetMagTransfers]
    @startDate DATETIME2(6) = null,
    @endDate DATETIME2(6) = null,
    @transferTypeId NUMERIC = null,
    @fromAmount NUMERIC = null,
    @toAmount NUMERIC = null,
    @transferId NUMERIC = null, -- TAKE CARE! this is TRANSACTION_ID on DB, and TRANSFER_ID is just a row index on DB.
    @description NVARCHAR(2000) = null,
    @orderReference NVARCHAR(2000) = null, -- AKA CARD_ID
    @p_source_ref NVARCHAR(2000) = null, -- TODO ... this isn't exposed on the AMS UI, and don't know what it means or if it is important
    @accountId NUMERIC,
	@pageNumber int=1,
    @pageSize int=20
AS
BEGIN
    -- And Awesome piece of SQL Query overloading!  At some point we'll need ot break this into separate queries.
    -- Probably the most frequently run query in AMS, so needs to be fast and non-locking.
    --    The vast majority of the time only a fixed subset of input parameters are provided.
    --    Three queries are provided below. The first two are optimised for common sets of input parameters and run considerably faster than the general purpose query, which appears last.


    -- CLean up parameters
    IF @startDate IS NULL
        SET @startDate = CAST(DATEADD(YEAR, -2, GETUTCDATE()) AS DATE);
    IF @endDate IS NULL
        SET @endDate = CAST(DATEADD(DAY, 1, GETUTCDATE()) AS DATE);
    IF @fromAmount IS NOT NULL
       AND @toAmount IS NULL
        SET @toAmount = @fromAmount;
    IF @toAmount IS NOT NULL
       AND @fromAmount IS NULL
        SET @fromAmount = @toAmount;

    -- Start by selecting at the most general level.  We'll then join tables and delete as necessary.
    CREATE TABLE #ResultSet
    (
        [TRANSFER_ID] [BIGINT] NOT NULL PRIMARY KEY CLUSTERED,
        [TRANSFER_TYPE_ID] [BIGINT] NOT NULL,
        [AMOUNT_MINOR_UNITS] [BIGINT] NOT NULL,
        [BATCH_ID] [BIGINT] NULL,
        [TRANSACTION_ID] [BIGINT] NOT NULL,
        [TRANSFER_METHOD_ID] [BIGINT] NOT NULL
    );

    INSERT INTO #ResultSet
    SELECT TRANSFER_ID,
           TRANSFER_TYPE_ID,
           ABS(AMOUNT_MINOR_UNITS),
           BATCH_ID,
           TRANSACTION_ID,
           TRANSFER_METHOD_ID
    FROM dbo.ACC_TRANSFERS
    WHERE ACCOUNT_ID = @accountId
          AND TRANSFER_TIME
          BETWEEN @startDate AND @endDate;

    -- Now select dwon the transaction list by parameter
    IF @transferId IS NOT NULL
        DELETE FROM #ResultSet
        WHERE TRANSACTION_ID <> @transferId;
    IF @transferTypeId IS NOT NULL
        DELETE FROM #ResultSet
        WHERE TRANSFER_TYPE_ID <> @transferTypeId;
    IF @fromAmount IS NOT NULL
        DELETE FROM #ResultSet
        WHERE AMOUNT_MINOR_UNITS < @fromAmount
              OR AMOUNT_MINOR_UNITS > @toAmount;


    -- Now look in related tables via key lookup and delete as appropriate - Nasty non-index scans last
    IF @p_source_ref IS NOT NULL
        DELETE FROM #ResultSet
        WHERE TRANSACTION_ID NOT IN
              (
                  SELECT a.TRANSACTION_ID
                  FROM ACC_TRANSACTIONS a
                      INNER JOIN #ResultSet r
                          ON a.TRANSACTION_ID = r.TRANSACTION_ID
                  WHERE a.SOURCE_REF = @p_source_ref
              );

    IF @orderReference IS NOT NULL
        DELETE FROM #ResultSet
        WHERE TRANSACTION_ID NOT IN
              (
                  SELECT a.TRANSACTION_ID
                  FROM ACC_SALE_DETAILS a
                      INNER JOIN #ResultSet r
                          ON a.TRANSACTION_ID = r.TRANSACTION_ID
                  WHERE a.CART_ID LIKE '%' + @orderReference + '%'
              );

    IF @description IS NOT NULL
        DELETE FROM #ResultSet
        WHERE TRANSACTION_ID NOT IN
              (
                  SELECT a.TRANSACTION_ID
                  FROM ACC_TRANSACTIONS a
                      INNER JOIN #ResultSet r
                          ON a.TRANSACTION_ID = r.TRANSACTION_ID
                  WHERE a.DESCRIPTION LIKE '%' + @description + '%'
              );

	-- We need a total count of rows for the pagination
	DECLARE @totalCount INT;
    SELECT @totalCount = COUNT(*) FROM #ResultSet;

    SELECT 
           t.AMOUNT_MINOR_UNITS AS Amount,
           t.BALANCE_AFTER_MINOR_UNITS AS Balance,
           t.BATCH_ID AS BatchId,
           s.CART_ID AS OrderReference,
           x.DESCRIPTION AS [Description],
           b.MATURED_TIME AS MaturityDate,
           tt.DESCRIPTION AS TransferTypeName,
           t.TRANSACTION_ID AS TransferId,
           ISNULL(xx.SOURCE_REF, CAST(ag.LEGACY_SOURCE_ID AS NVARCHAR(200))) AS MerchantId,
		   ag.OWNER_ID AS BusinessId,
           t.TRANSFER_TIME AS TransferDate,
           a.ACCOUNT_TYPE_ID AS Account,
           tt.TRANSFER_TYPE_ID AS TransferTypeId,
           tm.TRANSFER_METHOD_ID AS TransferMethodId,
           tm.DESCRIPTION AS TransferMethodName,
           xx.TRANSACTION_ID AS ParentTransferId,
           xx.EXTERNAL_REF AS ParentTransactionId,
           ag.CURRENCY_CODE_ALPHA3 AS Currency
    FROM #ResultSet r
        INNER JOIN dbo.ACC_TRANSFERS t WITH (NOLOCK)
            ON r.TRANSFER_ID = t.TRANSFER_ID
        LEFT JOIN dbo.ACC_TRANSACTIONS x WITH (NOLOCK)
            ON x.TRANSACTION_ID = t.TRANSACTION_ID
        LEFT JOIN dbo.ACC_TRANSACTIONS xx WITH (NOLOCK)
            ON x.TXN_FIRST_ID = xx.TRANSACTION_ID
        LEFT OUTER JOIN dbo.ACC_SALE_DETAILS s WITH (NOLOCK)
            ON s.TRANSACTION_ID = t.TRANSACTION_ID
        LEFT OUTER JOIN dbo.ACC_BATCHES b WITH (NOLOCK)
            ON b.BATCH_ID = t.BATCH_ID
        LEFT JOIN dbo.ACC_TRANSFER_TYPES tt WITH (NOLOCK)
            ON tt.TRANSFER_TYPE_ID = t.TRANSFER_TYPE_ID
        LEFT JOIN dbo.ACC_TRANSFER_METHODS tm WITH (NOLOCK)
            ON tm.TRANSFER_METHOD_ID = t.TRANSFER_METHOD_ID
        LEFT JOIN dbo.ACC_ACCOUNTS a WITH (NOLOCK)
            ON a.ACCOUNT_ID = t.ACCOUNT_ID
        LEFT JOIN dbo.ACC_ACCOUNT_GROUPS ag WITH (NOLOCK)
            ON ag.ACCOUNT_GROUP_ID = a.ACCOUNT_GROUP_ID
    ORDER BY t.TRANSACTION_ID ASC OFFSET [dbo].[fsPaginationOffSetValue](@pageNumber, @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY;

	-- Return search metrics in second result set
	SELECT
		@pageSize AS ResultsPerPage,
        @pageNumber AS PageNumber,
        @totalCount AS TotalCount

	IF OBJECT_ID('tempdb..#ResultSet') IS NOT NULL
		DROP TABLE #ResultSet
END;
GO
GRANT EXECUTE ON  [dbo].[spGetMagTransfers] TO [DataServiceUser]
GO
