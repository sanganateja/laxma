SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[spCostVisaSchemeFeeCreate]
    @cardType                      NVARCHAR(50),
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
    INSERT dbo.tlkpCostVisaSchemeFee
    (
        EffectiveFrom,
        EffectiveUntil,
        MerchantCountryRegion,
        IssuerCountryRegion,
        CardType,
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
        @cardType,
        @feePercentAsMultiplier,
        @fixedFeeMajorUnit,
        @fixedFeeCurrency
    );
END;
GO
