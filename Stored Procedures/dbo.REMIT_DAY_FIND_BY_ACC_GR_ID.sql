SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[REMIT_DAY_FIND_BY_ACC_GR_ID]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_account_group_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT r.REMIT_DAY_ID,
           r.REMIT_DAY,
           r.ACCOUNT_GROUP_ID
    FROM dbo.ACC_REMIT_DAYS AS r
    WHERE r.ACCOUNT_GROUP_ID = @p_account_group_id;

    RETURN;

END;
GO