SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACQ_FEE_IC_BY_PARAMS]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_account_group_id NUMERIC,
    @p_fee_distinguisher NVARCHAR(2000)
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT ACC_ACQUIRING_FEES_IC.ACQ_FEE_IC_ID,
           ACC_ACQUIRING_FEES_IC.ACCOUNT_GROUP_ID,
           ACC_ACQUIRING_FEES_IC.FEE_DISTINGUISHER,
           ACC_ACQUIRING_FEES_IC.AMOUNT_MINOR_UNITS,
           ACC_ACQUIRING_FEES_IC.PERCENTAGE
    FROM dbo.ACC_ACQUIRING_FEES_IC
    WHERE ACC_ACQUIRING_FEES_IC.ACCOUNT_GROUP_ID = @p_account_group_id
          AND ACC_ACQUIRING_FEES_IC.FEE_DISTINGUISHER = @p_fee_distinguisher;

    RETURN;

END;
GO