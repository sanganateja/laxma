SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[MONTHLY_ALLOWANCE_FIND]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_account_group_id NUMERIC,
    @p_transfer_method_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

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
