SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[BULK_PAYMENT_BATCH_UPDATE]
    @p_account_group_id NUMERIC,
    @p_bulk_payment_source_id NUMERIC,
    @p_description NVARCHAR(2000),
    @p_import_date DATETIME2(6),
    @p_owner_id NUMERIC,
    @p_payment_count NUMERIC,
    @p_status VARCHAR(2000),
    @p_submit_date DATETIME2(6),
    @p_batch_id NUMERIC
AS
BEGIN
    UPDATE dbo.ACC_BULK_PAYMENT_BATCHES
    SET ACCOUNT_GROUP_ID = @p_account_group_id,
        BULK_PAYMENT_SOURCE_ID = @p_bulk_payment_source_id,
        DESCRIPTION = @p_description,
        IMPORT_DATE = @p_import_date,
        OWNER_ID = @p_owner_id,
        PAYMENT_COUNT = @p_payment_count,
        STATUS = @p_status,
        SUBMIT_DATE = @p_submit_date
    WHERE ACC_BULK_PAYMENT_BATCHES.BATCH_ID = @p_batch_id;
END;
GO
