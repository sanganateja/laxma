SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[TRANSFER_FEE_FIND_BY_ACC_GROUP]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_account_group_id NUMERIC,
    @p_transfer_method_id NUMERIC
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
        JOIN dbo.ACC_ACCOUNT_GROUPS AS ag
            ON ag.ACCOUNT_GROUP_ID = tf.ACCOUNT_GROUP_ID
               AND ag.CURRENCY_CODE_ALPHA3 = tf.CURRENCY_CODE_ALPHA3
    WHERE tf.ACCOUNT_GROUP_ID = @p_account_group_id
          AND tf.TRANSFER_METHOD_ID = ISNULL(@p_transfer_method_id, tf.TRANSFER_METHOD_ID)
    ORDER BY tf.transfer_method_id;

    RETURN;

END;
GO
