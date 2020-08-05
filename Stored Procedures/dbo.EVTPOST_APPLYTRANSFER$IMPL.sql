SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[EVTPOST_APPLYTRANSFER$IMPL]	
            @p_transaction_id      BIGINT NULL,
            @p_account_id          BIGINT NULL,
            @p_amount_minor_units  BIGINT NULL,
            @p_maturity_date       DATETIME2(6) NULL,
            @p_transfer_method_id  BIGINT NULL,
            @p_transfer_time       DATETIME2(6) NULL,
            @p_transfer_type_id    BIGINT NULL,
            @p_min_allowed_balance BIGINT NULL
            
AS

BEGIN

	SET NOCOUNT ON
	
	DECLARE @v_txfr_id   BIGINT
	DECLARE @v_bal_after BIGINT
	DECLARE @errormessage NVARCHAR(2048)
	DECLARE @v_maturity_time DATETIME2(6) = NULL
	DECLARE @v_maturity_model TINYINT
	DECLARE @v_maturity_hours BIGINT
	DECLARE @v_account_type_id BIGINT
	DECLARE @v_whole_days SMALLINT
	DECLARE @v_event_type_id BIGINT
	DECLARE @v_transaction_time DATETIME2(6)

    SELECT	@v_txfr_id = NEXT VALUE FOR dbo.transfer_sequence

	-- Extended to retrieve the maturity model in order to set maturity_time accordingly

    UPDATE acc_accounts
       SET balance_minor_units = balance_minor_units + @p_amount_minor_units, @v_maturity_model = maturity_model, @v_account_type_id = account_type_id, @v_maturity_hours = maturity_hours
     WHERE account_id = @p_account_id
    
	SELECT @v_bal_after = MAX(balance_minor_units) FROM acc_accounts WHERE account_id = @p_account_id;

	-- This manipulation of maturity time only applies to the trading account and sales

	SELECT @v_event_type_id = EVENT_TYPE_ID, @v_transaction_time = TRANSACTION_TIME FROM ACC_TRANSACTIONS WHERE TRANSACTION_ID = @p_transaction_id

	IF @v_account_type_id  = 0 AND @v_event_type_id = 0
	BEGIN

		-- Set maturity_model to 1 for all Acquired.com and FPMS transactions --
		-- maturity model 0 is continuous settlement, 1 is midnight to midnight

		IF @v_maturity_model = 0
		BEGIN
		   SELECT @v_maturity_model = 1
		   FROM ACC_TRANSACTIONS tx inner join ACC_ACCOUNT_GROUPS ag on tx.ACCOUNT_GROUP_ID = ag.ACCOUNT_GROUP_ID
			INNER join ACC_OWNERS ao on ao.OWNER_ID = ag.OWNER_ID
			WHERE ao.CRM_ID in ('833','1034')
			AND tx.TRANSACTION_ID = @p_transaction_id
		END

		IF @v_maturity_model = 1
			BEGIN
				SET @v_whole_days = (@v_maturity_hours - 1) / 24
				SELECT @v_maturity_time = CAST(CAST(DATEADD(DAY,1,@v_transaction_time) AS DATE) AS DATETIME2)
				IF @v_whole_days > 0
				BEGIN
					SELECT @v_maturity_time = DATEADD(DAY,@v_whole_days,@v_maturity_time)
				END
			END

	END
        -- Couldn't update balance - have to suspect account isn't present.
    IF @v_bal_after IS NULL 
		BEGIN
			SET @errormessage = 'Unable to find account id ' + CAST(@p_account_id AS VARCHAR(10));

			THROW 50209, @errormessage, 1;
		END
    
        -- Transfer took balance too low...
    IF @p_min_allowed_balance IS NOT NULL AND @v_bal_after < @p_min_allowed_balance 
		BEGIN
			SET @errormessage = 'Insufficient funds available on account id ' + CAST(@p_account_id AS VARCHAR(25)) + 
								' (min_allowed ' + CAST(@p_min_allowed_balance AS VARCHAR(25)) +
								' , balance ' + CAST(@v_bal_after + @P_amount_minor_units AS VARCHAR(25)) +
								' for transfer of ' + @p_amount_minor_units;

			THROW 50210, @errormessage, 1;

		END

		IF @v_maturity_time is NULL
		BEGIN
			SET @v_maturity_time = @p_maturity_date
		END

	    INSERT INTO acc_transfers ( transfer_id,
                                account_id,
                                amount_minor_units,
                                balance_after_minor_units,
                                batch_id,
                                transaction_id,
                                transfer_method_id,
                                transfer_time,
                                transfer_type_id,
                                maturity_time
                              )
         VALUES ( @v_txfr_id,
                  @p_account_id,
                  @p_amount_minor_units,
                  @v_bal_after,
                  NULL,
                  @p_transaction_id,
                  @p_transfer_method_id,
                  @p_transfer_time,
                  @p_transfer_type_id,
                  @v_maturity_time
                );

    RETURN @v_txfr_id;
END
GO
