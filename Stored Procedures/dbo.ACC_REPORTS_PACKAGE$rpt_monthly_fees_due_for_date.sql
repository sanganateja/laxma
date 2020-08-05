SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_monthly_fees_due_for_date]
    @p_recordset VARCHAR(2000) OUTPUT,
    @p_duedate DATETIME2(6)
AS
BEGIN

    SET @p_recordset = NULL;

    SELECT a.EXTERNAL_REF AS BusinessId,
           a.OWNER_NAME AS BusinessName,
           a.description AS PricingTier,
           a.monthly_fee AS MonthlyFee,
           a.NEXT_RESET_DATE AS DueDate,
           a.outstanding_count AS TotalOutstandingCount,
           a.monthly_fee * a.outstanding_count AS TotalOutstandingAmount
    FROM
    (
        SELECT o.EXTERNAL_REF,
               o.OWNER_NAME,
               'CUSTOM' AS description,
               mf.AMOUNT_MINOR_UNITS / 100.0 AS monthly_fee,
               o.NEXT_RESET_DATE,
               DATEDIFF(MONTH, @p_duedate, o.NEXT_RESET_DATE) + 1 AS outstanding_count
        FROM dbo.ACC_OWNERS AS o
            JOIN dbo.ACC_ACCOUNT_GROUPS AS ag
                ON ag.OWNER_ID = o.OWNER_ID
            JOIN dbo.ACC_MONTHLY_FEES AS mf
                ON ag.OWNER_ID = mf.OWNER_ID
                   AND mf.CURRENCY_CODE_ALPHA3 = 'GBP'
        WHERE o.NEXT_RESET_DATE < @p_duedate
    ) AS a
    ORDER BY a.NEXT_RESET_DATE,
             a.EXTERNAL_REF;

END;
GO
