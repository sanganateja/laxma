SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[TRANSFER_TP_FIND_BY_ACCOUNT_TP]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_account_type_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT DISTINCT
           tt.TRANSFER_TYPE_ID,
           tt.NAME,
           tt.DESCRIPTION
    FROM dbo.ACC_TRANSFER_TYPES AS tt,
         dbo.ACC_POSTING_RULES AS pr
    WHERE tt.TRANSFER_TYPE_ID = pr.TRANSFER_TYPE_ID
          AND
          (
              pr.TO_ACCOUNT_TYPE_ID = @p_account_type_id
              OR pr.FROM_ACCOUNT_TYPE_ID = @p_account_type_id
          )
    ORDER BY tt.DESCRIPTION ASC;

    RETURN;

END;
GO
