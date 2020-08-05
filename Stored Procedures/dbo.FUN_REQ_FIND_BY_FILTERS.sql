SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[FUN_REQ_FIND_BY_FILTERS]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_target_ag_id NUMERIC,
    @p_currency VARCHAR(2000),
    @p_start_date DATETIME2(6),
    @p_end_date DATETIME2(6),
    @p_req_ref NVARCHAR(2000),
    @p_from_amount NUMERIC,
    @p_to_amount NUMERIC
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
        JOIN dbo.ACC_ACCOUNT_GROUPS AS ag
            ON fr.TARGET_ACCOUNT_GROUP_ID = ag.ACCOUNT_GROUP_ID
    WHERE fr.REQUEST_TIME >= @p_start_date
          AND fr.REQUEST_TIME <= @p_end_date
          AND ag.CURRENCY_CODE_ALPHA3 = @p_currency
          AND
          (
              @p_from_amount IS NULL
              OR fr.AMOUNT_MINOR_UNITS >= @p_from_amount
          )
          AND
          (
              @p_to_amount IS NULL
              OR fr.AMOUNT_MINOR_UNITS <= @p_to_amount
          )
          AND
          (
              @p_req_ref IS NULL
              OR fr.REQUEST_REFERENCE = @p_req_ref
          )
    ORDER BY fr.FUNDS_REQUEST_ID;

    RETURN;

END;
GO
