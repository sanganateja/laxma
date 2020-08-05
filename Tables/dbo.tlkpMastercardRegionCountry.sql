CREATE TABLE [dbo].[tlkpMastercardRegionCountry]
(
[MastercardRegionCountryId] [bigint] NOT NULL IDENTITY(1, 1),
[RegionCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CountryCodeAlpha2] [nchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tlkpMastercardRegionCountry] ADD CONSTRAINT [PK_tlkpMastercardRegionCountry] PRIMARY KEY CLUSTERED  ([MastercardRegionCountryId]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tlkpMastercardRegionCountry_CountryCodeAlpha2_RegionCode] ON [dbo].[tlkpMastercardRegionCountry] ([CountryCodeAlpha2], [RegionCode]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tlkpMastercardRegionCountry_RegionCode_CountryCodeAlpha2] ON [dbo].[tlkpMastercardRegionCountry] ([RegionCode], [CountryCodeAlpha2]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tlkpMastercardRegionCountry] ADD CONSTRAINT [FK_tlkpMastercardRegionCountry_tlkpMastercardRegion] FOREIGN KEY ([RegionCode]) REFERENCES [dbo].[tlkpMastercardRegion] ([RegionCode])
GO
