SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[ACC_REPORTS_PACKAGE$rpt_dte_merchant_acc_balances]
    @p_recordset VARCHAR(2000) OUTPUT,
    @p_enddate DATETIME2(6),
    @p_crm_id NVARCHAR(2000) = NULL
AS
DECLARE @FLAG_GrossSettlement BIGINT = 0x100000000;
BEGIN

    SET @p_recordset = NULL;

    SELECT ow.EXTERNAL_REF AS [Merchant Id],
           mt.MERCHANT_TYPE_NAME AS [Merchant Type],
           ow.OWNER_NAME AS [Merchant Name],
           CASE
               WHEN ow.MERCH_FLAGS&@FLAG_GrossSettlement = @FLAG_GrossSettlement THEN
                   'Yes'
               ELSE
                   'No'
           END AS [Gross Settlement],
           FORMAT(ag.ACCOUNT_NUMBER, '00000000#') AS [Account Number],
           a.ACCOUNT_ID AS [Account Id],
           AT.NAME AS Account,
           c.CURRENCY_CODE_ALPHA3 AS Currency,
           CAST(tr.BALANCE_AFTER_MINOR_UNITS AS FLOAT(53)) / POWER(10, c.DECIMAL_PLACES) AS Balance,
           pa.PARTNER_NAME AS [Partner Name]
    FROM dbo.ACC_OWNERS AS ow
        JOIN dbo.ACC_ACCOUNT_GROUPS AS ag
            ON ow.OWNER_ID = ag.OWNER_ID
               AND ag.ACCOUNT_GROUP_TYPE = 'A'
        LEFT JOIN /* Merchant account group*/ dbo.ACC_MERCHANT_TYPES AS mt
            ON ow.BUSINESS_TYPE = mt.MERCHANT_TYPE_ID
        JOIN dbo.ACC_CURRENCIES AS c
            ON ag.CURRENCY_CODE_ALPHA3 = c.CURRENCY_CODE_ALPHA3
        JOIN dbo.ACC_ACCOUNTS AS a
            ON ag.ACCOUNT_GROUP_ID = a.ACCOUNT_GROUP_ID
        JOIN dbo.ACC_ACCOUNT_TYPES AS AT
            ON a.ACCOUNT_TYPE_ID = AT.ACCOUNT_TYPE_ID
        JOIN dbo.ACC_TRANSFERS AS tr
            ON tr.TRANSFER_ID =
            (
                SELECT MAX(ACC_TRANSFERS.TRANSFER_ID) AS expr
                FROM dbo.ACC_TRANSFERS
                WHERE ACC_TRANSFERS.ACCOUNT_ID = a.ACCOUNT_ID
                      AND ACC_TRANSFERS.TRANSFER_TIME <= @p_enddate
            )
        LEFT JOIN dbo.ACC_PARTNERS AS pa
            ON (pa.CRM_ID = ow.CRM_ID)
    WHERE (
              a.ACCOUNT_TYPE_ID != 5
              AND a.ACCOUNT_TYPE_ID != 7
          )
          AND
          (
              @p_crm_id IS NULL
              OR @p_crm_id = ''
              OR @p_crm_id = pa.CRM_ID
          )
    ORDER BY ow.EXTERNAL_REF,
             c.CURRENCY_CODE_ALPHA3,
             a.ACCOUNT_TYPE_ID;

END;
GO
