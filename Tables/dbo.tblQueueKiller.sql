CREATE TABLE [dbo].[tblQueueKiller]
(
[QueueName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Conversation_Handle] [uniqueidentifier] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblQueueKiller] ADD CONSTRAINT [PK_tblQueueKillers] PRIMARY KEY CLUSTERED  ([QueueName], [Conversation_Handle]) ON [PRIMARY]
GO
