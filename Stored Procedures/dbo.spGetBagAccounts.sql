SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- Stored Procedure

-- ================================================================================	
--	Author:			NCM	
--	Create date:	10/10/2019	
--	Description:		
--		Gets the accounts for a business account group
--	
--	Return:	
--		accounts
--	
--  Change history	
--		10/10/2019 -	NM		- First version.    
--		14/01/2020 -	MC		- Added check for existance of business account number (ACQ-2674).    
--	
-- ================================================================================	
CREATE PROCEDURE [dbo].[spGetBagAccounts]
	@BusinessAccountNumber BIGINT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @StateAccountNumberInvalid AS INT = 1
	
	IF @BusinessAccountNumber IS NULL
	OR NOT EXISTS (SELECT * FROM [dbo].[ACC_ACCOUNT_GROUPS] ag WHERE ag.ACCOUNT_NUMBER = @BusinessAccountNumber) 
	BEGIN
		RAISERROR(50001,11,@StateAccountNumberInvalid)
		RETURN;
	END

	DECLARE @AccountGroupId BIGINT;

	SELECT @AccountGroupId = ag.ACCOUNT_GROUP_ID
	FROM [dbo].[ACC_ACCOUNT_GROUPS] AS ag 
	WHERE ag.ACCOUNT_GROUP_TYPE = 'C'
	AND @BusinessAccountNumber = ag.ACCOUNT_NUMBER

	SELECT 
		@AccountGroupId AS AccountGroupId,
		a.ACCOUNT_ID AS AccountId,
		a.ACCOUNT_TYPE_ID AS Account,
		ag.ACCOUNT_GROUP_NAME AS AccountName
	FROM [dbo].[ACC_ACCOUNTS] AS a
	JOIN [dbo].[ACC_ACCOUNT_GROUPS] AS ag ON a.ACCOUNT_GROUP_ID=ag.ACCOUNT_GROUP_ID
	WHERE a.ACCOUNT_GROUP_ID=@AccountGroupId

END
GO
GRANT EXECUTE ON  [dbo].[spGetBagAccounts] TO [DataServiceUser]
GO
