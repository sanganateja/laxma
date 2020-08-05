SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[spBankPaymentStaticDataFindByPaymentTypeAndCurrency]
    @cv_1 VARCHAR(2000) OUTPUT,
    @PaymentTypeId BIGINT,
    @CurrencyCodeAlpha3 CHAR(3)
AS
BEGIN
    SET @cv_1 = NULL;

    SELECT bp.BankPaymentStaticDataId,
           bp.PaymentBankId,
           bp.PaymentTypeId,
           bp.CurrencyCodeAlpha3,
           bp.EarliestPaymentTimeUKLocal,
           bp.LatestPaymentTimeUKLocal,
           bp.DefaultRemittanceTimeUKLocal,
           bp.FeeGBPMinorUnit,
           bp.MaxAmountGBPMinorUnits
    FROM tlkpBankPaymentStaticData bp
    WHERE bp.PaymentBankId = 1              -- MoneyCorp
      AND bp.PaymentTypeId = @PaymentTypeId
      AND bp.CurrencyCodeAlpha3 = @CurrencyCodeAlpha3;

END;
GO
