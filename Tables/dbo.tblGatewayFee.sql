CREATE TABLE [dbo].[tblGatewayFee]
(
[GatewayFeeTypeId] [int] NOT NULL,
[MerchantId] [bigint] NOT NULL,
[Amount] [decimal] (12, 2) NOT NULL,
[GatewayFeeId] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblGatewayFee] ADD CONSTRAINT [PK_tblGatewayFee] PRIMARY KEY CLUSTERED  ([GatewayFeeTypeId], [MerchantId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblGatewayFee] ADD CONSTRAINT [FK_tblGatewayFee_tblGatewayFee] FOREIGN KEY ([GatewayFeeTypeId], [MerchantId]) REFERENCES [dbo].[tblGatewayFee] ([GatewayFeeTypeId], [MerchantId])
GO
ALTER TABLE [dbo].[tblGatewayFee] ADD CONSTRAINT [FK_tblGatewayFee_tlkpGatewayFeeType] FOREIGN KEY ([GatewayFeeTypeId]) REFERENCES [dbo].[tlkpGatewayFeeType] ([GatewayFeeTypeId])
GO
