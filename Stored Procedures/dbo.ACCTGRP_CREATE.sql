SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACCTGRP_CREATE]
    @p_account_group_name NVARCHAR(2000),
    @p_account_group_type VARCHAR(2000),
    @p_account_number NUMERIC,
    @p_commission_plan_id NUMERIC,
    @p_currency_code_alpha3 NVARCHAR(2000),
    @p_display_balance NUMERIC, /* Required for entity.*/
    @p_group_status VARCHAR(2000),
    @p_hold_remittance VARCHAR(2000),
    @p_hold_remittance_reason NVARCHAR(2000),
    @p_owner_id NUMERIC,
    @p_partner_account_group_id NUMERIC,
    @p_payment_account_group_id NUMERIC,
    @p_pricing_policy_id NUMERIC,
    @p_account_group_id NUMERIC
AS
BEGIN
    INSERT dbo.ACC_ACCOUNT_GROUPS
    (
        ACCOUNT_GROUP_ID,
        OWNER_ID,
        CURRENCY_CODE_ALPHA3,
        HOLD_REMITTANCE,
        ACCOUNT_NUMBER,
        HOLD_REMITTANCE_REASON,
        PARTNER_ACCOUNT_GROUP_ID,
        PAYMENT_ACCOUNT_GROUP_ID,
        GROUP_STATUS,
        PRICING_POLICY_ID,
        COMMISSION_PLAN_ID,
        ACCOUNT_GROUP_NAME,
        ACCOUNT_GROUP_TYPE
    )
    VALUES
    (@p_account_group_id,
     @p_owner_id,
     @p_currency_code_alpha3,
     @p_hold_remittance,
     @p_account_number,
     @p_hold_remittance_reason,
     @p_partner_account_group_id,
     @p_payment_account_group_id,
     @p_group_status,
     @p_pricing_policy_id,
     @p_commission_plan_id,
     @p_account_group_name,
     @p_account_group_type);
END;
GO
