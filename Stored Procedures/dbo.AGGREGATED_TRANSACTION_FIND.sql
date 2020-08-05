SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[AGGREGATED_TRANSACTION_FIND]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_source_ref NVARCHAR(2000),
    @p_event_date DATETIME2(6),
    @p_account_group_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT agg.DECLINE_COUNT,
           agg.AUTHORISATION_COUNT,
           agg.ACCOUNT_GROUP_ID,
           agg.EVENT_DATE,
           agg.SOURCE_REF
    FROM dbo.ACC_AGGREGATED_TRANSACTIONS AS agg
    WHERE agg.ACCOUNT_GROUP_ID = @p_account_group_id
          AND agg.SOURCE_REF = @p_source_ref
          AND agg.EVENT_DATE = CAST(@p_event_date AS DATE);

    RETURN;

END;
GO
