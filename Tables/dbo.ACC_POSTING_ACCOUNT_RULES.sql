CREATE TABLE [dbo].[ACC_POSTING_ACCOUNT_RULES]
(
[EVENT_TYPE_ID] [bigint] NOT NULL,
[ACCOUNT_TYPE_ID] [bigint] NOT NULL,
[ACCOUNT_GROUP_TYPE] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MIN_BALANCE_MINOR_UNITS] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ACC_POSTING_ACCOUNT_RULES] ADD CONSTRAINT [PK_ACC_POST_ACC_RULES] PRIMARY KEY CLUSTERED  ([EVENT_TYPE_ID], [ACCOUNT_TYPE_ID], [ACCOUNT_GROUP_TYPE]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ACC_POSTING_ACCOUNT_RULES] WITH NOCHECK ADD CONSTRAINT [ACC_POST_ACC_RULE_ACC_FK] FOREIGN KEY ([ACCOUNT_TYPE_ID]) REFERENCES [dbo].[ACC_ACCOUNT_TYPES] ([ACCOUNT_TYPE_ID])
GO
ALTER TABLE [dbo].[ACC_POSTING_ACCOUNT_RULES] WITH NOCHECK ADD CONSTRAINT [ACC_POST_ACC_RULE_EVTTYPE_FK] FOREIGN KEY ([EVENT_TYPE_ID]) REFERENCES [dbo].[ACC_EVENT_TYPES] ([EVENT_TYPE_ID])
GO
