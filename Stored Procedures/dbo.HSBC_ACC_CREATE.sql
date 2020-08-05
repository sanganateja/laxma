SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[HSBC_ACC_CREATE]
    @p_account_number NVARCHAR(2000),
    @p_currency VARCHAR(2000),
    @p_description NVARCHAR(2000),
    @p_statement_enable VARCHAR(2000),
    @p_account_id NUMERIC
AS
BEGIN
    INSERT dbo.ACC_HSBC_ACCOUNTS
    (
        ACCOUNT_ID,
        CURRENCY_CODE_ALPHA3,
        ACCOUNT_NUMBER,
        DESCRIPTION,
        STATEMENT_ENABLED
    )
    VALUES
    (@p_account_id, @p_currency, @p_account_number, @p_description, @p_statement_enable);
END;
GO
