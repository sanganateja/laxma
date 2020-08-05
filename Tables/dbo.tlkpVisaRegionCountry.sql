CREATE TABLE [dbo].[tlkpVisaRegionCountry]
(
[VisaRegionCountryId] [bigint] NOT NULL IDENTITY(1, 1),
[RegionCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CountryCodeAlpha2] [nchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tlkpVisaRegionCountry] ADD CONSTRAINT [PK_tlkpVisaRegionCountry] PRIMARY KEY CLUSTERED  ([VisaRegionCountryId]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tlkpVisaRegionCountry_CountryCodeAlpha2_RegionCode] ON [dbo].[tlkpVisaRegionCountry] ([CountryCodeAlpha2], [RegionCode]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tlkpVisaRegionCountry_RegionCode_CountryCodeAlpha2] ON [dbo].[tlkpVisaRegionCountry] ([RegionCode], [CountryCodeAlpha2]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tlkpVisaRegionCountry] ADD CONSTRAINT [FK_tlkpVisaRegionCountry_tlkpVisaRegion] FOREIGN KEY ([RegionCode]) REFERENCES [dbo].[tlkpVisaRegion] ([RegionCode])
GO
