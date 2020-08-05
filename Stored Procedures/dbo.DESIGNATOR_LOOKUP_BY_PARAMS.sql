SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[DESIGNATOR_LOOKUP_BY_PARAMS]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_card_type NVARCHAR(2000),
    @p_fee_program NVARCHAR(2000),
    @p_rate_tier NVARCHAR(2000),
    @p_interchange_description NVARCHAR(2000)
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT CST_DESIGNATOR_ACQ_LOOKUP.LOOKUP_ID,
           CST_DESIGNATOR_ACQ_LOOKUP.FEE_PROGRAM,
           CST_DESIGNATOR_ACQ_LOOKUP.RATE_TIER,
           CST_DESIGNATOR_ACQ_LOOKUP.INTERCHANGE_DESCRIPTION,
           CST_DESIGNATOR_ACQ_LOOKUP.DESIGNATOR_ID
    FROM dbo.CST_DESIGNATOR_ACQ_LOOKUP
    WHERE CST_DESIGNATOR_ACQ_LOOKUP.FEE_PROGRAM LIKE @p_card_type
          AND
          (
              CST_DESIGNATOR_ACQ_LOOKUP.FEE_PROGRAM = @p_fee_program
              OR @p_fee_program IS NULL
          )
          AND
          (
              CST_DESIGNATOR_ACQ_LOOKUP.RATE_TIER = @p_rate_tier
              OR @p_rate_tier IS NULL
          )
          AND
          (
              CST_DESIGNATOR_ACQ_LOOKUP.INTERCHANGE_DESCRIPTION = @p_interchange_description
              OR @p_interchange_description IS NULL
          );

    RETURN;

END;
GO
