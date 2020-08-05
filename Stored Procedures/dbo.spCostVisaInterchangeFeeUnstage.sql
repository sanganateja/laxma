SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[spCostVisaInterchangeFeeUnstage]
AS
BEGIN
    -- Delete all existing data from tlkpCostVisaInterchangeFee and reseed the identity column value.
    TRUNCATE TABLE tlkpCostVisaInterchangeFee;
    DBCC CHECKIDENT ('tlkpCostVisaInterchangeFee', RESEED, 1);

    -- Load tlkpCostVisaInterchangeFee from tlkpCostVisaInterchangeFeeStage, expanding comma delimited column values into unique rows
    WITH AfsTable(FeeId, Afs, AfsList) AS
    (
        SELECT FeeId,
               LTRIM(LEFT(Afs, CHARINDEX(',', Afs + ',') - 1)) AS Afs,
               STUFF(Afs, 1, CHARINDEX(',', Afs + ','), '') AS AfsList
        FROM tlkpCostVisaInterchangeFeeStage
        UNION ALL
        SELECT FeeId,
               LTRIM(LEFT(CAST(AfsList AS NVARCHAR(1000)), CHARINDEX(',', AfsList + ',') - 1)) AS Afs,
               STUFF(AfsList, 1, CHARINDEX(',', AfsList + ','), '') AS AfsList
        FROM AfsTable
        WHERE AfsList > ''
    ),
    PidTable(FeeId, Pid, PidList) AS
    (
        SELECT FeeId,
               LTRIM(LEFT(Pid, CHARINDEX(',', Pid + ',') - 1)) AS Pid,
               STUFF(Pid, 1, CHARINDEX(',', Pid + ','), '') AS PidList
        FROM tlkpCostVisaInterchangeFeeStage
        UNION ALL
        SELECT FeeId,
               LTRIM(LEFT(CAST(PidList AS NVARCHAR(1000)), CHARINDEX(',', PidList + ',') - 1)) AS Pid,
               STUFF(PidList, 1, CHARINDEX(',', PidList + ','), '') AS PidList
        FROM PidTable
        WHERE PidList > ''
    ),
    PosEntryModeTable(FeeId, PosEntryMode, PosEntryModeList) AS
    (
        SELECT FeeId,
               LTRIM(LEFT(PosEntryMode, CHARINDEX(',', PosEntryMode + ',') - 1)) AS PosEntryMode,
               STUFF(PosEntryMode, 1, CHARINDEX(',', PosEntryMode + ','), '') AS PosEntryModeList
        FROM tlkpCostVisaInterchangeFeeStage
        UNION ALL
        SELECT FeeId,
               LTRIM(LEFT(CAST(PosEntryModeList AS NVARCHAR(1000)), CHARINDEX(',', PosEntryModeList + ',') - 1)) AS PosEntryMode,
               STUFF(PosEntryModeList, 1, CHARINDEX(',', PosEntryModeList + ','), '') AS PosEntryModeList
        FROM PosEntryModeTable
        WHERE PosEntryModeList > ''
    ),
    CardholderIdMethodTable(FeeId, CardholderIdMethod, CardholderIdMethodList) AS
    (
        SELECT FeeId,
               LTRIM(LEFT(CardholderIdMethod, CHARINDEX(',', CardholderIdMethod + ',') - 1)) AS CardholderIdMethod,
               STUFF(CardholderIdMethod, 1, CHARINDEX(',', CardholderIdMethod + ','), '') AS CardholderIdMethodList
        FROM tlkpCostVisaInterchangeFeeStage
        UNION ALL
        SELECT FeeId,
               LTRIM(LEFT(CAST(CardholderIdMethodList AS NVARCHAR(1000)), CHARINDEX(',', CardholderIdMethodList + ',') - 1)) AS CardholderIdMethod,
               STUFF(CardholderIdMethodList, 1, CHARINDEX(',', CardholderIdMethodList + ','), '') AS CardholderIdMethodList
        FROM CardholderIdMethodTable
        WHERE CardholderIdMethodList > ''
    ),
    AuthRespCodeTable(FeeId, AuthRespCode, AuthRespCodeList) AS
    (
        SELECT FeeId,
               LTRIM(LEFT(AuthRespCode, CHARINDEX(',', AuthRespCode + ',') - 1)) AS AuthRespCode,
               STUFF(AuthRespCode, 1, CHARINDEX(',', AuthRespCode + ','), '') AS AuthRespCodeList
        FROM tlkpCostVisaInterchangeFeeStage
        UNION ALL
        SELECT FeeId,
               LTRIM(LEFT(CAST(AuthRespCodeList AS NVARCHAR(1000)), CHARINDEX(',', AuthRespCodeList + ',') - 1)) AS AuthRespCode,
               STUFF(AuthRespCodeList, 1, CHARINDEX(',', AuthRespCodeList + ','), '') AS AuthRespCodeList
        FROM AuthRespCodeTable
        WHERE AuthRespCodeList > ''
    ),
    MccSpecificTable(FeeId, MccSpecific, MccSpecificList) AS
    (
        SELECT FeeId,
               LTRIM(LEFT(MccSpecific, CHARINDEX(',', MccSpecific + ',') - 1)) AS MccSpecific,
               STUFF(MccSpecific, 1, CHARINDEX(',', MccSpecific + ','), '') AS MccSpecificList
        FROM tlkpCostVisaInterchangeFeeStage
        UNION ALL
        SELECT FeeId,
               LTRIM(LEFT(CAST(MccSpecificList AS NVARCHAR(1000)), CHARINDEX(',', MccSpecificList + ',') - 1)) AS MccSpecific,
               STUFF(MccSpecificList, 1, CHARINDEX(',', MccSpecificList + ','), '') AS MccSpecificList
        FROM MccSpecificTable
        WHERE MccSpecificList > ''
    ),
    ReimbAttrTable(FeeId, ReimbAttr, ReimbAttrList) AS
    (
        SELECT FeeId,
               LTRIM(LEFT(ReimbAttr, CHARINDEX(',', ReimbAttr + ',') - 1)) AS ReimbAttr,
               STUFF(ReimbAttr, 1, CHARINDEX(',', ReimbAttr + ','), '') AS ReimbAttrList
        FROM tlkpCostVisaInterchangeFeeStage
        UNION ALL
        SELECT FeeId,
               LTRIM(LEFT(CAST(ReimbAttrList AS NVARCHAR(1000)), CHARINDEX(',', ReimbAttrList + ',') - 1)) AS ReimbAttr,
               STUFF(ReimbAttrList, 1, CHARINDEX(',', ReimbAttrList + ','), '') AS ReimbAttrList
        FROM ReimbAttrTable
        WHERE ReimbAttrList > ''
    )
    INSERT INTO tlkpCostVisaInterchangeFee (
        EffectiveFrom,
        EffectiveUntil,
        MerchantCountryRegion,
        IssuerCountryRegion,
        FeeScenario,
        MinimumAmountMajorUnit,
        MaximumAmountMajorUnit,
        AmountCurrency,
        Afs,
        Pid,
        ProductSubtype,
        ProductType,
        FeeDescriptor,
        FeePercentAsMultiplier,
        FixedFeeMajorUnit,
        CappedMajorUnit,
        FixedCurrency,
        Fpi,
        ReimbAttr,
        CardCapabilityFlag,
        PosTerminalCapability,
        AuthCode,
        PosEntryMode,
        CardholderIdMethod,
        MotoEci,
        MccSpecific,
        ExcludingMccs,
        PosEnvCode,
        Ati,
        AuthRespCode,
        CvvResult,
        TimelinessDays,
        ChipTerminalDeploymentFlag,
        BusinessApplicationIdentifier,
        AuthCharac,
        RequestedPaymentService,
        Dcci)
    SELECT s.EffectiveFrom,
           s.EffectiveUntil,
           s.MerchantCountryRegion,
           s.IssuerCountryRegion,
           s.FeeScenario,
           s.MinimumAmountMajorUnit,
           s.MaximumAmountMajorUnit,
           s.AmountCurrency,
           at.Afs,
           pt.Pid,
           s.ProductSubtype,
           s.ProductType,
           s.FeeDescriptor,
           s.FeePercentAsMultiplier,
           s.FixedFeeMajorUnit,
           s.CappedMajorUnit,
           s.FixedCurrency,
           s.Fpi,
           rat.ReimbAttr,
           s.CardCapabilityFlag,
           s.PosTerminalCapability,
           s.AuthCode,
           pemt.PosEntryMode,
           cimt.CardholderIdMethod,
           s.MotoEci,
           mst.MccSpecific,
           s.ExcludingMccs,
           s.PosEnvCode,
           s.Ati,
           arct.AuthRespCode,
           s.CvvResult,
           s.TimelinessDays,
           s.ChipTerminalDeploymentFlag,
           s.BusinessApplicationIdentifier,
           s.AuthCharac,
           s.RequestedPaymentService,
           s.Dcci
    FROM tlkpCostVisaInterchangeFeeStage s LEFT OUTER JOIN AfsTable at ON s.FeeId = at.FeeId
                                           LEFT OUTER JOIN PidTable pt ON s.FeeId = pt.FeeId
                                           LEFT OUTER JOIN PosEntryModeTable pemt ON s.FeeId = pemt.FeeId
                                           LEFT OUTER JOIN CardholderIdMethodTable cimt ON s.FeeId = cimt.FeeId
                                           LEFT OUTER JOIN AuthRespCodeTable arct ON s.FeeId = arct.FeeId
                                           LEFT OUTER JOIN MccSpecificTable mst ON s.FeeId = mst.FeeId
                                           LEFT OUTER JOIN ReimbAttrTable rat ON s.FeeId = rat.FeeId;
END;
GO
