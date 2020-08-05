SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		JP
-- Create date: 27/20/2020
-- Description:	Sets the Status for a beneficiary
--
--  Change history
--		27/02/2020	- JP	-	First version
-- =============================================
CREATE PROCEDURE [dbo].[spSetBeneficiaryStatus]
	@BeneficiaryId bigint,
	@Status INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @StateInvalidBeneficiary INT = 1
	IF NOT EXISTS (SELECT 1 FROM dbo.tblBeneficiaries WHERE Id = @BeneficiaryId)
	BEGIN
		RAISERROR(50001,11,@StateInvalidBeneficiary)
		RETURN;
	END

	UPDATE dbo.tblBeneficiaries
	SET BeneficiaryStatus = @Status
	WHERE ID = @BeneficiaryId
END

GO
GRANT EXECUTE ON  [dbo].[spSetBeneficiaryStatus] TO [DataServiceUser]
GO
