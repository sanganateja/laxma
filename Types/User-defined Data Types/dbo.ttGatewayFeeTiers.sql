CREATE TYPE [dbo].[ttGatewayFeeTiers] AS TABLE
(
[MerchantId] [bigint] NOT NULL,
[Tier] [int] NOT NULL,
[TransactionsThreshold] [bigint] NULL,
[Amount] [decimal] (12, 2) NOT NULL
)
GO
GRANT EXECUTE ON TYPE:: [dbo].[ttGatewayFeeTiers] TO [DataServiceUser]
GO
