SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_monthly_cost_data] @p_recordset VARCHAR(2000) OUTPUT
AS
BEGIN

    SET @p_recordset = NULL;

    SELECT al.FEE_PROGRAM,
           al.INTERCHANGE_DESCRIPTION,
           al.RATE_TIER,
           CAST(CASE
                    WHEN (cst.CURRENCY_CODE_ALPHA3 IS NULL) THEN
                        NULL
                    ELSE
                        cst.FIXED_AMOUNT_MINOR_UNITS / POWER(10, c.DECIMAL_PLACES)
                END AS BIGINT) AS fixed_amount,
           cst.CURRENCY_CODE_ALPHA3 AS currency_code,
           CAST(cst.VARIABLE_PCTG * 100 AS BIGINT) AS percentage
    FROM dbo.CST_DESIGNATOR_ACQ_LOOKUP AS al
        LEFT OUTER JOIN dbo.CST_DESIGNATOR_COSTS AS cst
            LEFT OUTER JOIN dbo.ACC_CURRENCIES AS c
                ON c.CURRENCY_CODE_ALPHA3 = cst.CURRENCY_CODE_ALPHA3
            ON cst.DESIGNATOR_ID = al.DESIGNATOR_ID
               AND cst.VALID_TO IS NULL;

END;
GO
