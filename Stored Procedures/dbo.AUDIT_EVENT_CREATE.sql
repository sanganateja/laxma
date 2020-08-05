SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[AUDIT_EVENT_CREATE]
    @p_audit_event_type_id NUMERIC,
    @p_audit_time DATETIME2(6),
    @p_description NVARCHAR(2000),
    @p_user_name NVARCHAR(2000),
    @p_audit_event_id NUMERIC /* ID*/
AS
BEGIN
    INSERT dbo.ACC_AUDIT_EVENTS
    (
        AUDIT_EVENT_TYPE_ID,
        AUDIT_TIME,
        DESCRIPTION,
        USER_NAME,
        AUDIT_EVENT_ID
    )
    VALUES
    (@p_audit_event_type_id, @p_audit_time, @p_description, @p_user_name, @p_audit_event_id);
END;
GO
