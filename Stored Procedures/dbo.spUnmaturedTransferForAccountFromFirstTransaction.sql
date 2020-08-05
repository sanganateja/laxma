SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[spUnmaturedTransferForAccountFromFirstTransaction]
    @cv1                NVARCHAR(2000) OUTPUT,
    @FirstTransactionId BIGINT,
    @AccountId          BIGINT
AS
SET NOCOUNT ON;
BEGIN
    SET @cv1 = NULL;

    WITH DependentTransaction (transaction_id) AS
    (
        SELECT transaction_id FROM acc_transactions WHERE txn_first_id = @FirstTransactionId
    )
    SELECT TOP 1 f.transfer_id,
                 f.account_id,
                 f.amount_minor_units,
                 f.balance_after_minor_units,
                 f.batch_id,
                 f.transaction_id,
                 f.transfer_method_id,
                 f.transfer_time,
                 f.transfer_type_id,
                 f.maturity_time,
                 f.maturity_transaction_id
    FROM acc_transfers f JOIN DependentTransaction dt ON f.transaction_id = dt.transaction_id
    WHERE f.maturity_transaction_id IS NULL
      AND f.account_id = @AccountId;
END;
GO
