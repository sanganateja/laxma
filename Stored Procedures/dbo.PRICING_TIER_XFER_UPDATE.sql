SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[PRICING_TIER_XFER_UPDATE]
    @p_amount_minor_units_in NUMERIC,
    @p_amount_minor_units_out NUMERIC,
    @p_amount_minor_units_out_add NUMERIC,
    @p_currency_code_alpha3 VARCHAR(2000),
    @p_pricing_tier_id NUMERIC,
    @p_transfer_method_id NUMERIC,
    @p_tier_transfer_fee_id NUMERIC /* ID*/
AS
BEGIN
    UPDATE dbo.ACC_PRICING_TIER_TRANSFER_FEES
    SET PRICING_TIER_ID = @p_pricing_tier_id,
        TRANSFER_METHOD_ID = @p_transfer_method_id,
        CURRENCY_CODE_ALPHA3 = @p_currency_code_alpha3,
        AMOUNT_MINOR_UNITS_IN = @p_amount_minor_units_in,
        AMOUNT_MINOR_UNITS_OUT = @p_amount_minor_units_out,
        AMOUNT_MINOR_UNITS_OUT_ADD = @p_amount_minor_units_out_add
    FROM dbo.ACC_PRICING_TIER_TRANSFER_FEES AS pttf
    WHERE pttf.TIER_TRANSFER_FEE_ID = @p_tier_transfer_fee_id;
END;
GO
