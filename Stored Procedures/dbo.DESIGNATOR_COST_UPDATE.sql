SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[DESIGNATOR_COST_UPDATE]
    @p_currency_code_alpha3 VARCHAR(2000),
    @p_designator_id NUMERIC,
    @p_fixed_amount_minor_units NUMERIC,
    @p_max_amount NUMERIC,
    @p_max_return_amount NUMERIC,
    @p_min_amount NUMERIC,
    @p_min_return_amount NUMERIC,
    @p_valid_from DATETIME2(6),
    @p_valid_to DATETIME2(6),
    @p_variable_pctg NUMERIC(12, 8),
    @p_cost_id NUMERIC /* ID*/
AS
BEGIN
    UPDATE dbo.CST_DESIGNATOR_COSTS
    SET CURRENCY_CODE_ALPHA3 = @p_currency_code_alpha3,
        DESIGNATOR_ID = @p_designator_id,
        FIXED_AMOUNT_MINOR_UNITS = @p_fixed_amount_minor_units,
        MAX_AMOUNT = @p_max_amount,
        MAX_RETURN_AMOUNT = @p_max_return_amount,
        MIN_AMOUNT = @p_min_amount,
        MIN_RETURN_AMOUNT = @p_min_return_amount,
        VALID_FROM = @p_valid_from,
        VALID_TO = @p_valid_to,
        VARIABLE_PCTG = @p_variable_pctg
    WHERE CST_DESIGNATOR_COSTS.COST_ID = @p_cost_id;
END;
GO
