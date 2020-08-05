SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACQUIRING_FEE_FIND_BY_ID]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_fee_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT af.FEE_ID,
           af.ACCOUNT_GROUP_ID,
           af.EVENT_TYPE_ID,
           af.PERCENTAGE,
           af.AMOUNT_MINOR_UNITS
    FROM dbo.ACC_ACQUIRING_FEES AS af
    WHERE af.FEE_ID = @p_fee_id;

    RETURN;

END;
GO