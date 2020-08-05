CREATE TYPE [dbo].[ttMerchantAccountGroupHoldState] AS TABLE
(
[AccountNumber] [bigint] NOT NULL,
[HoldState] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Reason] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
)
GO
GRANT EXECUTE ON TYPE:: [dbo].[ttMerchantAccountGroupHoldState] TO [DataServiceUser]
GO
