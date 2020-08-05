SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[SALE_DETAILS_FIND]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_transaction_id NUMERIC /* ID*/
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT t.TRANSACTION_ID,
           t.SALE_CLASS_ID,
           t.REGIONALITY,
           t.CARD_TYPE_ID,
           t.ACQUIRER_ID,
           t.CART_ID
    FROM dbo.ACC_SALE_DETAILS AS t
    WHERE t.TRANSACTION_ID = @p_transaction_id;

    RETURN;

END;
GO
