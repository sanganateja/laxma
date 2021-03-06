SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[PARTNER_RECORD_FIND_BY_CRM_ID]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_crm_id NVARCHAR(2000) /* CRM_ID*/
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT o.CRM_ID,
           o.PARTNER_NAME,
           o.PARTNER_OVERRIDE,
           o.PARTNER_ID,
           o.WEBSITE_URL,
           o.PARTNER_TYPE_ID,
           o.VISA_ISO_CODE,
           o.MASTER_CARD_ISO_CODE
    FROM dbo.ACC_PARTNERS AS o
    WHERE o.CRM_ID = @p_crm_id;

    RETURN;

END;
GO
