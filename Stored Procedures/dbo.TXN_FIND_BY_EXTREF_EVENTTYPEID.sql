SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[TXN_FIND_BY_EXTREF_EVENTTYPEID]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_extref NVARCHAR(2000), /* ID*/
    @p_event_type_id NUMERIC  /* event_type_id*/
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
    WHERE t.EXTERNAL_REF = @p_extref
          AND t.EVENT_TYPE_ID = @p_event_type_id;

    RETURN;

END;
GO
