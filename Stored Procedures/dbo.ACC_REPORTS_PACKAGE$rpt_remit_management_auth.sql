SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_remit_management_auth] @p_recordset VARCHAR(2000) OUTPUT	
AS	
BEGIN	

     SET @p_recordset = NULL;	

     SELECT o.OWNER_NAME AS business_name,	
           o.EXTERNAL_REF AS business_id,	
           FORMAT(ag.ACCOUNT_NUMBER, '00000000#') AS account_number,	
           ag.ACCOUNT_GROUP_NAME AS account_group_name,	
           ABS(SUM(CAST(tr.AMOUNT_MINOR_UNITS AS FLOAT(53)) / POWER(10, cur.DECIMAL_PLACES))) AS amount,	
           ag.CURRENCY_CODE_ALPHA3 AS currency,	
           FORMAT(ba.MATURED_TIME, 'dd-MM-yy HH\:mm') AS approval_date	
    FROM dbo.ACC_TRANSFERS AS tr	
        JOIN dbo.ACC_BATCHES AS ba	
            ON tr.BATCH_ID = ba.BATCH_ID	
        JOIN dbo.ACC_ACCOUNTS AS ac	
            ON tr.ACCOUNT_ID = ac.ACCOUNT_ID	
        JOIN dbo.ACC_ACCOUNT_GROUPS AS ag	
            ON ac.ACCOUNT_GROUP_ID = ag.ACCOUNT_GROUP_ID	
               AND ag.ACCOUNT_GROUP_TYPE = 'A'	
        JOIN dbo.ACC_OWNERS AS o	
            ON ag.OWNER_ID = o.OWNER_ID	
        JOIN dbo.ACC_CURRENCIES AS cur	
            ON cur.CURRENCY_CODE_ALPHA3 = ag.CURRENCY_CODE_ALPHA3	
    WHERE ba.MATURED_TIME IS NOT NULL	
          AND CAST(ba.MATURED_TIME AS DATE) = CAST(SYSDATETIME() AS DATE)	
          AND ac.ACCOUNT_TYPE_ID = 0	
          AND tr.TRANSFER_TYPE_ID = 2	
    GROUP BY ac.ACCOUNT_ID,	
             o.OWNER_NAME,	
             o.EXTERNAL_REF,	
             ag.ACCOUNT_NUMBER,	
             ag.ACCOUNT_GROUP_NAME,	
             ag.CURRENCY_CODE_ALPHA3,	
             FORMAT(ba.MATURED_TIME, 'dd-MM-yy HH\:mm')	
    ORDER BY o.OWNER_NAME,	
             ag.ACCOUNT_GROUP_NAME;	

 END;
GO
