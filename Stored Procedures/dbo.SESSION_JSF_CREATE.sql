SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[SESSION_JSF_CREATE]
    @p_access_count NUMERIC,
    @p_expiry_time DATETIME2(6),
    @p_session_state NVARCHAR(MAX),
    @p_session_uuid NVARCHAR(36)
AS
BEGIN
    INSERT dbo.ACC_SESSIONS_JSF
    (
        SESSION_UUID,
        SESSION_STATE,
        EXPIRY_TIME,
        ACCESS_COUNT
    )
    VALUES
    (@p_session_uuid, @p_session_state, @p_expiry_time, @p_access_count);
END;
GO
