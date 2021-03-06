SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[BANK_STANDING_ORDER_CREATE]
    @p_account_group_id NUMERIC,
    @p_amount_minor_units NUMERIC,
    @p_aba_number NVARCHAR(2000),
    @p_agent_bank_swift_code NVARCHAR(2000),
    @p_bank_accountname NVARCHAR(2000),
    @p_bank_account_number NVARCHAR(2000),
    @p_bank_address1 NVARCHAR(2000),
    @p_bank_address2 NVARCHAR(2000),
    @p_bank_address3 NVARCHAR(2000),
    @p_bank_and_branch_code NVARCHAR(2000),
    @p_bank_country VARCHAR(2000),
    @p_bank_name NVARCHAR(2000),
    @p_bank_sortcode NVARCHAR(2000),
    @p_bank_swift_code NVARCHAR(2000),
    @p_beneficiary_address1 NVARCHAR(2000),
    @p_beneficiary_address2 NVARCHAR(2000),
    @p_beneficiary_address3 NVARCHAR(2000),
    @p_beneficiary_country VARCHAR(2000),
    @p_beneficiary_name NVARCHAR(2000),
    @p_beneficiary_reference NVARCHAR(2000),
    @p_bsb_code NVARCHAR(2000),
    @p_general_account_number NVARCHAR(2000),
    @p_hksg_bank_and_branch_code NVARCHAR(2000),
    @p_iban NVARCHAR(2000),
    @p_routing_transit_number NVARCHAR(2000),
    @p_sa_bank_branch_code NVARCHAR(2000),
    @p_payer_address1 NVARCHAR(2000),
    @p_payer_address2 NVARCHAR(2000),
    @p_payer_address3 NVARCHAR(2000),
    @p_payer_country VARCHAR(2000),
    @p_payer_name NVARCHAR(2000),
    @p_business_day_convention VARCHAR(2000),
    @p_end_date DATETIME2(6),
    @p_frequency_multiplier NUMERIC,
    @p_frequency_units VARCHAR(2000),
    @p_last_failure_date DATETIME2(6),
    @p_next_payment_date DATETIME2(6),
    @p_next_schedule_date DATETIME2(6),
    @p_num_payments NUMERIC,
    @p_num_payments_faild NUMERIC,
    @p_num_payments_made NUMERIC,
    @p_start_date DATETIME2(6),
    @p_description NVARCHAR(2000),
    @p_pay_all VARCHAR(2000),
    @p_payment_failure_email NVARCHAR(2000),
    @p_payment_type VARCHAR(2000),
    @p_status VARCHAR(2000),
    @p_standing_order_id NUMERIC /* ID*/
