SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[spCostMastercardSchemeFeeCreate]
    @effectiveFrom                 DATETIME2,
    @effectiveUntil                DATETIME2,
    @feePercentAsMultiplier        DECIMAL(18,8),
    @fixedFeeCurrency              NCHAR(3),
    @fixedFeeMajorUnit             DECIMAL(18,8),
    @issuerCountryRegion           NVARCHAR(50),
    @merchantCountryRegion         NVARCHAR(50),
    @score                         BIGINT,
    @feeId                         BIGINT
AS
BEGIN
    INSERT dbo.tlkpCostMastercardSchemeFee
    (
        EffectiveFrom,
        EffectiveUntil,
        MerchantCountryRegion,
        IssuerCountryRegion,
        FeePercentAsMultiplier,
        FixedFeeMajorUnit,
        FixedFeeCurrency
    )
    VALUES
    (
        @effectiveFrom,
        @effectiveUntil,
        @merchantCountryRegion,
        @issuerCountryRegion,
        @feePercentAsMultiplier,
        @fixedFeeMajorUnit,
        @fixedFeeCurrency
    );
END;
GO
