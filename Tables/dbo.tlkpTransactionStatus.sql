CREATE TABLE [dbo].[tlkpTransactionStatus]
(
[TransactionStatusId] [smallint] NOT NULL,
[TransactionStatus] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tlkpTransactionStatus] ADD CONSTRAINT [PK_tlkpTransactionStatus] PRIMARY KEY CLUSTERED  ([TransactionStatusId]) ON [PRIMARY]
GO
