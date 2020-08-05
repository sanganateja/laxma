SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[REMIT_DAY_CREATE]
    @p_account_group_id NUMERIC,
    @p_remit_day NVARCHAR(2000),
    @p_remit_day_id NUMERIC
AS
BEGIN
    INSERT dbo.ACC_REMIT_DAYS
    (
        REMIT_DAY_ID,
        REMIT_DAY,
        ACCOUNT_GROUP_ID
    )
    VALUES
    (@p_remit_day_id, @p_remit_day, @p_account_group_id);
END;
GO
