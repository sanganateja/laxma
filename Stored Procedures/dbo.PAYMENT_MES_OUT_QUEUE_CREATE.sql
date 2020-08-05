SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[PAYMENT_MES_OUT_QUEUE_CREATE]
    @p_amount_minor_units NUMERIC,
    @p_cover_all_payment_fees CHAR(1),
    @p_currency_code_alpha3 CHAR(3),
    @p_end_to_end_id NVARCHAR(255),
    @p_instruction_for_next_agent NVARCHAR(140),
    @p_intermediary_agent_id NVARCHAR(35),
    @p_intermediary_agent_id_type CHAR(1),
    @p_message_timestamp DATETIME2(6),
    @p_payee_account_id NVARCHAR(35),
    @p_payee_account_id_type CHAR(1),
    @p_payee_address_1 NVARCHAR(255),
    @p_payee_address_2 NVARCHAR(255),
    @p_payee_address_3 NVARCHAR(255),
    @p_payee_agent_id NVARCHAR(35),
    @p_payee_agent_id_type CHAR(1),
    @p_payee_name NVARCHAR(255),
    @p_payee_sort_code NVARCHAR(35),
    @p_payer_account_id NVARCHAR(35),
    @p_payer_account_id_type CHAR(1),
    @p_payer_address_1 NVARCHAR(255),
    @p_payer_address_2 NVARCHAR(255),
    @p_payer_address_3 NVARCHAR(255),
    @p_payer_name NVARCHAR(255),
    @p_payer_sort_code NVARCHAR(35),
    @p_payment_or_return CHAR(1),
    @p_payment_type CHAR(2),
    @p_reference_for_beneficiary NVARCHAR(35),
    @p_rmt_inf_addtl NVARCHAR(140),
    @p_rmt_inf_ustrd NVARCHAR(140),
    @p_settlement_date DATETIME2(6),
    @p_transaction_id NUMERIC,
    @p_message_id NUMERIC
AS
BEGIN
    INSERT dbo.ACC_PAYMENT_MESSAGES_OUT_QUEUE
    (
        MESSAGE_ID,
        MESSAGE_TIMESTAMP,
        PAYMENT_TYPE,
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
        PAYMENT_OR_RETURN,
        PAYER_SORT_CODE,
        PAYEE_SORT_CODE,
        PAYEE_ACCOUNT_ID_TYPE,
        PAYEE_AGENT_ID,
        PAYEE_AGENT_ID_TYPE,
        PAYER_ACCOUNT_ID_TYPE,
        SETTLEMENT_DATE,
        INSTRUCTION_FOR_NEXT_AGENT,
        TRANSACTION_ID,
        REFERENCE_FOR_BENEFICIARY,
        END_TO_END_ID,
        RMT_INF_ADDTL,
        RMT_INF_USTRD,
        INTERMEDIARY_AGENT_ID,
        INTERMEDIARY_AGENT_ID_TYPE,
        COVER_ALL_PAYMENT_FEES)
    VALUES
    (   @p_message_id,
        @p_message_timestamp,
        @p_payment_type,
        @p_payer_name,
        @p_payer_account_id,
        CASE
            WHEN @p_payer_address_1 = '' THEN
                NULL
            ELSE
                @p_payer_address_1
        END,
        CASE
            WHEN @p_payer_address_2 = '' THEN
                NULL
            ELSE
                @p_payer_address_2
        END,
        CASE
            WHEN @p_payer_address_3 = '' THEN
                NULL
            ELSE
                @p_payer_address_3
        END,
        @p_payee_name,
        @p_payee_account_id,
        CASE
            WHEN @p_payee_address_1 = '' THEN
                NULL
            ELSE
                @p_payee_address_1
        END,
        CASE
            WHEN @p_payee_address_2 = '' THEN
                NULL
            ELSE
                @p_payee_address_2
        END,
        CASE
            WHEN @p_payee_address_3 = '' THEN
                NULL
            ELSE
                @p_payee_address_3
        END,
        @p_amount_minor_units,
        @p_currency_code_alpha3,
        @p_payment_or_return,
        CASE
            WHEN @p_payer_sort_code = '' THEN
                NULL
            ELSE
                @p_payer_sort_code
        END,
        CASE
            WHEN @p_payee_sort_code = '' THEN
                NULL
            ELSE
                @p_payee_sort_code
        END,
        @p_payee_account_id_type,
        CASE
            WHEN @p_payee_agent_id = '' THEN
                NULL
            ELSE
                @p_payee_agent_id
        END,
        CASE
            WHEN @p_payee_agent_id_type = '' THEN
                NULL
            ELSE
                @p_payee_agent_id_type
        END,
        @p_payer_account_id_type,
        @p_settlement_date,
        CASE
            WHEN @p_instruction_for_next_agent = '' THEN
                NULL
            ELSE
                @p_instruction_for_next_agent
        END,
        @p_transaction_id,
        CASE
            WHEN @p_reference_for_beneficiary = '' THEN
                NULL
            ELSE
                @p_reference_for_beneficiary
        END,
        CASE
            WHEN @p_end_to_end_id = '' THEN
                NULL
            ELSE
                @p_end_to_end_id
        END,
        CASE
            WHEN @p_rmt_inf_addtl = '' THEN
                NULL
            ELSE
                @p_rmt_inf_addtl
        END,
        CASE
            WHEN @p_rmt_inf_ustrd = '' THEN
                NULL
            ELSE
                @p_rmt_inf_ustrd
        END,
        CASE
            WHEN @p_intermediary_agent_id = '' THEN
                NULL
            ELSE
                @p_intermediary_agent_id
        END,
        CASE
            WHEN @p_intermediary_agent_id_type = '' THEN
                NULL
            ELSE
                @p_intermediary_agent_id_type
        END,
        CASE
            WHEN @p_cover_all_payment_fees = '' THEN
                NULL
            ELSE
                @p_cover_all_payment_fees
        END);
END;
GO
