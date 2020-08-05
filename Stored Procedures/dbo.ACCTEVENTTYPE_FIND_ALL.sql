SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACCTEVENTTYPE_FIND_ALL] @cv_1 VARCHAR(2000) OUTPUT
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT aet.EVENT_TYPE_ID,
           aet.EVENT_NAME
    FROM dbo.ACC_EVENT_TYPES AS aet;

    RETURN;

END;
GO