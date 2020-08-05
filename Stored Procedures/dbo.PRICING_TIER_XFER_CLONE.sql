SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   PROCEDURE [dbo].[PRICING_TIER_XFER_CLONE]
(
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_source_pricing_tier_id NUMERIC,
    @p_target_pricing_tier_id NUMERIC
)
AS
BEGIN

    SET @cv_1 = NULL;

    MERGE INTO acc_pricing_tier_transfer_fees pttft
    USING acc_pricing_tier_transfer_fees pttfs
    ON (
           pttft.pricing_tier_id = @p_target_pricing_tier_id
           AND pttfs.pricing_tier_id = @p_source_pricing_tier_id
           AND pttft.transfer_method_id = pttfs.transfer_method_id
           AND pttft.currency_code_alpha3 = pttfs.currency_code_alpha3
       )
    WHEN MATCHED THEN
        UPDATE SET pttft.amount_minor_units_out = pttfs.amount_minor_units_out,
                   pttft.amount_minor_units_in = pttfs.amount_minor_units_in,
                   pttft.amount_minor_units_out_add = pttfs.amount_minor_units_out_add
    WHEN NOT MATCHED AND pttfs.pricing_tier_id = @p_source_pricing_tier_id THEN
        INSERT
        (
            pricing_tier_id,
            transfer_method_id,
            currency_code_alpha3,
            amount_minor_units_out,
            amount_minor_units_in,
            amount_minor_units_out_add
        )
        VALUES
        (@p_target_pricing_tier_id,
         pttfs.transfer_method_id,
         pttfs.currency_code_alpha3,
         pttfs.amount_minor_units_out,
         pttfs.amount_minor_units_in,
         pttfs.amount_minor_units_out_add);

    EXEC pricing_tier_xfer_find_by_tier @cv_1, @p_target_pricing_tier_id;

END;
GO
