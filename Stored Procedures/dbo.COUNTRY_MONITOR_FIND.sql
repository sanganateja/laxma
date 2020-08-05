SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[COUNTRY_MONITOR_FIND]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT cm.MONITOR_ID,
           cm.COUNTRY_ID,
           cm.DESCRIPTION,
           cm.CREATION_DATE
    FROM dbo.ACC_COUNTRY_MONITORS AS cm
    WHERE cm.MONITOR_ID = @p_id;

    RETURN;

END;
GO
