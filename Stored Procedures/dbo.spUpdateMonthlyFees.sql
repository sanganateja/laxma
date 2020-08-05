SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:			Greg 
-- Create date:		13/11/2019
-- Description:	
--		Updates monthly fees
--
-- Change history
--		13/11/2019	- Greg	-	Initial version
--
-- =============================================
CREATE PROCEDURE [dbo].[spUpdateMonthlyFees]
	@MonthlyFees [ttMonthlyFee] READONLY,
	@AccountsOwnerId bigint
AS
BEGIN
	SET NOCOUNT ON;

	MERGE [dbo].[ACC_MONTHLY_FEES] AS TARGET
	USING (
		SELECT f.Currency, f.AmountMinorUnits, f.FeeType FROM @MonthlyFees f) AS SOURCE (Currency, AmountMinorUnits, FeeType)
	ON(TARGET.OWNER_ID = @AccountsOwnerId AND TARGET.CURRENCY_CODE_ALPHA3 = SOURCE.Currency AND TARGET.FEE_TYPE_ID = SOURCE.FeeType)
	WHEN MATCHED THEN 
		UPDATE SET
			AMOUNT_MINOR_UNITS = SOURCE.AmountMinorUnits;
 
END
GO
GRANT EXECUTE ON  [dbo].[spUpdateMonthlyFees] TO [DataServiceUser]
GO
