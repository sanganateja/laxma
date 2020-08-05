SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[PARTNER_RECORD_CREATE]
    @p_crm_id NVARCHAR(2000),
    @p_master_card_iso_code NVARCHAR(2000),
    @p_partner_name NVARCHAR(2000),
    @p_partner_overrirde NVARCHAR(2000),
    @p_partner_type_id NUMERIC,
    @p_visa_iso_code NVARCHAR(2000),
    @p_website_url NVARCHAR(2000),
    @p_partner_id NUMERIC
AS
BEGIN
    INSERT dbo.ACC_PARTNERS
    (
        PARTNER_ID,
        CRM_ID,
        PARTNER_NAME,
        PARTNER_OVERRIDE,
        WEBSITE_URL,
        PARTNER_TYPE_ID,
        VISA_ISO_CODE,
        MASTER_CARD_ISO_CODE
    )
    VALUES
    (@p_partner_id,
     @p_crm_id,
     @p_partner_name,
     @p_partner_overrirde,
     @p_website_url,
     @p_partner_type_id,
     @p_visa_iso_code,
     @p_master_card_iso_code);
END;
GO
