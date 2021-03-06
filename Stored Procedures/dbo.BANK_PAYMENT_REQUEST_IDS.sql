SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[BANK_PAYMENT_REQUEST_IDS]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_request_state VARCHAR(2000)
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT ACC_BANK_PAYMENT_REQUESTS.REQUEST_ID AS id
    FROM dbo.ACC_BANK_PAYMENT_REQUESTS
    WHERE ACC_BANK_PAYMENT_REQUESTS.REQUEST_STATE = @p_request_state;

    RETURN;

END;
GO
