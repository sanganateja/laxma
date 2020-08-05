SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:			Greg
-- Create date:		08/10/2019
-- Description:		Sets the default remittance method for an owner
--
--  Change history	
--		08/10/2019 - GB - Initial version
--		12/12/2019 - GB - Also set PAYMENT_TYPE for the Owners STANDING_ORDERS
--		16/03/2020 - AB - Pay All Flag being set to Yes for Auto Remittance Merchants
-- =============================================
CREATE PROCEDURE [dbo].[spSetOwnerAccountDefaultRemittanceMethod]
	@AccountsOwnerId bigint,
	@DefaultRemittanceMethod nvarchar(2) = NULL,
	@StandingOrdersPaymentType CHAR(2)
AS
BEGIN

	SET NOCOUNT ON;

	UPDATE [dbo].[ACC_OWNERS] 
		SET 
			DFLT_REMITTANCE_METHOD = @DefaultRemittanceMethod 
		WHERE OWNER_ID = @AccountsOwnerId;

	UPDATE [dbo].[ACC_BANK_STANDING_ORDERS] 
		SET
			PAYMENT_TYPE = @StandingOrdersPaymentType,
			PAY_ALL = 'Y'
		WHERE ACCOUNT_GROUP_ID IN (SELECT ACCOUNT_GROUP_ID FROM dbo.ACC_ACCOUNT_GROUPS WHERE OWNER_ID = @AccountsOwnerId)  
    
END
GO
GRANT EXECUTE ON  [dbo].[spSetOwnerAccountDefaultRemittanceMethod] TO [DataServiceUser]
GO
