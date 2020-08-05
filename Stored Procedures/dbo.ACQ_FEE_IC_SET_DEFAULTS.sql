SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACQ_FEE_IC_SET_DEFAULTS]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_account_group_id NUMERIC,
    @p_pricing_turnover_band_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    MERGE INTO ACC_ACQUIRING_FEES_IC f
    USING ACC_PRICING_TEMPLATES_IC t
    ON (
           f.ACCOUNT_GROUP_ID = @p_account_group_id
           AND t.PRICING_TURNOVER_BAND_ID = @p_pricing_turnover_band_id
           AND t.FEE_DISTINGUISHER = f.FEE_DISTINGUISHER
       )
    WHEN MATCHED THEN
        UPDATE SET f.PERCENTAGE = t.PERCENTAGE,
                   f.AMOUNT_MINOR_UNITS = t.AMOUNT_MINOR_UNITS
    WHEN NOT MATCHED AND t.PRICING_TURNOVER_BAND_ID = @p_pricing_turnover_band_id THEN
        INSERT
        (
            ACCOUNT_GROUP_ID,
            FEE_DISTINGUISHER,
            AMOUNT_MINOR_UNITS,
            PERCENTAGE
        )
        VALUES
        (@p_account_group_id, t.FEE_DISTINGUISHER, t.AMOUNT_MINOR_UNITS, t.PERCENTAGE);

    EXEC ACQ_FEE_IC_BY_AG @cv_1, @p_account_group_id;

    RETURN;

END;
GO
