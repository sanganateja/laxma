CREATE TYPE [dbo].[ttMerchantAccounts] AS TABLE
(
[MerchantId] [bigint] NOT NULL,
[Currency] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AccountNumber] [bigint] NOT NULL
)
GO
GRANT EXECUTE ON TYPE:: [dbo].[ttMerchantAccounts] TO [DataServiceUser]
GO
