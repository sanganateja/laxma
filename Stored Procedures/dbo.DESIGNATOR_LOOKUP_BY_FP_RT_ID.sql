SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[DESIGNATOR_LOOKUP_BY_FP_RT_ID]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_fee_program NVARCHAR(2000),
    @p_rate_tier NVARCHAR(2000),
    @p_interchange_description NVARCHAR(2000)
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT *
    FROM CST_DESIGNATOR_ACQ_LOOKUP
    WHERE FEE_PROGRAM = @p_fee_program
          AND RATE_TIER = @p_rate_tier
          AND INTERCHANGE_DESCRIPTION = @p_interchange_description;

    RETURN;

END;
GO
