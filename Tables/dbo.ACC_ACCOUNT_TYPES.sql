CREATE TABLE [dbo].[ACC_ACCOUNT_TYPES]
(
[ACCOUNT_TYPE_ID] [bigint] NOT NULL,
[NAME] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ROUNDING] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ACC_ACCOUNT_TYPES] ADD CONSTRAINT [ACC_ACCOUNT_TYPES_PK] PRIMARY KEY CLUSTERED  ([ACCOUNT_TYPE_ID]) ON [PRIMARY]
GO
