CREATE TABLE [dbo].[ACC_ACCOUNT_GROUPS]
(
[ACCOUNT_GROUP_ID] [bigint] NOT NULL,
[OWNER_ID] [bigint] NOT NULL,
[CURRENCY_CODE_ALPHA3] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HOLD_REMITTANCE] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ACC_ACCOUNT_GROUPS_HOLD_REMITTANCE] DEFAULT ('N'),
[ACCOUNT_NUMBER] [int] NOT NULL,
[HOLD_REMITTANCE_REASON] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PAYMENT_ACCOUNT_GROUP_ID] [bigint] NULL,
[GROUP_STATUS] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ACC_ACCOUNT_GROUPS_GROUP_STATUS] DEFAULT ('L'),
[ACCOUNT_GROUP_NAME] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ACCOUNT_GROUP_TYPE] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LEGACY_SOURCE_ID] [bigint] NULL,
[PRICING_POLICY_ID] [bigint] NULL,
[PARTNER_ACCOUNT_GROUP_ID] [bigint] NULL,
[COMMISSION_PLAN_ID] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ACC_ACCOUNT_GROUPS] ADD CONSTRAINT [ACC_ACCOUNT_GROUPS_PK] PRIMARY KEY CLUSTERED  ([ACCOUNT_GROUP_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ACC_ACCOUNT_GROUP_TYPE] ON [dbo].[ACC_ACCOUNT_GROUPS] ([ACCOUNT_GROUP_TYPE]) INCLUDE ([ACCOUNT_GROUP_ID]) ON [INDEX]
GO
ALTER TABLE [dbo].[ACC_ACCOUNT_GROUPS] ADD CONSTRAINT [ACC_ACCOUNT_GROUP_NUM_UNIQUE] UNIQUE NONCLUSTERED  ([ACCOUNT_NUMBER]) ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [ACC_ACCOUNT_GROUPS_CUR_FI] ON [dbo].[ACC_ACCOUNT_GROUPS] ([CURRENCY_CODE_ALPHA3]) WITH (PAD_INDEX=ON) ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [ACC_ACCOUNT_GROUP_OWNER_I] ON [dbo].[ACC_ACCOUNT_GROUPS] ([OWNER_ID]) WITH (PAD_INDEX=ON) ON [INDEX]
GO
CREATE NONCLUSTERED INDEX [ACC_ACCOUNT_GROUPS_PAYMENT_FI] ON [dbo].[ACC_ACCOUNT_GROUPS] ([PAYMENT_ACCOUNT_GROUP_ID]) WITH (PAD_INDEX=ON) ON [INDEX]
GO
ALTER TABLE [dbo].[ACC_ACCOUNT_GROUPS] WITH NOCHECK ADD CONSTRAINT [ACC_ACCOUNT_GROUPS_CURRENCY_FK] FOREIGN KEY ([CURRENCY_CODE_ALPHA3]) REFERENCES [dbo].[ACC_CURRENCIES] ([CURRENCY_CODE_ALPHA3])
GO
ALTER TABLE [dbo].[ACC_ACCOUNT_GROUPS] WITH NOCHECK ADD CONSTRAINT [ACC_ACCOUNT_GROUPS_OWNER_FK] FOREIGN KEY ([OWNER_ID]) REFERENCES [dbo].[ACC_OWNERS] ([OWNER_ID]) ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ACC_ACCOUNT_GROUPS] WITH NOCHECK ADD CONSTRAINT [ACC_ACCOUNT_GROUPS_PAYMENT_FK] FOREIGN KEY ([PAYMENT_ACCOUNT_GROUP_ID]) REFERENCES [dbo].[ACC_ACCOUNT_GROUPS] ([ACCOUNT_GROUP_ID])
GO
ALTER TABLE [dbo].[ACC_ACCOUNT_GROUPS] WITH NOCHECK ADD CONSTRAINT [ACCOUNT_GROUPS_POLICY_PK] FOREIGN KEY ([PRICING_POLICY_ID]) REFERENCES [dbo].[ACC_PRICING_POLICY] ([PRICING_POLICY_ID])
GO
