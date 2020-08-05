SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[spCostMastercardSchemeFeeValue]
    @cv1                           NVARCHAR(2000) OUTPUT,
    @amountMinorUnits              BIGINT,
    @currency                      NCHAR(3),
    @date                          DATETIME2,
    @merchantCountry               NCHAR(2),
    @issuerCountry                 NCHAR(2)
AS
SET NOCOUNT ON;
BEGIN
    DECLARE @amountMajorUnits DECIMAL(18,6);
    DECLARE @unitsMultiplier TINYINT;

    SET @cv1 = NULL;

    -- Amount, Currency and MerchantCountry are mandatory
    IF @amountMinorUnits IS NULL OR @currency IS NULL OR @merchantCountry IS NULL
        RETURN -1;

    SELECT @unitsMultiplier = POWER(10, decimal_places)
    FROM acc_currencies
    WHERE currency_code_alpha3 = @currency;

    SET @amountMajorUnits = CONVERT(DECIMAL(18,6), @amountMinorUnits) / @unitsMultiplier;

    SELECT TOP 1 x.feeId AS FeeId,
           3 AS FeeTypeId,          -- Scheme Fee
           ((@amountMajorUnits * ISNULL(x.FeePercentAsMultiplier, 1.0)) + (ISNULL(x.FixedFeeMajorUnit, 0.0) * x.FeeRate)) * @unitsMultiplier AS CostAmountMinorUnit,
           @currency AS CostCurrency,
           CONCAT(x.MerchantCountryRegion, ' ', ISNULL(x.IssuerCountryRegion,'NULL'))  AS CostDescriptor,
           CONVERT(BIGINT, ROUND(ISNULL(x.FixedFeeMajorUnit, 0.0) * POWER(10, ISNULL(fc.decimal_places, 0)), 0)) AS FixedAmountMinorUnits,
           x.FixedFeeCurrency AS FixedCurrency,
           @amountMinorUnits * ISNULL(x.FeePercentAsMultiplier, 1.0) AS VariableAmountMinorUnits,
           x.FeeRate AS FxRate
      FROM (
           SELECT mif.FeeId,
                  mif.EffectiveFrom,
                  mif.EffectiveUntil,
                  mif.MerchantCountryRegion,
                  mif.IssuerCountryRegion,
                  mif.FeePercentAsMultiplier,
                  mif.FixedFeeMajorUnit,
                  mif.FixedFeeCurrency,
                  fxf.rate AS FeeRate,
                  (   CASE WHEN mif.MerchantCountryRegion = @merchantCountry              AND mif.IssuerCountryRegion = @issuerCountry                                                                     THEN 9
                           WHEN mif.MerchantCountryRegion = @merchantCountry              AND mif.IssuerCountryRegion = ir.RegionCode                                                                      THEN 8
                           WHEN mif.MerchantCountryRegion = 'Intra-EEA'                   AND mif.IssuerCountryRegion = @issuerCountry 
                                                                                          AND mr.RegionCode = 'S'
                                                                                          AND ir.RegionCode = 'S'                                                                                          THEN 7
                           WHEN mif.MerchantCountryRegion = 'IntraEurope'                 AND mif.IssuerCountryRegion = @issuerCountry 
                                                                                          AND mr.RegionCode = 'D'
                                                                                          AND ir.RegionCode = 'D'                                                                                          THEN 6
                           WHEN mif.MerchantCountryRegion = 'Interregional'               AND mif.IssuerCountryRegion = @issuerCountry 
                                                                                          AND NOT EXISTS ((SELECT RegionCode FROM tlkpMastercardRegionCountry WHERE CountryCodeAlpha2 = @merchantCountry)
                                                                                                INTERSECT (SELECT RegionCode FROM tlkpMastercardRegionCountry WHERE CountryCodeAlpha2 = @issuerCountry))   THEN 6
                           WHEN mif.MerchantCountryRegion = @merchantCountry              AND mif.IssuerCountryRegion IS NULL                                                                              THEN 5
                           WHEN mif.MerchantCountryRegion IS NULL                         AND mif.IssuerCountryRegion = @issuerCountry                                                                     THEN 5
                           WHEN mif.MerchantCountryRegion = 'Intra-EEA'                   AND mif.IssuerCountryRegion = 'S'
                                                                                          AND mr.RegionCode = 'S'
                                                                                          AND ir.RegionCode = 'S'                                                                                          THEN 4
                           WHEN mif.MerchantCountryRegion = 'IntraEurope'                 AND mif.IssuerCountryRegion = 'D'
                                                                                          AND mr.RegionCode = 'D'
                                                                                          AND ir.RegionCode = 'D'                                                                                          THEN 3
                           WHEN mif.MerchantCountryRegion = 'Interregional'               AND mif.issuerCountryRegion = ir.RegionCode 
                                                                                          AND NOT EXISTS ((SELECT RegionCode FROM tlkpMastercardRegionCountry WHERE CountryCodeAlpha2 = @merchantCountry)
                                                                                                INTERSECT (SELECT RegionCode FROM tlkpMastercardRegionCountry WHERE CountryCodeAlpha2 = @issuerCountry))   THEN 3
                           WHEN mif.MerchantCountryRegion = 'Intra-EEA'                   AND mif.IssuerCountryRegion IS NULL
                                                                                          AND mr.RegionCode = 'S'
                                                                                          AND ir.RegionCode = 'S'                                                                                          THEN 2
                           WHEN mif.MerchantCountryRegion = 'IntraEurope'                 AND mif.IssuerCountryRegion IS NULL
                                                                                          AND mr.RegionCode = 'D'
                                                                                          AND ir.RegionCode = 'D'                                                                                          THEN 1
                           WHEN mif.MerchantCountryRegion = 'Interregional'               AND mif.IssuerCountryRegion IS NULL 
                                                                                          AND NOT EXISTS ((SELECT RegionCode FROM tlkpMastercardRegionCountry WHERE CountryCodeAlpha2 = @merchantCountry)
                                                                                                INTERSECT (SELECT RegionCode FROM tlkpMastercardRegionCountry WHERE CountryCodeAlpha2 = @issuerCountry))   THEN 1
                           WHEN mif.MerchantCountryRegion IS NULL                         AND mif.IssuerCountryRegion = ir.RegionCode                                                                      THEN 1
                           WHEN mif.MerchantCountryRegion IS NULL                         AND mif.IssuerCountryRegion IS NULL                                                                              THEN 0 ELSE NULL END  -- @merchant_country cannot be NULL
                  ) AS Score
             FROM tlkpCostMastercardSchemeFee mif JOIN fx_rates fxf ON ISNULL(mif.FixedFeeCurrency, @currency) = fxf.from_currency
                                                                   AND @currency = fxf.to_currency 
                                                                   AND fxf.rate_date = (SELECT MAX(fxff.rate_date)
                                                                                     FROM fx_rates fxff
                                                                                    WHERE fxff.from_currency = ISNULL(mif.FixedFeeCurrency, @currency)
                                                                                      AND fxff.to_currency = @currency
                                                                                      AND fxff.rate_date <= CAST(@date AS DATE))
                                      LEFT OUTER JOIN tlkpMastercardRegionCountry mr ON mr.countryCodeAlpha2 = @merchantCountry
                                      LEFT OUTER JOIN tlkpMastercardRegionCountry ir ON ir.countryCodeAlpha2 = @issuerCountry
           ) x LEFT OUTER JOIN acc_currencies fc ON x.FixedFeeCurrency = fc.currency_code_alpha3
     -- Mandatory parameters
     WHERE x.Score IS NOT NULL
       -- Date range - inclusive lower limit, exclusive upper limit
       AND @date >= ISNULL(x.EffectiveFrom, @date)
       AND @date < ISNULL(x.EffectiveUntil, DATEADD(SECOND, 1, @date))
    ORDER BY x.Score DESC;
END;
GO
