SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[FUN_REQ_CREATE]
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
    INSERT dbo.ACC_FUNDS_REQUESTS
    (
        ACCOUNT_GROUP_ID,
        AMOUNT_MINOR_UNITS,
        PAID_STATUS,
        PAYER_EMAIL,
        PAYER_NAME,
        REQUEST_REASON,
        REQUEST_REFERENCE,
        REQUEST_TIME,
        TARGET_ACCOUNT_GROUP_ID,
        TRANSACTION_ID,
        FUNDS_REQUEST_ID
    )
    VALUES
    (@p_account_group_id,
     @p_amount_minor_units,
     @p_paid_status,
     @p_payer_email,
     @p_payer_name,
     @p_request_reason,
     @p_request_reference,
     @p_request_time,
     @p_target_account_group_id,
     @p_transaction_id,
     @p_funds_request_id);
END;
GO
