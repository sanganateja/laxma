SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ROW_COUNT]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_table_name NVARCHAR(2000)
AS
BEGIN

    SET @cv_1 = NULL;

    DECLARE @l_str NVARCHAR(100);

    SET @l_str = N'SELECT count(*) FROM ' + ISNULL(@p_table_name, '');

    DECLARE @auxiliary_cursor_definition_sql NVARCHAR(2000);

    /* 
      *   SSMA error messages:
      *   O2SS0157: The OPEN...FOR statement will be converted, but the dynamic string must be converted manually.

      SET @auxiliary_cursor_definition_sql = @l_str      */



    EXECUTE sp_executesql @auxiliary_cursor_definition_sql;

    RETURN;

END;
GO
