SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[SESSION_FIND_BY_COOKIES]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_cookie_id NVARCHAR(2000),
    @p_cookie_ref NVARCHAR(2000)
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT ac.SESSION_ID,
           ac.COOKIE_ID,
           ac.COOKIE_REF,
           ac.USER_ID,
           ac.FIRST_NAME,
           ac.LAST_NAME,
           ac.EMAIL_ADDRESS,
           ac.IS_ADMIN,
           ac.IS_MERCHANT,
           ac.IS_READ_ONLY,
           ac.OWNER_ID,
           ac.ACCOUNT_GROUP_ID,
           ac.ACCOUNT_TYPE_ID,
           ac.EXPIRY_TIME
    FROM dbo.ACC_SESSIONS AS ac
    WHERE ac.COOKIE_ID = @p_cookie_id
          AND ac.COOKIE_REF = @p_cookie_ref;

    RETURN;

END;
GO
