SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[PRICING_TIER_MONTH_UPDATE]
    @p_amount_minor_units NUMERIC,
    @p_currency_code_alpha3 VARCHAR(2000),
    @p_pricing_tier_id NUMERIC,
    @p_tier_monthly_fee_id NUMERIC /* ID*/
AS
BEGIN
    UPDATE dbo.ACC_PRICING_TIER_MONTHLY_FEES
    SET PRICING_TIER_ID = @p_pricing_tier_id,
        CURRENCY_CODE_ALPHA3 = @p_currency_code_alpha3,
        AMOUNT_MINOR_UNITS = @p_amount_minor_units
    FROM dbo.ACC_PRICING_TIER_MONTHLY_FEES AS ptmf
    WHERE ptmf.TIER_MONTHLY_FEE_ID = @p_tier_monthly_fee_id;
END;
GO
