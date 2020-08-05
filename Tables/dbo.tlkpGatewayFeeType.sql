CREATE TABLE [dbo].[tlkpGatewayFeeType]
(
[GatewayFeeTypeId] [int] NOT NULL IDENTITY(1, 1),
[GatewayFeeType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tlkpGatewayFeeType] ADD CONSTRAINT [PK_tlkpGatewayFeeType] PRIMARY KEY CLUSTERED  ([GatewayFeeTypeId]) ON [PRIMARY]
GO
