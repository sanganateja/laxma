SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACCTGRP_UPD_REMITTOACCTGRP]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_account_group_id NUMERIC,
    @p_remit_to_account_group_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    UPDATE dbo.ACC_ACCOUNT_GROUPS
    SET PAYMENT_ACCOUNT_GROUP_ID = @p_remit_to_account_group_id
    WHERE ACC_ACCOUNT_GROUPS.ACCOUNT_GROUP_ID = @p_account_group_id;

    /* Return current state of owner.*/
    SELECT ag.ACCOUNT_GROUP_ID,
           ag.OWNER_ID,
           ag.CURRENCY_CODE_ALPHA3,
           ag.HOLD_REMITTANCE,
           ag.ACCOUNT_NUMBER,
           ag.HOLD_REMITTANCE_REASON,
           ag.PAYMENT_ACCOUNT_GROUP_ID,
           ag.GROUP_STATUS,
           ag.ACCOUNT_GROUP_NAME,
           ag.ACCOUNT_GROUP_TYPE,
           ag.LEGACY_SOURCE_ID,
           ag.PRICING_POLICY_ID,
           ag.PARTNER_ACCOUNT_GROUP_ID,
           ag.COMMISSION_PLAN_ID,
           NULL AS display_balance
    FROM dbo.ACC_ACCOUNT_GROUPS AS ag
    WHERE ag.ACCOUNT_GROUP_ID = @p_account_group_id;

END;
GO
