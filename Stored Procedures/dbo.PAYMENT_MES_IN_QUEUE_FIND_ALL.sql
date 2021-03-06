SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[PAYMENT_MES_IN_QUEUE_FIND_ALL] @cv_1 VARCHAR(2000) OUTPUT
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT ACC_PAYMENT_MESSAGES_IN_QUEUE.MESSAGE_ID,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.MESSAGE_TIMESTAMP,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.PAYMENT_TYPE,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.HEADER_MESSAGE_ID,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.END_TO_END_ID,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.PAYER_NAME,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.PAYER_ACCOUNT_ID,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.PAYER_ADDRESS_1,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.PAYER_ADDRESS_2,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.PAYER_ADDRESS_3,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.PAYEE_NAME,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.PAYEE_ACCOUNT_ID,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.PAYEE_ADDRESS_1,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.PAYEE_ADDRESS_2,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.PAYEE_ADDRESS_3,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.AMOUNT_MINOR_UNITS,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.CURRENCY_CODE_ALPHA3,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.MESSAGE_TEXT,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.PAYMENT_OR_RETURN,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.PAYER_SORT_CODE,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.PAYEE_SORT_CODE,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.INSTRUCTION_FOR_NEXT_AGENT,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.PAYEE_ACCOUNT_ID_TYPE,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.PAYER_ACCOUNT_ID_TYPE,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.PAYER_AGENT_ID,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.PAYER_AGENT_ID_TYPE,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.SETTLEMENT_DATE,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.MESSAGE_TRANSACTION_ID,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.REFERENCE_FOR_BENEFICIARY,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.RMT_INF_ADDTL,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.RMT_INF_USTRD,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.INTERMEDIARY_AGENT_ID,
           ACC_PAYMENT_MESSAGES_IN_QUEUE.INTERMEDIARY_AGENT_ID_TYPE
    FROM dbo.ACC_PAYMENT_MESSAGES_IN_QUEUE
    ORDER BY ACC_PAYMENT_MESSAGES_IN_QUEUE.MESSAGE_TIMESTAMP;

    RETURN;

END;
GO
