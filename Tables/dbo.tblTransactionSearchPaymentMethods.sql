CREATE TABLE [dbo].[tblTransactionSearchPaymentMethods]
(
[TransactionSearchPMId] [bigint] NOT NULL IDENTITY(1, 1),
[TransactionSearchId] [bigint] NOT NULL,
[PaymentMethod] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentMethodReference] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Priority] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblTransactionSearchPaymentMethods] ADD CONSTRAINT [PK_tblTransactionSearchPM] PRIMARY KEY CLUSTERED  ([TransactionSearchPMId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblTSPM_PaymentMethod_Priority] ON [dbo].[tblTransactionSearchPaymentMethods] ([PaymentMethod]) INCLUDE ([PaymentMethodReference], [Priority], [TransactionSearchId]) ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [IX_TSPM_Reference] ON [dbo].[tblTransactionSearchPaymentMethods] ([PaymentMethodReference]) INCLUDE ([PaymentMethod], [TransactionSearchId]) ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [IX_tblTSPM_TranSearchId] ON [dbo].[tblTransactionSearchPaymentMethods] ([TransactionSearchId]) INCLUDE ([PaymentMethod], [PaymentMethodReference], [Priority]) ON [INDEX]
GO
GRANT SELECT ON  [dbo].[tblTransactionSearchPaymentMethods] TO [DataServiceUser]
GO
