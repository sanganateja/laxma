CREATE TABLE [dbo].[tlkpMastercardRegion]
(
[RegionCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RegionDescription] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tlkpMastercardRegion] ADD CONSTRAINT [PK_tlkpMastercardRegion] PRIMARY KEY CLUSTERED  ([RegionCode]) ON [PRIMARY]
GO
