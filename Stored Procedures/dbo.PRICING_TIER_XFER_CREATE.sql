SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[PRICING_TIER_XFER_CREATE]
    @p_amount_minor_units_in NUMERIC,
    @p_amount_minor_units_out NUMERIC,
    @p_amount_minor_units_out_add NUMERIC,
    @p_currency_code_alpha3 VARCHAR(2000),
    @p_pricing_tier_id NUMERIC,
    @p_transfer_method_id NUMERIC,
    @p_tier_transfer_fee_id NUMERIC /* ID*/
AS
BEGIN
    INSERT dbo.ACC_PRICING_TIER_TRANSFER_FEES
    (
        TIER_TRANSFER_FEE_ID,
        PRICING_TIER_ID,
        TRANSFER_METHOD_ID,
        CURRENCY_CODE_ALPHA3,
        AMOUNT_MINOR_UNITS_IN,
        AMOUNT_MINOR_UNITS_OUT,
        AMOUNT_MINOR_UNITS_OUT_ADD
    )
    VALUES
    (@p_tier_transfer_fee_id,
     @p_pricing_tier_id,
     @p_transfer_method_id,
     @p_currency_code_alpha3,
     @p_amount_minor_units_in,
     @p_amount_minor_units_out,
     @p_amount_minor_units_out_add);
END;
GO
