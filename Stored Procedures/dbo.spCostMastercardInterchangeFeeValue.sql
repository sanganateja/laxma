SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[spCostMastercardInterchangeFeeValue]
    @cv1                        NVARCHAR(2000) OUTPUT,
    @amountMinorUnits           BIGINT,
    @currency                   NCHAR(3),
    @date                       DATETIME2,
    @merchantCountry            NCHAR(2),
    @mcc                        NCHAR(4),
    @issuerCountry              NCHAR(2),
    @cabProgram                 NVARCHAR(100),
    @ird                        NCHAR(2),
    @posTerminalInputCapability NCHAR(1),
    @cardDataInputMode          NCHAR(1),
    @cardholderPresentData      TINYINT,
    @cardPresentData            TINYINT,
    @cardholderAuthCapability   TINYINT,
    @cardholderAuthMethod       TINYINT,
    @icc                        NVARCHAR(100),
    @timelinessDays             BIGINT,
    @serviceCode                NCHAR(1),
    @accFundingSource           NCHAR(1),
    @productType                NVARCHAR(100),
    @cardProgIdentifier         NCHAR(3),
    @gcmsProductIdentifier      NCHAR(3),
    @mti                        NCHAR(4),
    @functionCode               NCHAR(3),
    @processingCode             NCHAR(2),
    @approvalCode               NVARCHAR(100),
    @corporateCardCommonData    NVARCHAR(100),
    @corporateLineItemDetail    NVARCHAR(100)