AS
BEGIN
    INSERT dbo.ACC_BANK_STANDING_ORDERS
    (
        STANDING_ORDER_ID,
        ACCOUNT_GROUP_ID,
        DESCRIPTION,
        BANK_NAME,
        BANK_ADDRESS1,
        BANK_ADDRESS2,
        BANK_ADDRESS3,
        BANK_SORTCODE,
        BANK_ACCOUNT_NUMBER,
        BANK_ACCOUNTNAME,
        BENEFICIARY_NAME,
        BENEFICIARY_ADDRESS1,
        BENEFICIARY_ADDRESS2,
        BENEFICIARY_ADDRESS3,
        BENEFICIARY_COUNTRY,
        BENEFICIARY_REFERENCE,
        BANK_SWIFT_CODE,
        AGENT_BANK_SWIFT_CODE,
        IBAN,
        BANK_AND_BRANCH_CODE,
        BSB_CODE,
        HKSG_BANK_AND_BRANCH_CODE,
        ABA_NUMBER,
        GENERAL_ACCOUNT_NUMBER,
        START_DATE,
        END_DATE,
        NEXT_PAYMENT_DATE,
        BUSINESS_DAY_CONVENTION,
        NUM_PAYMENTS,
        FREQUENCY_MULTIPLIER,
        FREQUENCY_UNITS,
        PAYMENT_TYPE,
        AMOUNT_MINOR_UNITS,
        STATUS,
        BANK_COUNTRY,
        NEXT_SCHEDULE_DATE,
        NUM_PAYMENTS_MADE,
        PAYER_NAME,
        PAYER_ADDRESS1,
        PAYER_ADDRESS2,
        PAYER_ADDRESS3,
        PAYER_COUNTRY,
        PAYMENT_FAILURE_EMAIL,
        NUM_PAYMENTS_FAILD,
        LAST_FAILURE_DATE,
        ROUTING_TRANSIT_NUMBER,
        SA_BANK_BRANCH_CODE,
        PAY_ALL
    )
    VALUES
    (@p_standing_order_id,
     @p_account_group_id,
     @p_description,
     CASE WHEN LEN(@p_bank_name) = 0 THEN NULL ELSE @p_bank_name END,
     CASE WHEN LEN(@p_bank_address1) = 0 THEN NULL ELSE @p_bank_address1 END,
     CASE WHEN LEN(@p_bank_address2) = 0 THEN NULL ELSE @p_bank_address2 END,
     CASE WHEN LEN(@p_bank_address3) = 0 THEN NULL ELSE @p_bank_address3 END,
     CASE WHEN LEN(@p_bank_sortcode) = 0 THEN NULL ELSE @p_bank_sortcode END,
     CASE WHEN LEN(@p_bank_account_number) = 0 THEN NULL ELSE @p_bank_account_number END,
     CASE WHEN LEN(@p_bank_accountname) = 0 THEN NULL ELSE @p_bank_accountname END,
     CASE WHEN LEN(@p_beneficiary_name) = 0 THEN NULL ELSE @p_beneficiary_name END,
     CASE WHEN LEN(@p_beneficiary_address1) = 0 THEN NULL ELSE @p_beneficiary_address1 END,
     CASE WHEN LEN(@p_beneficiary_address2) = 0 THEN NULL ELSE @p_beneficiary_address2 END,
     CASE WHEN LEN(@p_beneficiary_address3) = 0 THEN NULL ELSE @p_beneficiary_address3 END,
     @p_beneficiary_country,
     CASE WHEN LEN(@p_beneficiary_reference) = 0 THEN NULL ELSE @p_beneficiary_reference END,
     CASE WHEN LEN(@p_bank_swift_code) = 0 THEN NULL ELSE @p_bank_swift_code END,
     CASE WHEN LEN(@p_agent_bank_swift_code) = 0 THEN NULL ELSE @p_agent_bank_swift_code END,
     CASE WHEN LEN(@p_iban) = 0 THEN NULL ELSE @p_iban END,
     CASE WHEN LEN(@p_bank_and_branch_code) = 0 THEN NULL ELSE @p_bank_and_branch_code END,
     CASE WHEN LEN(@p_bsb_code) = 0 THEN NULL ELSE @p_bsb_code END,
     CASE WHEN LEN(@p_hksg_bank_and_branch_code) = 0 THEN NULL ELSE @p_hksg_bank_and_branch_code END,
     CASE WHEN LEN(@p_aba_number) = 0 THEN NULL ELSE @p_aba_number END,
     CASE WHEN LEN(@p_general_account_number) = 0 THEN NULL ELSE @p_general_account_number END,
     @p_start_date,
     @p_end_date,
     @p_next_payment_date,
     @p_business_day_convention,
     @p_num_payments,
     @p_frequency_multiplier,
     @p_frequency_units,
     @p_payment_type,
     @p_amount_minor_units,
     @p_status,
     @p_bank_country,
     @p_next_schedule_date,
     @p_num_payments_made,
     CASE WHEN LEN(@p_payer_name) = 0 THEN NULL ELSE @p_payer_name END,
     CASE WHEN LEN(@p_payer_address1) = 0 THEN NULL ELSE @p_payer_address1 END,
     CASE WHEN LEN(@p_payer_address2) = 0 THEN NULL ELSE @p_payer_address2 END,
     CASE WHEN LEN(@p_payer_address3) = 0 THEN NULL ELSE @p_payer_address3 END,
     @p_payer_country,
     CASE WHEN LEN(@p_payment_failure_email) = 0 THEN NULL ELSE @p_payment_failure_email END,
     @p_num_payments_faild,
     @p_last_failure_date,
     CASE WHEN LEN(@p_routing_transit_number) = 0 THEN NULL ELSE @p_routing_transit_number END,
     CASE WHEN LEN(@p_sa_bank_branch_code) = 0 THEN NULL ELSE @p_sa_bank_branch_code END,
     @p_pay_all);
END;
GO
