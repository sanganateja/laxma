SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACQ_FEE_BLENDED_PERSIST]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_account_group_id NUMERIC,
    @p_card_category_code NVARCHAR(2000),
    @p_transaction_category_code NVARCHAR(2000),
    @p_region CHAR,
    @p_amount_minor_units NUMERIC,
    @p_percentage NUMERIC(18, 9)
AS
BEGIN
    SET @cv_1 = NULL;

    MERGE INTO ACC_ACQUIRING_FEES_BLENDED af
    USING
    (SELECT 1 AS d) s
    ON (
           af.ACCOUNT_GROUP_ID = @p_account_group_id
           AND af.CARD_CATEGORY_CODE = @p_card_category_code
           AND af.TRANSACTION_CATEGORY_CODE = @p_transaction_category_code
           AND af.REGION = @p_region
       )
    WHEN MATCHED THEN
        UPDATE SET af.PERCENTAGE = @p_percentage,
                   af.AMOUNT_MINOR_UNITS = @p_amount_minor_units
    WHEN NOT MATCHED THEN
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
         @p_card_category_code,
         @p_transaction_category_code,
         @p_region,
         @p_amount_minor_units,
         @p_percentage);

    EXEC ACQ_FEE_BLENDED_BY_PARAMS @cv_1,
                                   @p_account_group_id,
                                   @p_card_category_code,
                                   @p_transaction_category_code,
                                   @p_region;

END;
GO
