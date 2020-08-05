SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[spPaymentTypeFindAll]
    @cv_1 VARCHAR(2000) OUTPUT
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT pt.PaymentTypeId,
           pt.[Code],
           pt.[Name],
           pt.[CurrencyCodeAlpha3]
    FROM dbo.tlkpPaymentType pt;

END;
GO
