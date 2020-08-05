CREATE TABLE [dbo].[tblTransactionSearch]
(
[TransactionSearchId] [bigint] NOT NULL IDENTITY(1, 1),
[PrincipalId] [bigint] NULL,
[BusinessId] [int] NOT NULL,
[MerchantId] [int] NULL,
[GatewayTerminalId] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartTime] [datetime2] NOT NULL,
[MerchantReference] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentJobReference] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ARN] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerName] [nvarchar] (340) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AmountRequested] [decimal] (12, 2) NOT NULL,
[AmountReceived] [decimal] (12, 2) NOT NULL,
[Currency] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TxStatus] [smallint] NOT NULL,
[TxType] [smallint] NOT NULL,
[Channel] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GatewayDetailsEndpoint] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SearchString] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblTransactionSearch] ADD CONSTRAINT [PK_tblTransactionSearch] PRIMARY KEY CLUSTERED  ([TransactionSearchId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TxSearch_MerchantId_StartTime_AmountRequested_Currency] ON [dbo].[tblTransactionSearch] ([MerchantId]) INCLUDE ([AmountRequested], [Currency], [StartTime]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TxSearch_PaymentJobRef] ON [dbo].[tblTransactionSearch] ([PaymentJobReference]) INCLUDE ([PrincipalId]) ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [IX_TxSearch_PrincipalId] ON [dbo].[tblTransactionSearch] ([PrincipalId]) ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [IX_TxSearch_BusinessId_StartTime] ON [dbo].[tblTransactionSearch] ([StartTime], [BusinessId], [MerchantId]) INCLUDE ([AmountReceived], [AmountRequested], [Channel], [Currency], [PrincipalId], [TxStatus], [TxType]) ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [IX_TxSearch_MainSearchIndex] ON [dbo].[tblTransactionSearch] ([TransactionSearchId], [PrincipalId], [StartTime], [PaymentJobReference], [CustomerName], [AmountRequested], [AmountReceived], [Currency], [TxStatus], [TxType], [Channel]) ON [INDEX]
GO
GRANT SELECT ON  [dbo].[tblTransactionSearch] TO [DataServiceUser]
GO
CREATE FULLTEXT INDEX ON [dbo].[tblTransactionSearch] KEY INDEX [PK_tblTransactionSearch] ON ([OmniChannelSearch], FILEGROUP [SEARCH])
GO
ALTER FULLTEXT INDEX ON [dbo].[tblTransactionSearch] ADD ([SearchString] LANGUAGE 1033)
GO
