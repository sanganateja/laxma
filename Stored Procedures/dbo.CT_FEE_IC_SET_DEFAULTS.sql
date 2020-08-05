SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[CT_FEE_IC_SET_DEFAULTS]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_account_group_id NUMERIC,
    @p_pricing_turnover_band_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    INSERT dbo.ACC_CT_FEES_IC
    (
        ACCOUNT_GROUP_ID,
        PERCENTAGE,
        AMOUNT_MINOR_UNITS
    )
    SELECT @p_account_group_id AS account_group_id,
           t.PERCENTAGE,
           t.AMOUNT_MINOR_UNITS
    FROM dbo.ACC_CT_PRICING_TMPLS_IC AS t
    WHERE t.PRICING_TURNOVER_BAND_ID = @p_pricing_turnover_band_id;

    /* Return what we've created*/
    EXECUTE dbo.CT_FEE_IC_FIND_BY_AG @cv_1 = @cv_1 OUTPUT,
                                     @p_account_group_id = @p_account_group_id;

END;
GO
