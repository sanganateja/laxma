SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[SESSION_JSF_DELETE] @p_session_uuid NVARCHAR(36)
AS
BEGIN
    DELETE dbo.ACC_SESSIONS_JSF
    WHERE ACC_SESSIONS_JSF.SESSION_UUID = @p_session_uuid;
END;
GO
