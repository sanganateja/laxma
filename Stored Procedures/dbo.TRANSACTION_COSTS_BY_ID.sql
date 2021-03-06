SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[TRANSACTION_COSTS_BY_ID]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_transaction_cost_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT ACC_TRANSACTION_COSTS.TRANSACTION_COST_ID,
           ACC_TRANSACTION_COSTS.TRANSACTION_ID,
           ACC_TRANSACTION_COSTS.TYPE_ID,
           ACC_TRANSACTION_COSTS.DESIGNATOR_ID,
           ACC_TRANSACTION_COSTS.FIXED_CURRENCY_CODE_ALPHA3,
           ACC_TRANSACTION_COSTS.FIXED_AMOUNT_MINOR_UNITS,
           ACC_TRANSACTION_COSTS.VARIABLE_CURRENCY_CODE_ALPHA3,
           ACC_TRANSACTION_COSTS.VARIABLE_AMOUNT_MINOR_UNITS,
           ACC_TRANSACTION_COSTS.FX_RATE_APPLIED_PRICING
    FROM dbo.ACC_TRANSACTION_COSTS
    WHERE ACC_TRANSACTION_COSTS.TRANSACTION_COST_ID = @p_transaction_cost_id;

    RETURN;

END;
GO
