SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_acc_remit_to_merch]
    @p_recordset VARCHAR(2000) OUTPUT,
    @p_startdate DATETIME2(6),
    @p_enddate DATETIME2(6),
    @p_crm_id NVARCHAR(2000) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @maturitydate DATETIME;

    SET @p_recordset = NULL;

    SELECT @maturitydate = MATURITY_DATE
    FROM dbo.VIEW_MATURITY_DATE;

    SELECT o.EXTERNAL_REF AS [Business Id],
           CASE
               WHEN LEN(ag.ACCOUNT_NUMBER) < 8 THEN
                   RIGHT('00000000' + CAST(ag.ACCOUNT_NUMBER AS VARCHAR(8)), 8)
               ELSE
                   ag.ACCOUNT_NUMBER
           END AS [Account Number],
           CAST(b.MATURED_TIME AS DATE) AS Date,
           ag.CURRENCY_CODE_ALPHA3 AS Currency,
           ISNULL(SUM(   CASE
                             WHEN a.ACCOUNT_TYPE_ID = 0
                                  AND b.MATURITY_DATE <= @maturitydate
                                  AND t.AMOUNT_MINOR_UNITS < 0 THEN
                                 -t.AMOUNT_MINOR_UNITS
                             ELSE
                                 0
                         END
                     ),
                  0
                 ) AS Amount
    FROM dbo.ACC_BATCHES AS b
        JOIN dbo.ACC_ACCOUNTS AS a
            ON b.ACCOUNT_ID = a.ACCOUNT_ID
               AND a.ACCOUNT_TYPE_ID IN ( 0, 2, 3 )
        JOIN dbo.ACC_ACCOUNT_GROUPS AS ag
            ON a.ACCOUNT_GROUP_ID = ag.ACCOUNT_GROUP_ID
        JOIN dbo.ACC_OWNERS AS o
            ON ag.OWNER_ID = o.OWNER_ID
               AND ag.ACCOUNT_GROUP_TYPE = 'A'
               AND (o.CRM_ID = @p_crm_id)
        LEFT OUTER JOIN dbo.ACC_TRANSFERS AS t
            ON b.BATCH_ID = t.BATCH_ID
    WHERE b.MATURED_TIME IS NOT NULL
          AND t.TRANSFER_TYPE_ID = 2 /* Remit_Trading*/
          AND ag.PAYMENT_ACCOUNT_GROUP_ID IS NOT NULL
          AND b.MATURED_TIME
          BETWEEN @p_startdate AND @p_enddate
    GROUP BY o.EXTERNAL_REF,
             o.OWNER_NAME,
             ag.CURRENCY_CODE_ALPHA3,
             ag.ACCOUNT_NUMBER,
             CAST(b.MATURED_TIME AS DATE)
    HAVING ISNULL(SUM(   CASE
                             WHEN a.ACCOUNT_TYPE_ID = 0
                                  AND b.MATURITY_DATE <= @maturitydate
                                  AND t.AMOUNT_MINOR_UNITS < 0 THEN
                                 -t.AMOUNT_MINOR_UNITS
                             ELSE
                                 0
                         END
                     ),
                  0
                 ) != 0
    ORDER BY CAST(b.MATURED_TIME AS DATE),
             o.EXTERNAL_REF,
             ag.ACCOUNT_NUMBER;

END;
GO
