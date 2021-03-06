SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[PAYMENT_MES_OUT_FIND_ALL] @cv_1 VARCHAR(2000) OUTPUT
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT ACC_PAYMENT_MESSAGES_OUT.MESSAGE_ID,
           ACC_PAYMENT_MESSAGES_OUT.MESSAGE_TIMESTAMP,
           ACC_PAYMENT_MESSAGES_OUT.PAYMENT_TYPE,
           ACC_PAYMENT_MESSAGES_OUT.HEADER_MESSAGE_ID,
           ACC_PAYMENT_MESSAGES_OUT.END_TO_END_ID,
           ACC_PAYMENT_MESSAGES_OUT.TRANSACTION_ID,
           ACC_PAYMENT_MESSAGES_OUT.PAYER_NAME,
           ACC_PAYMENT_MESSAGES_OUT.PAYER_ACCOUNT_ID,
           ACC_PAYMENT_MESSAGES_OUT.PAYER_ADDRESS_1,
           ACC_PAYMENT_MESSAGES_OUT.PAYER_ADDRESS_2,
           ACC_PAYMENT_MESSAGES_OUT.PAYER_ADDRESS_3,
           ACC_PAYMENT_MESSAGES_OUT.PAYEE_NAME,
           ACC_PAYMENT_MESSAGES_OUT.PAYEE_ACCOUNT_ID,
           ACC_PAYMENT_MESSAGES_OUT.PAYEE_ADDRESS_1,
           ACC_PAYMENT_MESSAGES_OUT.PAYEE_ADDRESS_2,
           ACC_PAYMENT_MESSAGES_OUT.PAYEE_ADDRESS_3,
           ACC_PAYMENT_MESSAGES_OUT.AMOUNT_MINOR_UNITS,
           ACC_PAYMENT_MESSAGES_OUT.CURRENCY_CODE_ALPHA3,
           ACC_PAYMENT_MESSAGES_OUT.MESSAGE_STATUS,
           ACC_PAYMENT_MESSAGES_OUT.MESSAGE_TEXT,
           ACC_PAYMENT_MESSAGES_OUT.PAYMENT_OR_RETURN,
           ACC_PAYMENT_MESSAGES_OUT.PAYER_SORT_CODE,
           ACC_PAYMENT_MESSAGES_OUT.PAYEE_SORT_CODE,
           ACC_PAYMENT_MESSAGES_OUT.INSTRUCTION_FOR_NEXT_AGENT,
           ACC_PAYMENT_MESSAGES_OUT.PAYEE_ACCOUNT_ID_TYPE,
           ACC_PAYMENT_MESSAGES_OUT.PAYEE_AGENT_ID,
           ACC_PAYMENT_MESSAGES_OUT.PAYEE_AGENT_ID_TYPE,
           ACC_PAYMENT_MESSAGES_OUT.PAYER_ACCOUNT_ID_TYPE,
           ACC_PAYMENT_MESSAGES_OUT.SETTLEMENT_DATE,
           ACC_PAYMENT_MESSAGES_OUT.MESSAGE_TRANSACTION_ID,
           ACC_PAYMENT_MESSAGES_OUT.REFERENCE_FOR_BENEFICIARY,
           ACC_PAYMENT_MESSAGES_OUT.RMT_INF_ADDTL,
           ACC_PAYMENT_MESSAGES_OUT.RMT_INF_USTRD,
           ACC_PAYMENT_MESSAGES_OUT.INTERMEDIARY_AGENT_ID,
           ACC_PAYMENT_MESSAGES_OUT.INTERMEDIARY_AGENT_ID_TYPE,
           ACC_PAYMENT_MESSAGES_OUT.COVER_ALL_PAYMENT_FEES
    FROM dbo.ACC_PAYMENT_MESSAGES_OUT
    ORDER BY ACC_PAYMENT_MESSAGES_OUT.MESSAGE_TIMESTAMP;

    RETURN;

END;
GO
