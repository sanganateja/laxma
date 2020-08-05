SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[PAYMENT_MES_OUT_QUEUE_FIND]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_message_id NUMERIC /* ID1*/
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT pm.MESSAGE_ID,
           pm.MESSAGE_TIMESTAMP,
           pm.PAYMENT_TYPE,
           pm.PAYER_NAME,
           pm.PAYER_ACCOUNT_ID,
           pm.PAYER_ADDRESS_1,
           pm.PAYER_ADDRESS_2,
           pm.PAYER_ADDRESS_3,
           pm.PAYEE_NAME,
           pm.PAYEE_ACCOUNT_ID,
           pm.PAYEE_ADDRESS_1,
           pm.PAYEE_ADDRESS_2,
           pm.PAYEE_ADDRESS_3,
           pm.AMOUNT_MINOR_UNITS,
           pm.CURRENCY_CODE_ALPHA3,
           pm.PAYMENT_OR_RETURN,
           pm.PAYER_SORT_CODE,
           pm.PAYEE_SORT_CODE,
           pm.PAYEE_ACCOUNT_ID_TYPE,
           pm.PAYEE_AGENT_ID,
           pm.PAYEE_AGENT_ID_TYPE,
           pm.PAYER_ACCOUNT_ID_TYPE,
           pm.SETTLEMENT_DATE,
           pm.INSTRUCTION_FOR_NEXT_AGENT,
           pm.TRANSACTION_ID,
           pm.REFERENCE_FOR_BENEFICIARY,
           pm.END_TO_END_ID,
           pm.RMT_INF_ADDTL,
           pm.RMT_INF_USTRD,
           pm.INTERMEDIARY_AGENT_ID,
           pm.INTERMEDIARY_AGENT_ID_TYPE,
           pm.COVER_ALL_PAYMENT_FEES
    FROM dbo.ACC_PAYMENT_MESSAGES_OUT_QUEUE AS pm
    WHERE pm.MESSAGE_ID = @p_message_id;

    RETURN;

END;
GO
