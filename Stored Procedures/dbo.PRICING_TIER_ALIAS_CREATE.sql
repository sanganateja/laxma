SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[PRICING_TIER_ALIAS_CREATE]
    @p_pricing_tier_id NUMERIC,
    @p_pricing_tier_alias NVARCHAR(2000) /* ID*/
AS
BEGIN
    INSERT dbo.ACC_PRICING_TIER_ALIASES
    (
        PRICING_TIER_ALIAS,
        PRICING_TIER_ID
    )
    VALUES
    (@p_pricing_tier_alias, @p_pricing_tier_id);
END;
GO
