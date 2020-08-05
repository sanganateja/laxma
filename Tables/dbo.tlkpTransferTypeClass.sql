CREATE TABLE [dbo].[tlkpTransferTypeClass]
(
[TransferTypeClassId] [bigint] NOT NULL,
[ClassName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tlkpTransferTypeClass] ADD CONSTRAINT [PK__tlkpTran__E24CF2F13DC05457] PRIMARY KEY CLUSTERED  ([TransferTypeClassId]) ON [PRIMARY]
GO
