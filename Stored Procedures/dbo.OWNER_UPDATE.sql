SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[OWNER_UPDATE]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_owner_id NUMERIC,
    @p_owner_type_id NUMERIC,
    @p_owner_name NVARCHAR(2000),
    @p_business_type NUMERIC,
    @p_address_line_1 NVARCHAR(2000),
    @p_address_line_2 NVARCHAR(2000),
    @p_address_line_3 NVARCHAR(2000),
    @p_address_line_4 NVARCHAR(2000),
    @p_business_city NVARCHAR(2000),
    @p_postal_code NVARCHAR(2000),
    @p_business_country NVARCHAR(2000),
    @p_crm_id NVARCHAR(2000),
    @p_cra_name NVARCHAR(2000),
    @p_merch_flag_mask BIGINT,
    @p_merch_flag_update BIGINT,
    @p_pci_status_id NUMERIC,
    @p_business_trading_limit_gbp NUMERIC,
    @p_dflt_remittance_method NVARCHAR(2)
    
AS
BEGIN

    SET @cv_1 = NULL;

    UPDATE dbo.ACC_OWNERS
    SET OWNER_NAME = @p_owner_name,
        OWNER_TYPE_ID = @p_owner_type_id,
        CRM_ID = @p_crm_id,
        ADDRESS_LINE_1 = @p_address_line_1,
        ADDRESS_LINE_2 = @p_address_line_2,
        ADDRESS_LINE_3 = @p_address_line_3,
        ADDRESS_LINE_4 = @p_address_line_4,
        BUSINESS_CITY = @p_business_city,
        POSTAL_CODE = @p_postal_code,
        BUSINESS_TYPE = @p_business_type,
        BUSINESS_COUNTRY = @p_business_country,
        CRA_NAME = @p_cra_name,
        --MERCH_FLAGS = (o.MERCH_FLAGS & -1 - @p_merch_flag_mask) + (@p_merch_flag_update & @p_merch_flag_mask), 
        MERCH_FLAGS = @p_merch_flag_update,
        PCI_STATUS_ID = @p_pci_status_id,
        BUSINESS_TRADING_LIMIT_GBP = @p_business_trading_limit_gbp,
        DFLT_REMITTANCE_METHOD = @p_dflt_remittance_method
    FROM dbo.ACC_OWNERS AS o
    WHERE o.OWNER_ID = @p_owner_id;

    /* Return current state of owner.*/
    SELECT o.OWNER_ID,
           o.CRM_ID,
           o.OWNER_NAME,
           o.BUSINESS_TYPE,
           o.BUSINESS_COUNTRY,
           o.INDUSTRY_CODE,
           o.BUSINESS_TRADING_LIMIT_GBP,
           o.CRA_NAME,
           o.DFLT_PRICING_TURNOVER_BAND_ID,
           o.MERCH_FLAGS,
           o.ADDRESS_LINE_1,
           o.ADDRESS_LINE_2,
           o.ADDRESS_LINE_3,
           o.ADDRESS_LINE_4,
           o.BUSINESS_CITY,
           o.POSTAL_CODE,
           o.NEXT_RESET_DATE,
           o.CHARGING_ACCOUNT_GROUP_ID,
           o.DFLT_PRICING_TIER_ID,
           o.DEFAULT_PRICING_POLICY_ID,
           o.EXTERNAL_REF,
           o.OWNER_TYPE_ID,
           o.PCI_STATUS_ID,
           o.BUSINESS_TRADING_LIMIT_GBP,
           o.DFLT_REMITTANCE_METHOD
    FROM dbo.ACC_OWNERS AS o
    WHERE o.OWNER_ID = @p_owner_id;
END;
GO
