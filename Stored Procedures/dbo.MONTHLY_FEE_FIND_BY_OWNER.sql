SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[MONTHLY_FEE_FIND_BY_OWNER]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_owner_id NUMERIC,
    @p_currency_code_alpha3 VARCHAR(2000),
    @p_fee_type_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT mf.MONTHLY_FEE_ID,
           mf.OWNER_ID,
           mf.CURRENCY_CODE_ALPHA3,
           mf.AMOUNT_MINOR_UNITS,
           mf.FEE_TYPE_ID
    FROM dbo.ACC_MONTHLY_FEES AS mf
    WHERE mf.OWNER_ID = @p_owner_id
          AND mf.CURRENCY_CODE_ALPHA3 = ISNULL(@p_currency_code_alpha3, mf.CURRENCY_CODE_ALPHA3)
          AND mf.FEE_TYPE_ID = @p_fee_type_id;

    RETURN;

END;
GO
