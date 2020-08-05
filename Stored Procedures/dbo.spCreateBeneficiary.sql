SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		MC
-- Create date: 26/02/2020
-- Description:	Adds a beneficiary

--  Change history
--      26/02/2020  - Mary       - First version
-- =============================================
CREATE PROCEDURE [dbo].[spCreateBeneficiary] 
@BeneficiaryStatus [int],
@BackgroundCheckRequestReference [nvarchar](255),
@BackgroundCheckReportLink [nvarchar](max),
@BusinessId [bigint],
@BeneficiaryType [int],
@FirstName [nvarchar](255) = NULL,
@MiddleName [nvarchar](255) = NULL,
@LastName [nvarchar](255) = NULL,
@DateOfBirth [datetime2] = NULL,
@Address1 [nvarchar](255) = NULL,
@Address2 [nvarchar](255) = NULL,
@Address3 [nvarchar](255) = NULL,
@CompanyName [nvarchar](255) = NULL,
@CompanyRegistrationNumber [nvarchar](255) = NULL,
@Country [char](2) = NULL,
@BankCountry [char](2),
@AccountNumber [nvarchar](34),
@SortCode [nvarchar](6) = NULL,
@SwiftCode [nvarchar](12) = NULL,
@IntermediarySwiftCode [nvarchar](12) = NULL,
@Iban [nvarchar](34) = NULL
AS
BEGIN

	SET NOCOUNT ON;

	INSERT INTO [dbo].[tblBeneficiaries]
           ([BeneficiaryStatus]
           ,[BackgroundCheckRequestReference]
           ,[BackgroundCheckReportLink]
           ,[BusinessId]
           ,[BeneficiaryType]
           ,[FirstName]
           ,[MiddleName]
           ,[LastName]
           ,[DateOfBirth]
           ,[Address1]
           ,[Address2]
           ,[Address3]
           ,[CompanyName]
           ,[CompanyRegistrationNumber]
           ,[Country]
           ,[BankCountry]
           ,[AccountNumber]
           ,[SortCode]
           ,[SwiftCode]
           ,[IntermediarySwiftCode]
           ,[Iban])
     VALUES
           (@BeneficiaryStatus
           ,@BackgroundCheckRequestReference
           ,@BackgroundCheckReportLink
           ,@BusinessId
           ,@BeneficiaryType
           ,@FirstName
           ,@MiddleName
           ,@LastName
           ,@DateOfBirth
           ,@Address1
           ,@Address2
           ,@Address3
           ,@CompanyName
           ,@CompanyRegistrationNumber
           ,@Country
           ,@BankCountry
           ,@AccountNumber
           ,@SortCode
           ,@SwiftCode
           ,@IntermediarySwiftCode
           ,@Iban);

END
GO
GRANT EXECUTE ON  [dbo].[spCreateBeneficiary] TO [DataServiceUser]
GO
