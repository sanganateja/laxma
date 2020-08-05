SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[TRANSFER_FEE_CREATE]
    @p_account_group_id NUMERIC,
    @p_amount_minor_units_in NUMERIC,
    @p_amount_minor_units_out NUMERIC,
    @p_amount_minor_units_out_add NUMERIC,
    @p_currency_code_alpha3 VARCHAR(2000),
    @p_transfer_method_id NUMERIC,
    @p_transfer_fee_id NUMERIC /* ID*/
AS
BEGIN
    INSERT dbo.ACC_TRANSFER_FEES
    (
        TRANSFER_FEE_ID,
        ACCOUNT_GROUP_ID,
        TRANSFER_METHOD_ID,
        CURRENCY_CODE_ALPHA3,
        AMOUNT_MINOR_UNITS_IN,
        AMOUNT_MINOR_UNITS_OUT,
        AMOUNT_MINOR_UNITS_OUT_ADD
    )
    VALUES
    (@p_transfer_fee_id,
     @p_account_group_id,
     @p_transfer_method_id,
     @p_currency_code_alpha3,
     @p_amount_minor_units_in,
     @p_amount_minor_units_out,
     @p_amount_minor_units_out_add);
END;
GO
