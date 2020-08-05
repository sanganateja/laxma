SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACQUIRING_FEE_UPDATE]
   @p_account_group_id numeric,
   @p_amount_minor_units numeric,
   @p_event_type_id numeric,
   @p_percentage numeric(18, 4),
   @p_fee_id numeric/* ID*/
AS

   BEGIN
      UPDATE dbo.ACC_ACQUIRING_FEES
         SET
            ACCOUNT_GROUP_ID = @p_account_group_id,
            EVENT_TYPE_ID = @p_event_type_id,
            PERCENTAGE = @p_percentage,
            AMOUNT_MINOR_UNITS = @p_amount_minor_units
      FROM dbo.ACC_ACQUIRING_FEES  AS af
      WHERE af.FEE_ID = @p_fee_id
   END
GO
