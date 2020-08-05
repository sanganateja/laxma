SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[SESSION_JSF_DELETE_EXPIRED]  
AS 
   
   BEGIN

      DECLARE
         @v_now datetime2(6) = sysdatetimeoffset()

      DELETE dbo.ACC_SESSIONS_JSF
      FROM dbo.ACC_SESSIONS_JSF  AS s
      WHERE @v_now >= s.EXPIRY_TIME

   END
GO
