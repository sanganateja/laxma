SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[DESIGNATOR_COST_BY_PROGRAM_TIER_DESC]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_program NVARCHAR(100),
    @p_tier NVARCHAR(100),
    @p_description NVARCHAR(100),
    @p_date DATETIME2(6)
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT TOP (1)
           fci.COST_ID,
           fci.VALID_FROM,
           fci.DESIGNATOR_ID,
           fci.CURRENCY_CODE_ALPHA3,
           fci.FIXED_AMOUNT_MINOR_UNITS,
           fci.VARIABLE_PCTG,
           fci.VALID_TO,
           fci.MIN_AMOUNT,
           fci.MAX_AMOUNT,
           fci.MIN_RETURN_AMOUNT,
           fci.MAX_RETURN_AMOUNT
    FROM
    (
        SELECT TOP 9223372036854775807
               CST_DESIGNATOR_COSTS.COST_ID,
               CST_DESIGNATOR_COSTS.VALID_FROM,
               CST_DESIGNATOR_COSTS.DESIGNATOR_ID,
               CST_DESIGNATOR_COSTS.CURRENCY_CODE_ALPHA3,
               CST_DESIGNATOR_COSTS.FIXED_AMOUNT_MINOR_UNITS,
               CST_DESIGNATOR_COSTS.VARIABLE_PCTG,
               CST_DESIGNATOR_COSTS.VALID_TO,
               CST_DESIGNATOR_COSTS.MIN_AMOUNT,
               CST_DESIGNATOR_COSTS.MAX_AMOUNT,
               CST_DESIGNATOR_COSTS.MIN_RETURN_AMOUNT,
               CST_DESIGNATOR_COSTS.MAX_RETURN_AMOUNT
        FROM dbo.CST_DESIGNATOR_COSTS
        WHERE CST_DESIGNATOR_COSTS.DESIGNATOR_ID =
                     (SELECT DESIGNATOR_ID FROM CST_DESIGNATOR_ACQ_LOOKUP WHERE
                         CST_DESIGNATOR_ACQ_LOOKUP.FEE_PROGRAM = @p_program
              AND CST_DESIGNATOR_ACQ_LOOKUP.RATE_TIER = @p_tier
              AND CST_DESIGNATOR_ACQ_LOOKUP.INTERCHANGE_DESCRIPTION = @p_description )
              AND
                       (CST_DESIGNATOR_COSTS.VALID_FROM <= @p_date
                           or CST_DESIGNATOR_COSTS.VALID_FROM IS NULL
                       )
              AND
              (
                  CST_DESIGNATOR_COSTS.VALID_TO IS NULL
                  OR CST_DESIGNATOR_COSTS.VALID_TO >= @p_date
              )
        ORDER BY CST_DESIGNATOR_COSTS.VALID_FROM DESC
    ) AS fci;

    RETURN;

END;
GO
