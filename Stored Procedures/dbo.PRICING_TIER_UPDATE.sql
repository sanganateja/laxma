SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE  [dbo].[PRICING_TIER_UPDATE]  
   @p_description nvarchar(2000),
   @p_fee_type_id numeric,
   @p_pci_status_id numeric,
   @p_pricing_tier_id numeric/* ID*/
AS 
   
   BEGIN
      UPDATE dbo.ACC_PRICING_TIERS
         SET 
            DESCRIPTION = @p_description, 
            FEE_TYPE_ID = @p_fee_type_id, 
            PCI_STATUS_ID = @p_pci_status_id
      FROM dbo.ACC_PRICING_TIERS  AS pt
      WHERE pt.PRICING_TIER_ID = @p_pricing_tier_id
   END
GO
