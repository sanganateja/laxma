SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[MONTHLY_ALLOWANCE_UPDATE]  
   @p_account_group_id numeric,
   @p_free_allowance numeric,
   @p_remaining_units numeric,
   @p_transfer_method_id numeric,
   @p_monthly_allowance_id numeric/* ID*/
AS 
   
   BEGIN
      UPDATE dbo.ACC_MONTHLY_ALLOWANCES
         SET 
            ACCOUNT_GROUP_ID = @p_account_group_id, 
            TRANSFER_METHOD_ID = @p_transfer_method_id, 
            FREE_ALLOWANCE = @p_free_allowance, 
            REMAINING_UNITS = @p_remaining_units
      FROM dbo.ACC_MONTHLY_ALLOWANCES  AS ma
      WHERE ma.MONTHLY_ALLOWANCE_ID = @p_monthly_allowance_id
   END
GO
