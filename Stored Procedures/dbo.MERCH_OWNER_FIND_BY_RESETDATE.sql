SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[MERCH_OWNER_FIND_BY_RESETDATE]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_due_date DATETIME2(6)
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT o.OWNER_ID,
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
    FROM dbo.ACC_OWNERS AS o
    WHERE o.OWNER_TYPE_ID = 1
          AND o.NEXT_RESET_DATE <= @p_due_date;

    RETURN;

END;
GO
