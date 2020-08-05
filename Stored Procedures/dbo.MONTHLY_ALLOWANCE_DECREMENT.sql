SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[MONTHLY_ALLOWANCE_DECREMENT]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_account_group_id NUMERIC,
    @p_transfer_method_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    UPDATE dbo.ACC_MONTHLY_ALLOWANCES
    SET REMAINING_UNITS = ACC_MONTHLY_ALLOWANCES.REMAINING_UNITS - 1
    WHERE ACC_MONTHLY_ALLOWANCES.ACCOUNT_GROUP_ID = @p_account_group_id
          AND ACC_MONTHLY_ALLOWANCES.TRANSFER_METHOD_ID = @p_transfer_method_id
          AND ACC_MONTHLY_ALLOWANCES.REMAINING_UNITS > 0;

    IF @@ROWCOUNT > 0
        /* Remaining Units was decremented, return original value*/
        SELECT ma.MONTHLY_ALLOWANCE_ID,
               ma.ACCOUNT_GROUP_ID,
               ma.TRANSFER_METHOD_ID,
               ma.FREE_ALLOWANCE,
               ma.REMAINING_UNITS + 1 AS remaining_units
        FROM dbo.ACC_MONTHLY_ALLOWANCES AS ma
        WHERE ma.ACCOUNT_GROUP_ID = @p_account_group_id
              AND ma.TRANSFER_METHOD_ID = @p_transfer_method_id;
    ELSE
        /* RemainingUnits was not decremented (it must be zero). Return it.*/
        SELECT ma.MONTHLY_ALLOWANCE_ID,
               ma.TRANSFER_METHOD_ID,
               ma.FREE_ALLOWANCE,
               ma.ACCOUNT_GROUP_ID,
               ma.REMAINING_UNITS
        FROM dbo.ACC_MONTHLY_ALLOWANCES AS ma
        WHERE ma.ACCOUNT_GROUP_ID = @p_account_group_id
              AND ma.TRANSFER_METHOD_ID = @p_transfer_method_id;

    RETURN;

END;
GO
