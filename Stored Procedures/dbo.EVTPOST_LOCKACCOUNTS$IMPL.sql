SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[EVTPOST_LOCKACCOUNTS$IMPL]  
   @p_registry_id BIGINT,
   @return_value_argument FLOAT(53)  OUTPUT
AS 
   BEGIN

      DECLARE
         @n int = 0, 
         @v_balance bigint

      SET @n = 0

      DECLARE
         @acc$account_id BIGINT

      DECLARE
          c_lockaccs CURSOR LOCAL FORWARD_ONLY FOR 
            SELECT ACC_EVTPOST_REGISTRY.FROM_ACCOUNT_ID AS account_id
            FROM dbo.ACC_EVTPOST_REGISTRY
            WHERE ACC_EVTPOST_REGISTRY.ID = @p_registry_id
             UNION
            SELECT ACC_EVTPOST_REGISTRY.TO_ACCOUNT_ID AS account_id
            FROM dbo.ACC_EVTPOST_REGISTRY
            WHERE ACC_EVTPOST_REGISTRY.ID = @p_registry_id
            ORDER BY account_id

      OPEN c_lockaccs

      
      /*
      *    Loop through all accounts in ID order, doing a no-op balance update that will take a
      *    lock on the account's row.
      */
      WHILE 1 = 1
      
         BEGIN

            FETCH c_lockaccs
                INTO @acc$account_id

            IF @@FETCH_STATUS = -1
               BREAK

           UPDATE dbo.ACC_ACCOUNTS
               SET 
                @v_balance =  BALANCE_MINOR_UNITS = ACC_ACCOUNTS.BALANCE_MINOR_UNITS               
            WHERE ACC_ACCOUNTS.ACCOUNT_ID = @acc$account_id


            UPDATE dbo.ACC_EVTPOST_REGISTRY
               SET 
                  TO_BALANCE = @v_balance
            WHERE ACC_EVTPOST_REGISTRY.TO_ACCOUNT_ID = @acc$account_id AND ACC_EVTPOST_REGISTRY.ID = @p_registry_id

            UPDATE dbo.ACC_EVTPOST_REGISTRY
               SET 
                  FROM_BALANCE = @v_balance
            WHERE ACC_EVTPOST_REGISTRY.FROM_ACCOUNT_ID = @acc$account_id AND ACC_EVTPOST_REGISTRY.ID = @p_registry_id

            SET @n = @n + 1

         END

      CLOSE c_lockaccs

      DEALLOCATE c_lockaccs

      SET @return_value_argument = @n

      RETURN 

   END
GO
