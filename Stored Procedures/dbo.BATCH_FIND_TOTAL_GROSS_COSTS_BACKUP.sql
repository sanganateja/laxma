SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE   PROCEDURE [dbo].[BATCH_FIND_TOTAL_GROSS_COSTS_BACKUP]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_batch_id BIGINT
AS
BEGIN
    DECLARE @v_total_gross_costs BIGINT;

    SELECT @v_total_gross_costs = SUM(f.amount_minor_units)
    FROM acc_transfers f JOIN acc_accounts a ON f.account_id = a.account_id AND a.account_type_id = 1
    WHERE f.transaction_id IN
    (
        SELECT DISTINCT transaction_id
        FROM acc_transfers
        WHERE batch_id = @p_batch_id
    )
      AND f.transfer_type_id NOT IN (68,70,86,87);  -- Partner_Commission, Partner_Negative_Commission, Partner_Commission_Void, Partner_Negative_Commission_Void

    SELECT ISNULL(@v_total_gross_costs, 0) AS TOTAL_GROSS_COSTS;

    RETURN;
END;
GO
