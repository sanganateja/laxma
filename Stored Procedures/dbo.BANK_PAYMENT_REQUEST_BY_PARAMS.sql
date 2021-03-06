SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[BANK_PAYMENT_REQUEST_BY_PARAMS]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_account_group_id NUMERIC,
    @p_request_date_start DATETIME2(6),
    @p_request_date_end DATETIME2(6),
    @p_payment_type VARCHAR(2000),
    @p_request_state VARCHAR(2000)
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT ACC_BANK_PAYMENT_REQUESTS.REQUEST_ID,
           ACC_BANK_PAYMENT_REQUESTS.REQUEST_DATE,
           ACC_BANK_PAYMENT_REQUESTS.AMOUNT_MINOR_UNITS,
           ACC_BANK_PAYMENT_REQUESTS.ACCOUNT_GROUP_ID,
           ACC_BANK_PAYMENT_REQUESTS.PAYMENT_TYPE,
           ACC_BANK_PAYMENT_REQUESTS.REQUEST_STATE,
           ACC_BANK_PAYMENT_REQUESTS.BANK_NAME,
           ACC_BANK_PAYMENT_REQUESTS.BANK_ADDRESS1,
           ACC_BANK_PAYMENT_REQUESTS.BANK_ADDRESS2,
           ACC_BANK_PAYMENT_REQUESTS.BANK_ADDRESS3,
           ACC_BANK_PAYMENT_REQUESTS.BANK_SORTCODE,
           ACC_BANK_PAYMENT_REQUESTS.BENEFICIARY_NAME,
           ACC_BANK_PAYMENT_REQUESTS.BENEFICIARY_ADDRESS1,
           ACC_BANK_PAYMENT_REQUESTS.BENEFICIARY_ADDRESS2,
           ACC_BANK_PAYMENT_REQUESTS.BENEFICIARY_ADDRESS3,
           ACC_BANK_PAYMENT_REQUESTS.BENEFICIARY_REFERENCE,
           ACC_BANK_PAYMENT_REQUESTS.BANK_ACCOUNT_NUMBER,
           ACC_BANK_PAYMENT_REQUESTS.BANK_SWIFT_CODE,
           ACC_BANK_PAYMENT_REQUESTS.BANK_AND_BRANCH_CODE,
           ACC_BANK_PAYMENT_REQUESTS.BSB_CODE,
           ACC_BANK_PAYMENT_REQUESTS.HKSG_BANK_AND_BRANCH_CODE,
           ACC_BANK_PAYMENT_REQUESTS.IBAN,
           ACC_BANK_PAYMENT_REQUESTS.ABA_NUMBER,
           ACC_BANK_PAYMENT_REQUESTS.GENERAL_ACCOUNT_NUMBER,
           ACC_BANK_PAYMENT_REQUESTS.AGENT_BANK_SWIFT_CODE,
           ACC_BANK_PAYMENT_REQUESTS.BANK_COUNTRY,
           ACC_BANK_PAYMENT_REQUESTS.BENEFICIARY_COUNTRY,
           ACC_BANK_PAYMENT_REQUESTS.BANK_ACCOUNTNAME,
           ACC_BANK_PAYMENT_REQUESTS.SCHEDULED_DATE,
           ACC_BANK_PAYMENT_REQUESTS.PAYER_NAME,
           ACC_BANK_PAYMENT_REQUESTS.PAYER_ADDRESS1,
           ACC_BANK_PAYMENT_REQUESTS.PAYER_ADDRESS2,
           ACC_BANK_PAYMENT_REQUESTS.PAYER_ADDRESS3,
           ACC_BANK_PAYMENT_REQUESTS.PAYER_COUNTRY,
           ACC_BANK_PAYMENT_REQUESTS.ROUTING_TRANSIT_NUMBER,
           ACC_BANK_PAYMENT_REQUESTS.SA_BANK_BRANCH_CODE
    FROM dbo.ACC_BANK_PAYMENT_REQUESTS
    WHERE (
              @p_account_group_id IS NULL
              OR ACC_BANK_PAYMENT_REQUESTS.ACCOUNT_GROUP_ID = @p_account_group_id
          )
          AND
          (
              @p_request_date_start IS NULL
              OR @p_request_date_start <= ACC_BANK_PAYMENT_REQUESTS.REQUEST_DATE
          )
          AND
          (
              @p_request_date_end IS NULL
              OR @p_request_date_end > ACC_BANK_PAYMENT_REQUESTS.REQUEST_DATE
          )
          AND
          (
              @p_payment_type IS NULL
              OR ACC_BANK_PAYMENT_REQUESTS.PAYMENT_TYPE = @p_payment_type
          )
          AND
          (
              @p_request_state IS NULL
              OR ACC_BANK_PAYMENT_REQUESTS.REQUEST_STATE = @p_request_state
          );

    RETURN;

END;
GO
