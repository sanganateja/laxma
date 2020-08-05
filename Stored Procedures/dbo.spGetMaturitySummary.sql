SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[spGetMaturitySummary]
    @cv_1            VARCHAR(2000) OUTPUT,
    @AccountId       BIGINT,
    @MaturityTime    DATETIME2
AS
BEGIN
    SET NOCOUNT ON 
    SET @cv_1 = NULL;

    WITH Summary AS
    (
        SELECT a.ACCOUNT_ID AS AccountId,
               COUNT(f.TRANSFER_ID) AS NumberTransfers,
               SUM(f.AMOUNT_MINOR_UNITS) AS Balance
        FROM ACC_ACCOUNTS a JOIN ACC_TRANSFERS f ON a.ACCOUNT_ID = f.ACCOUNT_ID
        WHERE a.ACCOUNT_ID = @AccountId
          AND f.MATURITY_TIME <= @MaturityTime
          AND f.MATURITY_TRANSACTION_ID IS NULL
        GROUP BY a.ACCOUNT_ID
        UNION
        SELECT @AccountId AS AccountId,
               0 AS NumberTransfers,
               0 AS Balance
    )
    SELECT @AccountId AS AccountId,
           SUM(s.NumberTransfers) AS NumberTransfers,
           SUM(s.Balance) AS Balance
    FROM Summary s;

END;
GO
