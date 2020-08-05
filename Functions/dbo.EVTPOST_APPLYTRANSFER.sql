SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   FUNCTION [dbo].[EVTPOST_APPLYTRANSFER] 
( 
   @p_transaction_id numeric,
   @p_account_id numeric,
   @p_amount_minor_units numeric,
   @p_maturity_date datetime2(6),
   @p_transfer_method_id numeric,
   @p_transfer_time datetime2(6),
   @p_transfer_type_id numeric,
   @p_min_allowed_balance numeric
)
/*
*   SSMA warning messages:
*   O2SS0356: Conversion from NUMBER datatype can cause data loss.
*/

RETURNS float(53)
AS 
   
   BEGIN      

      DECLARE
         /*
         *   SSMA warning messages:
         *   O2SS0356: Conversion from NUMBER datatype can cause data loss.
         */

         @return_value_argument float(53)

      EXEC [dbo].[EVTPOST_APPLYTRANSFER$IMPL]         
         @p_transaction_id, 
         @p_account_id, 
         @p_amount_minor_units, 
         @p_maturity_date, 
         @p_transfer_method_id, 
         @p_transfer_time, 
         @p_transfer_type_id, 
         @p_min_allowed_balance, 
         @return_value_argument  OUTPUT

      RETURN @return_value_argument

   END
GO
