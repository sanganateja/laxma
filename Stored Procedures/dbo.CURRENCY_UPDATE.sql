SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[CURRENCY_UPDATE]
    @DecimalPlaces NUMERIC,
    @DefaultRemittanceThresholdMinorUnit BIGINT,
    @CurrencyCodeAlpha3 CHAR(3)   /* ID*/
AS
BEGIN
    UPDATE dbo.ACC_CURRENCIES
    SET DECIMAL_PLACES = @DecimalPlaces,
        DEFAULT_REMITTANCE_THRESHOLD_MINOR_UNIT = @DefaultRemittanceThresholdMinorUnit
    WHERE CURRENCY_CODE_ALPHA3 = @CurrencyCodeAlpha3;
END;
GO
