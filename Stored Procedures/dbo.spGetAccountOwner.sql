SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:			Jacques
-- Create date:		11/09/2019
-- Description:		Gets an owner record
--
--  Change history	
--		11/09/2019 - JP - Initial version
--		12/09/2019 - JP - Add ExpectedMonthlyTrade
--		08/10/2019 - GB - Add DefaultRemittanceMethod
-- =============================================
CREATE PROCEDURE [dbo].[spGetAccountOwner]
	@AccountsOwnerId bigint
AS
BEGIN

	SET NOCOUNT ON;

	SELECT 
		OWNER_ID as AccountsOwnerID,
		MERCH_FLAGS as Flags,
		BUSINESS_TRADING_LIMIT_GBP as ExpectedMonthlyTradeMinorUnits,
		DFLT_REMITTANCE_METHOD as DefaultRemittanceMethod
	FROM [dbo].[ACC_OWNERS]  
	WHERE OWNER_ID = @AccountsOwnerId
    
END
GO
GRANT EXECUTE ON  [dbo].[spGetAccountOwner] TO [DataServiceUser]
GO
