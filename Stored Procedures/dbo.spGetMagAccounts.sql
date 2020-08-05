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
--	
-- ================================================================================	
CREATE PROCEDURE [dbo].[spGetMagAccounts]
	@MerchantAccountNumber BIGINT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @StateAccountNumberInvalid AS INT = 1
	IF (@MerchantAccountNumber IS NULL)
	BEGIN
		RAISERROR(50001,11,@StateAccountNumberInvalid)
		RETURN;
	END

	DECLARE @AccountGroupId BIGINT;
			
	SELECT @AccountGroupId = ag.ACCOUNT_GROUP_ID
	FROM [dbo].[ACC_ACCOUNT_GROUPS] as ag 
	WHERE ag.ACCOUNT_GROUP_TYPE = 'A'
	AND @MerchantAccountNumber = ag.ACCOUNT_NUMBER
	
	SELECT 
		@AccountGroupId AS AccountGroupId,
		a.ACCOUNT_ID as AccountId,
		a.ACCOUNT_TYPE_ID as Account,
		ag.ACCOUNT_GROUP_NAME AS AccountName
	FROM [dbo].[ACC_ACCOUNTS] AS a
	JOIN [dbo].[ACC_ACCOUNT_GROUPS] AS ag ON a.ACCOUNT_GROUP_ID=ag.ACCOUNT_GROUP_ID
	WHERE a.ACCOUNT_GROUP_ID=@AccountGroupId
	
END
GO
GRANT EXECUTE ON  [dbo].[spGetMagAccounts] TO [DataServiceUser]
GO
