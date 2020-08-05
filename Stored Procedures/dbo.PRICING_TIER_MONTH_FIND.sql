SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[PRICING_TIER_MONTH_FIND]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_pricing_tier_id NUMERIC,
    @p_currency_code_alpha3 VARCHAR(2000)
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT ptmf.TIER_MONTHLY_FEE_ID,
           ptmf.PRICING_TIER_ID,
           ptmf.CURRENCY_CODE_ALPHA3,
           ptmf.AMOUNT_MINOR_UNITS
    FROM dbo.ACC_PRICING_TIER_MONTHLY_FEES AS ptmf
    WHERE ptmf.PRICING_TIER_ID = @p_pricing_tier_id
          AND ptmf.CURRENCY_CODE_ALPHA3 = @p_currency_code_alpha3;

    RETURN;

END;
GO
