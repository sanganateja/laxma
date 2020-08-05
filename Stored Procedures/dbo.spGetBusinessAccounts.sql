SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ================================================================================	
--	Author:			MA	
--	Create date:	25/11/2019	
--	Description:		
--		Gets the accounts for a specified business
--	
--	Return:	
--		Business info and business accounts (currency and account number)
--	
--  Change history	
--		25/10/2019 -	MA		-	First version
--		26/11/2019 -	JP		-	Add account number filtering

--	
-- ================================================================================	
CREATE PROCEDURE [dbo].[spGetBusinessAccounts]
    @BusinessId BIGINT,
    @AccountNumber BIGINT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT EXTERNAL_REF AS BusinessId,
           OWNER_NAME AS BusinessName
    FROM [dbo].[ACC_OWNERS]
    WHERE EXTERNAL_REF = @BusinessId;

    SELECT ag.ACCOUNT_NUMBER AS AccountNumber,
           ag.CURRENCY_CODE_ALPHA3 AS Currency,
		   ag.ACCOUNT_GROUP_ID AS AccountGroupId
    FROM dbo.ACC_OWNERS ao
        INNER JOIN dbo.ACC_ACCOUNT_GROUPS ag
            ON ag.OWNER_ID = ao.OWNER_ID
               AND ag.ACCOUNT_GROUP_TYPE = 'C'
    WHERE ao.EXTERNAL_REF = @BusinessId
		AND (@AccountNumber IS NULL OR ag.ACCOUNT_NUMBER = @AccountNumber);
END;
GO
GRANT EXECUTE ON  [dbo].[spGetBusinessAccounts] TO [DataServiceUser]
GO
