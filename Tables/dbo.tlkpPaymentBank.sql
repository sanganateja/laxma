CREATE TABLE [dbo].[tlkpPaymentBank]
(
[PaymentBankId] [bigint] NOT NULL,
[BankName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tlkpPaymentBank] ADD CONSTRAINT [PK_tlkpPaymentBank] PRIMARY KEY CLUSTERED  ([PaymentBankId]) ON [PRIMARY]
GO
