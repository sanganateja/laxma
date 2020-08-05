SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE     PROCEDURE  [dbo].[EVTPOST_OBTAINBATCH$IMPL]
	( @p_account_id    NUMERIC,
	  @p_maturity_date DATETIME2(6),
          @return_value_argument FLOAT(53)  OUTPUT
        ) 
AS

BEGIN
	DECLARE @v_batch_id BIGINT,
    @v_matured_time DATETIME2(6),
    @v_maturity_date DATETIME2(6),
	@rowcount BIGINT,
	@errormsg NVARCHAR(100);

    SET @v_batch_id = NULL;

    IF @p_maturity_date IS NOT NULL
	BEGIN
		-- Want the batch to mature midnight on the required maturity date.        
		SET @v_maturity_date = @p_maturity_date;

		SELECT @v_batch_id = batch_id,
               @v_matured_time = matured_time
			FROM acc_batches b
			WHERE b.account_id = @p_account_id
				AND b.maturity_date = @v_maturity_date;

		SELECT @rowcount = @@ROWCOUNT

		IF @v_matured_time IS NOT NULL
		BEGIN
			SELECT @errormsg = 'Batch has already been matured, batch id = ' + CAST(@v_batch_id AS VARCHAR(18));
			THROW 50230, @errormsg, 1;
		END

		IF @rowcount = 0 
		BEGIN
			-- New batch required...
            SELECT @v_batch_id = NEXT VALUE FOR dbo.HIBERNATE_SEQUENCE
    
            -- As the account should be locked, then we should be the only ones here,
            -- otherwise we'd need to protect against multiple simulateous attempts...
            -- (like aggregated_transaction_record).
            INSERT INTO acc_batches ( batch_id,
                                      account_id,
                                      maturity_date,
                                      matured_time,
                                      hold,
                                      payment_transaction_id
                                     )
                 VALUES ( @v_batch_id,
                          @p_account_id,
                          @v_maturity_date,
                          NULL,
                          'N',
                          NULL
                         );		  
		END;
    END;
    RETURN @v_batch_id;
END
GO
