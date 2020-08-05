CREATE TABLE [dbo].[tlkpVisaRegion]
(
[RegionCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RegionDescription] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tlkpVisaRegion] ADD CONSTRAINT [PK_tlkpVisaRegion] PRIMARY KEY CLUSTERED  ([RegionCode]) ON [PRIMARY]
GO
