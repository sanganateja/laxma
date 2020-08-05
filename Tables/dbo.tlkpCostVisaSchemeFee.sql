CREATE TABLE [dbo].[tlkpCostVisaSchemeFee]
(
[FeeId] [bigint] NOT NULL IDENTITY(1, 1),
[EffectiveFrom] [datetime2] NULL,
[EffectiveUntil] [datetime2] NULL,
[MerchantCountryRegion] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IssuerCountryRegion] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardType] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FeePercentAsMultiplier] [decimal] (18, 8) NULL,
[FixedFeeMajorUnit] [decimal] (18, 8) NULL,
[FixedFeeCurrency] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tlkpCostVisaSchemeFee] ADD CONSTRAINT [PK_tlkpCostVisaSchemeFee] PRIMARY KEY CLUSTERED  ([FeeId]) ON [PRIMARY]
GO
