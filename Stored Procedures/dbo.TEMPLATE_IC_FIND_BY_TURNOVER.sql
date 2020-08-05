SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[TEMPLATE_IC_FIND_BY_TURNOVER]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_pricing_turnover_band_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT t.TEMPLATE_IC_ID,
           t.PRICING_TURNOVER_BAND_ID,
           t.PERCENTAGE,
           t.AMOUNT_MINOR_UNITS,
           t.FEE_DISTINGUISHER
    FROM dbo.ACC_PRICING_TEMPLATES_IC AS t
    WHERE t.PRICING_TURNOVER_BAND_ID = @p_pricing_turnover_band_id
    ORDER BY t.FEE_DISTINGUISHER DESC;

    RETURN;

END;
GO
