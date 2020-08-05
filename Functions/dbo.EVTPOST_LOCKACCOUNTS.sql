SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   FUNCTION [dbo].[EVTPOST_LOCKACCOUNTS] 
( 
   @p_registry_id BIGINT
)

RETURNS FLOAT(53)
AS 
   BEGIN

      DECLARE
         @active_spid INT, 
         @login_time DATETIME, 
         @db_name NVARCHAR(128)

      SET @active_spid = @@spid

      SELECT @login_time = login_time FROM sys.dm_exec_sessions WHERE session_id=@@spid

      SET @db_name = DB_NAME()

      DECLARE          @return_value_argument FLOAT(53)

		EXEC	[dbo].[EVTPOST_LOCKACCOUNTS$IMPL]
		@p_registry_id = @p_registry_id,
		@return_value_argument = @return_value_argument OUTPUT


      RETURN @return_value_argument

   END
GO
