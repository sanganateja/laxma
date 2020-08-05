SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[FX_RATE_FIND_LATEST]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_from_currency VARCHAR(2000),
    @p_to_currency VARCHAR(2000)
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT fx.RATE_ID,
           fx.RATE_DATE,
           fx.FROM_CURRENCY,
           fx.TO_CURRENCY,
           fx.RATE
    FROM dbo.FX_RATES AS fx
    WHERE fx.FROM_CURRENCY = @p_from_currency
          AND fx.TO_CURRENCY = @p_to_currency
          AND fx.RATE_DATE =
          (
              SELECT MAX(FX_RATES.RATE_DATE) AS expr
              FROM dbo.FX_RATES
              WHERE FX_RATES.FROM_CURRENCY = @p_from_currency
                    AND FX_RATES.TO_CURRENCY = @p_to_currency
          );

    RETURN;

END;
GO
