SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:			Greg 
-- Create date:		26/02/2020
-- Description:	
--		Returns Gateway fees
--
-- Return:
--		Gateway Fees
--
-- Change history
--		26/02/2020	- Greg	-	Initial version
--
-- =============================================
CREATE PROCEDURE [dbo].[spGetMerchantGatewayFees]
	@MerchantId BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		GatewayFeeTypeId,
		Amount
	FROM dbo.tblGatewayFee 
	WHERE MerchantId = @MerchantId

	SELECT
		Tier,
		TransactionsThreshold,
		Amount
	FROM dbo.tblGatewayFeeTier 
	WHERE MerchantId = @MerchantId

END

GO
GRANT EXECUTE ON  [dbo].[spGetMerchantGatewayFees] TO [DataServiceUser]
GO
