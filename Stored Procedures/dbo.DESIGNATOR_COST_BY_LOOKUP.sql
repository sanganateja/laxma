SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[DESIGNATOR_COST_BY_LOOKUP]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_transfer_method_id NUMERIC,
    @p_direction NVARCHAR(2000),
    @p_date DATETIME2(6)
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT cdc.COST_ID,
           cdc.VALID_FROM,
           cdc.DESIGNATOR_ID,
           cdc.CURRENCY_CODE_ALPHA3,
           cdc.FIXED_AMOUNT_MINOR_UNITS,
           cdc.VARIABLE_PCTG
    FROM CST_DESIGNATOR_COSTS cdc
        JOIN CST_DESIGNATOR_LOOKUP cdl
            ON cdc.DESIGNATOR_ID = cdl.DESIGNATOR_ID
    WHERE cdl.TRANSFER_METHOD_ID = @p_transfer_method_id
          AND RTRIM(LTRIM(cdl.DIRECTION)) = @p_direction
          AND cdc.VALID_FROM <= @p_date
    ORDER BY cdc.VALID_FROM DESC;

    RETURN;

END;
GO
