SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ARREARS_TYPE_FIND_ALL]
    @cv_1 VARCHAR(2000) OUTPUT
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT at.ArrearsTypeId,
           at.ArrearsTypeName
    FROM dbo.tlkpArrearsType AS at;

END;
GO
