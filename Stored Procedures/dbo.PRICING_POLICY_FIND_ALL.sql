SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[PRICING_POLICY_FIND_ALL] @cv_1 VARCHAR(2000) OUTPUT
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT ACC_PRICING_POLICY.PRICING_POLICY_ID,
           ACC_PRICING_POLICY.NAME
    FROM dbo.ACC_PRICING_POLICY;

    RETURN;

END;
GO
