SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[CT_FEE_BLENDED_SET_DEFAULTS]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_account_group_id NUMERIC,
    @p_pricing_turnover_band_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    INSERT dbo.ACC_CT_FEES_BLENDED
    (
        ACCOUNT_GROUP_ID,
        PRICING_REGION_CODE,
        FEE_DISTINGUISHER,
        PERCENTAGE,
        AMOUNT_MINOR_UNITS
    )
    SELECT @p_account_group_id AS account_group_id,
           t.PRICING_REGION_CODE,
           t.FEE_DISTINGUISHER,
           t.PERCENTAGE,
           t.AMOUNT_MINOR_UNITS
    FROM dbo.ACC_CT_PRICING_TMPLS_BLENDED AS t
    WHERE t.PRICING_TURNOVER_BAND_ID = @p_pricing_turnover_band_id;

    /* Return what we've created*/
    EXECUTE dbo.CT_FEE_BLENDED_FIND_BY_AG @cv_1 = @cv_1 OUTPUT,
                                          @p_account_group_id = @p_account_group_id;

END;
GO
