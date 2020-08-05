SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- Stored Procedure

-- ================================================================================	
--	Author:			Remy Hargeaves	
--	Create date:	23/10/2019	
--	Description:		
--		Gets active Currencies for Merchant Accounts (Merchant in the API)
--	
--	Return:	
--		MerchantAccountGroupSummaryResult
--	
--  Change history	
--		23/10/2019 - RH - Initial
--	
-- ================================================================================	
CREATE PROCEDURE [dbo].[spGetMerchantAccountActiveCurrencies]
	@MerchantAccounts ttMerchantAccounts READONLY
AS

BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT 
		ag.ACCOUNT_NUMBER as AccountNumber,
		ma.MerchantId as MerchantId,
		ag.CURRENCY_CODE_ALPHA3 as Currency
	FROM [dbo].[ACC_ACCOUNT_GROUPS] as ag 										 
	JOIN @MerchantAccounts as ma on ma.Currency = ag.CURRENCY_CODE_ALPHA3
								and ma.AccountNumber = ag.ACCOUNT_NUMBER
	WHERE ag.ACCOUNT_GROUP_TYPE = 'A' -- Merchants
	AND ag.GROUP_STATUS = 'L' -- Live Account Group

END

GO
GRANT EXECUTE ON  [dbo].[spGetMerchantAccountActiveCurrencies] TO [DataServiceUser]
GO
