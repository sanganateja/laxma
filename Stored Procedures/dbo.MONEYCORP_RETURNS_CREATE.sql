SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[MONEYCORP_RETURNS_CREATE]
    @p_allocated_amount NVARCHAR(2000),
    @p_amount NVARCHAR(2000),
    @p_client_ref NVARCHAR(2000),
    @p_moneycorp_payment_ref NVARCHAR(2000),
    @p_original_payment_ref NVARCHAR(2000),
    @p_payment_channel_id NVARCHAR(2000),
    @p_payment_date DATETIME2(6),
    @p_payment_ref NVARCHAR(2000),
    @p_processed_time DATETIME2(6),
    @p_received_time DATETIME2(6),
    @p_reference_7 NVARCHAR(2000),
    @p_reference_8 NVARCHAR(2000),
    @p_reference_key NVARCHAR(2000),
    @p_regex_out_1 NVARCHAR(2000),
    @p_regex_out_2 NVARCHAR(2000),
    @p_right_allocated_amount NVARCHAR(2000),
    @p_right_amount NVARCHAR(2000),
    @p_right_client_fund_line_id NVARCHAR(2000),
    @p_right_client_ref NVARCHAR(2000),
    @p_right_payment_date DATETIME2(6),
    @p_right_reference_key NVARCHAR(2000),
    @p_shortfall NVARCHAR(2000),
    @p_moneycorp_return_id NUMERIC /* ID*/
AS
BEGIN
    INSERT dbo.ACC_MONEYCORP_RETURNS
    (
        MONEYCORP_RETURN_ID,
        ALLOCATED_AMOUNT,
        AMOUNT,
        CLIENT_REF,
        MONEYCORP_PAYMENT_REF,
        ORIGINAL_PAYMENT_REF,
        PAYMENT_CHANNEL_ID,
        PAYMENT_DATE,
        PAYMENT_REF,
        PROCESSED_TIME,
        RECEIVED_TIME,
        REFERENCE_7,
        REFERENCE_8,
        REFERENCE_KEY,
        REGEX_OUT_1,
        REGEX_OUT_2,
        RIGHT_ALLOCATED_AMOUNT,
        RIGHT_AMOUNT,
        RIGHT_CLIENT_FUND_LINE_ID,
        RIGHT_CLIENT_REF,
        RIGHT_PAYMENT_DATE,
        RIGHT_REFERENCE_KEY,
        SHORTFALL
    )
    VALUES
    (@p_moneycorp_return_id,
     @p_allocated_amount,
     @p_amount,
     @p_client_ref,
     @p_moneycorp_payment_ref,
     @p_original_payment_ref,
     @p_payment_channel_id,
     @p_payment_date,
     @p_payment_ref,
     @p_processed_time,
     @p_received_time,
     @p_reference_7,
     @p_reference_8,
     @p_reference_key,
     @p_regex_out_1,
     @p_regex_out_2,
     @p_right_allocated_amount,
     @p_right_amount,
     @p_right_client_fund_line_id,
     @p_right_client_ref,
     @p_right_payment_date,
     @p_right_reference_key,
     @p_shortfall);
END;
GO
