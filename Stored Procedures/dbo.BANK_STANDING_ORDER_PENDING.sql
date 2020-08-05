SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[BANK_STANDING_ORDER_PENDING]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_run_time DATETIME2(6)
AS
BEGIN
    DECLARE @dst INTEGER;

    SET @cv_1 = NULL;

    -- Retrieve Daylight Saving Information
    -- EarliestPaymentTimeUKLocal and LatestPaymentTimeUKLocal need to be adjusted to UTC before comparing with time element in @p_run_time
    SELECT @dst = is_currently_dst
    FROM sys.time_zone_info
    WHERE name = 'GMT Standard Time';

    SELECT so.STANDING_ORDER_ID,
           so.ACCOUNT_GROUP_ID,
           so.DESCRIPTION,
           so.BANK_NAME,
           so.BANK_ADDRESS1,
           so.BANK_ADDRESS2,
           so.BANK_ADDRESS3,
           so.BANK_SORTCODE,
           so.BANK_ACCOUNT_NUMBER,
           so.BANK_ACCOUNTNAME,
           so.BENEFICIARY_NAME,
           so.BENEFICIARY_ADDRESS1,
           so.BENEFICIARY_ADDRESS2,
           so.BENEFICIARY_ADDRESS3,
           so.BENEFICIARY_COUNTRY,
           so.BENEFICIARY_REFERENCE,
           so.BANK_SWIFT_CODE,
           so.AGENT_BANK_SWIFT_CODE,
           so.IBAN,
           so.BANK_AND_BRANCH_CODE,
           so.BSB_CODE,
           so.HKSG_BANK_AND_BRANCH_CODE,
           so.ABA_NUMBER,
           so.GENERAL_ACCOUNT_NUMBER,
           so.START_DATE,
           so.END_DATE,
           so.NEXT_PAYMENT_DATE,
           so.BUSINESS_DAY_CONVENTION,
           so.NUM_PAYMENTS,
           so.FREQUENCY_MULTIPLIER,
           so.FREQUENCY_UNITS,
           so.PAYMENT_TYPE,
           so.AMOUNT_MINOR_UNITS,
           so.STATUS,
           so.BANK_COUNTRY,
           so.NEXT_SCHEDULE_DATE,
           so.NUM_PAYMENTS_MADE,
           so.PAYER_NAME,
           so.PAYER_ADDRESS1,
           so.PAYER_ADDRESS2,
           so.PAYER_ADDRESS3,
           so.PAYER_COUNTRY,
           so.PAYMENT_FAILURE_EMAIL,
           so.NUM_PAYMENTS_FAILD,
           so.LAST_FAILURE_DATE,
           so.ROUTING_TRANSIT_NUMBER,
           so.SA_BANK_BRANCH_CODE,
           so.PAY_ALL
    FROM dbo.ACC_BANK_STANDING_ORDERS so JOIN ACC_ACCOUNT_GROUPS ag ON so.ACCOUNT_GROUP_ID = ag.ACCOUNT_GROUP_ID
                                         JOIN ACC_TRANSFER_METHODS tm ON so.PAYMENT_TYPE = tm.PAYMENT_TYPE_MNEMONIC
                                         JOIN tlkpBankPaymentStaticData bp ON tm.TRANSFER_METHOD_ID = bp.PaymentTypeId AND ag.CURRENCY_CODE_ALPHA3 = bp.CurrencyCodeAlpha3
    WHERE so.STATUS = 'A'
      AND so.NEXT_PAYMENT_DATE <= @p_run_time
      AND DATEPART(hour, @p_run_time) BETWEEN DATEPART(hour, bp.EarliestPaymentTimeUKLocal) -@dst AND DATEPART(hour, bp.LatestPaymentTimeUKLocal) - @dst
    ORDER BY so.ACCOUNT_GROUP_ID, 
             so.PAY_ALL;               -- 'N' before 'Y'

END;
GO
