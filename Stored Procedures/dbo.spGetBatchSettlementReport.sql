SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ================================================================================
--  Author:			Neil
--  Create date:	10/10/2019
--  Description:
--     Returns the settlement batch report for a selected merchant account based on 
--     the trading account (account type 0) associated with the merchant account
--
--  Return:			
--      The selected page of batches, or an empty recordset
--
--  Change history
--		10/10/2019	- NM		- First version.
--		06/11/2019	- MA		- added currency, bid and mid into return type
--		20/02/2020	- Greg		- Release 18 support
--		10/03/2020	- Greg		- Fixes for pending batches 
--
-- ================================================================================
CREATE  PROCEDURE [dbo].[spGetBatchSettlementReport]
(
    @batchId NUMERIC = NULL,
	@maturityDateStart DATETIME2(6) = NULL,
    @maturityDateEnd DATETIME2(6) = NULL,
    @status NVARCHAR(2000) = NULL,
    @accountId NUMERIC = NULL,
	@pageNumber INT=1,
    @pageSize INT=20
)

AS
BEGIN
	SET NOCOUNT ON
	 DECLARE @totalCount INT = 0;

	--Get the total count
	IF @Status = 'Open'
    BEGIN
		SELECT @totalCount = COUNT(*) FROM(
			SELECT MATURITY_TRANSACTION_ID
			FROM dbo.ACC_TRANSFERS t
			JOIN dbo.ACC_ACCOUNTS AS a ON t.ACCOUNT_ID=a.ACCOUNT_ID
			JOIN dbo.ACC_ACCOUNT_GROUPS AS ag ON ag.ACCOUNT_GROUP_ID=a.ACCOUNT_GROUP_ID
			WHERE t.ACCOUNT_ID = @AccountId
			  AND t.MATURITY_TIME IS NOT NULL
			  AND t.MATURITY_TRANSACTION_ID IS NULL
			  AND 
			  (
				  @maturityDateStart IS NULL OR CAST(t.MATURITY_TIME AS DATE) >= CAST(@maturityDateStart AS DATE)
			  )
			  AND 
			  (
				  @maturityDateEnd IS NULL OR CAST(t.MATURITY_TIME AS DATE) <= CAST(@maturityDateEnd AS DATE)
			  )
			GROUP BY CONVERT(DATE, t.MATURITY_TIME), t.MATURITY_TRANSACTION_ID, ag.CURRENCY_CODE_ALPHA3,ag.OWNER_ID,ag.LEGACY_SOURCE_ID
		) as c
    END;

    IF @Status = 'Closed'
    BEGIN
		SELECT @totalCount = COUNT(*) FROM(
			SELECT MATURITY_TRANSACTION_ID
			FROM dbo.ACC_TRANSFERS t 
			JOIN dbo.ACC_ACCOUNTS AS a ON t.ACCOUNT_ID=a.ACCOUNT_ID
			JOIN dbo.ACC_ACCOUNT_GROUPS AS ag ON ag.ACCOUNT_GROUP_ID=a.ACCOUNT_GROUP_ID
			JOIN dbo.ACC_TRANSACTIONS tr ON t.MATURITY_TRANSACTION_ID = tr.TRANSACTION_ID
			WHERE t.ACCOUNT_ID = @AccountId
			  AND t.MATURITY_TRANSACTION_ID IS NOT NULL
			  AND 
			  (
				  @maturityDateStart IS NULL OR CAST(tr.TRANSACTION_TIME AS DATE) >= CAST(@maturityDateStart AS DATE)
			  )
			  AND 
			  (
				  @maturityDateEnd IS NULL OR CAST(tr.TRANSACTION_TIME AS DATE) <= CAST(@maturityDateEnd AS DATE)
			  )
			GROUP BY t.MATURITY_TRANSACTION_ID, t.ACCOUNT_ID, CONVERT(DATE, t.MATURITY_TIME),ag.CURRENCY_CODE_ALPHA3,ag.OWNER_ID,ag.LEGACY_SOURCE_ID
		) as c
    END;

    IF @Status IS NULL
    BEGIN
		SELECT @totalCount = COUNT(*) FROM(
			SELECT t.MATURITY_TRANSACTION_ID
			FROM dbo.ACC_TRANSFERS t
			JOIN dbo.ACC_ACCOUNTS AS a ON t.ACCOUNT_ID=a.ACCOUNT_ID
			JOIN dbo.ACC_ACCOUNT_GROUPS AS ag ON ag.ACCOUNT_GROUP_ID=a.ACCOUNT_GROUP_ID
			LEFT OUTER JOIN dbo.ACC_TRANSACTIONS tr ON t.MATURITY_TRANSACTION_ID = tr.TRANSACTION_ID
			WHERE t.ACCOUNT_ID = @AccountId
			  AND t.MATURITY_TIME IS NOT NULL
			  AND 
			  (
				  @maturityDateStart IS NULL OR ISNULL(tr.TRANSACTION_TIME, t.MATURITY_TIME) >= CAST(@maturityDateStart AS DATE)
			  )
			  AND 
			  (
				  @maturityDateEnd IS NULL OR ISNULL(tr.TRANSACTION_TIME, t.MATURITY_TIME) <= CAST(@maturityDateEnd AS DATE)
			  )
			GROUP BY CONVERT(DATE, t.MATURITY_TIME), t.ACCOUNT_ID, t.MATURITY_TRANSACTION_ID,ag.CURRENCY_CODE_ALPHA3,ag.OWNER_ID,ag.LEGACY_SOURCE_ID
		) as c;
    END;

	--Get the rows
	IF @Status = 'Open'
    BEGIN
        SELECT 
			CONVERT(DATE, t.MATURITY_TIME) AS 'MaturityDate',
			CASE WHEN t.MATURITY_TRANSACTION_ID IS NULL THEN 'Open' ELSE 'Closed' END AS 'Status',
			ISNULL(SUM(t.AMOUNT_MINOR_UNITS), 0) AS 'BatchBalance',
			ag.CURRENCY_CODE_ALPHA3 AS Currency,
			ag.OWNER_ID as BusinessId,
			ag.LEGACY_SOURCE_ID as MerchantId
		FROM dbo.ACC_TRANSFERS t
		JOIN dbo.ACC_ACCOUNTS AS a ON t.ACCOUNT_ID=a.ACCOUNT_ID
		JOIN dbo.ACC_ACCOUNT_GROUPS AS ag ON ag.ACCOUNT_GROUP_ID=a.ACCOUNT_GROUP_ID
        WHERE t.ACCOUNT_ID = @AccountId
          AND t.MATURITY_TIME IS NOT NULL
          AND t.MATURITY_TRANSACTION_ID IS NULL
          AND 
		  (
              @maturityDateStart IS NULL OR CAST(t.MATURITY_TIME AS DATE) >= CAST(@maturityDateStart AS DATE)
          )
          AND 
		  (
              @maturityDateEnd IS NULL OR CAST(t.MATURITY_TIME AS DATE) <= CAST(@maturityDateEnd AS DATE)
          )
		GROUP BY CONVERT(DATE, t.MATURITY_TIME), t.MATURITY_TRANSACTION_ID, ag.CURRENCY_CODE_ALPHA3,ag.OWNER_ID,ag.LEGACY_SOURCE_ID
		ORDER BY t.MATURITY_TRANSACTION_ID ASC OFFSET [dbo].[fsPaginationOffSetValue](@pageNumber, @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY;
    END;

    IF @Status = 'Closed'
    BEGIN
        SELECT 
			t.MATURITY_TRANSACTION_ID AS 'BatchId',
			CONVERT(DATE, t.MATURITY_TIME) AS 'MaturityDate',
			CASE WHEN t.MATURITY_TRANSACTION_ID IS NULL THEN 'Open' ELSE 'Closed' END AS 'Status',
			ISNULL(SUM(t.AMOUNT_MINOR_UNITS), 0) AS 'BatchBalance',
			ag.CURRENCY_CODE_ALPHA3 AS Currency,
			ag.OWNER_ID as BusinessId,
			ag.LEGACY_SOURCE_ID as MerchantId
        FROM dbo.ACC_TRANSFERS t
		JOIN dbo.ACC_ACCOUNTS AS a ON t.ACCOUNT_ID=a.ACCOUNT_ID
		JOIN dbo.ACC_ACCOUNT_GROUPS AS ag ON ag.ACCOUNT_GROUP_ID=a.ACCOUNT_GROUP_ID
		JOIN dbo.ACC_TRANSACTIONS tr ON t.MATURITY_TRANSACTION_ID = tr.TRANSACTION_ID
        WHERE t.ACCOUNT_ID = @AccountId
          AND t.MATURITY_TRANSACTION_ID IS NOT NULL
          AND 
		  (
              @maturityDateStart IS NULL OR CAST(tr.TRANSACTION_TIME AS DATE) >= CAST(@maturityDateStart AS DATE)
          )
          AND 
		  (
              @maturityDateEnd IS NULL OR CAST(tr.TRANSACTION_TIME AS DATE) <= CAST(@maturityDateEnd AS DATE)
          )
		GROUP BY t.MATURITY_TRANSACTION_ID, t.ACCOUNT_ID, CONVERT(DATE, t.MATURITY_TIME),ag.CURRENCY_CODE_ALPHA3,ag.OWNER_ID,ag.LEGACY_SOURCE_ID
		ORDER BY t.MATURITY_TRANSACTION_ID ASC OFFSET [dbo].[fsPaginationOffSetValue](@pageNumber, @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY;
    END;

    IF @Status IS NULL
    BEGIN
        SELECT 
			t.MATURITY_TRANSACTION_ID AS 'BatchId',
			CONVERT(DATE, t.MATURITY_TIME) AS 'MaturityDate',
			CASE WHEN t.MATURITY_TRANSACTION_ID IS NULL THEN 'Open' ELSE 'Closed' END AS 'Status',
			ISNULL(SUM(t.AMOUNT_MINOR_UNITS), 0) AS 'BatchBalance',
			ag.CURRENCY_CODE_ALPHA3 AS Currency,
			ag.OWNER_ID as BusinessId,
			ag.LEGACY_SOURCE_ID as MerchantId
        FROM dbo.ACC_TRANSFERS t
		JOIN dbo.ACC_ACCOUNTS AS a ON t.ACCOUNT_ID=a.ACCOUNT_ID
		JOIN dbo.ACC_ACCOUNT_GROUPS AS ag ON ag.ACCOUNT_GROUP_ID=a.ACCOUNT_GROUP_ID
		LEFT OUTER JOIN dbo.ACC_TRANSACTIONS tr ON t.MATURITY_TRANSACTION_ID = tr.TRANSACTION_ID
        WHERE t.ACCOUNT_ID = @AccountId
          AND t.MATURITY_TIME IS NOT NULL
		  AND 
		  (
              @maturityDateStart IS NULL OR ISNULL(tr.TRANSACTION_TIME, t.MATURITY_TIME) >= CAST(@maturityDateStart AS DATE)
          )
          AND 
		  (
              @maturityDateEnd IS NULL OR ISNULL(tr.TRANSACTION_TIME, t.MATURITY_TIME) <= CAST(@maturityDateEnd AS DATE)
          )
		GROUP BY CONVERT(DATE, t.MATURITY_TIME), t.ACCOUNT_ID, t.MATURITY_TRANSACTION_ID,ag.CURRENCY_CODE_ALPHA3,ag.OWNER_ID,ag.LEGACY_SOURCE_ID
		ORDER BY t.MATURITY_TRANSACTION_ID ASC OFFSET [dbo].[fsPaginationOffSetValue](@pageNumber, @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY;
    END;
	
	-- Return search metrics in second result set

	SELECT
		@pageSize AS ResultsPerPage,
        @pageNumber AS PageNumber,
        @totalCount AS TotalCount;
END;
GO
GRANT EXECUTE ON  [dbo].[spGetBatchSettlementReport] TO [DataServiceUser]
GO
