SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[MONTHLY_FEE_CREATE]
    @p_amount_minor_units NUMERIC,
    @p_currency_code_alpha3 VARCHAR(2000),
    @p_fee_type_id NUMERIC,
    @p_owner_id NUMERIC,
    @p_monthly_fee_id NUMERIC /* ID*/
AS
BEGIN
    INSERT dbo.ACC_MONTHLY_FEES
    (
        MONTHLY_FEE_ID,
        OWNER_ID,
        CURRENCY_CODE_ALPHA3,
        AMOUNT_MINOR_UNITS,
        FEE_TYPE_ID
    )
    VALUES
    (@p_monthly_fee_id, @p_owner_id, @p_currency_code_alpha3, @p_amount_minor_units, @p_fee_type_id);
END;
GO
