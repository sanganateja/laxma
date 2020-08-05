SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[OWNER_DELETE]  
   @p_owner_id numeric/* ID*/
AS 
   
   BEGIN
      DELETE dbo.ACC_OWNERS
      FROM dbo.ACC_OWNERS  AS b
      WHERE b.OWNER_ID = @p_owner_id
   END
GO
