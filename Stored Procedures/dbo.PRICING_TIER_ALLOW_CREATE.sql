SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[PRICING_TIER_ALLOW_CREATE]  
   @p_free_allowance numeric,
   @p_pricing_tier_id numeric,
   @p_transfer_method_id numeric,
   @p_tier_allowance_id numeric/* ID*/
AS 
   
   BEGIN
      INSERT dbo.ACC_PRICING_TIER_ALLOWANCES(TIER_ALLOWANCE_ID, PRICING_TIER_ID, TRANSFER_METHOD_ID, FREE_ALLOWANCE)
         VALUES (@p_tier_allowance_id, @p_pricing_tier_id, @p_transfer_method_id, @p_free_allowance)
   END
GO
