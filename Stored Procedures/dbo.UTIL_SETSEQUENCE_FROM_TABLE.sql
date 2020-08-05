SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[UTIL_SETSEQUENCE_FROM_TABLE]
(
    @p_seq_name NVARCHAR(2000),
    @p_table_name NVARCHAR(2000),
    @p_column_name NVARCHAR(2000)
)
AS
BEGIN

    SET NOCOUNT ON;
    DECLARE @v_currvalue BIGINT,
            @v_wantedvalue BIGINT,
            @tsql NVARCHAR(2000),
            @ParmDefinition NVARCHAR(500);


    SET @ParmDefinition = N'@value BIGINT OUTPUT';
    SET @tsql = N'SELECT @value = MAX(' + ISNULL(@p_column_name, 0) + N') FROM ' + @p_table_name;

    EXECUTE sys.sp_executesql @tsql,
                              @ParmDefinition,
                              @value = @v_wantedvalue OUTPUT;

    EXECUTE dbo.UTIL_SETSEQUENCE @p_seq_name = @p_seq_name,
                                 @p_wantedvalue = @v_wantedvalue;

END;
GO
