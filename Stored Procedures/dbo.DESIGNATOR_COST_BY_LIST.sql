SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[DESIGNATOR_COST_BY_LIST]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_ids_list NVARCHAR(2000)
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT c.COST_ID,
           c.VALID_FROM,
           c.DESIGNATOR_ID,
           c.CURRENCY_CODE_ALPHA3,
           c.FIXED_AMOUNT_MINOR_UNITS,
           c.VARIABLE_PCTG,
           c.VALID_TO,
           c.MIN_AMOUNT,
           c.MAX_AMOUNT,
           c.MIN_RETURN_AMOUNT,
           c.MAX_RETURN_AMOUNT
    FROM dbo.CST_DESIGNATOR_COSTS AS c
    WHERE c.DESIGNATOR_ID IN
          (
              SELECT value FROM STRING_SPLIT(@p_ids_list, ',')
          )
    ORDER BY c.VALID_FROM;


    RETURN;

END;
GO
