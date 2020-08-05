SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_future_queued_payment] @p_recordset VARCHAR(2000) OUTPUT
AS
BEGIN

    SET @p_recordset = NULL;

    SELECT o.EXTERNAL_REF AS [Business ID],
           o.OWNER_NAME AS [Business Name],
           CASE
               WHEN ISNUMERIC(pm.PAYEE_ACCOUNT_ID) = 0 THEN
                   pm.PAYEE_ACCOUNT_ID
               ELSE
                   FORMAT(CAST(pm.PAYEE_ACCOUNT_ID AS INT), '00000000#')
           END AS [Account Number/IBAN],
           ag.CURRENCY_CODE_ALPHA3 AS Currency,
           pm.PAYMENT_TYPE AS [Payment type],
           pm.AMOUNT_MINOR_UNITS AS [Payment amount],
           pm.PAYEE_NAME AS [Beneficiary Name],
           pm.MESSAGE_TIMESTAMP AS [Received date],
           pm.SETTLEMENT_DATE AS [Execution date]
    FROM dbo.ACC_PAYMENT_MESSAGES_IN_QUEUE AS pm
        JOIN dbo.ACC_ACCOUNT_GROUPS AS ag
            ON (
                   pm.PAYEE_ACCOUNT_ID_TYPE = 'A'
                   AND pm.PAYEE_ACCOUNT_ID = ag.ACCOUNT_NUMBER
                   OR pm.PAYEE_ACCOUNT_ID_TYPE = 'I'
                      AND SUBSTRING(pm.PAYEE_ACCOUNT_ID, 14, LEN(pm.PAYEE_ACCOUNT_ID)) = ag.ACCOUNT_NUMBER
               )
        JOIN dbo.ACC_OWNERS AS o
            ON (
                   o.OWNER_ID = ag.OWNER_ID
                   AND ag.ACCOUNT_GROUP_TYPE IN ( 'C', 'D' )
               )
    WHERE pm.SETTLEMENT_DATE >= SYSDATETIME();

END;
GO
