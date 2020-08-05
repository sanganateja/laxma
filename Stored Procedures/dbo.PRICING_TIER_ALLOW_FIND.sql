SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[PRICING_TIER_ALLOW_FIND]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_pricing_tier_id NUMERIC,
    @p_transfer_method_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT pta.TIER_ALLOWANCE_ID,
           pta.PRICING_TIER_ID,
           pta.TRANSFER_METHOD_ID,
           pta.FREE_ALLOWANCE
    FROM dbo.ACC_PRICING_TIER_ALLOWANCES AS pta
    WHERE pta.PRICING_TIER_ID = @p_pricing_tier_id
          AND pta.TRANSFER_METHOD_ID = @p_transfer_method_id;

    RETURN;

END;
GO
