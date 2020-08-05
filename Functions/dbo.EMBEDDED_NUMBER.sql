SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   FUNCTION [dbo].[EMBEDDED_NUMBER]
    /*
    *  Extract and return a number embedded in the supplied string
    *  Returns the first number encountered as a BIGINT, or zero if there is no number
    */
(
    @p_str varchar(2000)
)
RETURNS BIGINT
AS
BEGIN
    DECLARE @pos BIGINT
    DECLARE @numstr varchar(2000) = ''
    DECLARE @num BIGINT = 0

    SET @pos = PATINDEX('%[0-9]%', @p_str)                -- position of first digit
    IF @pos > 0
    BEGIN
        SET @numstr = SUBSTRING(@p_str, @pos,LEN(@p_str))
        SET @pos = PATINDEX('%[^0-9]%', @numstr)          -- position of character after last digit
        IF @pos = 0  SET @pos = LEN(@numstr)+1            -- cater for number at end of line
        SET @numstr = SUBSTRING(@numstr, 1, @pos-1)
        SET @num = CAST(@numstr AS BIGINT)
    END

    RETURN @num
END
GO
