SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[FX_RATE_CREATE]  
   @p_from_currency CHAR(3),
   @p_rate NUMERIC(12,5),
   @p_rate_date datetime2(6),
   @p_to_currency CHAR(3),
   @p_rate_id BIGINT
AS 
   
   BEGIN
   SET NOCOUNT ON

      INSERT dbo.FX_RATES(
         RATE_ID, 
         RATE_DATE, 
         FROM_CURRENCY, 
         TO_CURRENCY, 
         RATE)
         VALUES (
            @p_rate_id, 
            CAST(@p_rate_date AS DATE), 
            @p_from_currency, 
            @p_to_currency, 
            @p_rate)
   END
GO
