SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		JP
-- Create date: 21/02/2020
-- Description:	Gets beneficiaries
--
-- Change History:
--		21/02/2020  - JP		-	 Initial Version
-- =============================================
CREATE PROCEDURE [dbo].[spGetBeneficiaries]
    @PageNumber INT,
    @PageSize INT,
	@BusinessId BIGINT = NULL,
	@Status int = NULL
AS
BEGIN												
    SET NOCOUNT ON;

	DECLARE @TotalCount int
	SELECT @TotalCount = COUNT(*)
	FROM dbo.tblBeneficiaries
	WHERE BusinessId = ISNULL(@BusinessId, BusinessId) AND BeneficiaryStatus = ISNULL(@Status, BeneficiaryStatus)

    SELECT [Id] AS BeneficiaryId,
		   [BusinessId],
		   [BeneficiaryType],
		   [FirstName],
		   [MiddleName],
		   [LastName],
		   [CompanyName],
		   [BeneficiaryStatus],
		   [BackgroundCheckRequestReference],
		   [BackgroundCheckReportLink],
		   [BankCountry],
		   [AccountNumber],
		   [SortCode],
		   [SwiftCode],
		   [IntermediarySwiftCode],
		   [Iban]
    FROM dbo.tblBeneficiaries
	WHERE BusinessId = ISNULL(@BusinessId, BusinessId) AND BeneficiaryStatus = ISNULL(@Status, BeneficiaryStatus)
    ORDER BY [Id] ASC OFFSET [dbo].[fsPaginationOffSetValue] (@PageNumber, @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY;

    SELECT @pageSize AS ResultsPerPage,
			@PageNumber AS PageNumber,
			@TotalCount AS TotalCount;
 END;
 
GO
GRANT EXECUTE ON  [dbo].[spGetBeneficiaries] TO [DataServiceUser]
GO
