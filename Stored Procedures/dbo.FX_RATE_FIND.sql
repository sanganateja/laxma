SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[FX_RATE_FIND]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_from_currency VARCHAR(2000),
    @p_to_currency VARCHAR(2000),
    @p_rate_date DATETIME2(6) NULL
AS
SET NOCOUNT ON;

BEGIN
    IF @p_rate_date IS NULL
        SET @p_rate_date = CAST(SYSDATETIME() AS DATE);

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
              SELECT MAX(RATE_DATE)
              FROM dbo.FX_RATES
              WHERE FROM_CURRENCY = @p_from_currency
                AND TO_CURRENCY = @p_to_currency
                AND RATE_DATE <= CAST(@p_rate_date AS DATE)
          );

    RETURN;

END
GO
