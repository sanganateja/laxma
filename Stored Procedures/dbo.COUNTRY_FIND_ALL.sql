SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[COUNTRY_FIND_ALL] @cv_1 VARCHAR(2000) OUTPUT
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT ACC_COUNTRIES.COUNTRY_ID,
           ACC_COUNTRIES.COUNTRY_CODE_ALPHA2,
           ACC_COUNTRIES.COUNTRY_CODE_ALPHA3,
           ACC_COUNTRIES.COUNTRY_CODE,
           ACC_COUNTRIES.REGION_CODE,
           ACC_COUNTRIES.COUNTRY_NAME,
           ACC_COUNTRIES.TIMEZONE
    FROM dbo.ACC_COUNTRIES
    ORDER BY ACC_COUNTRIES.COUNTRY_NAME;

    RETURN;

END;
GO
