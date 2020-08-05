SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[DESIGNATOR_COST_BY_METHOD]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_transfer_method_id NUMERIC,
    @p_direction NVARCHAR(2000),
    @p_date DATETIME2(6)
AS
BEGIN
    SET NOCOUNT ON;
    SET @cv_1 = NULL;

    SELECT TOP (1)
           cost.COST_ID,
           cost.VALID_FROM,
           cost.DESIGNATOR_ID,
           cost.CURRENCY_CODE_ALPHA3,
           cost.FIXED_AMOUNT_MINOR_UNITS,
           cost.VARIABLE_PCTG,
           cost.VALID_TO,
           cost.MIN_AMOUNT,
           cost.MAX_AMOUNT,
           cost.MIN_RETURN_AMOUNT,
           cost.MAX_RETURN_AMOUNT
    FROM dbo.CST_DESIGNATOR_LOOKUP AS cdl
        JOIN dbo.CST_DESIGNATOR_COSTS AS cost
            ON cdl.DESIGNATOR_ID = cost.DESIGNATOR_ID
    WHERE cdl.TRANSFER_METHOD_ID = @p_transfer_method_id
          AND cdl.DIRECTION = @p_direction
          AND cost.VALID_FROM <= @p_date
          AND
          (
              cost.VALID_TO IS NULL
              OR cost.VALID_TO >= @p_date
          )
    ORDER BY cost.VALID_FROM;


    RETURN;

END;
GO
