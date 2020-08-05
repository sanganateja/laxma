SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[GEN_MES_OUT_QUEUE_LATEST] @CV_1 VARCHAR(2000) OUTPUT
AS
BEGIN

    SET @CV_1 = NULL;

    SELECT TOP (1)
           gm.MESSAGE_ID,
           gm.MESSAGE_TIMESTAMP,
           gm.MESSAGE_TYPE,
           gm.MESSAGE_REFERENCE,
           gm.MESSAGE_TEXT
    FROM dbo.ACC_GENERIC_MESSAGES_OUT_QUEUE AS gm
    ORDER BY gm.MESSAGE_TIMESTAMP;

    RETURN;

END;
GO