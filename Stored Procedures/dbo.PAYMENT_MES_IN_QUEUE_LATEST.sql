SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[PAYMENT_MES_IN_QUEUE_LATEST] @CV_1 VARCHAR(2000) OUTPUT
AS
BEGIN

    SET @CV_1 = NULL;

    /*
      *   SSMA warning messages:
      *   O2SS0204: Subqueries with ROWNUM emulation may have unnecessary columns.
      */

    SELECT SSMAROWNUM.MESSAGE_ID,
           SSMAROWNUM.MESSAGE_TIMESTAMP,
           SSMAROWNUM.PAYMENT_TYPE,
           SSMAROWNUM.HEADER_MESSAGE_ID,
           SSMAROWNUM.END_TO_END_ID,
           SSMAROWNUM.PAYER_NAME,
           SSMAROWNUM.PAYER_ACCOUNT_ID,
           SSMAROWNUM.PAYER_ADDRESS_1,
           SSMAROWNUM.PAYER_ADDRESS_2,
           SSMAROWNUM.PAYER_ADDRESS_3,
           SSMAROWNUM.PAYEE_NAME,
           SSMAROWNUM.PAYEE_ACCOUNT_ID,
           SSMAROWNUM.PAYEE_ADDRESS_1,
           SSMAROWNUM.PAYEE_ADDRESS_2,
           SSMAROWNUM.PAYEE_ADDRESS_3,
           SSMAROWNUM.AMOUNT_MINOR_UNITS,
           SSMAROWNUM.CURRENCY_CODE_ALPHA3,
           SSMAROWNUM.MESSAGE_TEXT,
           SSMAROWNUM.PAYMENT_OR_RETURN,
           SSMAROWNUM.PAYER_SORT_CODE,
           SSMAROWNUM.PAYEE_SORT_CODE,
           SSMAROWNUM.INSTRUCTION_FOR_NEXT_AGENT,
           SSMAROWNUM.PAYEE_ACCOUNT_ID_TYPE,
           SSMAROWNUM.PAYER_ACCOUNT_ID_TYPE,
           SSMAROWNUM.PAYER_AGENT_ID,
           SSMAROWNUM.PAYER_AGENT_ID_TYPE,
           SSMAROWNUM.SETTLEMENT_DATE,
           SSMAROWNUM.MESSAGE_TRANSACTION_ID,
           SSMAROWNUM.REFERENCE_FOR_BENEFICIARY,
           SSMAROWNUM.RMT_INF_ADDTL,
           SSMAROWNUM.RMT_INF_USTRD,
           SSMAROWNUM.INTERMEDIARY_AGENT_ID,
           SSMAROWNUM.INTERMEDIARY_AGENT_ID_TYPE
    FROM
    (
        SELECT MESSAGE_ID,
               MESSAGE_TIMESTAMP,
               PAYMENT_TYPE,
               HEADER_MESSAGE_ID,
               END_TO_END_ID,
               PAYER_NAME,
               PAYER_ACCOUNT_ID,
               PAYER_ADDRESS_1,
               PAYER_ADDRESS_2,
               PAYER_ADDRESS_3,
               PAYEE_NAME,
               PAYEE_ACCOUNT_ID,
               PAYEE_ADDRESS_1,
               PAYEE_ADDRESS_2,
               PAYEE_ADDRESS_3,
               AMOUNT_MINOR_UNITS,
               CURRENCY_CODE_ALPHA3,
               MESSAGE_TEXT,
               PAYMENT_OR_RETURN,
               PAYER_SORT_CODE,
               PAYEE_SORT_CODE,
               INSTRUCTION_FOR_NEXT_AGENT,
               PAYEE_ACCOUNT_ID_TYPE,
               PAYER_ACCOUNT_ID_TYPE,
               PAYER_AGENT_ID,
               PAYER_AGENT_ID_TYPE,
               SETTLEMENT_DATE,
               MESSAGE_TRANSACTION_ID,
               REFERENCE_FOR_BENEFICIARY,
               RMT_INF_ADDTL,
               RMT_INF_USTRD,
               INTERMEDIARY_AGENT_ID,
               INTERMEDIARY_AGENT_ID_TYPE,
               MESSAGE_TIMESTAMP$2,
               SETTLEMENT_DATE$2,
               ROW_NUMBER() OVER (ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
        FROM
        (
            SELECT pm.MESSAGE_ID,
                   pm.MESSAGE_TIMESTAMP,
                   pm.PAYMENT_TYPE,
                   pm.HEADER_MESSAGE_ID,
                   pm.END_TO_END_ID,
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
                   pm.MESSAGE_TEXT,
                   pm.PAYMENT_OR_RETURN,
                   pm.PAYER_SORT_CODE,
                   pm.PAYEE_SORT_CODE,
                   pm.INSTRUCTION_FOR_NEXT_AGENT,
                   pm.PAYEE_ACCOUNT_ID_TYPE,
                   pm.PAYER_ACCOUNT_ID_TYPE,
                   pm.PAYER_AGENT_ID,
                   pm.PAYER_AGENT_ID_TYPE,
                   pm.SETTLEMENT_DATE,
                   pm.MESSAGE_TRANSACTION_ID,
                   pm.REFERENCE_FOR_BENEFICIARY,
                   pm.RMT_INF_ADDTL,
                   pm.RMT_INF_USTRD,
                   pm.INTERMEDIARY_AGENT_ID,
                   pm.INTERMEDIARY_AGENT_ID_TYPE,
                   pm.MESSAGE_TIMESTAMP AS MESSAGE_TIMESTAMP$2,
                   pm.SETTLEMENT_DATE AS SETTLEMENT_DATE$2,
                   0 AS SSMAPSEUDOCOLUMN
            FROM dbo.ACC_PAYMENT_MESSAGES_IN_QUEUE AS pm
            WHERE pm.SETTLEMENT_DATE <= SYSDATETIME()
                  AND 1 = 1
        ) AS SSMAPSEUDO
    ) AS SSMAROWNUM
    WHERE SSMAROWNUM.SETTLEMENT_DATE <= SYSDATETIME()
          AND SSMAROWNUM.ROWNUM = 1
    ORDER BY SSMAROWNUM.MESSAGE_TIMESTAMP;

    RETURN;

END;
GO
