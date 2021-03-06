SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[BULK_PAYMENT_TR_CREATE]
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
    @p_batch_id NUMERIC,
    @p_comments NVARCHAR(2000),
    @p_cover_all_payment_fees VARCHAR(2000),
    @p_payment_currency VARCHAR(2000),
    @p_payment_date DATETIME2(6),
    @p_payment_type VARCHAR(2000),
    @p_status VARCHAR(2000),
    @p_bulk_transaction_id NUMERIC
AS
BEGIN
    INSERT dbo.ACC_BULK_PAYMENT_TRANSACTIONS
    (
        BULK_TRANSACTION_ID,
        BATCH_ID,
        COMMENTS,
        PAYMENT_CURRENCY,
        PAYMENT_DATE,
        ACCOUNT_GROUP_ID,
        BANK_NAME,
        BANK_ADDRESS1,
        BANK_ADDRESS2,
        BANK_ADDRESS3,
        BANK_COUNTRY,
        BENEFICIARY_NAME,
        BENEFICIARY_ADDRESS1,
        BENEFICIARY_ADDRESS2,
        BENEFICIARY_ADDRESS3,
        BENEFICIARY_COUNTRY,
        BENEFICIARY_REFERENCE,
        BANK_ACCOUNTNAME,
        BANK_SORTCODE,
        BANK_ACCOUNT_NUMBER,
        BANK_SWIFT_CODE,
        BANK_AND_BRANCH_CODE,
        BSB_CODE,
        HKSG_BANK_AND_BRANCH_CODE,
        IBAN,
        ABA_NUMBER,
        GENERAL_ACCOUNT_NUMBER,
        AGENT_BANK_SWIFT_CODE,
        PAYMENT_TYPE,
        AMOUNT_MINOR_UNITS,
        STATUS,
        PAYER_NAME,
        PAYER_ADDRESS1,
        PAYER_ADDRESS2,
        PAYER_ADDRESS3,
        PAYER_COUNTRY,
        COVER_ALL_PAYMENT_FEES,
        ROUTING_TRANSIT_NUMBER,
        SA_BANK_BRANCH_CODE
    )
    VALUES
    (@p_bulk_transaction_id,
     @p_batch_id,
     @p_comments,
     @p_payment_currency,
     @p_payment_date,
     @p_account_group_id,
     @p_bank_name,
     @p_bank_address1,
     @p_bank_address2,
     @p_bank_address3,
     @p_bank_country,
     @p_beneficiary_name,
     @p_beneficiary_address1,
     @p_beneficiary_address2,
     @p_beneficiary_address3,
     @p_beneficiary_country,
     @p_beneficiary_reference,
     @p_bank_accountname,
     @p_bank_sortcode,
     @p_bank_account_number,
     @p_bank_swift_code,
     @p_bank_and_branch_code,
     @p_bsb_code,
     @p_hksg_bank_and_branch_code,
     @p_iban,
     @p_aba_number,
     @p_general_account_number,
     @p_agent_bank_swift_code,
     @p_payment_type,
     @p_amount_minor_units,
     @p_status,
     @p_payer_name,
     @p_payer_address1,
     @p_payer_address2,
     @p_payer_address3,
     @p_payer_country,
     @p_cover_all_payment_fees,
     @p_routing_transit_number,
     @p_sa_bank_branch_code);
END;
GO
