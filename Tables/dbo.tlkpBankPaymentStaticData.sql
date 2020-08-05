CREATE TABLE [dbo].[tlkpBankPaymentStaticData]
(
[BankPaymentStaticDataId] [bigint] NOT NULL,
[PaymentBankId] [bigint] NOT NULL,
[PaymentTypeId] [bigint] NOT NULL,
[CurrencyCodeAlpha3] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EarliestPaymentTimeUKLocal] [time] NOT NULL,
[LatestPaymentTimeUKLocal] [time] NOT NULL,
[DefaultRemittanceTimeUKLocal] [time] NOT NULL,
[FeeGBPMinorUnit] [bigint] NOT NULL,
[MaxAmountGBPMinorUnits] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tlkpBankPaymentStaticData] ADD CONSTRAINT [PK_tlkpBankPayment] PRIMARY KEY CLUSTERED  ([BankPaymentStaticDataId]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tlkpBankPayment_PaymentBank_PaymentType_Currency] ON [dbo].[tlkpBankPaymentStaticData] ([PaymentBankId], [PaymentTypeId], [CurrencyCodeAlpha3]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tlkpBankPaymentStaticData_PaymentBankId_PaymentTypeId_CurrencyCodeAlpha3] ON [dbo].[tlkpBankPaymentStaticData] ([PaymentBankId], [PaymentTypeId], [CurrencyCodeAlpha3]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tlkpBankPaymentStaticData] ADD CONSTRAINT [FK_tlkpBankPayment_ACC_CURRENCIES] FOREIGN KEY ([CurrencyCodeAlpha3]) REFERENCES [dbo].[ACC_CURRENCIES] ([CURRENCY_CODE_ALPHA3])
GO
ALTER TABLE [dbo].[tlkpBankPaymentStaticData] ADD CONSTRAINT [FK_tlkpBankPayment_tlkpPaymentBank] FOREIGN KEY ([PaymentBankId]) REFERENCES [dbo].[tlkpPaymentBank] ([PaymentBankId])
GO
ALTER TABLE [dbo].[tlkpBankPaymentStaticData] ADD CONSTRAINT [FK_tlkpBankPayment_tlkpPaymentType] FOREIGN KEY ([PaymentTypeId]) REFERENCES [dbo].[tlkpPaymentType] ([PaymentTypeId])
GO
