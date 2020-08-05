SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[DESIGNATOR_COST_CREATE]
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
    INSERT dbo.CST_DESIGNATOR_COSTS
    (
        CURRENCY_CODE_ALPHA3,
        DESIGNATOR_ID,
        FIXED_AMOUNT_MINOR_UNITS,
        MAX_AMOUNT,
        MAX_RETURN_AMOUNT,
        MIN_AMOUNT,
        MIN_RETURN_AMOUNT,
        VALID_FROM,
        VALID_TO,
        VARIABLE_PCTG,
        COST_ID
    )
    VALUES
    (@p_currency_code_alpha3,
     @p_designator_id,
     @p_fixed_amount_minor_units,
     @p_max_amount,
     @p_max_return_amount,
     @p_min_amount,
     @p_min_return_amount,
     @p_valid_from,
     @p_valid_to,
     @p_variable_pctg,
     @p_cost_id);
END;
GO
