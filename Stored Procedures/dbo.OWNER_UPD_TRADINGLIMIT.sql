SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[OWNER_UPD_TRADINGLIMIT]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_owner_id NUMERIC,
    @p_business_trading_limit_gbp NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    UPDATE dbo.ACC_OWNERS
    SET BUSINESS_TRADING_LIMIT_GBP = @p_business_trading_limit_gbp
    FROM dbo.ACC_OWNERS AS o
    WHERE o.OWNER_ID = @p_owner_id;

    /* Return current state of owner.*/
    SELECT ACC_OWNERS.OWNER_ID,
           ACC_OWNERS.CRM_ID,
           ACC_OWNERS.OWNER_NAME,
           ACC_OWNERS.BUSINESS_TYPE,
           ACC_OWNERS.BUSINESS_COUNTRY,
           ACC_OWNERS.INDUSTRY_CODE,
           ACC_OWNERS.BUSINESS_TRADING_LIMIT_GBP,
           ACC_OWNERS.CRA_NAME,
           ACC_OWNERS.DFLT_PRICING_TURNOVER_BAND_ID,
           ACC_OWNERS.MERCH_FLAGS,
           ACC_OWNERS.ADDRESS_LINE_1,
           ACC_OWNERS.ADDRESS_LINE_2,
           ACC_OWNERS.ADDRESS_LINE_3,
           ACC_OWNERS.ADDRESS_LINE_4,
           ACC_OWNERS.BUSINESS_CITY,
           ACC_OWNERS.POSTAL_CODE,
           ACC_OWNERS.NEXT_RESET_DATE,
           ACC_OWNERS.CHARGING_ACCOUNT_GROUP_ID,
           ACC_OWNERS.DFLT_PRICING_TIER_ID,
           ACC_OWNERS.DEFAULT_PRICING_POLICY_ID,
           ACC_OWNERS.EXTERNAL_REF,
           ACC_OWNERS.OWNER_TYPE_ID,
           ACC_OWNERS.PCI_STATUS_ID,
           ACC_OWNERS.DFLT_REMITTANCE_METHOD
    FROM dbo.ACC_OWNERS
    WHERE ACC_OWNERS.OWNER_ID = @p_owner_id;

END;
GO