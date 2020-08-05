SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[COMM_POINT_CREATE]
    @p_commission_plan_id NUMERIC,
    @p_event_type_id NUMERIC,
    @p_fee_distinguisher NVARCHAR(2000),
    @p_fixed_amount_currency_code NVARCHAR(2000),
    @p_fixed_amount_minor_units NUMERIC,
    @p_scheme_region_code NVARCHAR(2000),
    @p_split_percentage NUMERIC(18, 2),
    @p_variable_percentage NUMERIC(18, 4),
    @p_point_id NUMERIC
AS
BEGIN
    INSERT dbo.ACC_COMMISSION_POINTS
    (
        POINT_ID,
        COMMISSION_PLAN_ID,
        EVENT_TYPE_ID,
        FEE_DISTINGUISHER,
        SCHEME_REGION_CODE,
        FIXED_AMOUNT_MINOR_UNITS,
        FIXED_CURRENCY_CODE_ALPHA3,
        VARIABLE_PERCENTAGE,
        SPLIT_PERCENTAGE
    )
    VALUES
    (@p_point_id,
     @p_commission_plan_id,
     @p_event_type_id,
     @p_fee_distinguisher,
     @p_scheme_region_code,
     @p_fixed_amount_minor_units,
     @p_fixed_amount_currency_code,
     @p_variable_percentage,
     @p_split_percentage);
END;
GO
