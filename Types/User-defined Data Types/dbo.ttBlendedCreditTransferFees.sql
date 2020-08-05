CREATE TYPE [dbo].[ttBlendedCreditTransferFees] AS TABLE
(
[AccountNumber] [bigint] NOT NULL,
[Region] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FeeDistinguisher] [nvarchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AmountMinorUnits] [bigint] NOT NULL,
[Percentage] [numeric] (18, 4) NOT NULL
)
GO
GRANT EXECUTE ON TYPE:: [dbo].[ttBlendedCreditTransferFees] TO [DataServiceUser]
GO
