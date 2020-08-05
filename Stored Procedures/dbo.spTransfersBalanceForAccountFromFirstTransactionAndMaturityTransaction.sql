SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[spTransfersBalanceForAccountFromFirstTransactionAndMaturityTransaction]
    @cv1                NVARCHAR(2000) OUTPUT,
    @FirstTransactionId BIGINT,
    @AccountId          BIGINT
AS
SET NOCOUNT ON;
BEGIN
    SET @cv1 = NULL;

    WITH DependentTransaction AS
    (
        SELECT transaction_id FROM acc_transactions WHERE txn_first_id = @FirstTransactionId
    ),
    DependentTransfer AS
    (
        SELECT f.* FROM ACC_TRANSFERS f JOIN DependentTransaction dt ON f.TRANSACTION_ID = dt.transaction_id AND f.ACCOUNT_ID = @AccountId
    ),
    MaturityTransaction AS
    (
        SELECT DISTINCT maturity_transaction_id FROM DependentTransfer
    ),
    MaturityTransfer AS
    (
        SELECT ff.* FROM ACC_TRANSFERS ff JOIN MaturityTransaction mt ON ff.TRANSACTION_ID = mt.maturity_transaction_id AND ff.ACCOUNT_ID = @AccountId
    ),
    Total AS
    (
        SELECT ISNULL(SUM(dt.amount_minor_units), 0) AS Amount
        FROM DependentTransfer dt
        UNION
        SELECT ISNULL(SUM(mt.amount_minor_units), 0) AS Amount
        FROM MaturityTransfer mt
    )
    SELECT SUM(Amount) AS COUNT
    FROM Total;

END;
GO
