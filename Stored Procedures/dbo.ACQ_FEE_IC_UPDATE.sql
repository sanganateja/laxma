SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACQ_FEE_IC_UPDATE]
    @p_account_group_id NUMERIC,
    @p_amount_minor_units NUMERIC,
    @p_fee_distinguisher NVARCHAR(2000),
    @p_percentage NUMERIC(18, 2),
    @p_fee_id NUMERIC
AS
BEGIN
    UPDATE dbo.ACC_ACQUIRING_FEES_IC
    SET ACCOUNT_GROUP_ID = @p_account_group_id,
        AMOUNT_MINOR_UNITS = @p_amount_minor_units,
        FEE_DISTINGUISHER = @p_fee_distinguisher,
        PERCENTAGE = @p_percentage
    WHERE ACC_ACQUIRING_FEES_IC.ACQ_FEE_IC_ID = @p_fee_id;
END;
GO
