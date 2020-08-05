SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[BULK_PM_TR_FIND_ALL_BY_BATCH]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_batch_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT b.BULK_TRANSACTION_ID,
           b.BATCH_ID,
           b.COMMENTS,
           b.PAYMENT_CURRENCY,
           b.PAYMENT_DATE,
           b.ACCOUNT_GROUP_ID,
           b.BANK_NAME,
           b.BANK_ADDRESS1,
           b.BANK_ADDRESS2,
           b.BANK_ADDRESS3,
           b.BANK_COUNTRY,
           b.BENEFICIARY_NAME,
           b.BENEFICIARY_ADDRESS1,
           b.BENEFICIARY_ADDRESS2,
           b.BENEFICIARY_ADDRESS3,
           b.BENEFICIARY_COUNTRY,
           b.BENEFICIARY_REFERENCE,
           b.BANK_ACCOUNTNAME,
           b.BANK_SORTCODE,
           b.BANK_ACCOUNT_NUMBER,
           b.BANK_SWIFT_CODE,
           b.BANK_AND_BRANCH_CODE,
           b.BSB_CODE,
           b.HKSG_BANK_AND_BRANCH_CODE,
           b.IBAN,
           b.ABA_NUMBER,
           b.GENERAL_ACCOUNT_NUMBER,
           b.AGENT_BANK_SWIFT_CODE,
           b.PAYMENT_TYPE,
           b.AMOUNT_MINOR_UNITS,
           b.STATUS,
           b.PAYER_NAME,
           b.PAYER_ADDRESS1,
           b.PAYER_ADDRESS2,
           b.PAYER_ADDRESS3,
           b.PAYER_COUNTRY,
           b.ROUTING_TRANSIT_NUMBER,
           b.COVER_ALL_PAYMENT_FEES,
           b.SA_BANK_BRANCH_CODE
    FROM dbo.ACC_BULK_PAYMENT_TRANSACTIONS AS b
    WHERE b.BATCH_ID = @p_batch_id
    ORDER BY 1;

    RETURN;

END;
GO
