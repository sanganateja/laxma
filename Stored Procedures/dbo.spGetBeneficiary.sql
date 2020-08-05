SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		AB
-- Create date: 25/02/2020
-- Description:	Gets beneficiary details
--
-- Change History:
--		25/02/2020	- AB		-	 Initial Version
--		27/02/2020	- AB		-	 Check for the existence of the beneficiary before getting the record
-- =============================================
CREATE PROCEDURE [dbo].[spGetBeneficiary]
	@BeneficiaryId BIGINT
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @StateInvalidBeneficiary INT = 1
      
	IF NOT EXISTS (SELECT 1 FROM [dbo].[tblBeneficiaries]
		WHERE Id = @BeneficiaryId)
	BEGIN
		RAISERROR(50001,11,@StateInvalidBeneficiary)
		RETURN;
	END

	 SELECT [Id] AS BeneficiaryId,
		   [BusinessId],
		   [BeneficiaryStatus],
		   [BeneficiaryType],
		   [BackgroundCheckRequestReference],
		   [BackgroundCheckReportLink],
		   [FirstName],
		   [MiddleName],
		   [LastName],
		   [DateOfBirth],
		   [Address1],
		   [Address2],
		   [Address3],
		   [CompanyName],
		   [CompanyRegistrationNumber],
		   [Country],
		   [BankCountry],
		   [AccountNumber],
		   [SortCode],
		   [SwiftCode],
		   [IntermediarySwiftCode],
		   [Iban]

    FROM dbo.tblBeneficiaries
	WHERE Id = @BeneficiaryId

END;
GO
GRANT EXECUTE ON  [dbo].[spGetBeneficiary] TO [DataServiceUser]
GO
