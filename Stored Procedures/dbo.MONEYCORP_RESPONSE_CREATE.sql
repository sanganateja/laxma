SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[MONEYCORP_RESPONSE_CREATE]
    @p_accountDescription NVARCHAR(2000),
    @p_accountName NVARCHAR(2000),
    @p_accountNumber NUMERIC,
    @p_amount NVARCHAR(2000),
    @p_bankingDetailsId NUMERIC,
    @p_bankingDetailsStatusName NVARCHAR(2000),
    @p_clientFundLineId NUMERIC,
    @p_clientFundLineTypeName NVARCHAR(2000),
    @p_clientReference NVARCHAR(2000),
    @p_countryName NVARCHAR(2000),
    @p_createdOn DATETIME2(6),
    @p_currencyCode NVARCHAR(2000),
    @p_currentBalance NVARCHAR(2000),
    @p_externalSystemReference NVARCHAR(2000),
    @p_fileName NVARCHAR(2000),
    @p_iban NVARCHAR(2000),
    @p_overallPaymentStatus NVARCHAR(2000),
    @p_paymentStatusName NVARCHAR(2000),
    @p_processedOn DATETIME2(6),
    @p_sortCode NUMERIC,
    @p_swiftReference NVARCHAR(2000),
    @moneyCorpResponseId NUMERIC
AS
BEGIN
    INSERT dbo.ACC_MONEYCORP_RESPONSES
    (
        MONEYCORP_RESPONSE_ID,
        CLIENT_FUND_LINE_ID,
        CLIENT_FUND_LINE_TYPE_NAME,
        CURRENCY_CODE,
        AMOUNT,
        CREATED_ON,
        CLIENT_REFERENCE,
        PAYMENT_STATUS_NAME,
        BANKING_DETAILS_ID,
        SORT_CODE,
        ACCOUNT_NUMBER,
        IBAN,
        BANKING_DETAILS_STATUS_NAME,
        COUNTRY_NAME,
        OVERALL_PAYMENT_STATUS,
        CURRENT_BALANCE,
        ACCOUNT_NAME,
        ACCOUNT_DESCRIPTION,
        SWIFT_REFERENCE,
        EXTERNAL_SYSTEM_REFERENCE,
        FILE_NAME,
        PROCESSED_ON
    )
    VALUES
    (NEXT VALUE FOR dbo.MONEYCORP_RESPONSE_SEQUENCE,
     @p_clientFundLineId,
     @p_clientFundLineTypeName,
     @p_currencyCode,
     @p_amount,
     @p_createdOn,
     @p_clientReference,
     @p_paymentStatusName,
     @p_bankingDetailsId,
     @p_sortCode,
     @p_accountNumber,
     @p_iban,
     @p_bankingDetailsStatusName,
     @p_countryName,
     @p_overallPaymentStatus,
     @p_currentBalance,
     @p_accountName,
     @p_accountDescription,
     @p_swiftReference,
     @p_externalSystemReference,
     @p_fileName,
     @p_processedOn);
END;
GO
