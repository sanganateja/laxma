SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[DESIGNATOR_LOOKUP_ALL] @cv_1 VARCHAR(2000) OUTPUT
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT dl.*
    FROM CST_DESIGNATOR_ACQ_LOOKUP dl
    ORDER BY dl.LOOKUP_ID DESC;

    RETURN;

END;
GO
