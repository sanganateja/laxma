SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACQ_FEE_BLENDED_BY_ID]


    @cv_1 VARCHAR(2000) OUTPUT,
    @p_fee_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT ACC_ACQUIRING_FEES_BLENDED.ACQ_FEE_BLENDED_ID,
           ACC_ACQUIRING_FEES_BLENDED.CARD_CATEGORY_CODE,
           ACC_ACQUIRING_FEES_BLENDED.TRANSACTION_CATEGORY_CODE,
           ACC_ACQUIRING_FEES_BLENDED.REGION,
           ACC_ACQUIRING_FEES_BLENDED.AMOUNT_MINOR_UNITS,
           ACC_ACQUIRING_FEES_BLENDED.PERCENTAGE,
           ACC_ACQUIRING_FEES_BLENDED.ACCOUNT_GROUP_ID
    FROM dbo.ACC_ACQUIRING_FEES_BLENDED
    WHERE ACC_ACQUIRING_FEES_BLENDED.ACQ_FEE_BLENDED_ID = @p_fee_id;

    RETURN;

END;
GO
