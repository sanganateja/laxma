SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[MONTHLY_ALLOW_RESET_REMAINING]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_account_group_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    UPDATE dbo.ACC_MONTHLY_ALLOWANCES
    SET REMAINING_UNITS = ACC_MONTHLY_ALLOWANCES.FREE_ALLOWANCE
    WHERE ACC_MONTHLY_ALLOWANCES.ACCOUNT_GROUP_ID = @p_account_group_id;

    EXECUTE dbo.MONTHLY_ALLOW_FIND_BY_ACC_GRP @cv_1 = @cv_1 OUTPUT,
                                              @p_account_group_id = @p_account_group_id;

END;
GO