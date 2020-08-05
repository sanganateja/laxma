CREATE TABLE [dbo].[tlkpPaymentType]
(
[PaymentTypeId] [bigint] NOT NULL,
[Code] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrencyCodeAlpha3] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tlkpPaymentType] ADD CONSTRAINT [PK_tlkpPaymentType] PRIMARY KEY CLUSTERED  ([PaymentTypeId]) ON [PRIMARY]
GO
