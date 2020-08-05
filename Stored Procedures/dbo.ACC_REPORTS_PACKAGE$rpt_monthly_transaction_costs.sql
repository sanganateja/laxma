SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_monthly_transaction_costs] @p_recordset VARCHAR(2000) OUTPUT
AS
BEGIN

    SET @p_recordset = NULL;

    DECLARE @v_startdate DATETIME2(6),
            @v_enddate DATETIME2(6);

    SELECT @v_enddate = DATEFROMPARTS(DATEPART(YEAR, SYSDATETIME()), DATEPART(MONTH, SYSDATETIME()), 01); /* First day of this month*/

    SELECT @v_startdate = DATEADD(MONTH, -1, @v_enddate); /* Go back a month*/

    SELECT sale.EXTERNAL_REF,
           CAST(msc.AMOUNT_MINOR_UNITS AS FLOAT(53)) / POWER(10, cur.DECIMAL_PLACES) AS AMOUNT_MINOR_UNITS,
           ag.CURRENCY_CODE_ALPHA3
    FROM dbo.ACC_TRANSACTIONS AS msc
        JOIN dbo.ACC_ACCOUNT_GROUPS AS ag
            JOIN dbo.ACC_CURRENCIES AS cur
                ON cur.CURRENCY_CODE_ALPHA3 = ag.CURRENCY_CODE_ALPHA3
            ON ag.ACCOUNT_GROUP_ID = msc.ACCOUNT_GROUP_ID
        JOIN dbo.ACC_TRANSACTIONS AS sale
            ON msc.TXN_FIRST_ID = sale.TRANSACTION_ID
    WHERE msc.EVENT_TYPE_ID = 26
          AND msc.TRANSACTION_TIME < @v_enddate
          AND msc.TRANSACTION_TIME >= @v_startdate;

END;
GO
