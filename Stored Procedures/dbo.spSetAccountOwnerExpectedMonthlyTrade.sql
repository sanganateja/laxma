SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:			Jacques
-- Create date:		12/09/2019
-- Description:		Sets the expected monthly trade for an account owner
--
--  Change history	
--		12/09/2019 - JP - Initial version
-- =============================================
CREATE PROCEDURE [dbo].[spSetAccountOwnerExpectedMonthlyTrade]
	@AccountsOwnerId bigint,
	@ExpectedMonthlyTrade bigint
AS
BEGIN

	SET NOCOUNT ON;

	UPDATE [dbo].[ACC_OWNERS] 
		SET 
			BUSINESS_TRADING_LIMIT_GBP = @ExpectedMonthlyTrade 
		WHERE OWNER_ID = @AccountsOwnerId
    
END
GO
GRANT EXECUTE ON  [dbo].[spSetAccountOwnerExpectedMonthlyTrade] TO [DataServiceUser]
GO
