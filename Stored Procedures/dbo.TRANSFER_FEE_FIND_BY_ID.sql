SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[TRANSFER_FEE_FIND_BY_ID]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_transfer_fee_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT tf.TRANSFER_FEE_ID,
           tf.ACCOUNT_GROUP_ID,
           tf.TRANSFER_METHOD_ID,
           tf.CURRENCY_CODE_ALPHA3,
           tf.AMOUNT_MINOR_UNITS_OUT,
           tf.AMOUNT_MINOR_UNITS_IN,
           tf.AMOUNT_MINOR_UNITS_OUT_ADD
    FROM dbo.ACC_TRANSFER_FEES AS tf
    WHERE tf.TRANSFER_FEE_ID = @p_transfer_fee_id;

    RETURN;

END;
GO
