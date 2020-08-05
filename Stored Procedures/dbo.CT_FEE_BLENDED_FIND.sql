SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[CT_FEE_BLENDED_FIND]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_account_group_id NUMERIC,
    @p_region_code NVARCHAR(2000),
    @p_fee_distinguisher NVARCHAR(2000)
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT f.ACCOUNT_GROUP_ID,
           f.PRICING_REGION_CODE,
           f.FEE_DISTINGUISHER,
           f.PERCENTAGE,
           f.AMOUNT_MINOR_UNITS
    FROM dbo.ACC_CT_FEES_BLENDED AS f
    WHERE f.ACCOUNT_GROUP_ID = @p_account_group_id
          AND f.FEE_DISTINGUISHER = @p_fee_distinguisher
          AND f.PRICING_REGION_CODE = @p_region_code;

    RETURN;

END;
GO
