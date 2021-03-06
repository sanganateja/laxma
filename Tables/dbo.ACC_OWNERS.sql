CREATE TABLE [dbo].[ACC_OWNERS]
(
[OWNER_ID] [bigint] NOT NULL,
[CRM_ID] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OWNER_NAME] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BUSINESS_TYPE] [bigint] NULL,
[BUSINESS_COUNTRY] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[INDUSTRY_CODE] [nvarchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BUSINESS_TRADING_LIMIT_GBP] [bigint] NOT NULL CONSTRAINT [DF_ACC_OWNERS_BUSINESS_TRADING_LIMIT_GBP] DEFAULT ((1000000)),
[CRA_NAME] [nvarchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DFLT_PRICING_TURNOVER_BAND_ID] [bigint] NULL CONSTRAINT [DF_ACC_OWNERS_DFLT_PRICING_TURNOVER_BAND_ID] DEFAULT ((7)),
[MERCH_FLAGS] [bigint] NOT NULL,
[ADDRESS_LINE_1] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADDRESS_LINE_2] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADDRESS_LINE_3] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ADDRESS_LINE_4] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BUSINESS_CITY] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[POSTAL_CODE] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NEXT_RESET_DATE] [datetime2] (6) NOT NULL,
[CHARGING_ACCOUNT_GROUP_ID] [bigint] NULL,
[DFLT_PRICING_TIER_ID] [bigint] NULL,
[DEFAULT_PRICING_POLICY_ID] [bigint] NOT NULL,
[EXTERNAL_REF] [nvarchar] (23) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OWNER_TYPE_ID] [bigint] NULL,
[PCI_STATUS_ID] [numeric] (18, 0) NULL CONSTRAINT [DF_ACC_OWNERS_PCI_STATUS_ID] DEFAULT ((4)),
[DFLT_REMITTANCE_METHOD] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ACC_OWNERS] ADD CONSTRAINT [ACC_OWNER_PK] PRIMARY KEY CLUSTERED  ([OWNER_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ACC_OWNERS_EXTERNAL_REF_UI] ON [dbo].[ACC_OWNERS] ([EXTERNAL_REF]) WHERE ([EXTERNAL_REF] IS NOT NULL) WITH (PAD_INDEX=ON) ON [INDEX]
GO
ALTER TABLE [dbo].[ACC_OWNERS] WITH NOCHECK ADD CONSTRAINT [ACC_DFLT_PRICING_POLICY_FK] FOREIGN KEY ([DEFAULT_PRICING_POLICY_ID]) REFERENCES [dbo].[ACC_PRICING_POLICY] ([PRICING_POLICY_ID])
GO
ALTER TABLE [dbo].[ACC_OWNERS] WITH NOCHECK ADD CONSTRAINT [ACC_OWNER_PT_FK] FOREIGN KEY ([DFLT_PRICING_TIER_ID]) REFERENCES [dbo].[ACC_PRICING_TIERS] ([PRICING_TIER_ID])
GO
ALTER TABLE [dbo].[ACC_OWNERS] WITH NOCHECK ADD CONSTRAINT [ACC_OWNER_TURNOVER_FK] FOREIGN KEY ([DFLT_PRICING_TURNOVER_BAND_ID]) REFERENCES [dbo].[ACC_PRICING_TURNOVER_BANDS] ([PRICING_TURNOVER_BAND_ID])
GO
ALTER TABLE [dbo].[ACC_OWNERS] WITH NOCHECK ADD CONSTRAINT [ACC_OWNERS_OWNER_TYPE_FK] FOREIGN KEY ([OWNER_TYPE_ID]) REFERENCES [dbo].[ACC_OWNER_TYPES] ([OWNER_TYPE_ID])
GO
