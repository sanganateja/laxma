CREATE TABLE [dbo].[ACC_CT_PRICING_TMPLS_BLENDED]
(
[PRICING_TURNOVER_BAND_ID] [bigint] NOT NULL,
[PRICING_REGION_CODE] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FEE_DISTINGUISHER] [nvarchar] (48) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PERCENTAGE] [decimal] (18, 2) NOT NULL,
[AMOUNT_MINOR_UNITS] [bigint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ACC_CT_PRICING_TMPLS_BLENDED] ADD CONSTRAINT [ACC_CT_PRICING_TMPLS_BL_PK] PRIMARY KEY CLUSTERED  ([PRICING_TURNOVER_BAND_ID], [PRICING_REGION_CODE], [FEE_DISTINGUISHER]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ACC_CT_PRICING_TMPLS_BLENDED] WITH NOCHECK ADD CONSTRAINT [ACC_CT_PR_TMPLS_BL_CT_REG_FK] FOREIGN KEY ([PRICING_REGION_CODE]) REFERENCES [dbo].[ACC_PRICING_REGIONS] ([PRICING_REGION_CODE])
GO
ALTER TABLE [dbo].[ACC_CT_PRICING_TMPLS_BLENDED] WITH NOCHECK ADD CONSTRAINT [ACC_CT_PR_TMPLS_BL_FD_FK] FOREIGN KEY ([FEE_DISTINGUISHER]) REFERENCES [dbo].[ACC_FEE_DISTINGUISHERS] ([FEE_DISTINGUISHER])
GO
ALTER TABLE [dbo].[ACC_CT_PRICING_TMPLS_BLENDED] WITH NOCHECK ADD CONSTRAINT [ACC_CT_PR_TMPLS_BL_TUR_BAND_FK] FOREIGN KEY ([PRICING_TURNOVER_BAND_ID]) REFERENCES [dbo].[ACC_PRICING_TURNOVER_BANDS] ([PRICING_TURNOVER_BAND_ID])
GO
