SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[TRANS_MARGIN_CREATE]
    @p_fixed_amount_minor FLOAT,
    @p_fixed_currency NVARCHAR(2000),
    @p_fx_rate NUMERIC(12, 6),
    @p_trans_id NUMERIC,
    @p_type_id NUMERIC,
    @p_variable_amount_minor FLOAT,
    @p_variable_currency NVARCHAR(2000),
    @p_id NUMERIC /* ID*/
AS
BEGIN
    INSERT dbo.ACC_TRANSACTION_MARGINS
    (
        TRANSACTION_MARGIN_ID,
        TRANSACTION_ID,
        TYPE_ID,
        FIXED_AMOUNT_MINOR_UNITS,
        FIXED_CURRENCY_CODE_ALPHA3,
        VAR_AMOUNT_MINOR_UNITS,
        VAR_CURRENCY_CODE_ALPHA3,
        FX_RATE_APPLIED_PRICING
    )
    VALUES
    (@p_id,
     @p_trans_id,
     @p_type_id,
     @p_fixed_amount_minor,
     @p_fixed_currency,
     @p_variable_amount_minor,
     @p_variable_currency,
     @p_fx_rate);
END;
GO
