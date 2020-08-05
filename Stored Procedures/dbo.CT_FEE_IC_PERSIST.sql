SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[CT_FEE_IC_PERSIST]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_account_group_id NUMERIC,
    @p_percentage NUMERIC(18, 2),
    @p_amount_minor_units NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    MERGE INTO dbo.ACC_CT_FEES_IC AS cft
    USING
    (SELECT 1 AS expr) AS src
    ON (cft.ACCOUNT_GROUP_ID = @p_account_group_id)
    WHEN MATCHED THEN
        UPDATE SET PERCENTAGE = @p_percentage,
                   AMOUNT_MINOR_UNITS = @p_amount_minor_units
    WHEN NOT MATCHED BY TARGET THEN
        INSERT
        (
            ACCOUNT_GROUP_ID,
            PERCENTAGE,
            AMOUNT_MINOR_UNITS
        )
        VALUES
        (@p_account_group_id, @p_percentage, @p_amount_minor_units);

    /* Return current state...*/
    SELECT cft.ACCOUNT_GROUP_ID,
           cft.PERCENTAGE,
           cft.AMOUNT_MINOR_UNITS
    FROM dbo.ACC_CT_FEES_IC AS cft
    WHERE cft.ACCOUNT_GROUP_ID = @p_account_group_id;

END;
GO
