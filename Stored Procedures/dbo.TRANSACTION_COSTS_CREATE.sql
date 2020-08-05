SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[TRANSACTION_COSTS_CREATE]
    @p_designator_id NUMERIC,
    @p_type_id NUMERIC,
    @p_fixed_amount_minor_units NUMERIC,
    @p_fixed_currency_code VARCHAR(2000),
    @p_fx_rate_applied_pricing NUMERIC(12, 6),
    @p_transaction_id NUMERIC,
    @p_variable_amount_minor_units NUMERIC(24, 6),
    @p_variable_currency_code VARCHAR(2000),
    @p_transaction_cost_id NUMERIC
AS
BEGIN
    INSERT dbo.ACC_TRANSACTION_COSTS
    (
        FIXED_AMOUNT_MINOR_UNITS,
        FIXED_CURRENCY_CODE_ALPHA3,
        FX_RATE_APPLIED_PRICING,
        DESIGNATOR_ID,
        TRANSACTION_ID,
        TYPE_ID,
        VARIABLE_AMOUNT_MINOR_UNITS,
        VARIABLE_CURRENCY_CODE_ALPHA3,
        TRANSACTION_COST_ID
    )
    VALUES
    (@p_fixed_amount_minor_units,
     @p_fixed_currency_code,
     @p_fx_rate_applied_pricing,
     @p_designator_id,
     @p_transaction_id,
     @p_type_id,
     @p_variable_amount_minor_units,
     @p_variable_currency_code,
     @p_transaction_cost_id);
END;
GO
