SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACCTGRP_SETAS_OWNERCHARGING]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_acc_group_id NUMERIC,
    @p_charging_for_owner_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    UPDATE dbo.ACC_OWNERS
    SET CHARGING_ACCOUNT_GROUP_ID = @p_acc_group_id
    FROM dbo.ACC_OWNERS AS o
    WHERE o.OWNER_ID = @p_charging_for_owner_id;

    /* Return current state of the associated account group.*/
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
    FROM dbo.ACC_OWNERS AS o
        LEFT OUTER JOIN dbo.ACC_ACCOUNT_GROUPS AS ag
            ON ag.ACCOUNT_GROUP_ID = o.CHARGING_ACCOUNT_GROUP_ID
    WHERE o.OWNER_ID = @p_charging_for_owner_id;

END;
GO
