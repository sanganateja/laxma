CREATE TABLE [dbo].[tlkpTransactionType]
(
[TransactionTypeId] [smallint] NOT NULL,
[TransactionType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tlkpTransactionType] ADD CONSTRAINT [PK_tlkpTransactionType] PRIMARY KEY CLUSTERED  ([TransactionTypeId]) ON [PRIMARY]
GO
