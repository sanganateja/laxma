SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACCTGRP_FIND]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_account_group_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT g.ACCOUNT_GROUP_ID,
           g.OWNER_ID,
           g.CURRENCY_CODE_ALPHA3,
           g.HOLD_REMITTANCE,
           g.ACCOUNT_NUMBER,
           g.HOLD_REMITTANCE_REASON,
           g.PAYMENT_ACCOUNT_GROUP_ID,
           g.GROUP_STATUS,
           g.ACCOUNT_GROUP_NAME,
           g.ACCOUNT_GROUP_TYPE,
           g.LEGACY_SOURCE_ID,
           g.PRICING_POLICY_ID,
           g.PARTNER_ACCOUNT_GROUP_ID,
           g.COMMISSION_PLAN_ID,
           NULL AS display_balance
    FROM dbo.ACC_ACCOUNT_GROUPS AS g
    WHERE g.ACCOUNT_GROUP_ID = @p_account_group_id;

    RETURN;

END;
GO
