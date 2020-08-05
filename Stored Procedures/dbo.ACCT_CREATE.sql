SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACCT_CREATE]  
   @p_account_group_id numeric,
   @p_account_type_id numeric,
   @p_balance_minor_units numeric,
   @p_maturity_hours numeric,
   @p_account_id numeric/* ID*/
AS 
   
   BEGIN
      INSERT dbo.ACC_ACCOUNTS(
         ACCOUNT_ID, 
         ACCOUNT_GROUP_ID, 
         ACCOUNT_TYPE_ID, 
         BALANCE_MINOR_UNITS, 
         MATURITY_HOURS)
         VALUES (
            @p_account_id, 
            @p_account_group_id, 
            @p_account_type_id, 
            @p_balance_minor_units, 
            @p_maturity_hours)
   END
GO
