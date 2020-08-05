CREATE TABLE [dbo].[tblGatewayFeeTier]
(
[MerchantId] [bigint] NOT NULL,
[Tier] [int] NOT NULL,
[TransactionsThreshold] [bigint] NULL,
[Amount] [decimal] (12, 2) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblGatewayFeeTier] ADD CONSTRAINT [PK_tblGatewayFeeTier] PRIMARY KEY CLUSTERED  ([MerchantId], [Tier]) ON [PRIMARY]
GO
