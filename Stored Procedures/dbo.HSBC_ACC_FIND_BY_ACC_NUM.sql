SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[HSBC_ACC_FIND_BY_ACC_NUM]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_acc_num NVARCHAR(2000)
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT ac.ACCOUNT_ID,
           ac.CURRENCY_CODE_ALPHA3,
           ac.ACCOUNT_NUMBER,
           ac.DESCRIPTION,
           ac.STATEMENT_ENABLED
    FROM dbo.ACC_HSBC_ACCOUNTS AS ac
    WHERE ac.ACCOUNT_NUMBER = @p_acc_num;

    RETURN;

END;
GO
