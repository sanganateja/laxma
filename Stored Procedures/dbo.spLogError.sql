SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
-- ================================================================================
--	Author:			Mat
--	Create date:	28/02/2019
--	Description:	
--		Log errors in message handling Sprocs in tblDatabaseLog
--	Return:			
--		Nothing
--
--  Change history
--		28/02/2019	- Mat	- First version (based on Alliance)
--
-- ================================================================================
CREATE PROCEDURE [dbo].[spLogError]
	@CallingSproc varchar(100),
	@Priority varchar(10),
	@ConversationID uniqueidentifier,
	@TransactionReference nvarchar(50),
	@Summary varchar(255),
	@Message nvarchar(max)
AS
BEGIN
	-- Logs both the information sent from the error handling in the SPROC
	-- (including the TransactionID if present) AND the full SQL Server error
	-- trapping information about the cause of the TRANSACTION failure
	
	INSERT INTO tblDatabaseLog(LogDate,CallingSPROC,Priority,Conversation_Handle,TransactionReference,
		Summary,ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,
		ErrorLine,ErrorMessage,[Message])
	SELECT GETDATE(),@CallingSproc,@Priority,@ConversationID,@TransactionReference,
		@Summary,ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),
		ERROR_LINE(),ERROR_MESSAGE(),@Message
END
GO
GRANT EXECUTE ON  [dbo].[spLogError] TO [ServiceBrokerUser]
GO