AS
SET NOCOUNT ON;
BEGIN
    DECLARE @amountMajorUnits DECIMAL(18,6);
    DECLARE @unitsMultiplier TINYINT;

    SET @cv1 = NULL;

    -- Amount, Currency and Country and MCC are mandatory
    IF @amountMinorUnits IS NULL OR @currency IS NULL OR @merchantCountry IS NULL OR @mcc IS NULL
        RETURN -1;

    SELECT @unitsMultiplier = POWER(10, decimal_places)
    FROM acc_currencies
    WHERE currency_code_alpha3 = @currency;

    SET @amountMajorUnits = CONVERT(DECIMAL(18,6), @amountMinorUnits) / @unitsMultiplier;

    WITH ExcludeMccTable(FeeId, Mcc, Mccs) AS
    (
        SELECT FeeId,
               LTRIM(LEFT(MccExcludes, CHARINDEX(',', MccExcludes + ',') - 1)) AS Mcc,
               STUFF(MccExcludes, 1, CHARINDEX(',', MccExcludes + ','), '') AS Mccs
        FROM tlkpCostMastercardInterchangeFee
        UNION ALL
        SELECT FeeId,
               LTRIM(LEFT(CAST(Mccs AS NVARCHAR(1000)), CHARINDEX(',', Mccs + ',') - 1)) AS Mcc,
               STUFF(Mccs, 1, CHARINDEX(',', Mccs + ','), '') AS Mccs
        FROM ExcludeMccTable
        WHERE Mccs > ''
    ),
    ExcludeCabProgramTable(FeeId, Cab, Cabs) AS
    (
        SELECT FeeId,
               LTRIM(LEFT(CabProgramExcludes, CHARINDEX(',', CabProgramExcludes + ',') - 1)) AS Cab,
               STUFF(CabProgramExcludes, 1, CHARINDEX(',', CabProgramExcludes + ','), '') AS Cabs
        FROM tlkpCostMastercardInterchangeFee
        UNION ALL
        SELECT FeeId,
               LTRIM(LEFT(CAST(Cabs AS NVARCHAR(1000)), CHARINDEX(',', Cabs + ',') - 1)) AS Cab,
               STUFF(Cabs, 1, CHARINDEX(',', Cabs + ','), '') AS Cabs
        FROM ExcludeCabProgramTable
        WHERE Cabs > ''
    )
    SELECT TOP 1 x.FeeId AS FeeId,
           2 AS FeeTypeId,          -- Interchange Fee
           CASE WHEN x.CappedMajorUnit IS NOT NULL AND x.CappedMajorUnit < ((@amountMajorUnits * ISNULL(x.FeePercentAsMultiplier, 1.0)) + (ISNULL(x.FixedFeeMajorUnit, 0.0) * x.FeeRate)) THEN x.CappedMajorUnit * x.FeeRate * @unitsMultiplier
                ELSE ((@amountMajorUnits * ISNULL(x.FeePercentAsMultiplier, 1.0)) + (ISNULL(x.FixedFeeMajorUnit, 0.0) * x.FeeRate)) * @unitsMultiplier
                END AS CostAmountMinorUnit,
           @currency AS CostCurrency,
           x.Ird AS CostDescriptor,
           CONVERT(BIGINT, ROUND(ISNULL(x.FixedFeeMajorUnit, 0.0) * POWER(10, ISNULL(fc.decimal_places, 0)), 0)) AS FixedAmountMinorUnits,
           x.FixedCurrency AS FixedCurrency,
           @amountMinorUnits * ISNULL(x.FeePercentAsMultiplier, 1.0) AS VariableAmountMinorUnits,
           x.FeeRate AS FxRate
      FROM (
           -- Date range - inclusive lower limit, exclusive upper limit
           SELECT mif.FeeId,
                  mif.EffectiveFrom,
                  mif.EffectiveUntil,
                  mif.MerchantCountryRegion,
                  mif.IssuerCountryRegion,
                  mif.Ird,
                  mif.IrdDescription,
                  mif.MinimumAmountMajorUnit,
                  mif.MaximumAmountMajorUnit,
                  mif.AmountCurrency,
                  mif.FeePercentAsMultiplier,
                  mif.FixedFeeMajorUnit,
                  mif.CappedMajorUnit,
                  mif.FixedCurrency,
                  mif.PosTerminalInputCapability,
                  mif.CardDataInputMode,
                  mif.CardholderPresentData,
                  mif.CardPresentData,
                  mif.CardholderAuthCapability,
                  mif.CardholderAuthMethod,
                  mif.Icc,
                  mif.TimelinessDays,
                  mif.ServiceCode,
                  mif.AccFundingSource,
                  mif.ProductType,
                  mif.CardProgIdentifier,
                  mif.GcmsProductIdentifier,
                  mif.Mti,
                  mif.FunctionCode,
                  mif.ProcessingCode,
                  mif.CabProgramInclude,
                  mif.CabProgramExcludes,
                  mif.MccInclude,
                  mif.MccExcludes,
                  mif.ApprovalCode,
                  mif.CorporateCardCommonData,
                  mif.CorporateLineItemDetail,
                  fxf.rate AS FeeRate,
                  fxa.rate AS AmountLimitRate,
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
                    + CASE WHEN mif.MccInclude = @mcc                                        THEN 1    WHEN mif.MccInclude IS NULL                                                            THEN 0 ELSE NULL END  -- @mcc cannot be NULL
                    + CASE WHEN mif.CabProgramInclude = @cabProgram                          THEN 1    WHEN mif.CabProgramInclude IS NULL OR @cabProgram IS NULL                              THEN 0 ELSE NULL END
                    + CASE WHEN mif.Ird = @ird                                               THEN 1    WHEN mif.Ird IS NULL OR @ird IS NULL                                                   THEN 0 ELSE NULL END
                    + CASE WHEN mif.PosTerminalInputCapability = @posTerminalInputCapability THEN 1    WHEN mif.PosTerminalInputCapability IS NULL OR @posTerminalInputCapability IS NULL     THEN 0 ELSE NULL END
                    + CASE WHEN mif.CardDataInputMode = @cardDataInputMode                   THEN 1    WHEN mif.CardDataInputMode IS NULL OR @cardDataInputMode IS NULL                       THEN 0 ELSE NULL END
                    + CASE WHEN mif.CardholderPresentData = @cardholderPresentData           THEN 1    WHEN mif.CardholderPresentData IS NULL OR @cardholderPresentData IS NULL               THEN 0 ELSE NULL END
                    + CASE WHEN mif.CardPresentData = @cardPresentData                       THEN 1    WHEN mif.CardPresentData IS NULL OR @cardPresentData IS NULL                           THEN 0 ELSE NULL END
                    + CASE WHEN mif.CardholderAuthCapability = @cardholderAuthCapability     THEN 1    WHEN mif.CardholderAuthCapability IS NULL OR @cardholderAuthCapability IS NULL         THEN 0 ELSE NULL END
                    + CASE WHEN mif.CardholderAuthMethod = @cardholderAuthMethod             THEN 1    WHEN mif.CardholderAuthMethod IS NULL OR @cardholderAuthMethod IS NULL                 THEN 0 ELSE NULL END
                    + CASE WHEN mif.Icc = @icc                                               THEN 1    WHEN mif.Icc IS NULL OR @icc IS NULL                                                   THEN 0 ELSE NULL END
                    + CASE WHEN mif.TimelinessDays = @timelinessDays                         THEN 1    WHEN mif.TimelinessDays IS NULL OR @timelinessDays IS NULL                             THEN 0 ELSE NULL END
                    + CASE WHEN mif.ServiceCode = @serviceCode                               THEN 1    WHEN mif.ServiceCode IS NULL OR @serviceCode IS NULL                                   THEN 0 ELSE NULL END
                    + CASE WHEN mif.AccFundingSource = @accFundingSource                     THEN 1    WHEN mif.AccFundingSource IS NULL OR @accFundingSource IS NULL                         THEN 0 ELSE NULL END
                    + CASE WHEN mif.ProductType = @productType                               THEN 1    WHEN mif.ProductType IS NULL OR @productType IS NULL                                   THEN 0 ELSE NULL END
                    + CASE WHEN mif.CardProgIdentifier = @cardProgIdentifier                 THEN 1    WHEN mif.CardProgIdentifier IS NULL OR @cardProgIdentifier IS NULL                     THEN 0 ELSE NULL END
                    + CASE WHEN mif.GcmsProductIdentifier = @gcmsProductIdentifier           THEN 1    WHEN mif.GcmsProductIdentifier IS NULL OR @gcmsProductIdentifier IS NULL               THEN 0 ELSE NULL END
                    + CASE WHEN mif.Mti = @mti                                               THEN 1    WHEN mif.Mti IS NULL OR @mti IS NULL                                                   THEN 0 ELSE NULL END
                    + CASE WHEN mif.FunctionCode = @functionCode                             THEN 1    WHEN mif.FunctionCode IS NULL OR @functionCode IS NULL                                 THEN 0 ELSE NULL END
                    + CASE WHEN mif.ProcessingCode = @processingCode                         THEN 1    WHEN mif.ProcessingCode IS NULL OR @processingCode IS NULL                             THEN 0 ELSE NULL END
                    + CASE WHEN mif.ApprovalCode = @approvalCode                             THEN 1    WHEN mif.ApprovalCode IS NULL OR @approvalCode IS NULL                                 THEN 0 ELSE NULL END
                    + CASE WHEN mif.CorporateCardCommonData = @corporateCardCommonData       THEN 1    WHEN mif.CorporateCardCommonData IS NULL OR @corporateCardCommonData IS NULL           THEN 0 ELSE NULL END
                    + CASE WHEN mif.CorporateLineItemDetail = @corporateLineItemDetail       THEN 1    WHEN mif.CorporateLineItemDetail IS NULL OR @corporateLineItemDetail IS NULL           THEN 0 ELSE NULL END
                  ) AS Score
             FROM tlkpCostMastercardInterchangeFee mif JOIN fx_rates fxf ON ISNULL(mif.FixedCurrency, @currency) = fxf.from_currency 
                                                                         AND @currency = fxf.to_currency 
                                                                         AND fxf.rate_date = (SELECT MAX(fxff.rate_date)
                                                                                              FROM   fx_rates fxff
                                                                                              WHERE  fxff.from_currency = ISNULL(mif.FixedCurrency, @currency)
                                                                                                AND  fxff.to_currency = @currency
                                                                                                AND  fxff.rate_date <= CAST(@date AS DATE))
                                                        JOIN fx_rates fxa ON ISNULL(mif.AmountCurrency, @currency) = fxa.from_currency 
                                                                         AND @currency = fxa.to_currency 
                                                                         AND fxa.rate_date = (SELECT MAX(fxaa.rate_date)
                                                                                              FROM   fx_rates fxaa
                                                                                              WHERE  fxaa.from_currency = ISNULL(mif.AmountCurrency, @currency)
                                                                                                AND  fxaa.to_currency = @currency
                                                                                                AND  fxaa.rate_date <= CAST(@date AS DATE))
                                             LEFT OUTER JOIN tlkpMastercardRegionCountry mr ON mr.CountryCodeAlpha2 = @merchantCountry
                                             LEFT OUTER JOIN tlkpMastercardRegionCountry ir ON ir.CountryCodeAlpha2 = @issuerCountry
           ) x LEFT OUTER JOIN acc_currencies fc ON x.FixedCurrency = fc.currency_code_alpha3
     -- Mandatory parameters
     WHERE x.Score IS NOT NULL
       -- Date range - inclusive lower limit, exclusive upper limit
       AND @date >= ISNULL(x.EffectiveFrom, @date)
       AND @date < ISNULL(x.EffectiveUntil, DATEADD(SECOND, 1, @date))
       AND @amountMajorUnits > ISNULL(x.MinimumAmountMajorUnit * x.AmountLimitRate, 0) AND @amountMajorUnits <= ISNULL(x.MaximumAmountMajorUnit * x.AmountLimitRate, @amountMajorUnits)
       AND (x.MccInclude IS NULL         OR @mcc = x.MccInclude)
       AND (x.MccExcludes IS NULL        OR @mcc NOT IN (SELECT emt.Mcc FROM ExcludeMccTable emt WHERE emt.FeeId = x.FeeId)) 
       -- Optional parameters
       AND (x.CabProgramInclude IS NULL  OR @cabProgram IS NULL OR @cabProgram = x.CabProgramInclude)
       AND (x.CabProgramExcludes IS NULL OR @cabProgram IS NULL OR @cabProgram NOT IN (SELECT ecpt.Cab FROM ExcludeCabProgramTable ecpt WHERE ecpt.FeeId = x.FeeId)) 
       AND (x.Ird IS NULL                        OR @ird IS NULL                        OR @ird = x.Ird)
       AND (x.PosTerminalInputCapability IS NULL OR @posTerminalInputCapability IS NULL OR @posTerminalInputCapability = x.PosTerminalInputCapability)
       AND (x.CardDataInputMode IS NULL          OR @cardDataInputMode IS NULL          OR @cardDataInputMode = x.CardDataInputMode)
       AND (x.CardholderPresentData IS NULL      OR @cardholderPresentData IS NULL      OR @cardholderPresentData = x.CardholderPresentData)
       AND (x.CardPresentData IS NULL            OR @cardPresentData IS NULL            OR @cardPresentData = x.CardPresentData)
       AND (x.CardholderAuthCapability IS NULL   OR @cardholderAuthCapability IS NULL   OR @cardholderAuthCapability = x.CardholderAuthCapability)
       AND (x.CardholderAuthMethod IS NULL       OR @cardholderAuthMethod IS NULL       OR @cardholderAuthMethod = x.CardholderAuthMethod)
       AND (x.Icc IS NULL                        OR @icc IS NULL                        OR @icc = x.Icc)
       AND (x.TimelinessDays IS NULL             OR @timelinessDays IS NULL             OR @timelinessDays = x.TimelinessDays)
       AND (x.ServiceCode IS NULL                OR @serviceCode IS NULL                OR @serviceCode = x.ServiceCode)
       AND (x.AccFundingSource IS NULL           OR @accFundingSource IS NULL           OR @accFundingSource = x.AccFundingSource)
       AND (x.ProductType IS NULL                OR @productType IS NULL                OR @productType = x.ProductType)
       AND (x.CardProgIdentifier IS NULL         OR @cardProgIdentifier IS NULL         OR @cardProgIdentifier = x.CardProgIdentifier)
       AND (x.GcmsProductIdentifier IS NULL      OR @gcmsProductIdentifier IS NULL      OR @gcmsProductIdentifier = x.GcmsProductIdentifier)
       AND (x.Mti IS NULL                        OR @mti IS NULL                        OR @mti = x.Mti)
       AND (x.FunctionCode IS NULL               OR @functionCode IS NULL               OR @functionCode = x.FunctionCode)
       AND (x.ProcessingCode IS NULL             OR @processingCode IS NULL             OR @processingCode = x.ProcessingCode)
       AND (x.ApprovalCode IS NULL               OR @approvalCode IS NULL               OR @approvalCode = x.ApprovalCode)
       AND (x.CorporateCardCommonData IS NULL    OR @corporateCardCommonData IS NULL    OR @corporateCardCommonData = x.CorporateCardCommonData)
       AND (x.CorporateLineItemDetail IS NULL    OR @corporateLineItemDetail IS NULL    OR @corporateLineItemDetail = x.CorporateLineItemDetail)
  ORDER BY x.Score DESC;
END;
GO
