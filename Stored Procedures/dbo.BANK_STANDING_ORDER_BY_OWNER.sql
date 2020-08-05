SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[BANK_STANDING_ORDER_BY_OWNER]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_owner_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT bso.STANDING_ORDER_ID,
           bso.ACCOUNT_GROUP_ID,
           bso.DESCRIPTION,
           bso.BANK_NAME,
           bso.BANK_ADDRESS1,
           bso.BANK_ADDRESS2,
           bso.BANK_ADDRESS3,
           bso.BANK_SORTCODE,
           bso.BANK_ACCOUNT_NUMBER,
           bso.BANK_ACCOUNTNAME,
           bso.BENEFICIARY_NAME,
           bso.BENEFICIARY_ADDRESS1,
           bso.BENEFICIARY_ADDRESS2,
           bso.BENEFICIARY_ADDRESS3,
           bso.BENEFICIARY_COUNTRY,
           bso.BENEFICIARY_REFERENCE,
           bso.BANK_SWIFT_CODE,
           bso.AGENT_BANK_SWIFT_CODE,
           bso.IBAN,
           bso.BANK_AND_BRANCH_CODE,
           bso.BSB_CODE,
           bso.HKSG_BANK_AND_BRANCH_CODE,
           bso.ABA_NUMBER,
           bso.GENERAL_ACCOUNT_NUMBER,
           bso.START_DATE,
           bso.END_DATE,
           bso.NEXT_PAYMENT_DATE,
           bso.BUSINESS_DAY_CONVENTION,
           bso.NUM_PAYMENTS,
           bso.FREQUENCY_MULTIPLIER,
           bso.FREQUENCY_UNITS,
           bso.PAYMENT_TYPE,
           bso.AMOUNT_MINOR_UNITS,
           bso.STATUS,
           bso.BANK_COUNTRY,
           bso.NEXT_SCHEDULE_DATE,
           bso.NUM_PAYMENTS_MADE,
           bso.PAYER_NAME,
           bso.PAYER_ADDRESS1,
           bso.PAYER_ADDRESS2,
           bso.PAYER_ADDRESS3,
           bso.PAYER_COUNTRY,
           bso.PAYMENT_FAILURE_EMAIL,
           bso.NUM_PAYMENTS_FAILD,
           bso.LAST_FAILURE_DATE,
           bso.ROUTING_TRANSIT_NUMBER,
           bso.SA_BANK_BRANCH_CODE,
           bso.PAY_ALL
    FROM dbo.ACC_ACCOUNT_GROUPS AS ag,
         dbo.ACC_BANK_STANDING_ORDERS AS bso
    WHERE ag.OWNER_ID = @p_owner_id
          AND ag.ACCOUNT_GROUP_ID = bso.ACCOUNT_GROUP_ID
    ORDER BY bso.STATUS,
             ag.ACCOUNT_NUMBER,
             bso.NEXT_PAYMENT_DATE,
             bso.START_DATE;

    RETURN;

END;
GO
