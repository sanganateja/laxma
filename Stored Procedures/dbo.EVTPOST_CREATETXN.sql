SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[EVTPOST_CREATETXN]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_txn_time DATETIME2(6),
    @p_description NVARCHAR(2000),
    @p_amount_minor_units NUMERIC,
    @p_external_ref NVARCHAR(2000),
    @p_source_ref NVARCHAR(2000),
    @p_customer_ref NVARCHAR(2000),
    @p_txn_association_id NUMERIC,
    @p_txn_group_id NVARCHAR(2000),
    @p_user_name NVARCHAR(2000),
    @p_txn_first_id NUMERIC,
    @p_account_group_id NUMERIC,
    @p_event_type_id NUMERIC,
    @p_currency NVARCHAR(2000),
    @p_exchange_rate NUMERIC(12, 5),
    @p_buy_fixed_amount_minor_unit numeric,
    @p_buy_variable_percentage numeric(18,2),
    @p_sell_fixed_amount_minor_unit numeric,
    @p_sell_variable_percentage numeric(18,2)
AS
BEGIN

      SET @cv_1 = NULL

      DECLARE
         @v_txn_id bigint

      SELECT @v_txn_id = NEXT VALUE FOR dbo.HIBERNATE_SEQUENCE

      INSERT dbo.ACC_TRANSACTIONS(
         TRANSACTION_ID,
         TRANSACTION_TIME,
         DESCRIPTION,
         AMOUNT_MINOR_UNITS,
         EVENT_TYPE_ID,
         EXTERNAL_REF,
         SOURCE_REF,
         CUSTOMER_REF,
         TXN_GROUP_ID,
         TXN_ASSOCIATION_ID,
         TXN_FIRST_ID,
         ACCOUNT_GROUP_ID,
         USER_NAME,
         CURRENCY,
         EXCHANGE_RATE,
         BUY_FIXED_AMOUNT_MINOR_UNIT,
         BUY_VARIABLE_PERCENTAGE,
         SELL_FIXED_AMOUNT_MINOR_UNIT,
         SELL_VARIABLE_PERCENTAGE)
         VALUES (
            @v_txn_id,
            @p_txn_time,
            @p_description,
            @p_amount_minor_units,
            @p_event_type_id,
            @p_external_ref,
            @p_source_ref,
            @p_customer_ref,
            @p_txn_group_id,
            @p_txn_association_id,
            isnull(@p_txn_first_id, @v_txn_id),
            @p_account_group_id,
            @p_user_name,
            @p_currency,
            @p_exchange_rate,
            @p_buy_fixed_amount_minor_unit,
            @p_buy_variable_percentage,
            @p_sell_fixed_amount_minor_unit,
            @p_sell_variable_percentage)

      SELECT
         ACC_TRANSACTIONS.TRANSACTION_ID,
         ACC_TRANSACTIONS.EVENT_TYPE_ID,
         ACC_TRANSACTIONS.TRANSACTION_TIME,
         ACC_TRANSACTIONS.DESCRIPTION,
         ACC_TRANSACTIONS.AMOUNT_MINOR_UNITS,
         ACC_TRANSACTIONS.ACCOUNT_GROUP_ID,
         ACC_TRANSACTIONS.TXN_FIRST_ID,
         ACC_TRANSACTIONS.EXTERNAL_REF,
         ACC_TRANSACTIONS.TXN_GROUP_ID,
         ACC_TRANSACTIONS.USER_NAME,
         ACC_TRANSACTIONS.CUSTOMER_REF,
         ACC_TRANSACTIONS.SOURCE_REF,
         ACC_TRANSACTIONS.CURRENCY,
         ACC_TRANSACTIONS.EXCHANGE_RATE,
         ACC_TRANSACTIONS.TXN_ASSOCIATION_ID,
         ACC_TRANSACTIONS.BUY_FIXED_AMOUNT_MINOR_UNIT,
         ACC_TRANSACTIONS.BUY_VARIABLE_PERCENTAGE,
         ACC_TRANSACTIONS.SELL_FIXED_AMOUNT_MINOR_UNIT,
         ACC_TRANSACTIONS.SELL_VARIABLE_PERCENTAGE
      FROM dbo.ACC_TRANSACTIONS
      WHERE ACC_TRANSACTIONS.TRANSACTION_ID = @v_txn_id


END;
GO
