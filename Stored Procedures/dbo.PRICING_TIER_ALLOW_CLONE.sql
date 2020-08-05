SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[PRICING_TIER_ALLOW_CLONE]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_source_pricing_tier_id NUMERIC,
    @p_target_pricing_tier_id NUMERIC
AS
BEGIN

    MERGE INTO acc_pricing_tier_allowances ptat
    USING acc_pricing_tier_allowances ptas
    ON (
           ptat.pricing_tier_id = @p_target_pricing_tier_id
           AND ptas.pricing_tier_id = @p_source_pricing_tier_id
           AND ptat.transfer_method_id = ptas.transfer_method_id
       )
    WHEN MATCHED THEN
        UPDATE SET ptat.free_allowance = ptas.free_allowance
    WHEN NOT MATCHED AND ptas.pricing_tier_id = @p_source_pricing_tier_id THEN
        INSERT
        (
            pricing_tier_id,
            transfer_method_id,
            free_allowance
        )
        VALUES
        (@p_target_pricing_tier_id, ptas.transfer_method_id, ptas.free_allowance);

    EXEC pricing_tier_allow_find_all @cv_1, @p_target_pricing_tier_id;
END;
GO
