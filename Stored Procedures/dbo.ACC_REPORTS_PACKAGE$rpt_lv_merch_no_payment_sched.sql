SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_lv_merch_no_payment_sched] @p_recordset VARCHAR(2000) OUTPUT
AS
BEGIN

    SET @p_recordset = NULL;

    SELECT o.EXTERNAL_REF AS [Business ID],
           o.OWNER_NAME AS [Business Name],
           FORMAT(ag.ACCOUNT_NUMBER, '00000000#') AS [Account Number],
           ag.ACCOUNT_GROUP_NAME AS [Account Group Name],
           ag.CURRENCY_CODE_ALPHA3 AS Currency
    FROM dbo.ACC_OWNERS AS o
        JOIN dbo.ACC_ACCOUNT_GROUPS AS ag
            ON ag.OWNER_ID = o.OWNER_ID
               AND ag.ACCOUNT_GROUP_TYPE IN ( 'A' )
    WHERE o.MERCH_FLAGS = 1
          AND ag.GROUP_STATUS IN ( 'L', '+', 'P' )
          AND
          (
              ag.PAYMENT_ACCOUNT_GROUP_ID IS NULL
              OR ag.PAYMENT_ACCOUNT_GROUP_ID NOT IN
                 (
                     SELECT ACC_BANK_STANDING_ORDERS.ACCOUNT_GROUP_ID
                     FROM dbo.ACC_BANK_STANDING_ORDERS
                     WHERE ACC_BANK_STANDING_ORDERS.FREQUENCY_UNITS = 'R'
                 )
          );

END;
GO
