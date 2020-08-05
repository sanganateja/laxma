SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   FUNCTION [dbo].[ACC_REPORTS_PACKAGE$rpt_define_country_code] 
( 
   @p_payment_type varchar(max),
   @p_account_id nvarchar(max),
   @p_account_id_type varchar(max),
   @p_payer_agent_id nvarchar(max),
   @p_payer_agent_id_type varchar(max)
)
RETURNS varchar(max)
AS    
   BEGIN

      DECLARE
         @v_gb_payment bit, 
         @v_country_code nvarchar(2)

		SELECT	@v_gb_payment = @p_payment_type WHERE @p_payment_type IN ('FP','CH','FC')
		
		IF @v_gb_payment IS NOT NULL 
			RETURN 324

		IF @p_account_id_type = 'I' -- IBAN_ACC_ID_TYPE
			SET @v_country_code = substring(@p_account_id, 1, 2)


      IF @v_country_code IS NULL AND @p_payer_agent_id_type = 'B' -- BIC_ACC_ID_TYPE
         SET @v_country_code = substring(@p_account_id, 5, 2)

      RETURN @v_country_code

   END
GO
