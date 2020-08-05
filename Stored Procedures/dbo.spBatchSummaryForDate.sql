SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[spBatchSummaryForDate]
    @cv_1 VARCHAR(2000) OUTPUT,
    @BatchDate DATETIME2(6),
    @Status NVARCHAR(2000),
    @AccountId BIGINT
AS
BEGIN
    DECLARE @NextDate DATE,
            @Balance BIGINT;

    SET NOCOUNT ON
    SET @cv_1 = NULL
    SET @NextDate = DATEADD(day, 1, @BatchDate);

    SELECT x.MaturityTransactionId,
           x.MaturityTime,
           x.[Status],
           x.Balance
    FROM
    (
        -- Transfers that were matured during the specified day = Closed batches
        SELECT t.TRANSACTION_ID AS MaturityTransactionId,
               t.TRANSACTION_TIME AS MaturityTime,
               'CLOSED' AS [Status],
               SUM(f.AMOUNT_MINOR_UNITS) AS Balance
        FROM dbo.ACC_TRANSFERS f JOIN dbo.ACC_TRANSACTIONS t ON f.MATURITY_TRANSACTION_ID = t.TRANSACTION_ID
        WHERE f.ACCOUNT_ID = @AccountId
          AND f.MATURITY_TRANSACTION_ID IS NOT NULL
          AND t.TRANSACTION_TIME >= @BatchDate
          AND t.TRANSACTION_TIME < @NextDate
          AND (@Status IS NULL OR @Status = 'Closed')
        GROUP BY t.TRANSACTION_ID,
                 t.TRANSACTION_TIME

        UNION

        -- Unmatured transfers with a maturity date during the specified day = Open batches
        SELECT NULL AS MaturityTransactionId,
               NULL AS MaturityTime,
               'OPEN' AS [Status],
               SUM(f.AMOUNT_MINOR_UNITS) AS Balance
        FROM dbo.ACC_TRANSFERS f
        WHERE f.ACCOUNT_ID = @AccountId
          AND f.MATURITY_TRANSACTION_ID IS NULL
          AND f.MATURITY_TIME >= @BatchDate
          AND f.MATURITY_TIME < @NextDate
          AND (@Status IS NULL OR @Status = 'Open')
    ) x
    WHERE x.Balance IS NOT NULL
    ORDER BY x.Status,
             x.MaturityTime;

END;
GO
