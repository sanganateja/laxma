SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[spPaymentBankFindAll]
    @cv_1 VARCHAR(2000) OUTPUT
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT pb.PaymentBankId,
           pb.BankName
    FROM dbo.tlkpPaymentBank pb;

END;
GO
