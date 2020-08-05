SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[SESSION_CREATE]
    @p_account_group_id NUMERIC,
    @p_account_type_id NUMERIC,
    @p_is_admin NUMERIC,
    @p_cookie_id NVARCHAR(2000),
    @p_cookie_ref NVARCHAR(2000),
    @p_email_address NVARCHAR(2000),
    @p_expiry_time DATETIME2(6),
    @p_first_name NVARCHAR(2000),
    @p_last_name NVARCHAR(2000),
    @p_is_merchant NUMERIC,
    @p_owner_id NUMERIC,
    @p_is_read_only NUMERIC,
    @p_user_id NUMERIC,
    @p_session_id NUMERIC
AS
BEGIN
    INSERT dbo.ACC_SESSIONS
    (
        SESSION_ID,
        COOKIE_ID,
        COOKIE_REF,
        USER_ID,
        FIRST_NAME,
        LAST_NAME,
        EMAIL_ADDRESS,
        IS_ADMIN,
        IS_MERCHANT,
        IS_READ_ONLY,
        EXPIRY_TIME
    )
    VALUES
    (@p_session_id,
     @p_cookie_id,
     @p_cookie_ref,
     @p_user_id,
     @p_first_name,
     @p_last_name,
     @p_email_address,
     @p_is_admin,
     @p_is_merchant,
     @p_is_read_only,
     @p_expiry_time);
END;
GO
