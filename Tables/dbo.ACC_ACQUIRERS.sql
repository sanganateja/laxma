CREATE TABLE [dbo].[ACC_ACQUIRERS]
(
[ACQUIRER_ID] [bigint] NOT NULL,
[ACQUIRER_NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ACQUIRER_SHORT_NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ACC_ACQUIRERS] ADD CONSTRAINT [ACC_ACQUIRERS_PK] PRIMARY KEY CLUSTERED  ([ACQUIRER_ID]) ON [PRIMARY]
GO