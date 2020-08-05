SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[HSBC_ACC_BAL_CREATE]  
   @p_balance_date datetime2(6),
   @p_closing_balance numeric,
   @p_account_id numeric,
   @p_opening_balance numeric,
   @p_balance_id numeric
AS 
   
   BEGIN
      INSERT dbo.ACC_HSBC_ACCOUNT_BALANCES(
         BALANCE_ID, 
         ACCOUNT_ID, 
         BALANCE_DATE, 
         OPENING_BALANCE_MINOR_UNITS, 
         CLOSING_BALANCE_MINOR_UNITS)
         VALUES (
            @p_balance_id, 
            @p_account_id, 
            CAST(@p_balance_date AS DATE), 
            @p_opening_balance, 
            @p_closing_balance)
   END
GO
