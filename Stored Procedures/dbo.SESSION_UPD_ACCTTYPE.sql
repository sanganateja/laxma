SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[SESSION_UPD_ACCTTYPE]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_session_id NUMERIC,
    @p_new_account_type_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    UPDATE dbo.ACC_SESSIONS
    SET ACCOUNT_TYPE_ID = @p_new_account_type_id
    WHERE ACC_SESSIONS.SESSION_ID = @p_session_id;

    /* Return current state of session.*/
    SELECT ACC_SESSIONS.SESSION_ID,
           ACC_SESSIONS.COOKIE_ID,
           ACC_SESSIONS.COOKIE_REF,
           ACC_SESSIONS.USER_ID,
           ACC_SESSIONS.FIRST_NAME,
           ACC_SESSIONS.LAST_NAME,
           ACC_SESSIONS.EMAIL_ADDRESS,
           ACC_SESSIONS.IS_ADMIN,
           ACC_SESSIONS.IS_MERCHANT,
           ACC_SESSIONS.IS_READ_ONLY,
           ACC_SESSIONS.OWNER_ID,
           ACC_SESSIONS.ACCOUNT_GROUP_ID,
           ACC_SESSIONS.ACCOUNT_TYPE_ID,
           ACC_SESSIONS.EXPIRY_TIME
    FROM dbo.ACC_SESSIONS
    WHERE ACC_SESSIONS.SESSION_ID = @p_session_id;

END;
GO
