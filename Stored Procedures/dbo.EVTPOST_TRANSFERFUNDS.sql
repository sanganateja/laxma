SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[EVTPOST_TRANSFERFUNDS]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_transaction_id NUMERIC,
    @p_from_account_id NUMERIC,
    @p_from_maturity_date DATETIME2(6),
    @p_from_min_allowed_balance NUMERIC,
    @p_to_account_id NUMERIC,
    @p_to_maturity_date DATETIME2(6),
    @p_amount_minor_units NUMERIC,
    @p_transfer_method_id NUMERIC,
    @p_transfer_time DATETIME2(6),
    @p_transfer_type_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    DECLARE @v_from_txfr_id NUMERIC(18, 0),
            @v_to_txfr_id NUMERIC(18, 0),
            @v_transaction_id NUMERIC(18, 0),
            @v_amount_minor_units_negative NUMERIC;

    IF @p_amount_minor_units <= 0
    BEGIN
        /* Allow zero values only for following transfer types*/
        IF @p_transfer_type_id NOT IN ( 2, 14, 15, 68, 69, 70, 71, 86, 87, 88, 89 )
        BEGIN

            /* Postive amount required.*/
            DECLARE @db_raise_application_error_message NVARCHAR(4000);

            SET @db_raise_application_error_message
                = N'ORA' + CAST(-20220 AS NVARCHAR) + N': '
                  + ('Transfer amount must be positive, amount = '
                     + ISNULL(CAST(@p_amount_minor_units AS NVARCHAR(2000)), '')
                    );

            RAISERROR(59998, 16, 1, @db_raise_application_error_message);

        END;
    END;

    SELECT @v_transaction_id = MAX(txn.TRANSACTION_ID)
    FROM dbo.ACC_TRANSACTIONS AS txn
        JOIN dbo.ACC_ACCOUNTS AS from_acc
            ON from_acc.ACCOUNT_GROUP_ID = txn.ACCOUNT_GROUP_ID
               AND from_acc.ACCOUNT_ID = @p_from_account_id
        JOIN dbo.ACC_ACCOUNTS AS to_acc
            ON to_acc.ACCOUNT_GROUP_ID = txn.ACCOUNT_GROUP_ID
               AND to_acc.ACCOUNT_ID = @p_to_account_id
    WHERE txn.TRANSACTION_ID = @p_transaction_id;

    IF @v_transaction_id IS NULL
    BEGIN


        /*
            *    Transaction, to and from accounts disagree, somehow, on the account groups they
            *    are part of.
            */
        DECLARE @db_raise_application_error_message$2 NVARCHAR(4000);

        SET @db_raise_application_error_message$2
            = N'ORA' + CAST(-20221 AS NVARCHAR) + N': '
              + ('Txn/ToAcc/FromAcc inconsitency detected, txn: '
                 + ISNULL(CAST(@p_transaction_id AS NVARCHAR(2000)), '') + ', from_acc: '
                 + ISNULL(CAST(@p_from_account_id AS NVARCHAR(2000)), '') + ', to_acc: '
                 + ISNULL(CAST(@p_to_account_id AS NVARCHAR(2000)), '')
                );

        RAISERROR(59998, 16, 1, @db_raise_application_error_message$2);

    END;


    SET @v_amount_minor_units_negative = @p_amount_minor_units * -1.0;
    /* Take the funds out...*/
    EXEC @v_from_txfr_id = dbo.EVTPOST_APPLYTRANSFER$IMPL @p_transaction_id = @p_transaction_id,
                                                          @p_account_id = @p_from_account_id,
                                                          @p_amount_minor_units = @v_amount_minor_units_negative,
                                                          @p_maturity_date = @p_from_maturity_date,
                                                          @p_transfer_method_id = @p_transfer_method_id,
                                                          @p_transfer_time = @p_transfer_time,
                                                          @p_transfer_type_id = @p_transfer_type_id,
                                                          @p_min_allowed_balance = @p_from_min_allowed_balance;

    /* .. and put them were they belong.*/
    EXEC @v_to_txfr_id = dbo.EVTPOST_APPLYTRANSFER$IMPL @p_transaction_id = @p_transaction_id,
                                                        @p_account_id = @p_to_account_id,
                                                        @p_amount_minor_units = @p_amount_minor_units,
                                                        @p_maturity_date = @p_to_maturity_date,
                                                        @p_transfer_method_id = @p_transfer_method_id,
                                                        @p_transfer_time = @p_transfer_time,
                                                        @p_transfer_type_id = @p_transfer_type_id,
                                                        @p_min_allowed_balance = NULL;

	-- New code to update the balance in core if we're transfering from the Current Account (Business Account) to External
	DECLARE @AccountGroupID bigint, @FromAccountType bigint, @ToAccountType bigint, @OwnerId bigint

	SELECT @AccountGroupID=ACCOUNT_GROUP_ID, @FromAccountType=ACCOUNT_TYPE_ID 
	FROM ACC_ACCOUNTS WITH (NOLOCK) WHERE ACCOUNT_ID=@p_from_account_id

	SELECT @ToAccountType=ACCOUNT_TYPE_ID 
	FROM ACC_ACCOUNTS WITH (NOLOCK) WHERE ACCOUNT_ID=@p_to_account_id

	IF @FromAccountType=9 and @ToAccountType=5 --and @p_transfer_type_id in (27,28,37,46)
	BEGIN
		SELECT @OwnerId=OWNER_ID FROM ACC_ACCOUNT_GROUPS WITH (NOLOCK) WHERE ACCOUNT_GROUP_ID=@AccountGroupID

		exec spSendToCore @OwnerId
	END

    SELECT ACC_TRANSFERS.TRANSFER_ID,
           ACC_TRANSFERS.TRANSFER_TIME,
           ACC_TRANSFERS.ACCOUNT_ID,
           ACC_TRANSFERS.TRANSFER_TYPE_ID,
           ACC_TRANSFERS.AMOUNT_MINOR_UNITS,
           ACC_TRANSFERS.BALANCE_AFTER_MINOR_UNITS,
           ACC_TRANSFERS.BATCH_ID,
           ACC_TRANSFERS.TRANSACTION_ID,
           ACC_TRANSFERS.TRANSFER_METHOD_ID,
           ACC_TRANSFERS.MATURITY_TIME,
           ACC_TRANSFERS.MATURITY_TRANSACTION_ID
    FROM dbo.ACC_TRANSFERS WITH (NOLOCK)
    WHERE ACC_TRANSFERS.TRANSFER_ID IN ( @v_to_txfr_id, @v_from_txfr_id )
    ORDER BY ACC_TRANSFERS.TRANSFER_ID;

END
GO
