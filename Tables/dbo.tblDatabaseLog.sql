CREATE TABLE [dbo].[tblDatabaseLog]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[LogDate] [datetime] NOT NULL,
[CallingSPROC] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Priority] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Conversation_Handle] [uniqueidentifier] NULL,
[TransactionReference] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Summary] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorNumber] [int] NULL,
[ErrorSeverity] [int] NULL,
[ErrorState] [int] NULL,
[ErrorProcedure] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorLine] [int] NULL,
[ErrorMessage] [varchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Message] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblDatabaseLog] ADD CONSTRAINT [pk_tblDatabaselog] PRIMARY KEY CLUSTERED  ([ID], [LogDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblDatabaseLog_TransactionPriority] ON [dbo].[tblDatabaseLog] ([TransactionReference], [LogDate], [Priority]) INCLUDE ([Conversation_Handle]) ON [INDEX]
GO
