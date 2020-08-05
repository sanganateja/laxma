SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[TRANSFER_FIND_DESCRIPTIONS]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_from_date DATETIME2(6),
    @p_to_date DATETIME2(6),
    @p_currency_code_alpha3 NVARCHAR(2000),
    @p_owner_id NUMERIC,
    @p_transfer_type_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT t.TRANSACTION_ID AS id,
           t.DESCRIPTION AS description
    FROM dbo.ACC_TRANSACTIONS AS t
        LEFT JOIN dbo.ACC_TRANSFERS AS tr
            ON tr.TRANSACTION_ID = t.TRANSACTION_ID
        LEFT JOIN dbo.ACC_ACCOUNT_GROUPS AS ag
            ON ag.ACCOUNT_GROUP_ID = t.ACCOUNT_GROUP_ID
    WHERE tr.TRANSFER_TIME
          BETWEEN @p_from_date AND @p_to_date
          AND ag.CURRENCY_CODE_ALPHA3 = @p_currency_code_alpha3
          AND ag.OWNER_ID = @p_owner_id
          AND tr.AMOUNT_MINOR_UNITS > 0
          AND tr.TRANSFER_TYPE_ID = @p_transfer_type_id;

    RETURN;

END;
GO
