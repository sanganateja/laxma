SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[BANK_STANDING_ORDER_UPDATE]
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
    UPDATE dbo.ACC_BANK_STANDING_ORDERS
    SET ACCOUNT_GROUP_ID = @p_account_group_id,
        AMOUNT_MINOR_UNITS = @p_amount_minor_units,
        DESCRIPTION = @p_description,
        ABA_NUMBER = CASE WHEN LEN(@p_aba_number) = 0 THEN NULL ELSE @p_aba_number END,
        AGENT_BANK_SWIFT_CODE = CASE WHEN LEN(@p_agent_bank_swift_code) = 0 THEN NULL ELSE @p_agent_bank_swift_code END,
        BANK_ADDRESS1 = CASE WHEN LEN(@p_bank_address1) = 0 THEN NULL ELSE @p_bank_address1 END,
        BANK_ADDRESS2 = CASE WHEN LEN(@p_bank_address2) = 0 THEN NULL ELSE @p_bank_address2 END,
        BANK_ADDRESS3 = CASE WHEN LEN(@p_bank_address3) = 0 THEN NULL ELSE @p_bank_address3 END,
        BANK_ACCOUNT_NUMBER = CASE WHEN LEN(@p_bank_account_number) = 0 THEN NULL ELSE @p_bank_account_number END,
        BANK_ACCOUNTNAME = CASE WHEN LEN(@p_bank_accountname) = 0 THEN NULL ELSE @p_bank_accountname END,
        BANK_AND_BRANCH_CODE = CASE WHEN LEN(@p_bank_and_branch_code) = 0 THEN NULL ELSE @p_bank_and_branch_code END,
        BANK_COUNTRY = @p_bank_country,
        BANK_NAME = CASE WHEN LEN(@p_bank_name) = 0 THEN NULL ELSE @p_bank_name END,
        BANK_SORTCODE = CASE WHEN LEN(@p_bank_sortcode) = 0 THEN NULL ELSE @p_bank_sortcode END,
        BANK_SWIFT_CODE = CASE WHEN LEN(@p_bank_swift_code) = 0 THEN NULL ELSE @p_bank_swift_code END,
        BENEFICIARY_ADDRESS1 = CASE WHEN LEN(@p_beneficiary_address1) = 0 THEN NULL ELSE @p_beneficiary_address1 END,
        BENEFICIARY_ADDRESS2 = CASE WHEN LEN(@p_beneficiary_address2) = 0 THEN NULL ELSE @p_beneficiary_address2 END,
        BENEFICIARY_ADDRESS3 = CASE WHEN LEN(@p_beneficiary_address3) = 0 THEN NULL ELSE @p_beneficiary_address3 END,
        BENEFICIARY_COUNTRY = @p_beneficiary_country,
        BENEFICIARY_NAME = CASE WHEN LEN(@p_beneficiary_name) = 0 THEN NULL ELSE @p_beneficiary_name END,
        BENEFICIARY_REFERENCE = CASE WHEN LEN(@p_beneficiary_reference) = 0 THEN NULL ELSE @p_beneficiary_reference END,
        BSB_CODE = CASE WHEN LEN(@p_bsb_code) = 0 THEN NULL ELSE @p_bsb_code END,
        GENERAL_ACCOUNT_NUMBER = CASE WHEN LEN(@p_general_account_number) = 0 THEN NULL ELSE @p_general_account_number END,
        HKSG_BANK_AND_BRANCH_CODE = CASE WHEN LEN(@p_hksg_bank_and_branch_code) = 0 THEN NULL ELSE @p_hksg_bank_and_branch_code END,
        IBAN = CASE WHEN LEN(@p_iban) = 0 THEN NULL ELSE @p_iban END,
        PAYER_ADDRESS1 = CASE WHEN LEN(@p_payer_address1) = 0 THEN NULL ELSE @p_payer_address1 END,
        PAYER_ADDRESS2 = CASE WHEN LEN(@p_payer_address2) = 0 THEN NULL ELSE @p_payer_address2 END,
        PAYER_ADDRESS3 = CASE WHEN LEN(@p_payer_address3) = 0 THEN NULL ELSE @p_payer_address3 END,
        PAYER_COUNTRY = @p_payer_country,
        PAYER_NAME = CASE WHEN LEN(@p_payer_name) = 0 THEN NULL ELSE @p_payer_name END,
        BUSINESS_DAY_CONVENTION = @p_business_day_convention,
        END_DATE = @p_end_date,
        FREQUENCY_MULTIPLIER = @p_frequency_multiplier,
        FREQUENCY_UNITS = @p_frequency_units,
        LAST_FAILURE_DATE = @p_last_failure_date,
        NEXT_PAYMENT_DATE = @p_next_payment_date,
        NEXT_SCHEDULE_DATE = @p_next_schedule_date,
        NUM_PAYMENTS = @p_num_payments,
        NUM_PAYMENTS_FAILD = @p_num_payments_faild,
        NUM_PAYMENTS_MADE = @p_num_payments_made,
        START_DATE = @p_start_date,
        PAYMENT_FAILURE_EMAIL = CASE WHEN LEN(@p_payment_failure_email) = 0 THEN NULL ELSE @p_payment_failure_email END,
        PAYMENT_TYPE = @p_payment_type,
        STATUS = @p_status,
        ROUTING_TRANSIT_NUMBER = CASE WHEN LEN(@p_routing_transit_number) = 0 THEN NULL ELSE @p_routing_transit_number END,
        SA_BANK_BRANCH_CODE = CASE WHEN LEN(@p_sa_bank_branch_code) = 0 THEN NULL ELSE @p_sa_bank_branch_code END,
        PAY_ALL = @p_pay_all
    WHERE ACC_BANK_STANDING_ORDERS.STANDING_ORDER_ID = @p_standing_order_id;
END;
GO