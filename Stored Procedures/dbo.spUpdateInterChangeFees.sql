SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:			Greg 
-- Create date:		17/05/2019
-- Description:	
--		Updates inter change fees (ACC_ACQUIRING_FEES_IC and ACC_CT_FEES_IC)
--
-- Change history
--		17/05/2019	- Greg	-	Initial version
--		29/07/2019	- SOS	-	Wrap in try catch
--
-- =============================================
CREATE PROCEDURE [dbo].[spUpdateInterChangeFees]
	@InterChangeFees ttGenericFees READONLY,
	@InterChangeCreditTransferFees ttInterChangeCreditTransferFees READONLY
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRANSACTION
	BEGIN TRY

		MERGE [dbo].[ACC_ACQUIRING_FEES_IC] AS TARGET
		USING (SELECT f.feeId, f.AmountMinorUnits, f.Percentage FROM @InterChangeFees f) AS SOURCE (feeId, AmountMinorUnits, FeePercentage)
		ON(TARGET.ACQ_FEE_IC_ID = SOURCE.feeId)
		WHEN MATCHED THEN 
			UPDATE SET
				AMOUNT_MINOR_UNITS = SOURCE.AmountMinorUnits,
				PERCENTAGE = SOURCE.FeePercentage;

		MERGE [dbo].[ACC_CT_FEES_IC] AS TARGET
		USING (
			SELECT ag.ACCOUNT_GROUP_ID, f.AmountMinorUnits, f.Percentage 
			FROM @InterChangeCreditTransferFees f 
			JOIN ACC_ACCOUNT_GROUPS as ag on f.AccountNumber = ag.ACCOUNT_NUMBER
		) 
		AS SOURCE (AccountGroupId, AmountMinorUnits, FeePercentage)
		ON(TARGET.ACCOUNT_GROUP_ID = SOURCE.AccountGroupId)
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
GRANT EXECUTE ON  [dbo].[spUpdateInterChangeFees] TO [DataServiceUser]
GO
