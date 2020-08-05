SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[RESP_MESSAGES_OUT_Q_ALL] @cv_1 VARCHAR(2000) OUTPUT
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT ACC_RESP_MESSAGES_OUT_QUEUE.MESSAGE_ID,
           ACC_RESP_MESSAGES_OUT_QUEUE.MESSAGE_TIMESTAMP,
           ACC_RESP_MESSAGES_OUT_QUEUE.PAYMENT_MESSAGE_ID,
           ACC_RESP_MESSAGES_OUT_QUEUE.PAYMENT_MESSAGE_STATUS,
           ACC_RESP_MESSAGES_OUT_QUEUE.REASON,
           ACC_RESP_MESSAGES_OUT_QUEUE.PAYMENT_HEADER_MESSAGE_ID,
           ACC_RESP_MESSAGES_OUT_QUEUE.PAYMENT_END_TO_END_ID,
           ACC_RESP_MESSAGES_OUT_QUEUE.PAYMENT_TRANSACTION_ID
    FROM dbo.ACC_RESP_MESSAGES_OUT_QUEUE;

    RETURN;

END;
GO