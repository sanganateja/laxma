SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Greg
-- Create date: 18/04/2019
-- Description:	Set the HOLD_REMITTANCE and HOLD_REMITTANCE_REASON for the passed in accounts
--
--  Change history
--		18/04/2019	- Greg	-	First version
--		25/07/2019	- Andy B -	Update error messages
-- =============================================
CREATE PROCEDURE [dbo].[spSetMerchantAccountGroupsHoldState]
	@Accounts ttMerchantAccountGroupHoldState READONLY
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @StateAccountNumberInvalid AS INT = 1

		IF EXISTS (SELECT 1 FROM @Accounts a
			LEFT JOIN [dbo].[ACC_ACCOUNT_GROUPS] ag on ag.ACCOUNT_NUMBER = a.AccountNumber
			WHERE AG.ACCOUNT_GROUP_ID IS NULL)

			BEGIN
				RAISERROR(50001,11,@StateAccountNumberInvalid)
				RETURN;
			END
	
			MERGE [dbo].[ACC_ACCOUNT_GROUPS] AS TARGET
			USING (SELECT a.AccountNumber, a.HoldState, a.Reason FROM @Accounts a) AS SOURCE (AccountNumber, HoldState, Reason)
			ON(TARGET.ACCOUNT_NUMBER = SOURCE.AccountNumber)
			WHEN MATCHED THEN 
				UPDATE SET
					HOLD_REMITTANCE = SOURCE.HoldState,
					HOLD_REMITTANCE_REASON = SOURCE.Reason;
END
GO
GRANT EXECUTE ON  [dbo].[spSetMerchantAccountGroupsHoldState] TO [DataServiceUser]
GO
