SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACQUIRING_FEE_SET_DEFAULTS]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_account_group_id NUMERIC,
    @p_pricing_turnover_band_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;


    MERGE INTO ACC_ACQUIRING_FEES f
    USING ACC_PRICING_TEMPLATES t
    ON (
           f.EVENT_TYPE_ID = t.EVENT_TYPE_ID
           AND t.PRICING_TURNOVER_BAND_ID = @p_pricing_turnover_band_id
           AND f.ACCOUNT_GROUP_ID = @p_account_group_id
       )
    WHEN MATCHED THEN
        UPDATE SET f.PERCENTAGE = t.PERCENTAGE,
                   f.AMOUNT_MINOR_UNITS = t.AMOUNT_MINOR_UNITS
    WHEN NOT MATCHED AND t.PRICING_TURNOVER_BAND_ID = @p_pricing_turnover_band_id THEN
        INSERT
        (
            ACCOUNT_GROUP_ID,
            EVENT_TYPE_ID,
            PERCENTAGE,
            AMOUNT_MINOR_UNITS
        )
        VALUES
        (@p_account_group_id, t.EVENT_TYPE_ID, t.PERCENTAGE, t.AMOUNT_MINOR_UNITS);
    SELECT ACC_ACQUIRING_FEES.FEE_ID,
           ACC_ACQUIRING_FEES.ACCOUNT_GROUP_ID,
           ACC_ACQUIRING_FEES.EVENT_TYPE_ID,
           ACC_ACQUIRING_FEES.PERCENTAGE,
           ACC_ACQUIRING_FEES.AMOUNT_MINOR_UNITS
    FROM dbo.ACC_ACQUIRING_FEES
    WHERE ACC_ACQUIRING_FEES.ACCOUNT_GROUP_ID = @p_account_group_id;

    RETURN;

END;
GO