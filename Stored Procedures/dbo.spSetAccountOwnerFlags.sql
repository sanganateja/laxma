SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:			Jacques
-- Create date:		21/08/2019
-- Description:		Replaces flags for an owner
--
--  Change history	
--		11/09/2019 - JP - Initial version
-- =============================================
CREATE PROCEDURE [dbo].[spSetAccountOwnerFlags]
	@AccountsOwnerId bigint,
	@Flags bigint
AS
BEGIN

	SET NOCOUNT ON;

	UPDATE [dbo].[ACC_OWNERS] 
		SET 
			MERCH_FLAGS = @Flags 
		WHERE OWNER_ID = @AccountsOwnerId
    
END

GO
GRANT EXECUTE ON  [dbo].[spSetAccountOwnerFlags] TO [DataServiceUser]
GO
