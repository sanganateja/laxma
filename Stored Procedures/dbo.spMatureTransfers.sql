SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[spMatureTransfers]
    @cv_1                  VARCHAR(2000) OUTPUT,
    @AccountId             BIGINT,
    @MaturityTime          DATETIME2,
    @MaturityTransactionId BIGINT
AS
BEGIN
    SET NOCOUNT ON 
    SET @cv_1 = NULL;

    DECLARE @UpdatedIDs TABLE (ID BIGINT);

    UPDATE ACC_TRANSFERS
    SET MATURITY_TRANSACTION_ID = @MaturityTransactionId
    OUTPUT INSERTED.TRANSFER_ID INTO @UpdatedIDs
    WHERE ACCOUNT_ID = @AccountId
      AND MATURITY_TRANSACTION_ID IS NULL
      AND MATURITY_TIME <= @MaturityTime;

    SELECT @AccountId AS AccountId,
           ISNULL(COUNT(f.TRANSFER_ID), 0) AS NumberTransfers,
           ISNULL(SUM(f.AMOUNT_MINOR_UNITS), 0) AS Balance
    FROM ACC_TRANSFERS f JOIN @UpdatedIDs i ON f.TRANSFER_ID = i.ID;
END;
GO
