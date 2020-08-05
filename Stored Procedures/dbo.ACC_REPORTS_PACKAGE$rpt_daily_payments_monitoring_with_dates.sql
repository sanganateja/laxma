SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_daily_payments_monitoring_with_dates]
    @p_recordset VARCHAR(2000) OUTPUT,
    @p_start_date DATETIME2(6) NULL,
    @p_end_date DATETIME2(6) NULL
AS
BEGIN

    SET @p_recordset = NULL;

    /* Select and check all payers for income payments.*/
    /*  */
    SELECT bu.OWNER_NAME AS [Business Name],
           bu.EXTERNAL_REF AS [Business ID],
           CASE
               WHEN ISNUMERIC(pin.PAYER_ACCOUNT_ID) = 0 THEN
                   pin.PAYER_ACCOUNT_ID
               ELSE
                   FORMAT(CAST(pin.PAYER_ACCOUNT_ID AS INT), '00000000#')
           END AS [Account number],
           pin.CURRENCY_CODE_ALPHA3 AS Currency,
           CAST(pin.AMOUNT_MINOR_UNITS AS FLOAT(53)) / POWER(10, cur.DECIMAL_PLACES) AS [Value of payment/credit],
           CONVERT(VARCHAR(2000), pin.MESSAGE_TIMESTAMP, 106) AS [Date of receipt/credit],
           CONVERT(NVARCHAR(8), pin.MESSAGE_TIMESTAMP, 8) AS [Time of receipt/credit],
           pin.PAYER_AGENT_ID AS [Sending or receiving BIC code],
           co.COUNTRY_NAME AS [Sending or receiving Country]
    FROM dbo.ACC_PAYMENT_MESSAGES_IN AS pin
        JOIN dbo.ACC_COUNTRIES AS co
            ON co.COUNTRY_CODE_ALPHA2 = dbo.ACC_REPORTS_PACKAGE$rpt_define_country_code(
                                                                                           pin.PAYMENT_TYPE,
                                                                                           pin.PAYER_ACCOUNT_ID,
                                                                                           pin.PAYER_ACCOUNT_ID_TYPE,
                                                                                           pin.PAYER_AGENT_ID,
                                                                                           pin.PAYER_AGENT_ID_TYPE
                                                                                       )
        JOIN dbo.ACC_COUNTRY_MONITORS AS pm
            ON pm.COUNTRY_ID = co.COUNTRY_ID
        JOIN dbo.ACC_CURRENCIES AS cur
            ON cur.CURRENCY_CODE_ALPHA3 = pin.CURRENCY_CODE_ALPHA3
        JOIN dbo.ACC_ACCOUNT_GROUPS AS ag
            ON (
                   pin.PAYEE_ACCOUNT_ID_TYPE = 'A'
                   AND pin.PAYEE_ACCOUNT_ID = ag.ACCOUNT_NUMBER
               )
               OR
               (
                   pin.PAYEE_ACCOUNT_ID_TYPE = 'I'
                   AND SUBSTRING(pin.PAYEE_ACCOUNT_ID, 14, LEN(pin.PAYEE_ACCOUNT_ID)) = ag.ACCOUNT_NUMBER
               )
        JOIN dbo.ACC_OWNERS AS bu
            ON bu.OWNER_ID = ag.OWNER_ID
    WHERE pin.MESSAGE_TIMESTAMP
    BETWEEN @p_start_date AND @p_end_date
    UNION ALL
    /* Select and check all payees for outcome payments.*/
    SELECT bu.OWNER_NAME AS [Business Name],
           bu.EXTERNAL_REF AS [Business ID],
           CASE
               WHEN ISNUMERIC(pout.PAYER_ACCOUNT_ID) = 0 THEN
                   pout.PAYER_ACCOUNT_ID
               ELSE
                   FORMAT(CAST(pout.PAYER_ACCOUNT_ID AS INT), '00000000#')
           END AS [Account number],
           pout.CURRENCY_CODE_ALPHA3 AS Currency,
           CAST(pout.AMOUNT_MINOR_UNITS AS FLOAT(53)) / POWER(10, cur.DECIMAL_PLACES) AS [Value of payment/credit],
           CONVERT(VARCHAR(10), pout.MESSAGE_TIMESTAMP, 103) AS [Date of receipt/credit],
           CONVERT(NVARCHAR(8), pout.MESSAGE_TIMESTAMP, 8) AS [Time of receipt/credit],
           pout.PAYEE_AGENT_ID AS [Sending or receiving BIC code],
           co.COUNTRY_NAME AS [Sending or receiving Country]
    FROM dbo.ACC_PAYMENT_MESSAGES_OUT AS pout
        JOIN dbo.ACC_COUNTRIES AS co
            ON co.COUNTRY_CODE_ALPHA2 = dbo.ACC_REPORTS_PACKAGE$rpt_define_country_code(
                                                                                           pout.PAYMENT_TYPE,
                                                                                           pout.PAYEE_ACCOUNT_ID,
                                                                                           pout.PAYEE_ACCOUNT_ID_TYPE,
                                                                                           pout.PAYEE_AGENT_ID,
                                                                                           pout.PAYEE_AGENT_ID_TYPE
                                                                                       )
        JOIN dbo.ACC_COUNTRY_MONITORS AS pm
            ON pm.COUNTRY_ID = co.COUNTRY_ID
        JOIN dbo.ACC_CURRENCIES AS cur
            ON cur.CURRENCY_CODE_ALPHA3 = pout.CURRENCY_CODE_ALPHA3
        JOIN dbo.ACC_ACCOUNT_GROUPS AS ag
            ON (
                   pout.PAYER_ACCOUNT_ID_TYPE = 'A'
                   AND pout.PAYER_ACCOUNT_ID = ag.ACCOUNT_NUMBER
               )
               OR
               (
                   pout.PAYER_ACCOUNT_ID_TYPE = 'I'
                   AND SUBSTRING(pout.PAYEE_ACCOUNT_ID, 14, LEN(pout.PAYEE_ACCOUNT_ID)) = ag.ACCOUNT_NUMBER
               )
        JOIN dbo.ACC_OWNERS AS bu
            ON bu.OWNER_ID = ag.OWNER_ID
    WHERE pout.MESSAGE_TIMESTAMP
    BETWEEN @p_start_date AND @p_end_date;
    
END;
GO
