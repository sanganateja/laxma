SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[PRELOAD_DESTINATION_CREATE]
    @p_destination_account_group_id NUMERIC,
    @p_currency_code_alpha3 NVARCHAR(2000),
    @p_owner_id NUMERIC
AS
BEGIN
    INSERT dbo.ACC_PRELOAD_DESTINATION
    (
        OWNER_ID,
        CURRENCY_CODE_ALPHA3,
        DESTINATION_ACCOUNT_GROUP_ID
    )
    VALUES
    (@p_owner_id, @p_currency_code_alpha3, @p_destination_account_group_id);
END;
GO
