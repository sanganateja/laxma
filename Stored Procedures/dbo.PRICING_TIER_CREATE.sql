SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[PRICING_TIER_CREATE]
    @p_description NVARCHAR(2000),
    @p_fee_type_id NUMERIC,
    @p_pci_status_id NUMERIC,
    @p_pricing_tier_id NUMERIC /* ID*/
AS
BEGIN
    INSERT dbo.ACC_PRICING_TIERS
    (
        PRICING_TIER_ID,
        DESCRIPTION,
        FEE_TYPE_ID,
        PCI_STATUS_ID
    )
    VALUES
    (@p_pricing_tier_id, @p_description, @p_fee_type_id, @p_pci_status_id);
END;
GO
