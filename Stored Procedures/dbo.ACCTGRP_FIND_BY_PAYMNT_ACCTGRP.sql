SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACCTGRP_FIND_BY_PAYMNT_ACCTGRP]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_id NUMERIC,
    @p_balance_acct_type NUMERIC
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
           a.BALANCE_MINOR_UNITS AS display_balance
    FROM dbo.ACC_ACCOUNT_GROUPS AS g
        JOIN dbo.ACC_ACCOUNTS AS a
            ON a.ACCOUNT_GROUP_ID = g.ACCOUNT_GROUP_ID
               AND a.ACCOUNT_TYPE_ID = @p_balance_acct_type
    WHERE g.PAYMENT_ACCOUNT_GROUP_ID = @p_id;

    RETURN;

END;
GO
