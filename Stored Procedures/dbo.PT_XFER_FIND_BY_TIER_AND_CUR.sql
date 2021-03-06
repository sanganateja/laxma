SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[PT_XFER_FIND_BY_TIER_AND_CUR]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_pricing_tier_id NUMERIC,
    @p_currency NVARCHAR(2000)
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT pttf.TIER_TRANSFER_FEE_ID,
           pttf.PRICING_TIER_ID,
           pttf.TRANSFER_METHOD_ID,
           pttf.CURRENCY_CODE_ALPHA3,
           pttf.AMOUNT_MINOR_UNITS_OUT,
           pttf.AMOUNT_MINOR_UNITS_IN,
           pttf.AMOUNT_MINOR_UNITS_OUT_ADD
    FROM dbo.ACC_PRICING_TIER_TRANSFER_FEES AS pttf
    WHERE pttf.PRICING_TIER_ID = @p_pricing_tier_id
          AND pttf.CURRENCY_CODE_ALPHA3 = @p_currency;

    RETURN;

END;
GO
