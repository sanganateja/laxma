SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACQ_FEE_BLENDED_SET_DEFAULTS]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_account_group_id NUMERIC,
    @p_pricing_turnover_band_id NUMERIC
AS
BEGIN
    SET @cv_1 = NULL;

    MERGE INTO ACC_ACQUIRING_FEES_BLENDED f
    USING ACC_PRICING_TEMPLATES_BLENDED t
    ON (
           f.CARD_CATEGORY_CODE = t.CARD_CATEGORY_CODE
           AND f.TRANSACTION_CATEGORY_CODE = t.TRANSACTION_CATEGORY_CODE
           AND f.REGION = t.REGION_CODE
           AND f.ACCOUNT_GROUP_ID = @p_account_group_id
           AND t.PRICING_TURNOVER_BAND_ID = @p_pricing_turnover_band_id
       )
    WHEN MATCHED THEN
        UPDATE SET f.PERCENTAGE = t.PERCENTAGE,
                   f.AMOUNT_MINOR_UNITS = t.AMOUNT_MINOR_UNITS
    WHEN NOT MATCHED AND t.PRICING_TURNOVER_BAND_ID = @p_pricing_turnover_band_id THEN
        INSERT
        (
            ACCOUNT_GROUP_ID,
            CARD_CATEGORY_CODE,
            TRANSACTION_CATEGORY_CODE,
            REGION,
            AMOUNT_MINOR_UNITS,
            PERCENTAGE
        )
        VALUES
        (@p_account_group_id,
         t.CARD_CATEGORY_CODE,
         t.TRANSACTION_CATEGORY_CODE,
         t.REGION_CODE,
         t.AMOUNT_MINOR_UNITS,
         t.PERCENTAGE);
    EXEC ACQ_FEE_BLENDED_BY_AG @cv_1, @p_account_group_id;

    RETURN;
END;
GO
