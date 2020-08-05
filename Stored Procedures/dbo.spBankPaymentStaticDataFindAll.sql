SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[spBankPaymentStaticDataFindAll]
    @cv_1 VARCHAR(2000) OUTPUT
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
    FROM tlkpBankPaymentStaticData bp;

END;
GO
