SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[PRICING_TURNOVER_ALIAS_FIND_ID]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_pricing_turnover_band_alias NVARCHAR(2000)
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT pta.PRICING_TURNOVER_BAND_ALIAS,
           pta.PRICING_TURNOVER_BAND_ID
    FROM dbo.ACC_PRICING_TURNOVER_ALIASES AS pta
    WHERE pta.PRICING_TURNOVER_BAND_ALIAS = @p_pricing_turnover_band_alias;

    RETURN;

END;
GO