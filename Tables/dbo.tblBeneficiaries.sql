CREATE TABLE [dbo].[tblBeneficiaries]
(
[Id] [bigint] NOT NULL IDENTITY(1, 1),
[BeneficiaryStatus] [int] NOT NULL,
[BackgroundCheckRequestReference] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BackgroundCheckReportLink] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BusinessId] [bigint] NOT NULL,
[BeneficiaryType] [int] NOT NULL,
[FirstName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiddleName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateOfBirth] [datetime2] NULL,
[Address1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address3] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CompanyName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CompanyRegistrationNumber] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Country] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BankCountry] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AccountNumber] [nvarchar] (34) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SortCode] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SwiftCode] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IntermediarySwiftCode] [nvarchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Iban] [nvarchar] (34) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblBeneficiaries] ADD CONSTRAINT [PK_tblBeneficiaries] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
