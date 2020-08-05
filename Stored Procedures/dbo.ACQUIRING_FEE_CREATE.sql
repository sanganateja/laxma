SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACQUIRING_FEE_CREATE]
   @p_account_group_id numeric,
   @p_amount_minor_units numeric,
   @p_event_type_id numeric,
   @p_percentage numeric(18, 4),
   @p_fee_id numeric/* ID*/
AS

   BEGIN
      INSERT dbo.ACC_ACQUIRING_FEES(
         FEE_ID,
         ACCOUNT_GROUP_ID,
         EVENT_TYPE_ID,
         PERCENTAGE,
         AMOUNT_MINOR_UNITS)
         VALUES (
            @p_fee_id,
            @p_account_group_id,
            @p_event_type_id,
            @p_percentage,
            @p_amount_minor_units)
   END
GO
