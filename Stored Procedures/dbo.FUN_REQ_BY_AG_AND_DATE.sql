SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[FUN_REQ_BY_AG_AND_DATE]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_ag_id NUMERIC,
    @p_start_date DATETIME2(6),
    @p_end_date DATETIME2(6)
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
    WHERE fr.ACCOUNT_GROUP_ID = @p_ag_id
          AND fr.REQUEST_TIME >= @p_start_date
          AND fr.REQUEST_TIME < @p_end_date;

    RETURN;

END;
GO
