SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[RESP_MESSAGES_OUT_Q_CREATE]
    @p_message_timestamp DATETIME2(6),
    @p_payment_end_to_end_id NVARCHAR(255),
    @p_payment_header_message_id NVARCHAR(35),
    @p_payment_message_id NUMERIC,
    @p_payment_message_status CHAR(1),
    @p_payment_transaction_id NVARCHAR(20),
    @p_reason NVARCHAR(255),
    @p_message_id NUMERIC /* ID*/
AS
BEGIN
    INSERT dbo.ACC_RESP_MESSAGES_OUT_QUEUE
    (
        MESSAGE_TIMESTAMP,
        PAYMENT_END_TO_END_ID,
        PAYMENT_HEADER_MESSAGE_ID,
        PAYMENT_MESSAGE_ID,
        PAYMENT_MESSAGE_STATUS,
        PAYMENT_TRANSACTION_ID,
        REASON,
        MESSAGE_ID
    )
    VALUES
    (@p_message_timestamp,
     @p_payment_end_to_end_id,
     @p_payment_header_message_id,
     @p_payment_message_id,
     @p_payment_message_status,
     @p_payment_transaction_id,
     @p_reason,
     @p_message_id);
END;
GO
