SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- Stored Procedure

-- ================================================================================	
--	Author:			SOS	
--	Create date:	04/04/2019	
--	Description:		
--		Gets the account balances for a merchant 
--	
--	Return:	
--		Merchant account balances
--	
--  Change history	
--		04/04/2019 -	SOS		- First version    
--		08/10/2019 -	GB		- Added MaturityDays    
--		12/12/2019 -	AB		- Updated to resolve ACQ-2667 so the newest record is picked rather than the highest ID
--		06/02/2020 -    Greg    - Support for MaturityHours
--	
-- ================================================================================	
CREATE PROCEDURE [dbo].[spGetMerchantAccountBalances]
	@MerchantAccounts ttMerchantAccounts READONLY,
	@EndDate datetime2 = null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @FLAG_GrossSettlement BIGINT = 0x100000000

	IF(@EndDate IS NULL)
		SET @EndDate = SYSUTCDATETIME()

	CREATE TABLE #MerchantAccountGroups
	(
		AccountGroupId bigint NOT NULL PRIMARY KEY,
		MerchantId bigint NOT NULL,
		GrossSettlement bit NOT NULL,
		AccountName nvarchar(256) NOT NULL,
		AccountNumber int NOT NULL,
		Currency nvarchar(3) COLLATE DATABASE_DEFAULT NOT NULL,
		HoldState char(1) NOT NULL
	)

	INSERT INTO #MerchantAccountGroups (AccountGroupId, MerchantId, GrossSettlement, AccountName, AccountNumber, Currency, HoldState)
	SELECT DISTINCT 
		ag.ACCOUNT_GROUP_ID,
		ma.MerchantId,
		CASE
			WHEN ow.MERCH_FLAGS&@FLAG_GrossSettlement = @FLAG_GrossSettlement THEN CAST(1 as bit)
			ELSE CAST(0 as bit)
		END,
		ag.ACCOUNT_GROUP_NAME,
		ag.ACCOUNT_NUMBER,
		ag.CURRENCY_CODE_ALPHA3,
		ag.HOLD_REMITTANCE
	FROM [dbo].[ACC_OWNERS] as ow
	JOIN [dbo].[ACC_ACCOUNT_GROUPS] as ag on ag.OWNER_ID = ow.OWNER_ID
										 and ag.ACCOUNT_GROUP_TYPE = 'A'
	JOIN @MerchantAccounts as ma on ma.Currency = ag.CURRENCY_CODE_ALPHA3
								and ma.AccountNumber = ag.ACCOUNT_NUMBER

	SELECT 
		MerchantId,
		GrossSettlement,
		AccountGroupId,
		AccountName,
		AccountNumber,
		Currency, 
		HoldState
	FROM #MerchantAccountGroups

	SELECT 
		mag.AccountGroupId,
		a.ACCOUNT_ID as AccountId,
		a.ACCOUNT_TYPE_ID as Account,
		ISNULL(tr.BALANCE_AFTER_MINOR_UNITS, 0) as Balance,
		@EndDate as [Date],
		MATURITY_HOURS as MaturityHours
	FROM #MerchantAccountGroups as mag
	JOIN [dbo].[ACC_ACCOUNTS] as a on a.ACCOUNT_GROUP_ID = mag.AccountGroupId
	LEFT JOIN dbo.ACC_TRANSFERS as tr on tr.TRANSFER_ID =
		(
			SELECT MAX(ACC_TRANSFERS.TRANSFER_ID) AS expr
			FROM dbo.ACC_TRANSFERS
			WHERE TRANSFER_TIME = (SELECT MAX(TRANSFER_TIME) FROM dbo.ACC_TRANSFERS WHERE ACC_TRANSFERS.ACCOUNT_ID = a.ACCOUNT_ID
					AND ACC_TRANSFERS.TRANSFER_TIME <= @EndDate)
					AND a.ACCOUNT_ID = ACC_TRANSFERS.ACCOUNT_ID
		)

	IF OBJECT_ID('tempdb..#MerchantAccountGroups') IS NOT NULL
	DROP TABLE #MerchantAccountGroups

END
GO
GRANT EXECUTE ON  [dbo].[spGetMerchantAccountBalances] TO [DataServiceUser]
GO
