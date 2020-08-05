SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[DESIGNATOR_COST_BY_ID]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_cost_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT CST_DESIGNATOR_COSTS.COST_ID,
           CST_DESIGNATOR_COSTS.VALID_FROM,
           CST_DESIGNATOR_COSTS.DESIGNATOR_ID,
           CST_DESIGNATOR_COSTS.CURRENCY_CODE_ALPHA3,
           CST_DESIGNATOR_COSTS.FIXED_AMOUNT_MINOR_UNITS,
           CST_DESIGNATOR_COSTS.VARIABLE_PCTG,
           CST_DESIGNATOR_COSTS.VALID_TO,
           CST_DESIGNATOR_COSTS.MIN_AMOUNT,
           CST_DESIGNATOR_COSTS.MAX_AMOUNT,
           CST_DESIGNATOR_COSTS.MIN_RETURN_AMOUNT,
           CST_DESIGNATOR_COSTS.MAX_RETURN_AMOUNT
    FROM dbo.CST_DESIGNATOR_COSTS
    WHERE CST_DESIGNATOR_COSTS.COST_ID = @p_cost_id;

    RETURN;

END;
GO
