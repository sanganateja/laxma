SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[BANK_PAYEE_CREATE]
    @p_account_group_id NUMERIC,
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
    @p_payee_id NUMERIC /* ID*/
AS
BEGIN
    INSERT dbo.ACC_BANK_PAYEES
    (
        PAYEE_ID,
        ACCOUNT_GROUP_ID,
        BANK_NAME,
        BANK_ADDRESS1,
        BANK_ADDRESS2,
        BANK_ADDRESS3,
        BANK_SORTCODE,
        BANK_ACCOUNTNAME,
        BENEFICIARY_ADDRESS1,
        BENEFICIARY_ADDRESS2,
        BENEFICIARY_ADDRESS3,
        BENEFICIARY_REFERENCE,
        BANK_ACCOUNT_NUMBER,
        BANK_SWIFT_CODE,
        BANK_AND_BRANCH_CODE,
        BSB_CODE,
        HKSG_BANK_AND_BRANCH_CODE,
        IBAN,
        ABA_NUMBER,
        GENERAL_ACCOUNT_NUMBER,
        BENEFICIARY_NAME,
        AGENT_BANK_SWIFT_CODE,
        BENEFICIARY_COUNTRY,
        BANK_COUNTRY,
        ROUTING_TRANSIT_NUMBER,
        SA_BANK_BRANCH_CODE
    )
    VALUES
    (@p_payee_id,
     @p_account_group_id,
     @p_bank_name,
     @p_bank_address1,
     @p_bank_address2,
     @p_bank_address3,
     @p_bank_sortcode,
     @p_bank_accountname,
     @p_beneficiary_address1,
     @p_beneficiary_address2,
     @p_beneficiary_address3,
     @p_beneficiary_reference,
     @p_bank_account_number,
     @p_bank_swift_code,
     @p_bank_and_branch_code,
     @p_bsb_code,
     @p_hksg_bank_and_branch_code,
     @p_iban,
     @p_aba_number,
     @p_general_account_number,
     @p_beneficiary_name,
     @p_agent_bank_swift_code,
     @p_beneficiary_country,
     @p_bank_country,
     @p_routing_transit_number,
     @p_sa_bank_branch_code);
END;
GO
