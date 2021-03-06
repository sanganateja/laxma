SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[POSTING_RULE_FIND_BY_EVENT_ID]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_event_type_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT ACC_POSTING_RULES.EVENT_TYPE_ID,
           ACC_POSTING_RULES.FROM_ACCOUNT_TYPE_ID,
           ACC_POSTING_RULES.TO_ACCOUNT_TYPE_ID,
           ACC_POSTING_RULES.TRANSFER_TYPE_ID,
           ACC_POSTING_RULES.ACCOUNT_GROUP_TYPE,
           ACC_POSTING_RULES.FROM_ACCOUNT_ARREARS_TYPE_ID,
           ACC_POSTING_RULES.TO_ACCOUNT_ARREARS_TYPE_ID
    FROM dbo.ACC_POSTING_RULES
    WHERE ACC_POSTING_RULES.EVENT_TYPE_ID = @p_event_type_id;

    RETURN;

END;
GO
