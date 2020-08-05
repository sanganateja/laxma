SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[TRANSFER_FIND_MAX_BY_DATE]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_end_date DATETIME2(6),
    @p_id NUMERIC /* ID*/
AS
BEGIN

    SET @cv_1 = NULL;


    /*
      *    Get the lates transfer for an account before a date
      *    Note this is slightly different to the above date constraints as it is inclusive of the endDate.
      *    Uses ID to determine max (latest) transfer as it is possible for multiple transfers to happen in the same millisecond.
      */
    SELECT t.TRANSFER_ID,
           t.TRANSFER_TIME,
           t.ACCOUNT_ID,
           t.TRANSFER_TYPE_ID,
           t.AMOUNT_MINOR_UNITS,
           t.BALANCE_AFTER_MINOR_UNITS,
           t.BATCH_ID,
           t.TRANSACTION_ID,
           t.TRANSFER_METHOD_ID,
           t.MATURITY_TIME,
           t.MATURITY_TRANSACTION_ID
    FROM dbo.ACC_TRANSFERS AS t
    WHERE t.TRANSFER_ID IN
          (
              SELECT MAX(m.TRANSFER_ID) AS expr
              FROM dbo.ACC_TRANSFERS AS m
              WHERE m.ACCOUNT_ID = @p_id
                    AND m.TRANSFER_TIME <= @p_end_date
          );

    RETURN;

END;
GO
