SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[PRICING_TIER_MONTH_CLONE]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_source_pricing_tier_id NUMERIC,
    @p_target_pricing_tier_id NUMERIC
AS
BEGIN

    MERGE INTO acc_pricing_tier_monthly_fees ptmft
    USING acc_pricing_tier_monthly_fees ptmfs
    ON (
           ptmft.pricing_tier_id = @p_target_pricing_tier_id
           AND ptmfs.pricing_tier_id = @p_source_pricing_tier_id
           AND ptmft.currency_code_alpha3 = ptmfs.currency_code_alpha3
       )
    WHEN MATCHED THEN
        UPDATE SET ptmft.amount_minor_units = ptmfs.amount_minor_units
    WHEN NOT MATCHED AND ptmfs.pricing_tier_id = @p_source_pricing_tier_id THEN
        INSERT
        (
            pricing_tier_id,
            currency_code_alpha3,
            amount_minor_units
        )
        VALUES
        (@p_target_pricing_tier_id, ptmfs.currency_code_alpha3, ptmfs.amount_minor_units);

    EXEC pricing_tier_month_findby_tier @cv_1, @p_target_pricing_tier_id;

END;
GO
