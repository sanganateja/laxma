SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[SALE_DETAILS_CREATE]
    @p_acquirer_id NUMERIC,
    @p_card_type_id NUMERIC,
    @p_cart_id NVARCHAR(2000),
    @p_regionality VARCHAR(2000),
    @p_sale_class_id NVARCHAR(2000),
    @p_transaction_id NUMERIC /* ID*/
AS
BEGIN
    INSERT dbo.ACC_SALE_DETAILS
    (
        TRANSACTION_ID,
        ACQUIRER_ID,
        CARD_TYPE_ID,
        CART_ID,
        REGIONALITY,
        SALE_CLASS_ID
    )
    VALUES
    (@p_transaction_id, @p_acquirer_id, @p_card_type_id, @p_cart_id, @p_regionality, @p_sale_class_id);
END;
GO
