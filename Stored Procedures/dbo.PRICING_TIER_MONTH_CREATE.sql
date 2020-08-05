SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE  [dbo].[PRICING_TIER_MONTH_CREATE]  
   @p_amount_minor_units numeric,
   @p_currency_code_alpha3 varchar(2000),
   @p_pricing_tier_id numeric,
   @p_tier_monthly_fee_id numeric/* ID*/
AS 
   
   BEGIN
      INSERT dbo.ACC_PRICING_TIER_MONTHLY_FEES(TIER_MONTHLY_FEE_ID, PRICING_TIER_ID, CURRENCY_CODE_ALPHA3, AMOUNT_MINOR_UNITS)
         VALUES (@p_tier_monthly_fee_id, @p_pricing_tier_id, @p_currency_code_alpha3, @p_amount_minor_units)
   END
GO
