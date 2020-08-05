SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[spAccountGroupFindRemittingForOwner]
    @cv_1 VARCHAR(2000) OUTPUT,
    @OwnerId BIGINT
AS
BEGIN
    SET NOCOUNT ON
    SET @cv_1 = NULL;

    SELECT DISTINCT ag.ACCOUNT_GROUP_ID,
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
    FROM dbo.ACC_ACCOUNT_GROUPS ag JOIN dbo.ACC_ACCOUNTS a ON ag.ACCOUNT_GROUP_ID = a.ACCOUNT_GROUP_ID AND a.ACCOUNT_TYPE_ID = 4  -- Remittance Account
    WHERE ag.OWNER_ID = @OwnerId
      AND ag.ACCOUNT_GROUP_TYPE = 'A'   -- MAG
      AND ag.HOLD_REMITTANCE = 'N'
      AND a.BALANCE_MINOR_UNITS > 0

END;
GO
