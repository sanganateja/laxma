SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[AGGREGATED_TRANSACTION_FINDALL] @cv_1 VARCHAR(2000) OUTPUT
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT agg.DECLINE_COUNT,
           agg.AUTHORISATION_COUNT,
           agg.ACCOUNT_GROUP_ID,
           agg.EVENT_DATE,
           agg.SOURCE_REF
    FROM dbo.ACC_AGGREGATED_TRANSACTIONS AS agg
    ORDER BY agg.EVENT_DATE,
             agg.ACCOUNT_GROUP_ID,
             agg.SOURCE_REF;

    RETURN;

END;
GO
