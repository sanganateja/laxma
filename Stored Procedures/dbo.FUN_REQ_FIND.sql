SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[FUN_REQ_FIND]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT ACC_FUNDS_REQUESTS.FUNDS_REQUEST_ID,
           ACC_FUNDS_REQUESTS.REQUEST_TIME,
           ACC_FUNDS_REQUESTS.PAYER_NAME,
           ACC_FUNDS_REQUESTS.PAYER_EMAIL,
           ACC_FUNDS_REQUESTS.AMOUNT_MINOR_UNITS,
           ACC_FUNDS_REQUESTS.REQUEST_REASON,
           ACC_FUNDS_REQUESTS.REQUEST_REFERENCE,
           ACC_FUNDS_REQUESTS.TRANSACTION_ID,
           ACC_FUNDS_REQUESTS.PAID_STATUS,
           ACC_FUNDS_REQUESTS.ACCOUNT_GROUP_ID,
           ACC_FUNDS_REQUESTS.TARGET_ACCOUNT_GROUP_ID
    FROM dbo.ACC_FUNDS_REQUESTS
    WHERE ACC_FUNDS_REQUESTS.FUNDS_REQUEST_ID = @p_id;

    RETURN;

END;
GO
