SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[COUNTRY_MONITOR_REMOVE]  
   @p_id numeric
AS 
   
   BEGIN
      DELETE dbo.ACC_COUNTRY_MONITORS
      FROM dbo.ACC_COUNTRY_MONITORS  AS cm
      WHERE cm.MONITOR_ID = @p_id
   END
GO
