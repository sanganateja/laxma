SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[OWNER_FIND_DUE_REMITTANCE]
    @cv_1         VARCHAR(2000) OUTPUT,
    @RemittanceTime DATETIME2
AS
BEGIN
    SET NOCOUNT ON
    SET @cv_1 = NULL;

    SELECT DISTINCT
           o.OWNER_ID,
           o.CRM_ID,
           o.OWNER_NAME,
           o.BUSINESS_TYPE,
           o.BUSINESS_COUNTRY,
           o.INDUSTRY_CODE,
           o.BUSINESS_TRADING_LIMIT_GBP,
           o.CRA_NAME,
           o.DFLT_PRICING_TURNOVER_BAND_ID,
           o.MERCH_FLAGS,
           o.ADDRESS_LINE_1,
           o.ADDRESS_LINE_2,
           o.ADDRESS_LINE_3,
           o.ADDRESS_LINE_4,
           o.BUSINESS_CITY,
           o.POSTAL_CODE,
           o.NEXT_RESET_DATE,
           o.CHARGING_ACCOUNT_GROUP_ID,
           o.DFLT_PRICING_TIER_ID,
           o.DEFAULT_PRICING_POLICY_ID,
           o.EXTERNAL_REF,
           o.OWNER_TYPE_ID,
           o.PCI_STATUS_ID,
           o.DFLT_REMITTANCE_METHOD
    FROM dbo.ACC_TRANSFERS f JOIN dbo.ACC_ACCOUNTS a        ON f.ACCOUNT_ID = a.ACCOUNT_ID
                             JOIN dbo.ACC_ACCOUNT_GROUPS ag ON a.ACCOUNT_GROUP_ID = ag.ACCOUNT_GROUP_ID
                             JOIN dbo.ACC_OWNERS o          ON ag.OWNER_ID = o.OWNER_ID
    WHERE ag.ACCOUNT_GROUP_TYPE = 'A'
      AND a.ACCOUNT_TYPE_ID = 0              -- Trading
      AND f.MATURITY_TIME <= @RemittanceTime
      AND f.MATURITY_TRANSACTION_ID IS NULL;

END;
GO
