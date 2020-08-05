SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[PARTNER_RECORD_FIND_BY_NAME]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_partner_name NVARCHAR(2000) /* PARTNER_NAME*/
AS
BEGIN

    SET @cv_1 = NULL;

    DECLARE @v_partner_name NVARCHAR(255);

    SET @v_partner_name = UPPER(@p_partner_name);

    SELECT o.CRM_ID,
           o.PARTNER_NAME,
           o.PARTNER_OVERRIDE,
           o.PARTNER_ID,
           o.WEBSITE_URL,
           o.PARTNER_TYPE_ID,
           o.VISA_ISO_CODE,
           o.MASTER_CARD_ISO_CODE
    FROM dbo.ACC_PARTNERS AS o
    WHERE o.PARTNER_NAME LIKE '%' + ISNULL(@v_partner_name, '') + '%'
    ORDER BY o.PARTNER_ID DESC;

    RETURN;

END;
GO
