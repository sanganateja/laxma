SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[OWNER_CREATE]
    @p_address_line_1 NVARCHAR(2000),
    @p_address_line_2 NVARCHAR(2000),
    @p_address_line_3 NVARCHAR(2000),
    @p_address_line_4 NVARCHAR(2000),
    @p_business_city NVARCHAR(2000),
    @p_business_country NVARCHAR(2000),
    @p_business_trading_limit_gbp NUMERIC,
    @p_business_type NUMERIC,
    @p_charging_acc_group_id NUMERIC,
    @p_cra_name NVARCHAR(2000),
    @p_crm_id NVARCHAR(2000),
    @p_default_pricing_policy_id NUMERIC,
    @p_dflt_pricing_tier_id NUMERIC,
    @p_dflt_pricing_tur_band_id NUMERIC,
    @p_dflt_remittance_method NVARCHAR(2),
    @p_external_ref NVARCHAR(2000),
    @p_industry_code NVARCHAR(2000),
    @p_merch_flags NUMERIC,
    @p_next_reset_date DATETIME2(6),
    @p_owner_name NVARCHAR(2000),
    @p_owner_type_id NUMERIC,
    @p_pci_status_id NUMERIC,
    @p_postal_code NVARCHAR(2000),
    @p_owner_id NUMERIC
AS
BEGIN
    INSERT dbo.ACC_OWNERS
    (
        OWNER_ID,
        OWNER_TYPE_ID,
        CRM_ID,
        OWNER_NAME,
        BUSINESS_TYPE,
        BUSINESS_COUNTRY,
        INDUSTRY_CODE,
        BUSINESS_TRADING_LIMIT_GBP,
        CRA_NAME,
        DFLT_PRICING_TURNOVER_BAND_ID,
        MERCH_FLAGS,
        ADDRESS_LINE_1,
        ADDRESS_LINE_2,
        ADDRESS_LINE_3,
        ADDRESS_LINE_4,
        BUSINESS_CITY,
        POSTAL_CODE,
        NEXT_RESET_DATE,
        CHARGING_ACCOUNT_GROUP_ID,
        DFLT_PRICING_TIER_ID,
        DEFAULT_PRICING_POLICY_ID,
        EXTERNAL_REF,
        PCI_STATUS_ID,
        DFLT_REMITTANCE_METHOD
    )
    VALUES
    (@p_owner_id,
     @p_owner_type_id,
     @p_crm_id,
     @p_owner_name,
     @p_business_type,
     @p_business_country,
     @p_industry_code,
     @p_business_trading_limit_gbp,
     @p_cra_name,
     @p_dflt_pricing_tur_band_id,
     @p_merch_flags,
     @p_address_line_1,
     @p_address_line_2,
     @p_address_line_3,
     @p_address_line_4,
     @p_business_city,
     @p_postal_code,
     @p_next_reset_date,
     @p_charging_acc_group_id,
     @p_dflt_pricing_tier_id,
     @p_default_pricing_policy_id,
     @p_external_ref,
     @p_pci_status_id,
     @p_dflt_remittance_method);
END;
GO
