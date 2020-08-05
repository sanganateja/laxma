SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[RESP_MESSAGES_OUT_Q_DELETE]  
   @p_message_id numeric
AS 
   
   BEGIN
      DELETE dbo.ACC_RESP_MESSAGES_OUT_QUEUE
      WHERE ACC_RESP_MESSAGES_OUT_QUEUE.MESSAGE_ID = @p_message_id
   END
GO
