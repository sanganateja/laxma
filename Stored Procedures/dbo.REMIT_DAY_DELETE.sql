SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[REMIT_DAY_DELETE]  
   @p_remit_day_id numeric
AS 
   
   BEGIN
      DELETE dbo.ACC_REMIT_DAYS
      FROM dbo.ACC_REMIT_DAYS  AS r
      WHERE r.REMIT_DAY_ID = @p_remit_day_id
   END
GO
