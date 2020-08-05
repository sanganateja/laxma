SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[COMM_PLAN_CREATE]
    @p_crm_id NVARCHAR(2000),
    @p_is_default NUMERIC,
    @p_name NVARCHAR(2000),
    @p_plan_id NUMERIC
AS
BEGIN
    INSERT dbo.ACC_COMMISSION_PLANS
    (
        PLAN_ID,
        CRM_ID,
        PLAN_NAME,
        IS_DEFAULT
    )
    VALUES
    (@p_plan_id, @p_crm_id, @p_name, @p_is_default);
END;
GO
