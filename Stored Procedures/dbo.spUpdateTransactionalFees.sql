SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:			Greg 
-- Create date:		13/05/2019
-- Description:	
--		Updates  transactional fees
--
-- Return:
--		pricing policies
--
-- Change history
--		13/05/2019	- Greg	-	Initial version
--
-- =============================================
CREATE PROCEDURE [dbo].[spUpdateTransactionalFees]
	@TransactionalFees ttGenericFees READONLY
AS
BEGIN
	SET NOCOUNT ON;

	MERGE [dbo].[ACC_ACQUIRING_FEES] AS TARGET
	USING (SELECT f.feeId, f.AmountMinorUnits FROM @TransactionalFees f) AS SOURCE (feeId, AmountMinorUnits)
	ON(TARGET.FEE_ID = SOURCE.feeId)
	WHEN MATCHED THEN 
		UPDATE SET
			AMOUNT_MINOR_UNITS = SOURCE.AmountMinorUnits;
 
END
GO
GRANT EXECUTE ON  [dbo].[spUpdateTransactionalFees] TO [DataServiceUser]
GO
