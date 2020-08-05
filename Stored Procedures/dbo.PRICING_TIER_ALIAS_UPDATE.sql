SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[PRICING_TIER_ALIAS_UPDATE]
    @p_pricing_tier_id NUMERIC,
    @p_pricing_tier_alias NVARCHAR(2000) /* ID*/
AS
BEGIN
    UPDATE dbo.ACC_PRICING_TIER_ALIASES
    SET PRICING_TIER_ID = @p_pricing_tier_id
    FROM dbo.ACC_PRICING_TIER_ALIASES AS pta
    WHERE pta.PRICING_TIER_ALIAS = @p_pricing_tier_alias;
END;
GO
