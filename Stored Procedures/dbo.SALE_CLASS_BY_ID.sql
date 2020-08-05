SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[SALE_CLASS_BY_ID]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_sale_class_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT ACC_SALE_CLASSES.SALE_CLASS_ID,
           ACC_SALE_CLASSES.NAME,
           ACC_SALE_CLASSES.TRANSACTION_CATEGORY_CODE
    FROM dbo.ACC_SALE_CLASSES
    WHERE @p_sale_class_id = ACC_SALE_CLASSES.SALE_CLASS_ID;

    RETURN;

END;
GO