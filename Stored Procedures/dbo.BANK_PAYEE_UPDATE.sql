SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[BANK_PAYEE_UPDATE]
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
    UPDATE dbo.ACC_BANK_PAYEES
    SET ABA_NUMBER = @p_aba_number,
        ACCOUNT_GROUP_ID = @p_account_group_id,
        AGENT_BANK_SWIFT_CODE = @p_agent_bank_swift_code,
        BANK_ADDRESS1 = @p_bank_address1,
        BANK_ADDRESS2 = @p_bank_address2,
        BANK_ADDRESS3 = @p_bank_address3,
        BANK_ACCOUNT_NUMBER = @p_bank_account_number,
        BANK_ACCOUNTNAME = @p_bank_accountname,
        BANK_AND_BRANCH_CODE = @p_bank_and_branch_code,
        BANK_COUNTRY = @p_bank_country,
        BANK_NAME = @p_bank_name,
        BANK_SORTCODE = @p_bank_sortcode,
        BANK_SWIFT_CODE = @p_bank_swift_code,
        BENEFICIARY_ADDRESS1 = @p_beneficiary_address1,
        BENEFICIARY_ADDRESS2 = @p_beneficiary_address2,
        BENEFICIARY_ADDRESS3 = @p_beneficiary_address3,
        BENEFICIARY_COUNTRY = @p_beneficiary_country,
        BENEFICIARY_NAME = @p_beneficiary_name,
        BENEFICIARY_REFERENCE = @p_beneficiary_reference,
        BSB_CODE = @p_bsb_code,
        GENERAL_ACCOUNT_NUMBER = @p_general_account_number,
        HKSG_BANK_AND_BRANCH_CODE = @p_hksg_bank_and_branch_code,
        IBAN = @p_iban,
        ROUTING_TRANSIT_NUMBER = @p_routing_transit_number,
        SA_BANK_BRANCH_CODE = @p_sa_bank_branch_code
    WHERE ACC_BANK_PAYEES.PAYEE_ID = @p_payee_id;
END;
GO
