SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACCTGRP_FIND_FOR_OWNER]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_owner_id NUMERIC,
    @p_account_group_type NVARCHAR(2000),
    @p_balance_acct_type NUMERIC,
    @p_currency_code_alpha3 NVARCHAR(2000) /* Optional.*/
AS
BEGIN

    SET @cv_1 = NULL;

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
           a.BALANCE_MINOR_UNITS AS display_balance
    FROM dbo.ACC_ACCOUNT_GROUPS AS ag
        JOIN dbo.ACC_ACCOUNTS AS a
            ON a.ACCOUNT_GROUP_ID = ag.ACCOUNT_GROUP_ID
               AND a.ACCOUNT_TYPE_ID = @p_balance_acct_type
    WHERE ag.OWNER_ID = @p_owner_id
          AND
          (
              (ag.ACCOUNT_GROUP_TYPE = @p_account_group_type)
              OR
              (
                  @p_account_group_type = 'C'
                  AND ag.ACCOUNT_GROUP_TYPE = 'D'
              )
          )
          AND ag.CURRENCY_CODE_ALPHA3 = ISNULL(@p_currency_code_alpha3, ag.CURRENCY_CODE_ALPHA3);

    RETURN;

END;
GO
