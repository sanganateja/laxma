SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[PAYMENT_MES_OUT_REMOVE]  
   @p_messsage_id numeric/* ID*/
AS 
   
   BEGIN
      DELETE dbo.ACC_PAYMENT_MESSAGES_OUT
      FROM dbo.ACC_PAYMENT_MESSAGES_OUT  AS g
      WHERE g.MESSAGE_ID = @p_messsage_id
   END
GO
