CREATE TABLE [dbo].[ACC_PRODUCT_RATES]
(
[PRODUCT_RATE_ID] [bigint] NOT NULL,
[PRODUCT_TYPE] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EFFECTIVE_DATE] [datetime2] (0) NOT NULL,
[DAILY_CALC_RATE] [numeric] (11, 9) NOT NULL,
[AER_RATE] [numeric] (11, 9) NOT NULL,
[DAILY_VCG_RATE] [numeric] (11, 9) NOT NULL,
[AER_VCG_RATE] [numeric] (11, 9) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ACC_PRODUCT_RATES] ADD CONSTRAINT [ACC_PRODUCT_RATES_PK] PRIMARY KEY CLUSTERED  ([PRODUCT_RATE_ID]) ON [PRIMARY]
GO
