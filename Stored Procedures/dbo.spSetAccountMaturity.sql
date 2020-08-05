SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:			Greg
-- Create date:		08/10/2019
-- Description:		Sets the maturity for an account
--
--  Change history	
--		08/10/2019 - GB - Initial version
--		06/02/2020 - GB - Support for MaturityHours
-- =============================================
CREATE PROCEDURE [dbo].[spSetAccountMaturity]
	@AccountId bigint,
	@MaturityHours bigint
AS
BEGIN

	SET NOCOUNT ON;

	UPDATE [dbo].[ACC_ACCOUNTS] 
		SET 
			MATURITY_HOURS = @MaturityHours 
		WHERE ACCOUNT_ID = @AccountId
    
END
GO
GRANT EXECUTE ON  [dbo].[spSetAccountMaturity] TO [DataServiceUser]
GO
