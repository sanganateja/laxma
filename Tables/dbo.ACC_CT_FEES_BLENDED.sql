CREATE TABLE [dbo].[ACC_CT_FEES_BLENDED]
(
[ACCOUNT_GROUP_ID] [bigint] NOT NULL,
[PRICING_REGION_CODE] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FEE_DISTINGUISHER] [nvarchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PERCENTAGE] [decimal] (18, 2) NOT NULL,
[AMOUNT_MINOR_UNITS] [bigint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ACC_CT_FEES_BLENDED] ADD CONSTRAINT [ACC_CT_FEES_BL_PK] PRIMARY KEY CLUSTERED  ([ACCOUNT_GROUP_ID], [PRICING_REGION_CODE], [FEE_DISTINGUISHER]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ACC_CT_FEES_BLENDED] WITH NOCHECK ADD CONSTRAINT [ACC_CT_FEES_BL_AG_FK] FOREIGN KEY ([ACCOUNT_GROUP_ID]) REFERENCES [dbo].[ACC_ACCOUNT_GROUPS] ([ACCOUNT_GROUP_ID])
GO
ALTER TABLE [dbo].[ACC_CT_FEES_BLENDED] WITH NOCHECK ADD CONSTRAINT [ACC_CT_FEES_BL_CT_REG_FK] FOREIGN KEY ([PRICING_REGION_CODE]) REFERENCES [dbo].[ACC_PRICING_REGIONS] ([PRICING_REGION_CODE])
GO
ALTER TABLE [dbo].[ACC_CT_FEES_BLENDED] WITH NOCHECK ADD CONSTRAINT [ACC_CT_FEES_BL_FD_FK] FOREIGN KEY ([FEE_DISTINGUISHER]) REFERENCES [dbo].[ACC_FEE_DISTINGUISHERS] ([FEE_DISTINGUISHER])
GO