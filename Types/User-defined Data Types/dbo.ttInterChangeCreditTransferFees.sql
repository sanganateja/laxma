CREATE TYPE [dbo].[ttInterChangeCreditTransferFees] AS TABLE
(
[AccountNumber] [bigint] NOT NULL,
[AmountMinorUnits] [bigint] NOT NULL,
[Percentage] [numeric] (18, 2) NOT NULL
)
GO
GRANT EXECUTE ON TYPE:: [dbo].[ttInterChangeCreditTransferFees] TO [DataServiceUser]
GO
