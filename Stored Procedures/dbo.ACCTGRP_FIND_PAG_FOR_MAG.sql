SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACCTGRP_FIND_PAG_FOR_MAG]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_crm_id NVARCHAR(2000),
    @p_currency_code_alpha3 VARCHAR(2000) = NULL
AS
BEGIN

    SET @cv_1 = NULL;

    /*
      *   SSMA warning messages:
      *   O2SS0204: Subqueries with ROWNUM emulation may have unnecessary columns.
      */

    SELECT SSMAROWNUM.ACCOUNT_GROUP_ID,
           SSMAROWNUM.OWNER_ID,
           SSMAROWNUM.CURRENCY_CODE_ALPHA3,
           SSMAROWNUM.HOLD_REMITTANCE,
           SSMAROWNUM.ACCOUNT_NUMBER,
           SSMAROWNUM.HOLD_REMITTANCE_REASON,
           SSMAROWNUM.PAYMENT_ACCOUNT_GROUP_ID,
           SSMAROWNUM.GROUP_STATUS,
           SSMAROWNUM.ACCOUNT_GROUP_NAME,
           SSMAROWNUM.ACCOUNT_GROUP_TYPE,
           SSMAROWNUM.LEGACY_SOURCE_ID,
           SSMAROWNUM.PRICING_POLICY_ID,
           SSMAROWNUM.PARTNER_ACCOUNT_GROUP_ID,
           SSMAROWNUM.COMMISSION_PLAN_ID,
           0 AS display_balance
    FROM
    (
        SELECT ACCOUNT_GROUP_ID,
               OWNER_ID,
               CURRENCY_CODE_ALPHA3,
               HOLD_REMITTANCE,
               ACCOUNT_NUMBER,
               HOLD_REMITTANCE_REASON,
               PAYMENT_ACCOUNT_GROUP_ID,
               GROUP_STATUS,
               ACCOUNT_GROUP_NAME,
               ACCOUNT_GROUP_TYPE,
               LEGACY_SOURCE_ID,
               PRICING_POLICY_ID,
               PARTNER_ACCOUNT_GROUP_ID,
               COMMISSION_PLAN_ID,
               OWNER_ID$2,
               ACCOUNT_GROUP_TYPE$2,
               CURRENCY_CODE_ALPHA3$2,
               ROW_NUMBER() OVER (ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
        FROM
        (
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
                   ag.OWNER_ID AS OWNER_ID$2,
                   ag.ACCOUNT_GROUP_TYPE AS ACCOUNT_GROUP_TYPE$2,
                   ag.CURRENCY_CODE_ALPHA3 AS CURRENCY_CODE_ALPHA3$2,
                   0 AS SSMAPSEUDOCOLUMN
            FROM dbo.ACC_ACCOUNT_GROUPS AS ag
            WHERE ag.OWNER_ID =
            (
                SELECT ACC_OWNERS.OWNER_ID
                FROM dbo.ACC_OWNERS
                WHERE ACC_OWNERS.OWNER_TYPE_ID != 1
                      AND ACC_OWNERS.CRM_ID = @p_crm_id
            )
                  AND ag.ACCOUNT_GROUP_TYPE = 'P'
                  AND ag.CURRENCY_CODE_ALPHA3 = ISNULL(@p_currency_code_alpha3, ag.CURRENCY_CODE_ALPHA3)
                  AND 1 = 1
        ) AS SSMAPSEUDO
    ) AS SSMAROWNUM
    WHERE SSMAROWNUM.OWNER_ID =
    (
        SELECT ACC_OWNERS.OWNER_ID
        FROM dbo.ACC_OWNERS
        WHERE ACC_OWNERS.OWNER_TYPE_ID != 1
              AND ACC_OWNERS.CRM_ID = @p_crm_id
    )
          AND SSMAROWNUM.ACCOUNT_GROUP_TYPE = 'P'
          AND SSMAROWNUM.CURRENCY_CODE_ALPHA3 = ISNULL(@p_currency_code_alpha3, SSMAROWNUM.CURRENCY_CODE_ALPHA3)
          AND SSMAROWNUM.ROWNUM = 1;

    RETURN;

END;
GO
