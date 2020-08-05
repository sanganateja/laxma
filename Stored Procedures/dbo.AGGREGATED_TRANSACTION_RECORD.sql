SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[AGGREGATED_TRANSACTION_RECORD]
(
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_account_group_id BIGINT,
    @p_source_ref NVARCHAR(16),
    @p_event_date DATE,
    @p_authorisation_inc BIGINT,
    @p_decline_inc BIGINT
)
AS
DECLARE @v_event_date DATE;
BEGIN
    SET @v_event_date = CAST(@p_event_date AS DATE);
    SET @cv_1 = NULL;
    IF EXISTS
    (
        SELECT 1
        FROM ACC_AGGREGATED_TRANSACTIONS
        WHERE ACCOUNT_GROUP_ID = @p_account_group_id
              AND SOURCE_REF = @p_source_ref
              AND EVENT_DATE = @v_event_date
    )
    BEGIN
        UPDATE ACC_AGGREGATED_TRANSACTIONS
        SET DECLINE_COUNT = DECLINE_COUNT + @p_decline_inc,
            AUTHORISATION_COUNT = AUTHORISATION_COUNT + @p_authorisation_inc
        WHERE ACCOUNT_GROUP_ID = @p_account_group_id
              AND SOURCE_REF = @p_source_ref
              AND EVENT_DATE = @v_event_date;
    END;
    ELSE
    BEGIN
        INSERT INTO ACC_AGGREGATED_TRANSACTIONS
        (
            ACCOUNT_GROUP_ID,
            SOURCE_REF,
            EVENT_DATE,
            DECLINE_COUNT,
            AUTHORISATION_COUNT
        )
        VALUES
        (@p_account_group_id, @p_source_ref, @v_event_date, @p_decline_inc, @p_authorisation_inc);
    END;


    SELECT *
    FROM ACC_AGGREGATED_TRANSACTIONS
    WHERE ACCOUNT_GROUP_ID = @p_account_group_id
          AND SOURCE_REF = @p_source_ref
          AND EVENT_DATE = @v_event_date;

END;
GO
