CREATE TYPE [dbo].[ttGenericFees] AS TABLE
(
[FeeId] [bigint] NOT NULL,
[Percentage] [decimal] (18, 2) NOT NULL,
[AmountMinorUnits] [bigint] NOT NULL
)
GO
GRANT EXECUTE ON TYPE:: [dbo].[ttGenericFees] TO [DataServiceUser]
GO
