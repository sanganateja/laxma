SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[TRANSACTION_FIND_BY_ACCT_GRP]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_account_group_id NUMERIC /* ID*/
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT t.TRANSACTION_ID,
           t.EVENT_TYPE_ID,
           t.TRANSACTION_TIME,
           t.DESCRIPTION,
           t.AMOUNT_MINOR_UNITS,
           t.ACCOUNT_GROUP_ID,
           t.TXN_FIRST_ID,
           t.EXTERNAL_REF,
           t.TXN_GROUP_ID,
           t.USER_NAME,
           t.CUSTOMER_REF,
           t.SOURCE_REF,
           t.CURRENCY,
           t.EXCHANGE_RATE,
           t.TXN_ASSOCIATION_ID,
           t.BUY_FIXED_AMOUNT_MINOR_UNIT,
           t.BUY_VARIABLE_PERCENTAGE,
           t.SELL_FIXED_AMOUNT_MINOR_UNIT,
           t.SELL_VARIABLE_PERCENTAGE
    FROM dbo.ACC_TRANSACTIONS AS t
    WHERE t.ACCOUNT_GROUP_ID = @p_account_group_id
    ORDER BY t.TRANSACTION_ID;

    RETURN;

END;
GO
