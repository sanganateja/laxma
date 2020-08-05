SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ================================================================================
--  Author:			NM
--  Create date:	11/10/2019
--  Description:
--     Returns transfers for the cost account associated with a merchant account. 
--     This is a slightly modified version of COST_STATEMET that adds pagination 
--     and renames a number of parameters and response properties
--
--  Return:			
--      The selected page of transfer data, or an empty recordset
--
--  Change history
--		11/10/2019	- NM		- First version
--		22/10/2019	- MA		- Added currency and business id, for consistency with MAG transfers data
--		04/11/2019	- MA		- added joins to account_group to bring back legacy_source_id (for merchantId) when transfers source_ref is null
--
-- ================================================================================
CREATE PROCEDURE [dbo].[spGetCostStatement]
(
    @startDate DATETIME2(6)=NULL,
    @endDate DATETIME2(6)=NULL,
    @transferTypeId NUMERIC=NULL,
    @fromAmount NUMERIC=NULL, -- Amount in minor units
    @toAmount NUMERIC=NULL, -- Amount in minor units
    @transferID NUMERIC=NULL, -- This is the transaction_id
    @description NVARCHAR(2000)=NULL,
    @orderReference NVARCHAR(2000)=NULL, -- This is the Card ID
    @merchantID NVARCHAR(2000)=NULL, -- This is the Source Ref aka Prolfile ID
    @accountId NUMERIC=NULL, -- This is the Costs account (type 1) associated with the MAG
	@pageNumber INT=1,
    @pageSize INT=20
)
AS
BEGIN

	SET NOCOUNT ON

	DECLARE @totalCount INT = 0;

	SET @startDate = ISNULL(@startDate, CAST(DATEADD(dd , -3, cast (GETDATE() AS DATE)) AS DATETIME))
	SET @endDate = ISNULL(@endDate, CAST(DATEADD(dd , 1, cast (GETDATE() AS DATE)) AS DATETIME))



    IF (
           (@Description IS NULL)
           AND (@orderReference IS NULL)
           AND (@transferID IS NULL)
           AND (@toAmount IS NULL)
           AND (@fromAmount IS NULL)
           AND (@transferTypeId IS NULL)
           AND (@merchantID IS NULL)
       )
    BEGIN

		SELECT @TotalCount=COUNT(*)
		FROM dbo.ACC_TRANSFERS AS t
        WHERE t.ACCOUNT_ID = @accountId
              AND (t.TRANSFER_TIME
              BETWEEN @startDate AND @endDate
                  )
              AND t.TRANSFER_TYPE_ID IN ( 4, 19, 85 );


        SELECT t.AMOUNT_MINOR_UNITS AS Amount,
               t.BALANCE_AFTER_MINOR_UNITS AS Balance,
               t.BATCH_ID AS BatchId,
               s.CART_ID AS OrderReference,
               x.DESCRIPTION AS [Description],
               tt.DESCRIPTION AS TransferTypeName,
			   ISNULL(xx.SOURCE_REF, CAST(ag.LEGACY_SOURCE_ID AS NVARCHAR(200))) AS MerchantId,
               t.TRANSACTION_ID AS TransferId ,
               t.TRANSFER_TIME AS TransferDate,
               tt.TRANSFER_TYPE_ID AS TransferTypeId,
               xx.TRANSACTION_ID AS ParentTransferId,
               xx.EXTERNAL_REF AS ParentTransactionId,
               x.AMOUNT_MINOR_UNITS AS SaleAmount,
               ds.DESCRIPTION AS CostTypeName,
               CEILING(tc1.VARIABLE_AMOUNT_MINOR_UNITS) AS InterchangeVariableAmount,
               tc1.FIXED_AMOUNT_MINOR_UNITS AS InterchangeFixedAmount,
               tc1.FIXED_CURRENCY_CODE_ALPHA3 AS InterchangeFixedCurrency,
               tc1.FX_RATE_APPLIED_PRICING AS InterchangeFXRate,
               CEILING(tc2.VARIABLE_AMOUNT_MINOR_UNITS) AS SchemeVariableAmount,
               tc2.FIXED_AMOUNT_MINOR_UNITS AS SchemeFixedAmount,
               tc2.FIXED_CURRENCY_CODE_ALPHA3 AS SchemeFixedCurrency,
               tc2.FX_RATE_APPLIED_PRICING AS SchemeFXRate,
			   ag.CURRENCY_CODE_ALPHA3 AS Currency,
			   ag.OWNER_ID AS BusinessId
        FROM dbo.ACC_TRANSFERS AS t
            LEFT JOIN dbo.ACC_TRANSACTIONS AS x
                LEFT JOIN dbo.ACC_TRANSACTIONS AS xx
                    ON x.TXN_FIRST_ID = xx.TRANSACTION_ID
                ON x.TRANSACTION_ID = t.TRANSACTION_ID
            LEFT OUTER JOIN dbo.ACC_SALE_DETAILS AS s
                ON s.TRANSACTION_ID = t.TRANSACTION_ID
            LEFT JOIN dbo.ACC_TRANSFER_TYPES AS tt
                ON tt.TRANSFER_TYPE_ID = t.TRANSFER_TYPE_ID
            LEFT JOIN dbo.ACC_TRANSACTION_MARGINS AS tmg
                ON t.TRANSACTION_ID = tmg.TRANSACTION_ID
            LEFT JOIN dbo.ACC_TRANSACTION_COSTS AS tc1
                ON t.TRANSACTION_ID = tc1.TRANSACTION_ID
                   AND tc1.TYPE_ID = 2
            LEFT JOIN dbo.CST_DESIGNATORS AS ds
                ON ds.DESIGNATOR_ID = tc1.DESIGNATOR_ID
            LEFT JOIN dbo.ACC_TRANSACTION_COSTS AS tc2
                ON t.TRANSACTION_ID = tc2.TRANSACTION_ID
                   AND tc2.TYPE_ID = 3
			LEFT JOIN dbo.ACC_ACCOUNTS a WITH (NOLOCK)
				ON a.ACCOUNT_ID = t.ACCOUNT_ID
			LEFT JOIN dbo.ACC_ACCOUNT_GROUPS ag WITH (NOLOCK)
				ON ag.ACCOUNT_GROUP_ID = a.ACCOUNT_GROUP_ID
        WHERE t.ACCOUNT_ID = @accountId
              AND (t.TRANSFER_TIME
              BETWEEN @startDate AND @endDate
                  )
              AND t.TRANSFER_TYPE_ID IN ( 4, 19, 85 ) /* MSC, Refund, MSC Void */
        ORDER BY t.TRANSFER_ID ASC OFFSET [dbo].[fsPaginationOffSetValue](@pageNumber, @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY;;



    END;
    ELSE IF (
                (@description IS NULL)
                AND (@orderReference IS NULL)
                AND (@merchantID IS NULL)
                AND (@transferID IS NULL)
            )
    BEGIN

		SELECT @TotalCount=COUNT(*)
		       FROM dbo.ACC_TRANSFERS AS t
        WHERE t.ACCOUNT_ID = @accountId
              AND (t.TRANSFER_TIME
              BETWEEN @startDate AND @endDate
                  )
              AND t.TRANSFER_TYPE_ID = ISNULL(@transferTypeId, t.TRANSFER_TYPE_ID)
              AND t.TRANSFER_TYPE_ID IN ( 4, 19, 85 ) /* MSC, Refund, MSC Void */
              AND ABS(t.AMOUNT_MINOR_UNITS)
              BETWEEN ISNULL(@fromAmount, ABS(t.AMOUNT_MINOR_UNITS)) AND ISNULL(
                                                                                      @toAmount,
                                                                                      ABS(t.AMOUNT_MINOR_UNITS)
                                                                                  );


        SELECT t.AMOUNT_MINOR_UNITS AS Amount,
               t.BALANCE_AFTER_MINOR_UNITS AS Balance,
               t.BATCH_ID AS BatchId,
               s.CART_ID AS OrderReference,
               x.DESCRIPTION AS [Description],
               tt.DESCRIPTION AS TransferTypeName,
   			   ISNULL(xx.SOURCE_REF, CAST(ag.LEGACY_SOURCE_ID AS NVARCHAR(200))) AS MerchantId,
               t.TRANSACTION_ID AS TransferId ,
               t.TRANSFER_TIME AS TransferDate,
               tt.TRANSFER_TYPE_ID AS TransferTypeId,
               xx.TRANSACTION_ID AS ParentTransferId,
               xx.EXTERNAL_REF AS ParentTransactionId,
               x.AMOUNT_MINOR_UNITS AS SaleAmount,
               ds.DESCRIPTION AS CostTypeName,
               CEILING(tc1.VARIABLE_AMOUNT_MINOR_UNITS) AS InterchangeVariableAmount,
               tc1.FIXED_AMOUNT_MINOR_UNITS AS InterchangeFixedAmount,
               tc1.FIXED_CURRENCY_CODE_ALPHA3 AS InterchangeFixedCurrency,
               tc1.FX_RATE_APPLIED_PRICING AS InterchangeFXRate,
               CEILING(tc2.VARIABLE_AMOUNT_MINOR_UNITS) AS SchemeVariableAmount,
               tc2.FIXED_AMOUNT_MINOR_UNITS AS SchemeFixedAmount,
               tc2.FIXED_CURRENCY_CODE_ALPHA3 AS SchemeFixedCurrency,
               tc2.FX_RATE_APPLIED_PRICING AS SchemeFXRate,
			   ag.CURRENCY_CODE_ALPHA3 AS Currency,
			   ag.OWNER_ID AS BusinessId
        FROM dbo.ACC_TRANSFERS AS t
            LEFT JOIN dbo.ACC_TRANSACTIONS AS x
                LEFT JOIN dbo.ACC_TRANSACTIONS AS xx
                    ON x.TXN_FIRST_ID = xx.TRANSACTION_ID
                ON x.TRANSACTION_ID = t.TRANSACTION_ID
            LEFT OUTER JOIN dbo.ACC_SALE_DETAILS AS s
                ON s.TRANSACTION_ID = t.TRANSACTION_ID
            LEFT JOIN dbo.ACC_TRANSFER_TYPES AS tt
                ON tt.TRANSFER_TYPE_ID = t.TRANSFER_TYPE_ID
            LEFT JOIN dbo.ACC_TRANSACTION_MARGINS AS tmg
                ON t.TRANSACTION_ID = tmg.TRANSACTION_ID
            LEFT JOIN dbo.ACC_TRANSACTION_COSTS AS tc1
                ON t.TRANSACTION_ID = tc1.TRANSACTION_ID
                   AND tc1.TYPE_ID = 2
            LEFT JOIN dbo.CST_DESIGNATORS AS ds
                ON ds.DESIGNATOR_ID = tc1.DESIGNATOR_ID
            LEFT JOIN dbo.ACC_TRANSACTION_COSTS AS tc2
                ON t.TRANSACTION_ID = tc2.TRANSACTION_ID
                   AND tc2.TYPE_ID = 3
			LEFT JOIN dbo.ACC_ACCOUNTS a WITH (NOLOCK)
				ON a.ACCOUNT_ID = t.ACCOUNT_ID
			LEFT JOIN dbo.ACC_ACCOUNT_GROUPS ag WITH (NOLOCK)
				ON ag.ACCOUNT_GROUP_ID = a.ACCOUNT_GROUP_ID
        WHERE t.ACCOUNT_ID = @accountId
              AND (t.TRANSFER_TIME
              BETWEEN @startDate AND @endDate
                  )
              AND t.TRANSFER_TYPE_ID = ISNULL(@transferTypeId, t.TRANSFER_TYPE_ID)
              AND t.TRANSFER_TYPE_ID IN ( 4, 19, 85 ) /* MSC, Refund, MSC Void */
              AND ABS(t.AMOUNT_MINOR_UNITS)
              BETWEEN ISNULL(@fromAmount, ABS(t.AMOUNT_MINOR_UNITS)) AND ISNULL(
                                                                                      @toAmount,
                                                                                      ABS(t.AMOUNT_MINOR_UNITS)
                                                                                  )
        ORDER BY t.TRANSFER_ID ASC OFFSET [dbo].[fsPaginationOffSetValue](@pageNumber, @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY;;


    END;
    ELSE
    BEGIN
		
		SELECT @totalCount = COUNT(*)
		        FROM dbo.ACC_TRANSFERS AS t
            LEFT JOIN dbo.ACC_TRANSACTIONS AS x
                LEFT JOIN dbo.ACC_TRANSACTIONS AS xx
                    ON x.TXN_FIRST_ID = xx.TRANSACTION_ID
                ON x.TRANSACTION_ID = t.TRANSACTION_ID
            LEFT OUTER JOIN dbo.ACC_SALE_DETAILS AS s
                ON s.TRANSACTION_ID = t.TRANSACTION_ID
			LEFT JOIN dbo.ACC_ACCOUNTS a WITH (NOLOCK)
				ON a.ACCOUNT_ID = t.ACCOUNT_ID
			LEFT JOIN dbo.ACC_ACCOUNT_GROUPS ag WITH (NOLOCK)
				ON ag.ACCOUNT_GROUP_ID = a.ACCOUNT_GROUP_ID
        WHERE t.ACCOUNT_ID = @accountId
              AND (t.TRANSFER_TIME
              BETWEEN @startDate AND @endDate
                  )
              AND t.TRANSFER_TYPE_ID = ISNULL(@transferTypeId, t.TRANSFER_TYPE_ID)
              AND t.TRANSFER_TYPE_ID IN ( 4, 19, 85 ) /* MSC, Refund, MSC Void */
              AND ABS(t.AMOUNT_MINOR_UNITS)
              BETWEEN ISNULL(@fromAmount, ABS(t.AMOUNT_MINOR_UNITS)) AND ISNULL(
                                                                                      @fromAmount,
                                                                                      ABS(t.AMOUNT_MINOR_UNITS)
                                                                                  )
              AND t.TRANSACTION_ID = ISNULL(@transferID, t.TRANSACTION_ID)
              AND
              (
                  @orderReference IS NULL
                  OR s.CART_ID LIKE '%' + ISNULL(@orderReference, '') + '%'
              )
              AND
              (
                  @merchantID IS NULL
				  OR ISNULL(x.SOURCE_REF, ag.LEGACY_SOURCE_ID) = @merchantID
              )
              AND
              (
                  @description IS NULL
                  OR x.DESCRIPTION LIKE '%' + ISNULL(@description, '') + '%'
              )

        SELECT t.AMOUNT_MINOR_UNITS AS Amount,
               t.BALANCE_AFTER_MINOR_UNITS AS Balance,
               t.BATCH_ID AS BatchId,
               s.CART_ID AS OrderReference,
               x.DESCRIPTION AS [Description],
               tt.DESCRIPTION AS TransferTypeName,
   			   ISNULL(xx.SOURCE_REF, CAST(ag.LEGACY_SOURCE_ID AS NVARCHAR(200))) AS MerchantId,
               t.TRANSACTION_ID AS TransferId ,
               t.TRANSFER_TIME AS TransferDate,
               tt.TRANSFER_TYPE_ID AS TransferTypeId,
               xx.TRANSACTION_ID AS ParentTransferId,
               xx.EXTERNAL_REF AS ParentTransactionId,
               x.AMOUNT_MINOR_UNITS AS SaleAmount,
               ds.DESCRIPTION AS CostTypeName,
               CEILING(tc1.VARIABLE_AMOUNT_MINOR_UNITS) AS InterchangeVariableAmount,
               tc1.FIXED_AMOUNT_MINOR_UNITS AS InterchangeFixedAmount,
               tc1.FIXED_CURRENCY_CODE_ALPHA3 AS InterchangeFixedCurrency,
               tc1.FX_RATE_APPLIED_PRICING AS InterchangeFXRate,
               CEILING(tc2.VARIABLE_AMOUNT_MINOR_UNITS) AS SchemeVariableAmount,
               tc2.FIXED_AMOUNT_MINOR_UNITS AS SchemeFixedAmount,
               tc2.FIXED_CURRENCY_CODE_ALPHA3 AS SchemeFixedCurrency,
               tc2.FX_RATE_APPLIED_PRICING AS SchemeFXRate,
			   ag.CURRENCY_CODE_ALPHA3 AS Currency,
			   ag.OWNER_ID AS BusinessId
        FROM dbo.ACC_TRANSFERS AS t
            LEFT JOIN dbo.ACC_TRANSACTIONS AS x
                LEFT JOIN dbo.ACC_TRANSACTIONS AS xx
                    ON x.TXN_FIRST_ID = xx.TRANSACTION_ID
                ON x.TRANSACTION_ID = t.TRANSACTION_ID
            LEFT OUTER JOIN dbo.ACC_SALE_DETAILS AS s
                ON s.TRANSACTION_ID = t.TRANSACTION_ID
            LEFT JOIN dbo.ACC_TRANSFER_TYPES AS tt
                ON tt.TRANSFER_TYPE_ID = t.TRANSFER_TYPE_ID
            LEFT JOIN dbo.ACC_TRANSACTION_MARGINS AS tmg
                ON t.TRANSACTION_ID = tmg.TRANSACTION_ID
            LEFT JOIN dbo.ACC_TRANSACTION_COSTS AS tc1
                ON t.TRANSACTION_ID = tc1.TRANSACTION_ID
                   AND tc1.TYPE_ID = 2
            LEFT JOIN dbo.CST_DESIGNATORS AS ds
                ON ds.DESIGNATOR_ID = tc1.DESIGNATOR_ID
            LEFT JOIN dbo.ACC_TRANSACTION_COSTS AS tc2
                ON t.TRANSACTION_ID = tc2.TRANSACTION_ID
                   AND tc2.TYPE_ID = 3
			LEFT JOIN dbo.ACC_ACCOUNTS a WITH (NOLOCK)
				ON a.ACCOUNT_ID = t.ACCOUNT_ID
			LEFT JOIN dbo.ACC_ACCOUNT_GROUPS ag WITH (NOLOCK)
				ON ag.ACCOUNT_GROUP_ID = a.ACCOUNT_GROUP_ID
        WHERE t.ACCOUNT_ID = @accountId
              AND (t.TRANSFER_TIME
              BETWEEN @startDate AND @endDate
                  )
              AND t.TRANSFER_TYPE_ID = ISNULL(@transferTypeId, t.TRANSFER_TYPE_ID)
              AND t.TRANSFER_TYPE_ID IN ( 4, 19, 85 ) /* MSC, Refund, MSC Void */
              AND ABS(t.AMOUNT_MINOR_UNITS)
              BETWEEN ISNULL(@fromAmount, ABS(t.AMOUNT_MINOR_UNITS)) AND ISNULL(
                                                                                      @toAmount,
                                                                                      ABS(t.AMOUNT_MINOR_UNITS)
                                                                                  )
              AND t.TRANSACTION_ID = ISNULL(@transferID, t.TRANSACTION_ID)
              AND
              (
                  @orderReference IS NULL
                  OR s.CART_ID LIKE '%' + ISNULL(@orderReference, '') + '%'
              )
              AND
              (
                  @merchantID IS NULL
  				  OR ISNULL(x.SOURCE_REF, ag.LEGACY_SOURCE_ID) = @merchantID

              )
              AND
              (
                  @description IS NULL
                  OR x.DESCRIPTION LIKE '%' + ISNULL(@description, '') + '%'
              )
        ORDER BY t.TRANSFER_ID ASC OFFSET [dbo].[fsPaginationOffSetValue](@pageNumber, @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY;

        	-- Return search metrics in second result set
	

    END;
	SELECT
		@pageSize AS ResultsPerPage,
        @pageNumber AS PageNumber,
        @totalCount AS TotalCount

END;
GO
GRANT EXECUTE ON  [dbo].[spGetCostStatement] TO [DataServiceUser]
GO
