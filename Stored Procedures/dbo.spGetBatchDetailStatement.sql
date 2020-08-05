SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ================================================================================
--  Author:			Neil
--  Create date:	11/10/2019
--  Description:
--     Returns transfers associated with a batch to produce the Batch Detail Statement
--
--  Return:
--      The transfers associated with a batch
--      The balance displayed on the statement appears to be dynamically calculated
--      based on the value of the transfers rather than the balance on transfer
--
--  Change history
--		10/10/2019	- NM		- First version.
--		15/11/2019  - MC		- Changes for MAPI get batch detail report endpoint (ACQ-2786)
--		18/12/2019  - MC		- Removed redundant fields (ACQ-3034)
--		19/02/2020  - Greg		- Release 18 schema changes support
--		26/02/2020	- MA		- removed VALUE_DATE field which slipped in again with all the merging
--
-- ================================================================================
CREATE PROCEDURE [dbo].[spGetBatchDetailStatement]
(
    @batchId NUMERIC = NULL,
	@accountId BIGINT,
	@pageNumber INT=1,
    @pageSize INT=20
)

AS
BEGIN
	SET NOCOUNT ON
	DECLARE @totalCount INT = 0;

	SELECT @totalcount = COUNT(*)
	FROM dbo.ACC_TRANSFERS AS t
    WHERE t.BATCH_ID = @batchId
          and t.ACCOUNT_ID = @accountId


    SELECT t.TRANSACTION_ID AS TransferID,
		   t.TRANSFER_time AS TransferDate,
		   tx.DESCRIPTION AS [Description],
		   tx.CUSTOMER_REF AS OrderReference,
		   tt.Description AS TransferTypeName,
		   t.TRANSFER_TYPE_ID AS TransferTypeId,
		   xx.TRANSACTION_ID AS ParentTransferId,
           t.AMOUNT_MINOR_UNITS AS AmountMinorUnits,
           t.BALANCE_AFTER_MINOR_UNITS AS BalanceMinorUnits,
		   t.MATURITY_TRANSACTION_ID AS BatchId,
           t.TRANSFER_METHOD_ID AS TransferMethodId,
           tm.DESCRIPTION AS TransferMethodName
    FROM dbo.ACC_TRANSFERS AS t
		JOIN dbo.ACC_TRANSACTIONS tx
			JOIN dbo.ACC_TRANSACTIONS AS xx
                ON tx.TXN_FIRST_ID = xx.TRANSACTION_ID
			ON tx.TRANSACTION_ID = t.TRANSACTION_ID
	JOIN dbo.ACC_TRANSFER_TYPES AS tt ON tt.TRANSFER_TYPE_ID = t.TRANSFER_TYPE_ID
	JOIN dbo.ACC_TRANSFER_METHODS tm ON tm.TRANSFER_METHOD_ID = t.TRANSFER_METHOD_ID

    WHERE t.MATURITY_TRANSACTION_ID = @batchId
	AND t.ACCOUNT_ID = @accountId
    ORDER BY t.TRANSFER_ID ASC OFFSET [dbo].[fsPaginationOffSetValue](@pageNumber, @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY;

	-- Return search metrics in second result set

	SELECT
		@pageSize AS ResultsPerPage,
        @pageNumber AS PageNumber,
        @totalCount AS TotalCount;


END;
GO
GRANT EXECUTE ON  [dbo].[spGetBatchDetailStatement] TO [DataServiceUser]
GO
