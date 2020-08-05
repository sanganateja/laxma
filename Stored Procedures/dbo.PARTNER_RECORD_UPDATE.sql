SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[PARTNER_RECORD_UPDATE]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_partner_id NUMERIC,
    @p_crm_id NVARCHAR(2000),
    @p_partner_name NVARCHAR(2000),
    @p_partner_override NVARCHAR(2000),
    @p_website_url NVARCHAR(2000),
    @p_partner_type_id NUMERIC,
    @p_visa_iso_code NVARCHAR(2000),
    @p_master_card_iso_code NVARCHAR(2000)
AS
BEGIN

    SET @cv_1 = NULL;

    UPDATE dbo.ACC_PARTNERS
    SET CRM_ID = @p_crm_id,
        PARTNER_NAME = @p_partner_name,
        PARTNER_OVERRIDE = @p_partner_override,
        WEBSITE_URL = @p_website_url,
        PARTNER_TYPE_ID = @p_partner_type_id,
        VISA_ISO_CODE = @p_visa_iso_code,
        MASTER_CARD_ISO_CODE = @p_master_card_iso_code
    WHERE ACC_PARTNERS.PARTNER_ID = @p_partner_id;

    /* Return current state of partner record.*/
    SELECT ACC_PARTNERS.CRM_ID,
           ACC_PARTNERS.PARTNER_NAME,
           ACC_PARTNERS.PARTNER_OVERRIDE,
           ACC_PARTNERS.PARTNER_ID,
           ACC_PARTNERS.WEBSITE_URL,
           ACC_PARTNERS.PARTNER_TYPE_ID,
           ACC_PARTNERS.VISA_ISO_CODE,
           ACC_PARTNERS.MASTER_CARD_ISO_CODE
    FROM dbo.ACC_PARTNERS
    WHERE ACC_PARTNERS.PARTNER_ID = @p_partner_id;

END;
GO
