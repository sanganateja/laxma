CREATE TABLE [dbo].[ACC_ACQUIRING_FEES_BLENDED]
(
[ACQ_FEE_BLENDED_ID] [bigint] NOT NULL CONSTRAINT [ACC_ACQUIRING_FEES_BLENDED_DEFAULT] DEFAULT (NEXT VALUE FOR [dbo].[ACQUIRING_FEE_SEQUENCE]),
[CARD_CATEGORY_CODE] [nvarchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TRANSACTION_CATEGORY_CODE] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[REGION] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AMOUNT_MINOR_UNITS] [bigint] NOT NULL,
[PERCENTAGE] [numeric] (18, 4) NOT NULL,
[ACCOUNT_GROUP_ID] [bigint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ACC_ACQUIRING_FEES_BLENDED] ADD CONSTRAINT [ACC_ACQ_FEES_BLENDED_PK] PRIMARY KEY CLUSTERED  ([ACQ_FEE_BLENDED_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ACC_ACQUIRING_FEES_BLENDED_ACTR] ON [dbo].[ACC_ACQUIRING_FEES_BLENDED] ([ACCOUNT_GROUP_ID], [CARD_CATEGORY_CODE], [TRANSACTION_CATEGORY_CODE], [REGION]) ON [INDEX]
GO
ALTER TABLE [dbo].[ACC_ACQUIRING_FEES_BLENDED] WITH NOCHECK ADD CONSTRAINT [ACC_ACQ_FEES_BLENDED_AG_PK] FOREIGN KEY ([ACCOUNT_GROUP_ID]) REFERENCES [dbo].[ACC_ACCOUNT_GROUPS] ([ACCOUNT_GROUP_ID])
GO
ALTER TABLE [dbo].[ACC_ACQUIRING_FEES_BLENDED] WITH NOCHECK ADD CONSTRAINT [ACC_ACQ_FEES_BLENDED_CARD_FK] FOREIGN KEY ([CARD_CATEGORY_CODE]) REFERENCES [dbo].[ACC_CARD_CATEGORIES] ([CARD_CATEGORY_CODE])
GO
ALTER TABLE [dbo].[ACC_ACQUIRING_FEES_BLENDED] WITH NOCHECK ADD CONSTRAINT [ACC_ACQ_FEES_BLENDED_TR_CAT_FK] FOREIGN KEY ([TRANSACTION_CATEGORY_CODE]) REFERENCES [dbo].[ACC_TRANSACTION_CATEGORIES] ([TRANSACTION_CATEGORY_CODE])
GO
