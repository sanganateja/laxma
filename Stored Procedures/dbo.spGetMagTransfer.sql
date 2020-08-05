SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- ================================================================================
--  Author:			Remy
--  Create date:	13/12/2019
--  Description:
--     Returns transfer between merchant account groups for the provided transactionId.
--
--  Return:
--      A list of transaction relating to the parent of the provided transactionId.
--
--  Change history
--		13/12/2019	- RH		- First version
--		16/01/2020	- RH		- Revised to use accountNumber as lookup instead of accountGroupId
--		06/02/2020	- RH		- Changed datatypes for parameters following review
--		07/02/2020	- RH		- Removed some columns from the transfer summary and updated to always return parents transactions like in AMS
--
-- ================================================================================
CREATE PROCEDURE [dbo].[spGetMagTransfer]
    @transferId BIGINT = NULL, -- TAKE CARE! this is TRANSACTION_ID on DB, and TRANSFER_ID is just a row index on DB.
	@accountNumber INT
AS
BEGIN

    DECLARE @firstTransferId BIGINT;
	DECLARE @parentTransferId BIGINT;

	SELECT TOP 1
	@firstTransferId = TRANSACTION_ID,
	@parentTransferId = TXN_FIRST_ID
	FROM dbo.ACC_TRANSACTIONS as txn
	WHERE TRANSACTION_ID = @transferId
   
	SELECT t.AMOUNT_MINOR_UNITS AS Amount,
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
	INTO #transfers
	FROM dbo.ACC_TRANSFERS t WITH (NOLOCK)
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
			WHERE x.TXN_FIRST_ID = @parentTransferId
			AND ag.ACCOUNT_GROUP_TYPE = 'A'
			AND ag.ACCOUNT_NUMBER = @accountNumber

	SELECT TOP 1
           [Description],
           TransferId,
           MerchantId,
		   BusinessId,
           TransferDate,
		   TransferMethodId,
		   TransferMethodName,
           ParentTransferId,
           ParentTransactionId
    FROM #transfers 
			WHERE TransferId = @transferId

	SELECT 
		Amount,
		Balance,
		BatchId,
		OrderReference,
		[Description],
		MaturityDate,
		TransferTypeName,
		TransferId,
        MerchantId,
		BusinessId,
		TransferDate,
		Account,
		TransferTypeId,
		Currency
	FROM #transfers 
		WHERE ParentTransferId = @parentTransferId

	IF OBJECT_ID('tempdb..#transfers') IS NOT NULL DROP TABLE #transfers

END;
GO
GRANT EXECUTE ON  [dbo].[spGetMagTransfer] TO [DataServiceUser]
GO
