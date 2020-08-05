SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[BULK_PAYMENT_BATCH_CREATE]
    @p_account_group_id NUMERIC,
    @p_bulk_payment_source_id NUMERIC,
    @p_description NVARCHAR(2000),
    @p_import_date DATETIME2(6),
    @p_owner_id NUMERIC,
    @p_payment_count NUMERIC,
    @p_status VARCHAR(2000),
    @p_submit_date DATETIME2(6),
    @batch_id NUMERIC
AS
BEGIN
    INSERT dbo.ACC_BULK_PAYMENT_BATCHES
    (
        ACCOUNT_GROUP_ID,
        BULK_PAYMENT_SOURCE_ID,
        DESCRIPTION,
        IMPORT_DATE,
        OWNER_ID,
        PAYMENT_COUNT,
        STATUS,
        SUBMIT_DATE,
        BATCH_ID
    )
    VALUES
    (@p_account_group_id,
     @p_bulk_payment_source_id,
     @p_description,
     @p_import_date,
     @p_owner_id,
     @p_payment_count,
     @p_status,
     @p_submit_date,
     @batch_id);
END;
GO
