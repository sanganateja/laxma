SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[spCostVisaInterchangeFeeMatches]
    @cv1                           NVARCHAR(2000) OUTPUT,
    @amountMinorUnits              BIGINT,
    @currency                      NCHAR(3),
    @date                          DATETIME2,
    @merchantCountry               NCHAR(2),
    @mcc                           NCHAR(4),
    @issuerCountry                 NCHAR(2),
    @feeScenario                   NVARCHAR(50),
    @afs                           NCHAR(1),
    @pid                           NCHAR(2),
    @productSubtype                NVARCHAR(50),
    @productType                   NVARCHAR(50),
    @fpi                           NVARCHAR(100),
    @reimbAttr                     NCHAR(1),
    @cardCapabilityFlag            NCHAR(1),
    @posTerminalCapability         NCHAR(1),
    @authCode                      NVARCHAR(100),
    @posEntryMode                  NCHAR(2),
    @cardholderIdMethod            NCHAR(1),
    @motoEci                       NVARCHAR(100),
    @posEnvCode                    NVARCHAR(100),
    @ati                           NVARCHAR(100),
    @authRespCode                  NCHAR(2),
    @cvvResult                     NVARCHAR(100),
    @timelinessDays                BIGINT,
    @chipTerminalDeploymentFlag    NCHAR(1),
    @businessApplicationIdentifier NVARCHAR(100),
    @authCharac                    NVARCHAR(100),
    @requestedPaymentService       NVARCHAR(100),
    @dcci                          NVARCHAR(100)
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
               LTRIM(LEFT(ExcludingMccs, CHARINDEX(',', ExcludingMccs + ',') - 1)) AS Mcc,
               STUFF(ExcludingMccs, 1, CHARINDEX(',', ExcludingMccs + ','), '') AS Mccs
        FROM tlkpCostVisaInterchangeFee
        UNION ALL
        SELECT FeeId,
               LTRIM(LEFT(CAST(Mccs AS NVARCHAR(1000)), CHARINDEX(',', Mccs + ',') - 1)) AS Mcc,
               STUFF(Mccs, 1, CHARINDEX(',', Mccs + ','), '') AS Mccs
        FROM ExcludeMccTable
        WHERE Mccs > ''
    )
    SELECT x.FeeId,
           x.Score,
           x.EffectiveFrom,
           x.EffectiveUntil,
           x.MerchantCountryRegion,
           x.IssuerCountryRegion,
           x.FeeScenario,
           x.MinimumAmountMajorUnit,
           x.MaximumAmountMajorUnit,
           x.AmountCurrency,
           x.Afs,
           x.Pid,
           x.ProductSubtype,
           x.ProductType,
           x.FeeDescriptor,
           x.FeePercentAsMultiplier,
           x.FixedFeeMajorUnit,
           x.CappedMajorUnit,
           x.FixedCurrency,
           x.Fpi,
           x.ReimbAttr,
           x.CardCapabilityFlag,
           x.PosTerminalCapability,
           x.AuthCode,
           x.PosEntryMode,
           x.CardholderIdMethod,
           x.MotoEci,
           x.MccSpecific,
           x.ExcludingMccs,
           x.PosEnvCode,
           x.Ati,
           x.AuthRespCode,
           x.CvvResult,
           x.TimelinessDays,
           x.ChipTerminalDeploymentFlag,
           x.BusinessApplicationIdentifier,
           x.AuthCharac,
           x.RequestedPaymentService,
           x.Dcci
      FROM (
           SELECT vif.FeeId,
                  vif.EffectiveFrom,
                  vif.EffectiveUntil,
                  vif.MerchantCountryRegion,
                  vif.IssuerCountryRegion,
                  vif.FeeScenario,
                  vif.MinimumAmountMajorUnit,
                  vif.MaximumAmountMajorUnit,
                  vif.AmountCurrency,
                  vif.Afs,
                  vif.Pid,
                  vif.ProductSubtype,
                  vif.ProductType,
                  vif.FeeDescriptor,
                  vif.FeePercentAsMultiplier,
                  vif.FixedFeeMajorUnit,
                  vif.CappedMajorUnit,
                  vif.FixedCurrency,
                  vif.Fpi,
                  vif.ReimbAttr,
                  vif.CardCapabilityFlag,
                  vif.PosTerminalCapability,
                  vif.AuthCode,
                  vif.PosEntryMode,
                  vif.CardholderIdMethod,
                  vif.MotoEci,
                  vif.MccSpecific,
                  vif.ExcludingMccs,
                  vif.PosEnvCode,
                  vif.Ati,
                  vif.AuthRespCode,
                  vif.CvvResult,
                  vif.TimelinessDays,
                  vif.ChipTerminalDeploymentFlag,
                  vif.BusinessApplicationIdentifier,
                  vif.AuthCharac,
                  vif.RequestedPaymentService,
                  vif.Dcci,
                  fxf.rate AS FeeRate,
                  fxa.rate AS AmountLimitRate,
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
                    + CASE WHEN vif.MccSpecific = @mcc                                             THEN 1 WHEN vif.MccSpecific IS NULL                                                             THEN 0 ELSE NULL END  -- @mcc cannot be NULL
                    + CASE WHEN vif.FeeScenario = @feeScenario                                     THEN 1 WHEN vif.FeeScenario IS NULL OR @feeScenario IS NULL                                     THEN 0 ELSE NULL END
                    + CASE WHEN vif.Afs = @afs                                                     THEN 1 WHEN vif.Afs IS NULL OR @afs IS NULL                                                     THEN 0 ELSE NULL END
                    + CASE WHEN vif.Pid = @pid                                                     THEN 1 WHEN vif.Pid IS NULL OR @pid IS NULL                                                     THEN 0 ELSE NULL END
                    + CASE WHEN vif.ProductSubtype = @productSubtype                               THEN 1 WHEN vif.ProductSubtype IS NULL OR @productSubtype IS NULL                               THEN 0 ELSE NULL END
                    + CASE WHEN vif.ProductType = @productType                                     THEN 1 WHEN vif.ProductType IS NULL OR @productType IS NULL                                     THEN 0 ELSE NULL END
                    + CASE WHEN vif.Fpi = @fpi                                                     THEN 1 WHEN vif.Fpi IS NULL OR @fpi IS NULL                                                     THEN 0 ELSE NULL END
                    + CASE WHEN vif.ReimbAttr = @reimbAttr                                         THEN 1 WHEN vif.ReimbAttr IS NULL OR @reimbAttr IS NULL                                         THEN 0 ELSE NULL END
                    + CASE WHEN vif.CardCapabilityFlag = @cardCapabilityFlag                       THEN 1 WHEN vif.CardCapabilityFlag IS NULL OR @cardCapabilityFlag IS NULL                       THEN 0 ELSE NULL END
                    + CASE WHEN vif.PosTerminalCapability = @posTerminalCapability                 THEN 1 WHEN vif.PosTerminalCapability IS NULL OR @posTerminalCapability IS NULL                 THEN 0 ELSE NULL END
                    + CASE WHEN vif.AuthCode = @authCode                                           THEN 1 WHEN vif.AuthCode IS NULL OR @authCode IS NULL                                           THEN 0 ELSE NULL END
                    + CASE WHEN vif.PosEntryMode = @posEntryMode                                   THEN 1 WHEN vif.PosEntryMode IS NULL OR @posEntryMode IS NULL                                   THEN 0 ELSE NULL END
                    + CASE WHEN vif.CardholderIdMethod = @cardholderIdMethod                       THEN 1 WHEN vif.CardholderIdMethod IS NULL OR @cardholderIdMethod IS NULL                       THEN 0 ELSE NULL END
                    + CASE WHEN vif.MotoEci = @motoEci                                             THEN 1 WHEN vif.MotoEci IS NULL OR @motoEci IS NULL                                             THEN 0 ELSE NULL END
                    + CASE WHEN vif.PosEnvCode = @posEnvCode                                       THEN 1 WHEN vif.PosEnvCode IS NULL OR @posEnvCode IS NULL                                       THEN 0 ELSE NULL END
                    + CASE WHEN vif.Ati = @ati                                                     THEN 1 WHEN vif.Ati IS NULL OR @ati IS NULL                                                     THEN 0 ELSE NULL END
                    + CASE WHEN vif.AuthRespCode = @authRespCode                                   THEN 1 WHEN vif.AuthRespCode IS NULL OR @authRespCode IS NULL                                   THEN 0 ELSE NULL END
                    + CASE WHEN vif.CvvResult = @cvvResult                                         THEN 1 WHEN vif.CvvResult IS NULL OR @cvvResult IS NULL                                         THEN 0 ELSE NULL END
                    + CASE WHEN vif.TimelinessDays = @timelinessDays                               THEN 1 WHEN vif.TimelinessDays IS NULL OR @timelinessDays IS NULL                               THEN 0 ELSE NULL END
                    + CASE WHEN vif.ChipTerminalDeploymentFlag = @chipTerminalDeploymentFlag       THEN 1 WHEN vif.ChipTerminalDeploymentFlag IS NULL OR @chipTerminalDeploymentFlag IS NULL       THEN 0 ELSE NULL END
                    + CASE WHEN vif.BusinessApplicationIdentifier = @businessApplicationIdentifier THEN 1 WHEN vif.BusinessApplicationIdentifier IS NULL OR @businessApplicationIdentifier IS NULL THEN 0 ELSE NULL END
                    + CASE WHEN vif.AuthCharac = @authCharac                                       THEN 1 WHEN vif.AuthCharac IS NULL OR @authCharac IS NULL                                       THEN 0 ELSE NULL END
                    + CASE WHEN vif.RequestedPaymentService = @requestedPaymentService             THEN 1 WHEN vif.RequestedPaymentService IS NULL OR @requestedPaymentService IS NULL             THEN 0 ELSE NULL END
                    + CASE WHEN vif.Dcci = @dcci                                                   THEN 1 WHEN vif.Dcci IS NULL OR @dcci IS NULL                                                   THEN 0 ELSE NULL END
                  ) AS Score
             FROM tlkpCostVisaInterchangeFee vif JOIN fx_rates fxf ON ISNULL(vif.FixedCurrency, @currency) = fxf.from_currency 
                                                                  AND @currency = fxf.to_currency 
                                                                  AND fxf.rate_date = (SELECT MAX(fxff.rate_date)
                                                                                         FROM fx_rates fxff
                                                                                        WHERE fxff.from_currency = ISNULL(vif.FixedCurrency, @currency)
                                                                                          AND fxff.to_currency = @currency
                                                                                          AND fxff.rate_date <= CAST(@date AS DATE))
                                                 JOIN fx_rates fxa ON ISNULL(vif.AmountCurrency, @currency) = fxa.from_currency 
                                                                  AND @currency = fxa.to_currency 
                                                                  AND fxa.rate_date = (SELECT MAX(fxaa.rate_date)
                                                                                         FROM fx_rates fxaa
                                                                                        WHERE fxaa.from_currency = ISNULL(vif.AmountCurrency, @currency)
                                                                                          AND fxaa.to_currency = @currency
                                                                                          AND fxaa.rate_date <= CAST(@date AS DATE))
                                      LEFT OUTER JOIN tlkpVisaRegionCountry mr ON mr.CountryCodeAlpha2 = @merchantCountry
                                      LEFT OUTER JOIN tlkpVisaRegionCountry ir ON ir.CountryCodeAlpha2 = @issuerCountry
           ) x LEFT OUTER JOIN acc_currencies fc ON x.FixedCurrency = fc.currency_code_alpha3
     -- Mandatory parameters
     WHERE x.Score IS NOT NULL
       -- Date range - inclusive lower limit, exclusive upper limit
       AND @date >= ISNULL(x.EffectiveFrom, @date)
       AND @date < ISNULL(x.EffectiveUntil, DATEADD(SECOND, 1, @date))
       AND @amountMajorUnits > ISNULL(x.MinimumAmountMajorUnit * x.AmountLimitRate, 0) AND @amountMajorUnits <= ISNULL(x.MaximumAmountMajorUnit * x.AmountLimitRate, @amountMajorUnits)
       AND (x.MccSpecific IS NULL   OR @mcc = x.MccSpecific)
       AND (x.ExcludingMccs IS NULL OR @mcc NOT IN (SELECT emt.Mcc FROM ExcludeMccTable emt WHERE emt.FeeId = x.FeeId)) 
       -- Optional parameters
       AND (x.FeeScenario IS NULL                   OR @feeScenario IS NULL                   OR @feeScenario = x.FeeScenario)
       AND (x.Afs IS NULL                           OR @afs IS NULL                           OR @afs = x.Afs)
       AND (x.Pid IS NULL                           OR @pid IS NULL                           OR @pid = x.Pid)
       AND (x.ProductSubtype IS NULL                OR @productSubtype IS NULL                OR @productSubtype = x.ProductSubtype)
       AND (x.ProductType IS NULL                   OR @productType IS NULL                   OR @productType = x.ProductType)
       AND (x.Fpi IS NULL                           OR @fpi IS NULL                           OR @fpi = x.Fpi)
       AND (x.ReimbAttr IS NULL                     OR @reimbAttr IS NULL                     OR @reimbAttr = x.ReimbAttr)
       AND (x.CardCapabilityFlag IS NULL            OR @cardCapabilityFlag IS NULL            OR @cardCapabilityFlag = x.CardCapabilityFlag)
       AND (x.PosTerminalCapability IS NULL         OR @posTerminalCapability IS NULL         OR @posTerminalCapability = x.PosTerminalCapability)
       AND (x.AuthCode IS NULL                      OR @authCode IS NULL                      OR @authCode = x.AuthCode)
       AND (x.PosEntryMode IS NULL                  OR @posEntryMode IS NULL                  OR @posEntryMode = x.PosEntryMode)
       AND (x.CardholderIdMethod IS NULL            OR @cardholderIdMethod IS NULL            OR @cardholderIdMethod = x.CardholderIdMethod)
       AND (x.MotoEci IS NULL                       OR @motoEci IS NULL                       OR @motoEci = x.MotoEci)
       AND (x.PosEnvCode IS NULL                    OR @posEnvCode IS NULL                    OR @posEnvCode = x.PosEnvCode)
       AND (x.Ati IS NULL                           OR @ati IS NULL                           OR @ati = x.Ati)
       AND (x.AuthRespCode IS NULL                  OR @authRespCode IS NULL                  OR @authRespCode = x.AuthRespCode)
       AND (x.CvvResult IS NULL                     OR @cvvResult IS NULL                     OR @cvvResult = x.CvvResult)
       AND (x.TimelinessDays IS NULL                OR @timelinessDays IS NULL                OR @timelinessDays = x.TimelinessDays)
       AND (x.ChipTerminalDeploymentFlag IS NULL    OR @chipTerminalDeploymentFlag IS NULL    OR @chipTerminalDeploymentFlag = x.ChipTerminalDeploymentFlag)
       AND (x.BusinessApplicationIdentifier IS NULL OR @businessApplicationIdentifier IS NULL OR @businessApplicationIdentifier = x.BusinessApplicationIdentifier)
       AND (x.AuthCharac IS NULL                    OR @authCharac IS NULL                    OR @authCharac = x.AuthCharac)
       AND (x.RequestedPaymentService IS NULL       OR @requestedPaymentService IS NULL       OR @requestedPaymentService = x.RequestedPaymentService)
       AND (x.Dcci IS NULL                          OR @dcci IS NULL                          OR @dcci = x.Dcci)
  ORDER BY x.Score DESC;
END;
GO
