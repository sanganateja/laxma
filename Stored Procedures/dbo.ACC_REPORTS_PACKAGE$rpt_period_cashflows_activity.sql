SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_period_cashflows_activity]
(
    @p_recordset VARCHAR(2000) OUTPUT,
    @p_enddate DATE,
    @p_ownerid BIGINT
)
AS
BEGIN

    -- We need dynamic sql because the pivot table functionality has to have the columns defined during the parse stage,
    -- and there is no way to define the aliases to include the previous 12 month names without dynamic sql.
    --
    -- NOTE, The outgoing count and payment_amounts are negative on purpose - a requirement from Nick Playford -
    --       to enable conditional formatting in excel
    --

    SET NOCOUNT ON;
    SET @p_recordset = NULL;

    DECLARE @periodenddate DATE;
    DECLARE @startdate DATE;
    DECLARE @pivot VARCHAR(2000) = '';
    DECLARE @columns VARCHAR(max) = '';
    DECLARE @tsql NVARCHAR(max);
    DECLARE @ParmDefinition NVARCHAR(1000);


    -- If we have passed in an enddate of the 1st of the month, we leave it as it is -
    -- i.e. we are processing for the previous 12 months starting from the last complete month.
    -- If we have passed in an enddate of any other day of the month, we have to include the partial month as
    -- the first of the months to report on.

    SET @periodenddate = CASE
                             WHEN DATEPART(DAY, @p_enddate) = 01 THEN
                                 @p_enddate
                             ELSE
                                 DATEADD(DAY, 1, EOMONTH(@p_enddate))
                         END;
    SET @startdate = DATEADD(MONTH, -12, @periodenddate);
    SET @ParmDefinition = N'@periodenddate DATE, @startdate DATE, @p_enddate DATE,@p_ownerid BIGINT';



    --This genrates the list of column names for the previous 12 months including the necessary formatting to 
    --present the currencies in the correct format

    WITH x
    AS (SELECT @startdate fecha
        UNION ALL
        SELECT DATEADD(m, 1, fecha)
        FROM x
        WHERE fecha < @periodenddate)
    SELECT @pivot = @pivot + '[' + FORMAT(fecha, 'MMM_yyyy') + '_' + c.col + '],',
           @columns
               = @columns
                 + CASE
                       WHEN c.col LIKE '%COUNT' THEN
                           'CAST([' + FORMAT(fecha, 'MMM_yyyy') + '_' + c.col + '] AS INT) AS ['
                           + FORMAT(fecha, 'MMM_yyyy') + '_' + c.col + '],'
                       ELSE
                           'LEFT(CAST([' + FORMAT(fecha, 'MMM_yyyy') + '_' + c.col
                           + ']AS VARCHAR(1000)),CHARINDEX(''.'',[' + FORMAT(fecha, 'MMM_yyyy') + '_' + c.col
                           + ']) + CASE WHEN DECIMAL_PLACES > 0 THEN DECIMAL_PLACES ELSE -1 END ) AS ['
                           + FORMAT(fecha, 'MMM_yyyy') + '_' + c.col + '],'
                   END
    FROM x
        CROSS JOIN
        (
            SELECT 'out_payment_count' AS col
            UNION ALL
            SELECT 'out_payment_amount' AS col
            UNION ALL
            SELECT 'in_payment_count'
            UNION ALL
            SELECT 'in_payment_amount'
        ) c
    WHERE x.fecha < @periodenddate
    ORDER BY fecha DESC;


    --removes the last comma from the results generated above	
    SET @pivot = LEFT(@pivot, LEN(@pivot) - 1);
    SET @columns = LEFT(@columns, LEN(@columns) - 1);

    --Construct the dynamic SQL for the vairable generated above

    SELECT @tsql
        = N'
		
		WITH pivot_data AS (
		  SELECT     o.external_ref AS business_id,
		             o.owner_name AS business_name,
		             ag.currency_code_alpha3 AS currency,
		             FORMAT(DATEADD(MONTH,-1*DATEDIFF(MONTH, tr.transfer_time, @periodenddate),@periodenddate),''MMM_yyyy'') AS period,
					 CASE WHEN (tr.transfer_type_id IN (36, 46)) THEN tr.amount_minor_units / POWER(10.0, c.decimal_places) ELSE 0.0 END AS out_payment_amount,
		             CASE WHEN (tr.transfer_type_id = 38) THEN tr.amount_minor_units / POWER(10.0, c.decimal_places) ELSE 0.0 END AS in_payment_amount,
		             CASE WHEN (tr.transfer_type_id IN (36, 46)) THEN -1 ELSE 0 END AS out_payment_count,
		             CASE WHEN (tr.transfer_type_id = 38) THEN 1 ELSE 0 END AS in_payment_count
		     FROM acc_transfers tr   
		     JOIN acc_accounts ac ON ac.account_id = tr.account_id
		     JOIN acc_account_groups ag ON ag.account_group_id = ac.account_group_id and ag.account_group_type in (''C'', ''D'')
		     JOIN acc_currencies c ON ag.currency_code_alpha3 = c.currency_code_alpha3
		     JOIN acc_owners o ON o.owner_id = ag.owner_id
		     WHERE tr.transfer_type_id in ( 36, 38, 46 ) /* Payments in and out (including deprecated payment requests)*/
		     AND ac.account_type_id = 9  /* Current account*/
		     AND tr.transfer_time >= @startdate AND tr.transfer_time < @p_enddate
		     AND (o.owner_id = @p_ownerid OR @p_ownerid = 0)
		     )
		
			 ,last_transaction_data AS (
		     SELECT  o.external_ref AS business_id,
		             o.owner_name AS business_name,
		             ag.currency_code_alpha3 AS currency,
		             CAST(MIN(tr.transfer_time) AS DATE) AS first_transaction_date,
		             CAST(MAX(tr.transfer_time) AS DATE) AS last_transaction_date,
		             MIN(o.cra_name) AS cra_name,
		             MIN(pa.partner_name) AS partner_name,
					 c.DECIMAL_PLACES
		     FROM acc_transfers tr   
		     JOIN acc_accounts ac ON ac.account_id = tr.account_id
		     JOIN acc_account_groups ag ON ag.account_group_id = ac.account_group_id and ag.account_group_type in (''C'', ''D'')
		     JOIN acc_currencies c ON ag.currency_code_alpha3 = c.currency_code_alpha3
		     JOIN acc_owners o ON o.owner_id = ag.owner_id
		     LEFT JOIN acc_partners pa ON o.crm_id = pa.crm_id
		     WHERE tr.transfer_type_id in ( 36, 38, 46 ) /* Payments in and out (including deprecated payment requests)*/
		     AND ac.account_type_id = 9  /* Current account*/
		     AND tr.transfer_time < @p_enddate
		     AND (o.owner_id = @p_ownerid OR @p_ownerid = 0)
		     GROUP BY o.external_ref, o.owner_name, ag.currency_code_alpha3, c.DECIMAL_PLACES
		     )
		SELECT	piv.business_id, business_name,currency,first_transaction_date,last_transaction_date,cra_name,'
          + @columns
          + N'
		FROM	(
		
				SELECT business_id, business_name, currency, term +''_''+ col AS col, value , DECIMAL_PLACES, first_transaction_date, last_transaction_date, cra_name
				FROM(
					SELECT p.business_id,p.business_name, p.period AS term, p.currency, t.first_transaction_date, t.last_transaction_date, t.cra_name, t.decimal_places, CAST(SUM(out_payment_count) AS DECIMAL(30,5)) AS out_payment_count, CAST(SUM(p.out_payment_amount) AS DECIMAL(30,5)) AS out_payment_amount, CAST(SUM(in_payment_count) AS DECIMAL(30,5)) AS in_payment_count, CAST(SUM(p.in_payment_amount) AS DECIMAL(30,5)) AS in_payment_amount
					 FROM pivot_data p
					 JOIN last_transaction_data t
						ON t.business_id = p.business_id
						AND t.currency = p.currency
					GROUP BY p.business_id,p.business_name, p.period, p.currency, t.first_transaction_date, t.last_transaction_date, t.cra_name, t.DECIMAL_PLACES) rt
				UNPIVOT (value FOR col IN (out_payment_count,out_payment_amount,in_payment_count,in_payment_amount))unpiv) tp
		PIVOT (SUM(value) FOR col IN (' + @pivot + N'))piv';


    --Execute the SQL
    EXECUTE sp_executesql @tsql,
                          @ParmDefinition,
                          @periodenddate = @periodenddate,
                          @startdate = @startdate,
                          @p_enddate = @p_enddate,
                          @p_ownerid = @p_ownerid;

END;
GO
