SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[PRICING_TURNOVER_ALIAS_CREATE]
    @p_pricing_turnover_band_id NUMERIC,
    @p_pricing_turnover_band_alias NVARCHAR(2000) /* ID*/
AS
BEGIN
    INSERT dbo.ACC_PRICING_TURNOVER_ALIASES
    (
        PRICING_TURNOVER_BAND_ALIAS,
        PRICING_TURNOVER_BAND_ID
    )
    VALUES
    (@p_pricing_turnover_band_alias, @p_pricing_turnover_band_id);
END;
GO
