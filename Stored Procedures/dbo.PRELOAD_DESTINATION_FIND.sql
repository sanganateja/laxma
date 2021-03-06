SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[PRELOAD_DESTINATION_FIND]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_currency_code_alpha3 NVARCHAR(2000),
    @p_owner_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT d.OWNER_ID,
           d.CURRENCY_CODE_ALPHA3,
           d.DESTINATION_ACCOUNT_GROUP_ID
    FROM dbo.ACC_PRELOAD_DESTINATION AS d
    WHERE d.CURRENCY_CODE_ALPHA3 = @p_currency_code_alpha3
          AND d.OWNER_ID = @p_owner_id;

    RETURN;

END;
GO
