SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[TRANSFER_FIND_BY_TRANS_OW]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_transaction_id NUMERIC,
    @p_owner_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT t.TRANSFER_ID,
           t.TRANSFER_TIME,
           t.ACCOUNT_ID,
           t.TRANSFER_TYPE_ID,
           t.AMOUNT_MINOR_UNITS,
           t.BALANCE_AFTER_MINOR_UNITS,
           t.BATCH_ID,
           t.TRANSACTION_ID,
           t.TRANSFER_METHOD_ID,
           t.MATURITY_TIME,
           t.MATURITY_TRANSACTION_ID
    FROM dbo.ACC_TRANSFERS AS t
        JOIN dbo.ACC_ACCOUNTS AS a
            ON t.ACCOUNT_ID = a.ACCOUNT_ID
        JOIN dbo.ACC_ACCOUNT_GROUPS AS ag
            ON a.ACCOUNT_GROUP_ID = ag.ACCOUNT_GROUP_ID
               AND ag.OWNER_ID = @p_owner_id
    WHERE t.TRANSACTION_ID = @p_transaction_id
    ORDER BY t.TRANSFER_ID;

    RETURN;

END;
GO
