CREATE TABLE [dbo].[tblGlobalSetting]
(
[SettingName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SettingValue] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblGlobalSetting] ADD CONSTRAINT [PK_tblGlobalSetting] PRIMARY KEY CLUSTERED  ([SettingName]) ON [PRIMARY]
GO
