SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[UTIL_SETSEQUENCE]
(
    @p_seq_name NVARCHAR(2000),
    @p_wantedvalue NUMERIC
)
AS
BEGIN
    DECLARE @v_currvalue BIGINT;

    DECLARE @tsql NVARCHAR(2000);
    DECLARE @parmDefinition NVARCHAR(500);

    SET @tsql = N'SELECT @v_currvalueOUT = NEXT VALUE FOR dbo.' + @p_seq_name;
    SET @parmDefinition = N'@v_currvalueOUT NUMERIC(28,0) OUTPUT';
    EXEC sp_executesql @tsql,
                       @parmDefinition,
                       @v_currvalueOUT = @v_currvalue OUTPUT;

    IF @v_currvalue <= @p_wantedvalue
    BEGIN
        SET @tsql
            = N'ALTER SEQUENCE dbo.' + @p_seq_name + N' RESTART WITH ' + CAST(@p_wantedvalue + 1 AS NVARCHAR(28));

        EXEC sp_executesql @tsql;
    END;
END;
GO
