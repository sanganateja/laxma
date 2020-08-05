SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[COUNTRY_FIND]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_country_id NVARCHAR(2000)
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT c.COUNTRY_ID,
           c.COUNTRY_CODE_ALPHA2,
           c.COUNTRY_CODE_ALPHA3,
           c.COUNTRY_CODE,
           c.REGION_CODE,
           c.COUNTRY_NAME,
           c.TIMEZONE
    FROM dbo.ACC_COUNTRIES AS c
    WHERE c.COUNTRY_ID = @p_country_id;

    RETURN;

END;
GO
