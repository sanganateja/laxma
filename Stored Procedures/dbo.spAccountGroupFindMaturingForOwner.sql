SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[spAccountGroupFindMaturingForOwner]
    @cv_1 VARCHAR(2000) OUTPUT,
    @OwnerId BIGINT,
    @MaturityTime DATETIME2
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
    FROM dbo.ACC_ACCOUNT_GROUPS ag JOIN dbo.ACC_ACCOUNTS a ON ag.ACCOUNT_GROUP_ID = a.ACCOUNT_GROUP_ID
                                   JOIN dbo.ACC_TRANSFERS f ON a.ACCOUNT_ID = f.ACCOUNT_ID 
    WHERE ag.OWNER_ID = @OwnerId
      AND f.MATURITY_TIME <= @MaturityTime
      AND f.MATURITY_TRANSACTION_ID IS NULL
      AND ag.HOLD_REMITTANCE = 'N';

END;
GO
