SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[GEN_MES_OUT_QUEUE_CREATE]
    @p_message_reference NVARCHAR(2000),
    @p_message_text VARCHAR(2000),
    @p_message_timestamp DATETIME2(6),
    @p_message_type VARCHAR(2000),
    @p_message_id NUMERIC
AS
BEGIN
    INSERT dbo.ACC_GENERIC_MESSAGES_OUT_QUEUE
    (
        MESSAGE_ID,
        MESSAGE_TIMESTAMP,
        MESSAGE_TYPE,
        MESSAGE_REFERENCE,
        MESSAGE_TEXT
    )
    VALUES
    (@p_message_id, @p_message_timestamp, @p_message_type, @p_message_reference, @p_message_text);
END;
GO
