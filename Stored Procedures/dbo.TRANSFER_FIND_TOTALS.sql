SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[TRANSFER_FIND_TOTALS]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_from_date DATETIME2(6),
    @p_account_group_id NUMERIC,
    @p_to_date DATETIME2(6)
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT tt.TRANSFER_TYPE_ID AS transferTypeId,
           COUNT_BIG(*) AS quantity,
           SUM(tr.AMOUNT_MINOR_UNITS) AS totalMinorUnits,
           ag.CURRENCY_CODE_ALPHA3 AS currency
    FROM dbo.ACC_TRANSFERS AS tr
        INNER JOIN dbo.ACC_TRANSACTIONS AS t
            ON t.TRANSACTION_ID = tr.TRANSACTION_ID
        INNER JOIN dbo.ACC_ACCOUNT_GROUPS AS ag
            ON ag.ACCOUNT_GROUP_ID = t.ACCOUNT_GROUP_ID
        INNER JOIN dbo.ACC_TRANSFER_TYPES AS tt
            ON tt.TRANSFER_TYPE_ID = tr.TRANSFER_TYPE_ID
    WHERE tr.TRANSFER_TIME
          BETWEEN @p_from_date AND @p_to_date
          AND ag.ACCOUNT_GROUP_ID = @p_account_group_id
          AND tr.AMOUNT_MINOR_UNITS > 0
    GROUP BY ag.CURRENCY_CODE_ALPHA3,
             tt.TRANSFER_TYPE_ID;

    RETURN;

END;
GO
