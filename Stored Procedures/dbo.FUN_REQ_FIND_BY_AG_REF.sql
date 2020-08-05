SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[FUN_REQ_FIND_BY_AG_REF]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_ag_id NUMERIC,
    @p_req_ref NVARCHAR(2000)
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT fr.FUNDS_REQUEST_ID,
           fr.REQUEST_TIME,
           fr.PAYER_NAME,
           fr.PAYER_EMAIL,
           fr.AMOUNT_MINOR_UNITS,
           fr.REQUEST_REASON,
           fr.REQUEST_REFERENCE,
           fr.TRANSACTION_ID,
           fr.PAID_STATUS,
           fr.ACCOUNT_GROUP_ID,
           fr.TARGET_ACCOUNT_GROUP_ID
    FROM dbo.ACC_FUNDS_REQUESTS AS fr
    WHERE fr.TARGET_ACCOUNT_GROUP_ID = @p_ag_id
          AND fr.REQUEST_REFERENCE = @p_req_ref;

    RETURN;

END;
GO
