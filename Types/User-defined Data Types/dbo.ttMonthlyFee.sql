CREATE TYPE [dbo].[ttMonthlyFee] AS TABLE
(
[Currency] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AmountMinorUnits] [bigint] NOT NULL,
[FeeType] [numeric] (18, 0) NOT NULL
)
GO
GRANT EXECUTE ON TYPE:: [dbo].[ttMonthlyFee] TO [DataServiceUser] WITH GRANT OPTION
GO
