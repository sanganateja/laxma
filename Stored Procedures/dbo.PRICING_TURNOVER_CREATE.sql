SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[PRICING_TURNOVER_CREATE]
    @p_description NVARCHAR(2000),
    @p_pricing_turnover_band_id NUMERIC /* ID*/
AS
BEGIN
    INSERT dbo.ACC_PRICING_TURNOVER_BANDS
    (
        PRICING_TURNOVER_BAND_ID,
        DESCRIPTION
    )
    VALUES
    (@p_pricing_turnover_band_id, @p_description);
END;
GO
