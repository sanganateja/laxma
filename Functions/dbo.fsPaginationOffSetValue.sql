SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fsPaginationOffSetValue] (@PageNumber INT, @PageSize INT)
RETURNS INT
WITH SCHEMABINDING AS
BEGIN
  DECLARE @OffSet INT = @PageSize * (@PageNumber -1)
  RETURN @OffSet ;
END;

GO
GRANT EXECUTE ON  [dbo].[fsPaginationOffSetValue] TO [DataServiceUser]
GO
