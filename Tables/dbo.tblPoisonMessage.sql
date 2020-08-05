CREATE TABLE [dbo].[tblPoisonMessage]
(
[poisonid] [int] NOT NULL IDENTITY(1, 1),
[conversation_handle] [uniqueidentifier] NOT NULL,
[messagerecorded] [datetime] NULL,
[count] [smallint] NULL,
[originationqueue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[messagetype] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[message] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblPoisonMessage] ADD CONSTRAINT [PK_tblPoisonMessage] PRIMARY KEY CLUSTERED  ([poisonid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblPoisonMessage_ConversationCount] ON [dbo].[tblPoisonMessage] ([conversation_handle], [count]) ON [INDEX]
GO
