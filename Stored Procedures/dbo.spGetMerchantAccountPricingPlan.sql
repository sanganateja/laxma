SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:			Greg 
-- Create date:		20/03/2019
-- Description:	
--		Returns Account Group pricing all pricing policies
--
-- Return:
--		pricing policies
--
-- Change history
--		08/05/2019	- Greg	-	Initial version
--
-- =============================================
CREATE PROCEDURE [dbo].[spGetMerchantAccountPricingPlan]
	@MerchantAccountGroups ttMerchantAccounts READONLY
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		ag.ACCOUNT_NUMBER as AccountNumber,
		ag.CURRENCY_CODE_ALPHA3 as Currency,
		ag.PRICING_POLICY_ID as PricingPolicyId,
		pp.NAME as PricingPolicyName
	FROM [dbo].ACC_ACCOUNT_GROUPS as ag
	JOIN ACC_PRICING_POLICY as pp on ag.PRICING_POLICY_ID = pp.PRICING_POLICY_ID
	JOIN @MerchantAccountGroups as ma on ma.AccountNumber = ag.ACCOUNT_NUMBER

	SELECT
		fee.FEE_ID as FeeId,
		ag.ACCOUNT_NUMBER as AccountNumber,
		fee.EVENT_TYPE_ID as EventType,
		fee.PERCENTAGE,
		fee.AMOUNT_MINOR_UNITS as AmountMinorUnits
	FROM [dbo].[ACC_ACQUIRING_FEES] as fee
	JOIN ACC_ACCOUNT_GROUPS as ag ON ag.ACCOUNT_GROUP_ID = fee.ACCOUNT_GROUP_ID
	JOIN @MerchantAccountGroups as ma on ma.AccountNumber = ag.ACCOUNT_NUMBER

	SELECT
		fee.ACQ_FEE_BLENDED_ID as FeeId,
		ag.ACCOUNT_NUMBER as AccountNumber,
		fee.CARD_CATEGORY_CODE as CardCategory,
		fee.TRANSACTION_CATEGORY_CODE as TransactionCategory,
		fee.REGION as Region,
		fee.AMOUNT_MINOR_UNITS as AmountMinorUnits,
		fee.PERCENTAGE
	FROM [dbo].[ACC_ACQUIRING_FEES_BLENDED] as fee
	JOIN ACC_ACCOUNT_GROUPS as ag ON ag.ACCOUNT_GROUP_ID = fee.ACCOUNT_GROUP_ID
	JOIN @MerchantAccountGroups as ma on ma.AccountNumber = ag.ACCOUNT_NUMBER

	SELECT
		fee.ACQ_FEE_IC_ID as FeeId,
		ag.ACCOUNT_NUMBER as AccountNumber,
		fee.FEE_DISTINGUISHER as FeeDistinguisher,
		fee.PERCENTAGE as Percentage,
		fee.AMOUNT_MINOR_UNITS as AmountMinorUnits
	FROM [dbo].[ACC_ACQUIRING_FEES_IC] as fee
	JOIN ACC_ACCOUNT_GROUPS as ag ON ag.ACCOUNT_GROUP_ID = fee.ACCOUNT_GROUP_ID
	JOIN @MerchantAccountGroups as ma on ma.AccountNumber = ag.ACCOUNT_NUMBER

	SELECT
		ag.ACCOUNT_NUMBER as AccountNumber,
		fee.PRICING_REGION_CODE as Region,
		fee.FEE_DISTINGUISHER as FeeDistinguisher,
		fee.PERCENTAGE as Percentage,
		fee.AMOUNT_MINOR_UNITS as AmountMinorUnits
	FROM [dbo].[ACC_CT_FEES_BLENDED] as fee
	JOIN ACC_ACCOUNT_GROUPS as ag ON ag.ACCOUNT_GROUP_ID = fee.ACCOUNT_GROUP_ID
	JOIN @MerchantAccountGroups as ma on ma.AccountNumber = ag.ACCOUNT_NUMBER

	SELECT 
		ag.ACCOUNT_NUMBER as AccountNumber,
		fee.PERCENTAGE as Percentage,
		fee.AMOUNT_MINOR_UNITS as AmountMinorUnits
	FROM [dbo].[ACC_CT_FEES_IC] as fee
	JOIN ACC_ACCOUNT_GROUPS as ag ON ag.ACCOUNT_GROUP_ID = fee.ACCOUNT_GROUP_ID
	JOIN @MerchantAccountGroups as ma on ma.AccountNumber = ag.ACCOUNT_NUMBER
 
END
GO
GRANT EXECUTE ON  [dbo].[spGetMerchantAccountPricingPlan] TO [DataServiceUser]
GO
