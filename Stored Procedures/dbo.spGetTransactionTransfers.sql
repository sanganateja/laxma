SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ================================================================================
--  Author:			Neil
--  Create date:	11/10/2019
--  Description:
--     Returns transfers associated with a transaction 
--
--  Return:			
--      The transfers associated with a transaction
--
--  Change history
--		10/10/2019	- NM		- First version.
--
-- ================================================================================
CREATE PROCEDURE [dbo].[spGetTransactionTransfers]
(
    @transferId NUMERIC = NULL,
	@pageNumber INT=1,
    @pageSize INT=20
)

AS
BEGIN
	SET NOCOUNT ON
	DECLARE @totalCount INT = 0;

	/* This may not be necessary as the maximum number of transfers for a transaction is currently 10 */

	SELECT @totalcount = COUNT(*)
    FROM dbo.ACC_TRANSFERS AS t 
    WHERE t.TRANSACTION_ID = @transferId


    SELECT t.TRANSFER_TIME AS TransferDate,
		   tx.DESCRIPTION AS [Description],
		   CASE aat.NAME WHEN 'Trading' THEN 'Merchant Account' ELSE aat.NAME END AS Account,
		   tx.CUSTOMER_REF AS OrderReference,
		   tt.DESCRIPTION AS TransferTypeName,
           t.TRANSFER_TYPE_ID AS TransferTypeId,
           t.AMOUNT_MINOR_UNITS AS Amount,
           t.BALANCE_AFTER_MINOR_UNITS AS Balance,
           t.BATCH_ID AS BatchId,
           t.TRANSACTION_ID AS TransferId,
           t.TRANSFER_METHOD_ID AS TransferMethodId
    FROM dbo.ACC_TRANSFERS AS t JOIN dbo.ACC_TRANSACTIONS tx ON t.TRANSACTION_ID = tx.TRANSACTION_ID
	JOIN dbo.ACC_TRANSFER_TYPES AS tt ON tt.TRANSFER_TYPE_ID = t.TRANSFER_TYPE_ID
	JOIN dbo.ACC_ACCOUNTS a ON t.ACCOUNT_ID = a.ACCOUNT_ID
	JOIN dbo.ACC_ACCOUNT_TYPES aat ON aat.ACCOUNT_TYPE_ID = a.ACCOUNT_TYPE_ID
    WHERE t.TRANSACTION_ID = @transferId
    ORDER BY t.TRANSFER_ID OFFSET [dbo].[fsPaginationOffSetValue](@pageNumber, @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY;
	
	-- Return search metrics in second result set

	SELECT
		@pageSize AS ResultsPerPage,
        @pageNumber AS PageNumber,
        @totalCount AS TotalCount;


END;
GO
GRANT EXECUTE ON  [dbo].[spGetTransactionTransfers] TO [DataServiceUser]
GO
