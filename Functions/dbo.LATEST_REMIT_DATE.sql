SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   FUNCTION [dbo].[LATEST_REMIT_DATE] 
( 
   @p_accgrp_id numeric
)
RETURNS datetime2(0)
AS 
   
   BEGIN

      DECLARE
         @v_latest_date datetime2(6), 
         @v_remit_date datetime2(6)

      SELECT @v_remit_date = VIEW_MATURITY_DATE.MATURITY_DATE
      FROM dbo.VIEW_MATURITY_DATE

      SELECT @v_latest_date = max(dbo.next_day(DATEADD(D, -7, @v_remit_date), rd.REMIT_DAY))
      FROM dbo.ACC_REMIT_DAYS  AS rd
      WHERE @p_accgrp_id = rd.ACCOUNT_GROUP_ID

      RETURN isnull(@v_latest_date, @v_remit_date)

   END
GO
