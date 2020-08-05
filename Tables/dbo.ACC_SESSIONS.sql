CREATE TABLE [dbo].[ACC_SESSIONS]
(
[SESSION_ID] [bigint] NOT NULL,
[COOKIE_ID] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[COOKIE_REF] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[USER_ID] [bigint] NULL,
[FIRST_NAME] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LAST_NAME] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EMAIL_ADDRESS] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IS_ADMIN] [smallint] NULL,
[IS_MERCHANT] [smallint] NULL,
[IS_READ_ONLY] [smallint] NULL,
[OWNER_ID] [bigint] NULL,
[ACCOUNT_GROUP_ID] [bigint] NULL,
[ACCOUNT_TYPE_ID] [bigint] NULL,
[EXPIRY_TIME] [datetime2] (6) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ACC_SESSIONS] ADD CONSTRAINT [ACC_SESSIONS_PK] PRIMARY KEY CLUSTERED  ([SESSION_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ACC_SESSIONS_COOKIE_ID_REF] ON [dbo].[ACC_SESSIONS] ([COOKIE_ID], [COOKIE_REF]) ON [INDEX]
GO