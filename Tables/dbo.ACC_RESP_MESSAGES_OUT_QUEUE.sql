CREATE TABLE [dbo].[ACC_RESP_MESSAGES_OUT_QUEUE]
(
[MESSAGE_ID] [bigint] NOT NULL,
[MESSAGE_TIMESTAMP] [datetime2] (6) NOT NULL,
[PAYMENT_MESSAGE_ID] [bigint] NOT NULL,
[PAYMENT_MESSAGE_STATUS] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[REASON] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PAYMENT_HEADER_MESSAGE_ID] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PAYMENT_END_TO_END_ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PAYMENT_TRANSACTION_ID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ACC_RESP_MESSAGES_OUT_QUEUE] ADD CONSTRAINT [ACC_RESP_MESSAGES_O_Q_PK] PRIMARY KEY CLUSTERED  ([MESSAGE_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ACC_RESP_MESSAGES_OUT_QUEUE] WITH NOCHECK ADD CONSTRAINT [ACC_RESP_MESSAGES_OUT_QUEUE_FK] FOREIGN KEY ([PAYMENT_MESSAGE_ID]) REFERENCES [dbo].[ACC_PAYMENT_MESSAGES_IN] ([MESSAGE_ID])
GO