SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_ST_CREATE]
    @p_account_group_id NUMERIC,
    @p_currency_code NVARCHAR(2000),
    @p_quantity NUMERIC,
    @p_statement_month DATETIME2(6),
    @p_total_minor_units NUMERIC,
    @p_transfer_type_id NUMERIC,
    @p_account_statement_id NUMERIC
AS
BEGIN
    INSERT dbo.ACC_ACCOUNT_STATEMENTS
    (
        ACCOUNT_STATEMENT_ID,
        ACCOUNT_GROUP_ID,
        STATEMENT_MONTH,
        TRANSFER_TYPE_ID,
        QUANTITY,
        TOTAL_MINOR_UNITS
    )
    VALUES
    (@p_account_statement_id,
     @p_account_group_id,
     @p_statement_month,
     @p_transfer_type_id,
     @p_quantity,
     @p_total_minor_units);
END;
GO
