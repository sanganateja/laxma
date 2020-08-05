SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[HSBC_ACC_MAP_CREATE]
    @p_currency VARCHAR(2000),
    @p_account_id NUMERIC,
    @p_sort_code NVARCHAR(2000),
    @p_transfer_method_id NUMERIC,
    @p_transfer_type_id NUMERIC,
    @p_account_mapping_id NUMERIC
AS
BEGIN
    INSERT dbo.ACC_HSBC_ACCOUNT_MAPPINGS
    (
        ACCOUNT_MAPPING_ID,
        CURRENCY_CODE_ALPHA3,
        SORT_CODE,
        TRANSFER_TYPE_ID,
        TRANSFER_METHOD_ID,
        ACCOUNT_ID
    )
    VALUES
    (@p_account_mapping_id, @p_currency, @p_sort_code, @p_transfer_type_id, @p_transfer_method_id, @p_account_id);
END;
GO
