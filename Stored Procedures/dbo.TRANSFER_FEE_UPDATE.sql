SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[TRANSFER_FEE_UPDATE]
    @p_account_group_id NUMERIC,
    @p_amount_minor_units_in NUMERIC,
    @p_amount_minor_units_out NUMERIC,
    @p_amount_minor_units_out_add NUMERIC,
    @p_currency_code_alpha3 VARCHAR(2000),
    @p_transfer_method_id NUMERIC,
    @p_transfer_fee_id NUMERIC /* ID*/
AS
BEGIN
    UPDATE dbo.ACC_TRANSFER_FEES
    SET ACCOUNT_GROUP_ID = @p_account_group_id,
        TRANSFER_METHOD_ID = @p_transfer_method_id,
        CURRENCY_CODE_ALPHA3 = @p_currency_code_alpha3,
        AMOUNT_MINOR_UNITS_IN = @p_amount_minor_units_in,
        AMOUNT_MINOR_UNITS_OUT = @p_amount_minor_units_out,
        AMOUNT_MINOR_UNITS_OUT_ADD = @p_amount_minor_units_out_add
    FROM dbo.ACC_TRANSFER_FEES AS tf
    WHERE tf.TRANSFER_FEE_ID = @p_transfer_fee_id;
END;
GO
