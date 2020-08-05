SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACQ_FEE_IC_PERSIST]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_account_group_id NUMERIC,
    @p_fee_distinguisher NVARCHAR(2000),
    @p_amount_minor_units NUMERIC,
    @p_percentage NUMERIC(18, 2)
AS
BEGIN
    SET @cv_1 = NULL;

    MERGE INTO ACC_ACQUIRING_FEES_IC af
    USING
    (SELECT 1 AS d) s
    ON (
           af.ACCOUNT_GROUP_ID = @p_account_group_id
           AND af.FEE_DISTINGUISHER = @p_fee_distinguisher
       )
    WHEN MATCHED THEN
        UPDATE SET af.PERCENTAGE = @p_percentage,
                   af.AMOUNT_MINOR_UNITS = @p_amount_minor_units
    WHEN NOT MATCHED THEN
        INSERT
        (
            ACCOUNT_GROUP_ID,
            FEE_DISTINGUISHER,
            AMOUNT_MINOR_UNITS,
            PERCENTAGE
        )
        VALUES
        (@p_account_group_id, @p_fee_distinguisher, @p_amount_minor_units, @p_percentage);

    EXEC ACQ_FEE_IC_BY_PARAMS @cv_1,
                              @p_account_group_id,
                              @p_fee_distinguisher;
END;
GO
