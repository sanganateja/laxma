SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Stored Procedure

-- ================================================================================	
--	Author:			MA	
--	Create date:	30/10/2019	
--	Description:		
--		Gets the account balances for an account group
--	
--	Return:	
--		Merchant account balances
--	
--  Change history	
--		30/10/2019 -	MA		- First version    
--		12/12/2019 -	AB		- Updated to resolve ACQ-2667 so the newest record is picked rather than the highest ID
--		06/02/2020 -    Greg    - Support for MaturityHours
--	
-- ================================================================================	
CREATE PROCEDURE [dbo].[spGetAccountBalances]
	@AccountGroupId bigint,
	@EndDate datetime2
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		@AccountGroupId AS AccountGroupId,
		a.ACCOUNT_ID as AccountId,
		a.ACCOUNT_TYPE_ID as Account,
		ISNULL(tr.BALANCE_AFTER_MINOR_UNITS, 0) as Balance,
		@EndDate as [Date],
		MATURITY_HOURS as MaturityHours
	
	FROM [dbo].[ACC_ACCOUNTS] as a 
	LEFT JOIN dbo.ACC_TRANSFERS as tr on tr.TRANSFER_ID =
		(
			SELECT MAX(ACC_TRANSFERS.TRANSFER_ID) AS expr
			FROM dbo.ACC_TRANSFERS
			WHERE TRANSFER_TIME = (SELECT MAX(TRANSFER_TIME) FROM dbo.ACC_TRANSFERS WHERE ACC_TRANSFERS.ACCOUNT_ID = a.ACCOUNT_ID
					AND ACC_TRANSFERS.TRANSFER_TIME <= @EndDate)
					AND a.ACCOUNT_ID = ACC_TRANSFERS.ACCOUNT_ID
				
		)
		WHERE a.ACCOUNT_GROUP_ID = @AccountGroupId
	
END
GO
GRANT EXECUTE ON  [dbo].[spGetAccountBalances] TO [DataServiceUser]
GO
