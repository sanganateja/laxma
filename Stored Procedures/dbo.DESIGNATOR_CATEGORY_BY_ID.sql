SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[DESIGNATOR_CATEGORY_BY_ID]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_category_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT CST_DESIGNATOR_CATEGORIES.CATEGORY_ID,
           CST_DESIGNATOR_CATEGORIES.DESCRIPTION
    FROM dbo.CST_DESIGNATOR_CATEGORIES
    WHERE CST_DESIGNATOR_CATEGORIES.CATEGORY_ID = @p_category_id;

    RETURN;

END;
GO