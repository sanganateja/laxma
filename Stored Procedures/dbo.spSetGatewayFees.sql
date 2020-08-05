SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:			Greg 
-- Create date:		25/02/2020
-- Description:	
--		Updates Gateway fees
--
-- Change history
--		25/02/2020	- Greg	-	Initial version
--
-- =============================================
CREATE PROCEDURE [dbo].[spSetGatewayFees]
	@GatewayFees ttGatewayFees READONLY,
	@GatewayFeeTiers ttGatewayFeeTiers READONLY
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRANSACTION
	BEGIN TRY

		MERGE [dbo].tblGatewayFee AS TARGET
		USING (SELECT f.GatewayFeeTypeId, f.MerchantId, f.Amount FROM @GatewayFees f) AS SOURCE (GatewayFeeTypeId, MerchantId, Amount)
		ON(TARGET.GatewayFeeTypeId = SOURCE.GatewayFeeTypeId AND TARGET.MerchantId = SOURCE.MerchantId)
		WHEN MATCHED THEN 
			UPDATE SET
				Amount = SOURCE.Amount
		WHEN NOT MATCHED THEN  
			INSERT (GatewayFeeTypeId,MerchantId,Amount)  
			VALUES (SOURCE.GatewayFeeTypeId, SOURCE.MerchantId, SOURCE.Amount); 

		MERGE [dbo].tblGatewayFeeTier AS TARGET
		USING (SELECT f.MerchantId, f.Tier, f.TransactionsThreshold, f.Amount FROM @GatewayFeeTiers f) AS SOURCE (MerchantId, Tier, TransactionsThreshold, Amount)
		ON(TARGET.MerchantId = SOURCE.MerchantId AND TARGET.Tier = SOURCE.Tier)
		WHEN MATCHED THEN 
			UPDATE SET
				TransactionsThreshold = SOURCE.TransactionsThreshold,
				Amount = SOURCE.Amount
		WHEN NOT MATCHED THEN  
			INSERT (MerchantId,Tier,TransactionsThreshold,Amount)  
			VALUES (SOURCE.MerchantId, SOURCE.Tier, SOURCE.TransactionsThreshold, SOURCE.Amount); 



		COMMIT TRANSACTION			 
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		--Return error info
		DECLARE @ErrorNumber INT;  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
			@ErrorNumber = ERROR_NUMBER(),  
			@ErrorSeverity = ERROR_SEVERITY(),  
			@ErrorState = ERROR_STATE(); 

		RAISERROR (@ErrorNumber, @ErrorSeverity, @ErrorState);  
	END CATCH
	
END


GO
GRANT EXECUTE ON  [dbo].[spSetGatewayFees] TO [DataServiceUser]
GO
