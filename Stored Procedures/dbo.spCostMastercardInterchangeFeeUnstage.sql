SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[spCostMastercardInterchangeFeeUnstage]
AS
BEGIN
    -- Delete all existing data from tlkpCostMastercardInterchangeFee and reseed the identity column value.
    TRUNCATE TABLE tlkpCostMastercardInterchangeFee;
    DBCC CHECKIDENT ('tlkpCostMastercardInterchangeFee', RESEED, 1);

    -- Load tlkpCostMastercardInterchangeFee from tlkpCostMastercardInterchangeFeeStage, expanding comma delimited column values into unique rows
    WITH PosTerminalInputCapabilityTable(FeeId, PosTerminalInputCapability, PosTerminalInputCapabilityList) AS
    (
        SELECT FeeId,
               LTRIM(LEFT(PosTerminalInputCapability, CHARINDEX(',', PosTerminalInputCapability + ',') - 1)) AS PosTerminalInputCapability,
               STUFF(PosTerminalInputCapability, 1, CHARINDEX(',', PosTerminalInputCapability + ','), '') AS PosTerminalInputCapabilityList
        FROM tlkpCostMastercardInterchangeFeeStage
        UNION ALL
        SELECT FeeId,
               LTRIM(LEFT(CAST(PosTerminalInputCapabilityList AS NVARCHAR(1000)), CHARINDEX(',', PosTerminalInputCapabilityList + ',') - 1)) AS PosTerminalInputCapability,
               STUFF(PosTerminalInputCapabilityList, 1, CHARINDEX(',', PosTerminalInputCapabilityList + ','), '') AS PosTerminalInputCapabilityList
        FROM PosTerminalInputCapabilityTable
        WHERE PosTerminalInputCapabilityList > ''
    ),
    CardDataInputModeTable(FeeId, CardDataInputMode, CardDataInputModeList) AS
    (
        SELECT FeeId,
               LTRIM(LEFT(CardDataInputMode, CHARINDEX(',', CardDataInputMode + ',') - 1)) AS CardDataInputMode,
               STUFF(CardDataInputMode, 1, CHARINDEX(',', CardDataInputMode + ','), '') AS CardDataInputModeList
        FROM tlkpCostMastercardInterchangeFeeStage
        UNION ALL
        SELECT FeeId,
               LTRIM(LEFT(CAST(CardDataInputModeList AS NVARCHAR(1000)), CHARINDEX(',', CardDataInputModeList + ',') - 1)) AS CardDataInputModeList,
               STUFF(CardDataInputModeList, 1, CHARINDEX(',', CardDataInputModeList + ','), '') AS CardDataInputModeList
        FROM CardDataInputModeTable
        WHERE CardDataInputModeList > ''
    ),
    GcmsProductIdentifierTable(FeeId, GcmsProductIdentifier, GcmsProductIdentifierList) AS
    (
        SELECT FeeId,
               LTRIM(LEFT(GcmsProductIdentifier, CHARINDEX(',', GcmsProductIdentifier + ',') - 1)) AS GcmsProductIdentifier,
               STUFF(GcmsProductIdentifier, 1, CHARINDEX(',', GcmsProductIdentifier + ','), '') AS GcmsProductIdentifierList
        FROM tlkpCostMastercardInterchangeFeeStage
        UNION ALL
        SELECT FeeId,
               LTRIM(LEFT(CAST(GcmsProductIdentifierList AS NVARCHAR(1000)), CHARINDEX(',', GcmsProductIdentifierList + ',') - 1)) AS GcmsProductIdentifier,
               STUFF(GcmsProductIdentifierList, 1, CHARINDEX(',', GcmsProductIdentifierList + ','), '') AS GcmsProductIdentifierList
        FROM GcmsProductIdentifierTable
        WHERE GcmsProductIdentifierList > ''
    ),
    FunctionCodeTable(FeeId, FunctionCode, FunctionCodeList) AS
    (
        SELECT FeeId,
               LTRIM(LEFT(FunctionCode, CHARINDEX(',', FunctionCode + ',') - 1)) AS FunctionCode,
               STUFF(FunctionCode, 1, CHARINDEX(',', FunctionCode + ','), '') AS FunctionCodeList
        FROM tlkpCostMastercardInterchangeFeeStage
        UNION ALL
        SELECT FeeId,
               LTRIM(LEFT(CAST(FunctionCodeList AS NVARCHAR(1000)), CHARINDEX(',', FunctionCodeList + ',') - 1)) AS FunctionCode,
               STUFF(FunctionCodeList, 1, CHARINDEX(',', FunctionCodeList + ','), '') AS FunctionCodeList
        FROM FunctionCodeTable
        WHERE FunctionCodeList > ''
    ),
    ProcessingCodeTable(FeeId, ProcessingCode, ProcessingCodeList) AS
    (
        SELECT FeeId,
               LTRIM(LEFT(ProcessingCode, CHARINDEX(',', ProcessingCode + ',') - 1)) AS ProcessingCode,
               STUFF(ProcessingCode, 1, CHARINDEX(',', ProcessingCode + ','), '') AS ProcessingCodeList
        FROM tlkpCostMastercardInterchangeFeeStage
        UNION ALL
        SELECT FeeId,
               LTRIM(LEFT(CAST(ProcessingCodeList AS NVARCHAR(1000)), CHARINDEX(',', ProcessingCodeList + ',') - 1)) AS ProcessingCode,
               STUFF(ProcessingCodeList, 1, CHARINDEX(',', ProcessingCodeList + ','), '') AS ProcessingCodeList
        FROM ProcessingCodeTable
        WHERE ProcessingCodeList > ''
    ),
    AccFundingSourceTable(FeeId, AccFundingSource, AccFundingSourceList) AS
    (
        SELECT FeeId,
               LTRIM(LEFT(AccFundingSource, CHARINDEX(',', AccFundingSource + ',') - 1)) AS AccFundingSource,
               STUFF(AccFundingSource, 1, CHARINDEX(',', AccFundingSource + ','), '') AS AccFundingSourceList
        FROM tlkpCostMastercardInterchangeFeeStage
        UNION ALL
        SELECT FeeId,
               LTRIM(LEFT(CAST(AccFundingSourceList AS NVARCHAR(1000)), CHARINDEX(',', AccFundingSourceList + ',') - 1)) AS AccFundingSource,
               STUFF(AccFundingSourceList, 1, CHARINDEX(',', AccFundingSourceList + ','), '') AS AccFundingSourceList
        FROM AccFundingSourceTable
        WHERE AccFundingSourceList > ''
    ),
    MccIncludeTable(FeeId, MccInclude, MccIncludeList) AS
    (
        SELECT FeeId,
               LTRIM(LEFT(MccInclude, CHARINDEX(',', MccInclude + ',') - 1)) AS MccInclude,
               STUFF(MccInclude, 1, CHARINDEX(',', MccInclude + ','), '') AS MccIncludeList
        FROM tlkpCostMastercardInterchangeFeeStage
        UNION ALL
        SELECT FeeId,
               LTRIM(LEFT(CAST(MccIncludeList AS NVARCHAR(1000)), CHARINDEX(',', MccIncludeList + ',') - 1)) AS MccInclude,
               STUFF(MccIncludeList, 1, CHARINDEX(',', MccIncludeList + ','), '') AS MccIncludeList
        FROM MccIncludeTable
        WHERE MccIncludeList > ''
    ),
    CabProgramIncludeTable(FeeId, CabProgramInclude, CabProgramIncludeList) AS
    (
        SELECT FeeId,
               LTRIM(LEFT(CabProgramInclude, CHARINDEX(',', CabProgramInclude + ',') - 1)) AS CabProgramInclude,
               STUFF(CabProgramInclude, 1, CHARINDEX(',', CabProgramInclude + ','), '') AS CabProgramIncludeList
        FROM tlkpCostMastercardInterchangeFeeStage
        UNION ALL
        SELECT FeeId,
               LTRIM(LEFT(CAST(CabProgramIncludeList AS NVARCHAR(1000)), CHARINDEX(',', CabProgramIncludeList + ',') - 1)) AS CabProgramInclude,
               STUFF(CabProgramIncludeList, 1, CHARINDEX(',', CabProgramIncludeList + ','), '') AS CabProgramIncludeList
        FROM CabProgramIncludeTable
        WHERE CabProgramIncludeList > ''
    ),
    ServiceCodeTable(FeeId, ServiceCode, ServiceCodeList) AS
    (
        SELECT FeeId,
               LTRIM(LEFT(ServiceCode, CHARINDEX(',', ServiceCode + ',') - 1)) AS ServiceCode,
               STUFF(ServiceCode, 1, CHARINDEX(',', ServiceCode + ','), '') AS ServiceCodeList
        FROM tlkpCostMastercardInterchangeFeeStage
        UNION ALL
        SELECT FeeId,
               LTRIM(LEFT(CAST(ServiceCodeList AS NVARCHAR(1000)), CHARINDEX(',', ServiceCodeList + ',') - 1)) AS ServiceCode,
               STUFF(ServiceCodeList, 1, CHARINDEX(',', ServiceCodeList + ','), '') AS ServiceCodeList
        FROM ServiceCodeTable
        WHERE ServiceCodeList > ''
    ),
    MtiTable(FeeId, Mti, MtiList) AS
    (
        SELECT FeeId,
               LTRIM(LEFT(Mti, CHARINDEX(',', Mti+ ',') - 1)) AS Mti,
               STUFF(Mti, 1, CHARINDEX(',', Mti + ','), '') AS MtiList
        FROM tlkpCostMastercardInterchangeFeeStage
        UNION ALL
        SELECT FeeId,
               LTRIM(LEFT(CAST(MtiList AS NVARCHAR(1000)), CHARINDEX(',', MtiList + ',') - 1)) AS Mti,
               STUFF(MtiList, 1, CHARINDEX(',', MtiList + ','), '') AS MtiList
        FROM MtiTable
        WHERE MtiList > ''
    )
    INSERT INTO tlkpCostMastercardInterchangeFee (
        EffectiveFrom,
        EffectiveUntil,
        MerchantCountryRegion,
        IssuerCountryRegion,
        Ird,
        IrdDescription,
        MinimumAmountMajorUnit,
        MaximumAmountMajorUnit,
        AmountCurrency,
        FeePercentAsMultiplier,
        FixedFeeMajorUnit,
        CappedMajorUnit,
        FixedCurrency,
        PosTerminalInputCapability,
        CardDataInputMode,
        CardholderPresentData,
        CardPresentData,
        CardholderAuthCapability,
        CardholderAuthMethod,
        Icc,
        TimelinessDays,
        ServiceCode,
        AccFundingSource,
        ProductType,
        CardProgIdentifier,
        GcmsProductIdentifier,
        Mti,
        FunctionCode,
        ProcessingCode,
        CabProgramInclude,
        CabProgramExcludes,
        MccInclude,
        MccExcludes,
        ApprovalCode,
        CorporateCardCommonData,
        CorporateLineItemDetail)
    SELECT s.EffectiveFrom,
           s.EffectiveUntil,
           s.MerchantCountryRegion,
           s.IssuerCountryRegion,
           s.Ird,
           s.IrdDescription,
           s.MinimumAmountMajorUnit,
           s.MaximumAmountMajorUnit,
           s.AmountCurrency,
           s.FeePercentAsMultiplier,
           s.FixedFeeMajorUnit,
           s.CappedMajorUnit,
           s.FixedCurrency,
           ptict.PosTerminalInputCapability,
           cdimt.CardDataInputMode,
           s.CardholderPresentData,
           s.CardPresentData,
           s.CardholderAuthCapability,
           s.CardholderAuthMethod,
           s.Icc,
           s.TimelinessDays,
           sct.ServiceCode,
           afst.AccFundingSource,
           s.ProductType,
           s.CardProgIdentifier,
           gpit.GcmsProductIdentifier,
           mt.Mti,
           fct.FunctionCode,
           pct.ProcessingCode,
           cpit.CabProgramInclude,
           s.CabProgramExcludes,
           mit.MccInclude,
           s.MccExcludes,
           s.ApprovalCode,
           s.CorporateCardCommonData,
           s.CorporateLineItemDetail
    FROM tlkpCostMastercardInterchangeFeeStage s LEFT OUTER JOIN PosTerminalInputCapabilityTable ptict ON s.FeeId = ptict.FeeId
                                                 LEFT OUTER JOIN CardDataInputModeTable cdimt ON s.FeeId = cdimt.FeeId
                                                 LEFT OUTER JOIN GcmsProductIdentifierTable gpit ON s.FeeId = gpit.FeeId
                                                 LEFT OUTER JOIN FunctionCodeTable fct ON s.FeeId = fct.FeeId
                                                 LEFT OUTER JOIN ProcessingCodeTable pct ON s.FeeId = pct.FeeId
                                                 LEFT OUTER JOIN AccFundingSourceTable afst ON s.FeeId = afst.FeeId
                                                 LEFT OUTER JOIN MccIncludeTable mit ON s.FeeId = mit.FeeId
                                                 LEFT OUTER JOIN CabProgramIncludeTable cpit ON s.FeeId = cpit.FeeId
                                                 LEFT OUTER JOIN ServiceCodeTable sct ON s.FeeId = sct.FeeId
                                                 LEFT OUTER JOIN MtiTable mt ON s.FeeId = mt.FeeId
END;
GO
