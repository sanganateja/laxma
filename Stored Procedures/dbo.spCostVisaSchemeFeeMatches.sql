SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[spCostVisaSchemeFeeMatches]
    @cv1                           NVARCHAR(2000) OUTPUT,
    @amountMinorUnits              BIGINT,
    @currency                      NCHAR(3),
    @date                          DATETIME2,
    @merchantCountry               NCHAR(2),
    @issuerCountry                 NCHAR(2),
    @cardType                      NVARCHAR(50)
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

    SELECT x.FeeId,
           x.Score,
           x.EffectiveFrom,
           x.EffectiveUntil,
           x.MerchantCountryRegion,
           x.IssuerCountryRegion,
           x.CardType,
           x.FeePercentAsMultiplier,
           x.FixedFeeMajorUnit,
           x.FixedFeeCurrency
      FROM (
           SELECT vif.FeeId,
                  vif.EffectiveFrom,
                  vif.EffectiveUntil,
                  vif.MerchantCountryRegion,
                  vif.IssuerCountryRegion,
                  vif.CardType,
                  vif.FeePercentAsMultiplier,
                  vif.FixedFeeMajorUnit,
                  vif.FixedFeeCurrency,
                  fxf.rate AS FeeRate,
                  (   CASE WHEN vif.MerchantCountryRegion = @merchantCountry AND vif.IssuerCountryRegion = @issuerCountry                                                                          THEN 6
                           WHEN vif.MerchantCountryRegion = @merchantCountry AND vif.IssuerCountryRegion = ir.RegionCode                                                                           THEN 5
                           WHEN vif.MerchantCountryRegion = 'IntraEEA'       AND vif.IssuerCountryRegion = @issuerCountry 
                                                                             AND mr.RegionCode = 'EEA'
                                                                             AND ir.RegionCode = 'EEA'                                                                                             THEN 4
                           WHEN vif.MerchantCountryRegion = 'IntraNonEEA'    AND vif.IssuerCountryRegion = @issuerCountry
                                                                             AND mr.RegionCode = ir.RegionCode
                                                                             AND 'EEA' NOT IN (SELECT RegionCode FROM tlkpVisaRegionCountry WHERE CountryCodeAlpha2 = @merchantCountry) 
                                                                             AND 'EEA' NOT IN (SELECT RegionCode FROM tlkpVisaRegionCountry WHERE CountryCodeAlpha2 = @issuerCountry)              THEN 4
                           WHEN vif.MerchantCountryRegion = 'Interregional'  AND vif.IssuerCountryRegion = @issuerCountry 
                                                                             AND NOT EXISTS ((SELECT RegionCode FROM tlkpVisaRegionCountry WHERE CountryCodeAlpha2 = @merchantCountry)
                                                                                   INTERSECT (SELECT RegionCode FROM tlkpVisaRegionCountry WHERE CountryCodeAlpha2 = @issuerCountry))              THEN 4
                           WHEN vif.MerchantCountryRegion = @merchantCountry AND vif.IssuerCountryRegion IS NULL                                                                                   THEN 3
                           WHEN vif.MerchantCountryRegion IS NULL            AND vif.IssuerCountryRegion = @issuerCountry                                                                          THEN 3
                           WHEN vif.MerchantCountryRegion = 'IntraEEA'       AND vif.IssuerCountryRegion = 'EEA'
                                                                             AND mr.RegionCode = 'EEA'
                                                                             AND ir.RegionCode = 'EEA'                                                                                             THEN 2
                           WHEN vif.MerchantCountryRegion = 'IntraNonEEA'    AND vif.IssuerCountryRegion = ir.RegionCode
                                                                             AND mr.RegionCode = ir.RegionCode
                                                                             AND 'EEA' NOT IN (SELECT RegionCode FROM tlkpVisaRegionCountry WHERE CountryCodeAlpha2 = @merchantCountry) 
                                                                             AND 'EEA' NOT IN (SELECT RegionCode FROM tlkpVisaRegionCountry WHERE CountryCodeAlpha2 = @issuerCountry)              THEN 2
                           WHEN vif.MerchantCountryRegion = 'Interregional'  AND vif.IssuerCountryRegion = ir.RegionCode 
                                                                             AND NOT EXISTS ((SELECT RegionCode FROM tlkpVisaRegionCountry WHERE CountryCodeAlpha2 = @merchantCountry)
                                                                                   INTERSECT (SELECT RegionCode FROM tlkpVisaRegionCountry WHERE CountryCodeAlpha2 = @issuerCountry))              THEN 2
                           WHEN vif.MerchantCountryRegion = 'IntraEEA'       AND vif.IssuerCountryRegion IS NULL
                                                                             AND mr.RegionCode = 'EEA'
                                                                             AND ir.RegionCode = 'EEA'                                                                                             THEN 1
                           WHEN vif.MerchantCountryRegion = 'IntraNonEEA'    AND vif.IssuerCountryRegion IS NULL
                                                                             AND mr.RegionCode = ir.RegionCode
                                                                             AND 'EEA' NOT IN (SELECT RegionCode FROM tlkpVisaRegionCountry WHERE CountryCodeAlpha2 = @merchantCountry) 
                                                                             AND 'EEA' NOT IN (SELECT RegioncODE FROM tlkpVisaRegionCountry WHERE CountryCodeAlpha2 = @issuerCountry)              THEN 1
                           WHEN vif.MerchantCountryRegion = 'Interregional'  AND vif.IssuerCountryRegion IS NULL 
                                                                             AND NOT EXISTS ((SELECT RegionCode FROM tlkpVisaRegionCountry WHERE CountryCodeAlpha2 = @merchantCountry)
                                                                                   INTERSECT (SELECT RegionCode FROM tlkpVisaRegionCountry WHERE CountryCodeAlpha2 = @issuerCountry))              THEN 1
                           WHEN vif.MerchantCountryRegion IS NULL            AND vif.IssuerCountryRegion = ir.RegionCode                                                                           THEN 1
                           WHEN vif.MerchantCountryRegion IS NULL            AND vif.IssuerCountryRegion IS NULL                                                                                   THEN 0 ELSE NULL END  -- @merchantCountry cannot be NULL
                  ) AS Score
             FROM tlkpCostVisaSchemeFee vif JOIN fx_rates fxf ON ISNULL(vif.FixedFeeCurrency, @currency) = fxf.from_currency 
                                                              AND @currency = fxf.to_currency 
                                                              AND fxf.rate_date = (SELECT MAX(fxff.rate_date)
                                                                                     FROM fx_rates fxff
                                                                                    WHERE fxff.from_currency = ISNULL(vif.FixedFeeCurrency, @currency)
                                                                                      AND fxff.to_currency = @currency
                                                                                      AND fxff.rate_date <= CAST(@date AS DATE))
                                      LEFT OUTER JOIN tlkpVisaRegionCountry mr ON mr.CountryCodeAlpha2 = @merchantCountry
                                      LEFT OUTER JOIN tlkpVisaRegionCountry ir ON ir.CountryCodeAlpha2 = @issuerCountry
           ) x LEFT OUTER JOIN acc_currencies fc ON x.FixedFeeCurrency = fc.currency_code_alpha3
     -- Mandatory parameters
     WHERE x.Score IS NOT NULL
       -- Date range - inclusive lower limit, exclusive upper limit
       AND @date >= ISNULL(x.EffectiveFrom, @date)
       AND @date < ISNULL(x.EffectiveUntil, DATEADD(SECOND, 1, @date))
       AND x.CardType = 'CREDIT' -- @cardType = x.CardType    -- Card Type must be specified and must match
    ORDER BY x.Score DESC;
END;
GO
