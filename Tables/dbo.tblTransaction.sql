CREATE TABLE [dbo].[tblTransaction]
(
[PrincipalId] [bigint] NOT NULL IDENTITY(1000000000, 1),
[TransactionId] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MerchantReference] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransactionType] [bigint] NOT NULL,
[TransactionClass] [int] NULL,
[AuthAmount] [decimal] (12, 2) NOT NULL,
[AuthCurrency] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AuthAmountGBP] [decimal] (12, 2) NOT NULL,
[AuthFxRate] [float] NOT NULL,
[StartTime] [datetime2] NOT NULL,
[EndTime] [datetime2] NULL,
[Duration] [float] NULL,
[AcquirerId] [smallint] NOT NULL,
[BusinessId] [int] NOT NULL,
[MerchantId] [int] NOT NULL,
[TerminalId] [int] NULL,
[BillingAddress] [bigint] NULL,
[CardId] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblTransaction] ADD CONSTRAINT [PK_tblTransaction] PRIMARY KEY CLUSTERED  ([PrincipalId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblTransaction_TranIdWithBIDMIDTID] ON [dbo].[tblTransaction] ([TransactionId]) INCLUDE ([BusinessId], [MerchantId], [MerchantReference], [TerminalId]) ON [INDEX]
GO
