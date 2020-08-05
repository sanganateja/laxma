SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[OWNER_FIND]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_owner_id NUMERIC /* ID1*/
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT b.OWNER_ID,
           b.CRM_ID,
           b.OWNER_NAME,
           b.BUSINESS_TYPE,
           b.BUSINESS_COUNTRY,
           b.INDUSTRY_CODE,
           b.BUSINESS_TRADING_LIMIT_GBP,
           b.CRA_NAME,
           b.DFLT_PRICING_TURNOVER_BAND_ID,
           b.MERCH_FLAGS,
           b.ADDRESS_LINE_1,
           b.ADDRESS_LINE_2,
           b.ADDRESS_LINE_3,
           b.ADDRESS_LINE_4,
           b.BUSINESS_CITY,
           b.POSTAL_CODE,
           b.NEXT_RESET_DATE,
           b.CHARGING_ACCOUNT_GROUP_ID,
           b.DFLT_PRICING_TIER_ID,
           b.DEFAULT_PRICING_POLICY_ID,
           b.EXTERNAL_REF,
           b.OWNER_TYPE_ID,
           b.PCI_STATUS_ID,
           b.DFLT_REMITTANCE_METHOD
    FROM dbo.ACC_OWNERS AS b
    WHERE b.OWNER_ID = @p_owner_id;

    RETURN;

END;
GO
