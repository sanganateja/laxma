CREATE TYPE [dbo].[ttGatewayFees] AS TABLE
(
[GatewayFeeTypeId] [int] NOT NULL,
[MerchantId] [bigint] NOT NULL,
[Amount] [decimal] (12, 2) NOT NULL
)
GO
GRANT EXECUTE ON TYPE:: [dbo].[ttGatewayFees] TO [DataServiceUser]
GO
