SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[MONTHLY_FEE_UPDATE]
    @p_amount_minor_units NUMERIC,
    @p_currency_code_alpha3 VARCHAR(2000),
    @p_fee_type_id NUMERIC,
    @p_owner_id NUMERIC,
    @p_monthly_fee_id NUMERIC /* ID*/
AS
BEGIN
    UPDATE dbo.ACC_MONTHLY_FEES
    SET OWNER_ID = @p_owner_id,
        CURRENCY_CODE_ALPHA3 = @p_currency_code_alpha3,
        AMOUNT_MINOR_UNITS = @p_amount_minor_units
    FROM dbo.ACC_MONTHLY_FEES AS mf
    WHERE mf.MONTHLY_FEE_ID = @p_monthly_fee_id
          AND mf.FEE_TYPE_ID = @p_fee_type_id;
END;
GO
