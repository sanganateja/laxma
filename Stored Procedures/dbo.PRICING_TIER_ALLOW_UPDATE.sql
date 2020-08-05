SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[PRICING_TIER_ALLOW_UPDATE]  
   @p_free_allowance numeric,
   @p_pricing_tier_id numeric,
   @p_transfer_method_id numeric,
   @p_tier_allowance_id numeric/* ID*/
AS 
   
   BEGIN
      UPDATE dbo.ACC_PRICING_TIER_ALLOWANCES
         SET 
            PRICING_TIER_ID = @p_pricing_tier_id, 
            TRANSFER_METHOD_ID = @p_transfer_method_id, 
            FREE_ALLOWANCE = @p_free_allowance
      FROM dbo.ACC_PRICING_TIER_ALLOWANCES  AS pta
      WHERE pta.TIER_ALLOWANCE_ID = @p_tier_allowance_id
   END
GO
