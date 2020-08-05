SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:			Greg 
-- Create date:		15/05/2019
-- Description:	
--		Updates blended fees (ACC_ACQUIRING_FEES_BLENDED and ACC_CT_FEES_BLENDED)
--
-- Return:
--		pricing policies
--
-- Change history
--		15/05/2019	- Greg	-	Initial version
--		29/07/2019	- SOS	-	Wrap in try catch
--
-- =============================================
CREATE PROCEDURE [dbo].[spUpdateBlendedFees]
	@BlendedFees ttGenericFees READONLY,
	@BlendedCreditTransferFees ttBlendedCreditTransferFees READONLY
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRANSACTION
	BEGIN TRY

		MERGE [dbo].[ACC_ACQUIRING_FEES_BLENDED] AS TARGET
		USING (SELECT f.feeId, f.AmountMinorUnits, f.Percentage FROM @BlendedFees f) AS SOURCE (feeId, AmountMinorUnits, FeePercentage)
		ON(TARGET.ACQ_FEE_BLENDED_ID = SOURCE.feeId)
		WHEN MATCHED THEN 
			UPDATE SET
				AMOUNT_MINOR_UNITS = SOURCE.AmountMinorUnits,
				PERCENTAGE = SOURCE.FeePercentage;

		MERGE [dbo].[ACC_CT_FEES_BLENDED] AS TARGET
		USING (
			SELECT ag.ACCOUNT_GROUP_ID, f.Region, f.FeeDistinguisher, f.AmountMinorUnits, f.Percentage 
			FROM @BlendedCreditTransferFees f 
			JOIN ACC_ACCOUNT_GROUPS as ag on f.AccountNumber = ag.ACCOUNT_NUMBER
		) 
		AS SOURCE (AccountGroupId, Region, FeeDistinguisher, AmountMinorUnits, FeePercentage)
		ON(TARGET.ACCOUNT_GROUP_ID = SOURCE.AccountGroupId AND TARGET.PRICING_REGION_CODE = SOURCE.Region AND TARGET.FEE_DISTINGUISHER = SOURCE.FeeDistinguisher)
		WHEN MATCHED THEN 
			UPDATE SET
				AMOUNT_MINOR_UNITS = SOURCE.AmountMinorUnits,
				PERCENTAGE = SOURCE.FeePercentage;

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
GRANT EXECUTE ON  [dbo].[spUpdateBlendedFees] TO [DataServiceUser]
GO
