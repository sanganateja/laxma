CREATE TYPE [dbo].[ttTransactionTypeList] AS TABLE
(
[TransactionTypeId] [smallint] NOT NULL
)
GO
GRANT EXECUTE ON TYPE:: [dbo].[ttTransactionTypeList] TO [DataServiceUser] WITH GRANT OPTION
GO
