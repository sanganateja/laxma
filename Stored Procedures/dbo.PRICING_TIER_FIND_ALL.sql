SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[PRICING_TIER_FIND_ALL] @cv_1 VARCHAR(2000) OUTPUT
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT pt.PRICING_TIER_ID,
           pt.DESCRIPTION,
           pt.FEE_TYPE_ID,
           pt.PCI_STATUS_ID
    FROM dbo.ACC_PRICING_TIERS AS pt
    ORDER BY pt.PRICING_TIER_ID;

    RETURN;

END;
GO