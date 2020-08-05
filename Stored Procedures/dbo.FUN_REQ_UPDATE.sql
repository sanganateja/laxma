SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[FUN_REQ_UPDATE]
    @p_account_group_id NUMERIC,
    @p_amount_minor_units NUMERIC,
    @p_paid_status VARCHAR(2000),
    @p_payer_email NVARCHAR(2000),
    @p_payer_name NVARCHAR(2000),
    @p_request_reason NVARCHAR(2000),
    @p_request_reference NVARCHAR(2000),
    @p_request_time DATETIME2(6),
    @p_target_account_group_id NUMERIC,
    @p_transaction_id NUMERIC,
    @p_funds_request_id NUMERIC
AS
BEGIN
    UPDATE dbo.ACC_FUNDS_REQUESTS
    SET ACCOUNT_GROUP_ID = @p_account_group_id,
        AMOUNT_MINOR_UNITS = @p_amount_minor_units,
        PAID_STATUS = @p_paid_status,
        PAYER_EMAIL = @p_payer_email,
        PAYER_NAME = @p_payer_name,
        REQUEST_REASON = @p_request_reason,
        REQUEST_REFERENCE = @p_request_reference,
        REQUEST_TIME = @p_request_time,
        TARGET_ACCOUNT_GROUP_ID = @p_target_account_group_id,
        TRANSACTION_ID = @p_transaction_id
    WHERE ACC_FUNDS_REQUESTS.FUNDS_REQUEST_ID = @p_funds_request_id;
END;
GO
