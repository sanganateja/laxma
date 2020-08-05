CREATE TYPE [dbo].[ttDatapointList] AS TABLE
(
[StartDate] [datetime2] NOT NULL,
[EndDate] [datetime2] NOT NULL
)
GO
GRANT EXECUTE ON TYPE:: [dbo].[ttDatapointList] TO [DataServiceUser]
GO
