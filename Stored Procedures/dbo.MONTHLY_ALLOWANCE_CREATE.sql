SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[MONTHLY_ALLOWANCE_CREATE]  
   @p_account_group_id numeric,
   @p_free_allowance numeric,
   @p_remaining_units numeric,
   @p_transfer_method_id numeric,
   @p_monthly_allowance_id numeric/* ID*/
AS 
   
   BEGIN
      INSERT dbo.ACC_MONTHLY_ALLOWANCES(
         MONTHLY_ALLOWANCE_ID, 
         ACCOUNT_GROUP_ID, 
         TRANSFER_METHOD_ID, 
         FREE_ALLOWANCE, 
         REMAINING_UNITS)
         VALUES (
            @p_monthly_allowance_id, 
            @p_account_group_id, 
            @p_transfer_method_id, 
            @p_free_allowance, 
            @p_remaining_units)
   END
GO
