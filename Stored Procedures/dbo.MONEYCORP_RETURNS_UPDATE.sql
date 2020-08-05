SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[MONEYCORP_RETURNS_UPDATE]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_moneycorp_return_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    UPDATE dbo.ACC_MONEYCORP_RETURNS
    SET PROCESSED_TIME = SYSDATETIME()
    WHERE ACC_MONEYCORP_RETURNS.MONEYCORP_RETURN_ID = @p_moneycorp_return_id;

    /* Calling function requires list of Moneycorp Return records to be returned*/
    SELECT ACC_MONEYCORP_RETURNS.MONEYCORP_RETURN_ID,
           ACC_MONEYCORP_RETURNS.RECEIVED_TIME,
           ACC_MONEYCORP_RETURNS.PROCESSED_TIME,
           ACC_MONEYCORP_RETURNS.PAYMENT_REF,
           ACC_MONEYCORP_RETURNS.MONEYCORP_PAYMENT_REF,
           ACC_MONEYCORP_RETURNS.AMOUNT,
           ACC_MONEYCORP_RETURNS.PAYMENT_CHANNEL_ID,
           ACC_MONEYCORP_RETURNS.CLIENT_REF,
           ACC_MONEYCORP_RETURNS.PAYMENT_DATE,
           ACC_MONEYCORP_RETURNS.REFERENCE_KEY,
           ACC_MONEYCORP_RETURNS.ALLOCATED_AMOUNT,
           ACC_MONEYCORP_RETURNS.REFERENCE_7,
           ACC_MONEYCORP_RETURNS.REFERENCE_8,
           ACC_MONEYCORP_RETURNS.RIGHT_CLIENT_FUND_LINE_ID,
           ACC_MONEYCORP_RETURNS.RIGHT_AMOUNT,
           ACC_MONEYCORP_RETURNS.RIGHT_CLIENT_REF,
           ACC_MONEYCORP_RETURNS.RIGHT_PAYMENT_DATE,
           ACC_MONEYCORP_RETURNS.RIGHT_REFERENCE_KEY,
           ACC_MONEYCORP_RETURNS.RIGHT_ALLOCATED_AMOUNT,
           ACC_MONEYCORP_RETURNS.REGEX_OUT_1,
           ACC_MONEYCORP_RETURNS.REGEX_OUT_2,
           ACC_MONEYCORP_RETURNS.ORIGINAL_PAYMENT_REF,
           ACC_MONEYCORP_RETURNS.SHORTFALL
    FROM dbo.ACC_MONEYCORP_RETURNS
    WHERE ACC_MONEYCORP_RETURNS.MONEYCORP_RETURN_ID = @p_moneycorp_return_id;

END;
GO
