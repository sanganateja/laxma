SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACCTGRP_FIND_CURRENCIES]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_owner_id NUMERIC,
    @p_acct_group_type NVARCHAR(2000)
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT DISTINCT
           ag.CURRENCY_CODE_ALPHA3
    FROM dbo.ACC_ACCOUNT_GROUPS AS ag
    WHERE ag.OWNER_ID = @p_owner_id
          AND
          (
              (ag.ACCOUNT_GROUP_TYPE = ISNULL(@p_acct_group_type, ag.ACCOUNT_GROUP_TYPE))
              OR
              (
                  @p_acct_group_type = 'C'
                  AND ag.ACCOUNT_GROUP_TYPE = 'D'
              )
          );

    RETURN;

END;
GO
