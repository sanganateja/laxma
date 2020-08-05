SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[OWNER_FIND_WITH_REMITTANCE]
    @cv_1 VARCHAR(2000) OUTPUT
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
    FROM dbo.ACC_OWNERS o JOIN dbo.ACC_ACCOUNT_GROUPS ag ON o.OWNER_ID = ag.OWNER_ID AND ag.ACCOUNT_GROUP_TYPE = 'A'        -- MAG
                          JOIN dbo.ACC_ACCOUNTS a ON ag.ACCOUNT_GROUP_ID = a.ACCOUNT_GROUP_ID AND a.ACCOUNT_TYPE_ID = 4     -- Remittance Account
    WHERE ag.HOLD_REMITTANCE = 'N'
      AND a.BALANCE_MINOR_UNITS > 0;
END;
GO
