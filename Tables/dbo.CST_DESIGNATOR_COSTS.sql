CREATE TABLE [dbo].[CST_DESIGNATOR_COSTS]
(
[COST_ID] [bigint] NOT NULL,
[VALID_FROM] [datetime2] (6) NULL,
[DESIGNATOR_ID] [bigint] NOT NULL,
[CURRENCY_CODE_ALPHA3] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FIXED_AMOUNT_MINOR_UNITS] [numeric] (18, 6) NULL,
[VARIABLE_PCTG] [numeric] (12, 8) NOT NULL,
[VALID_TO] [datetime2] (6) NULL,
[MIN_AMOUNT] [numeric] (18, 6) NULL,
[MAX_AMOUNT] [numeric] (18, 6) NULL,
[MIN_RETURN_AMOUNT] [numeric] (18, 0) NULL,
[MAX_RETURN_AMOUNT] [numeric] (18, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CST_DESIGNATOR_COSTS] ADD CONSTRAINT [CST_DESIGNATOR_COSTS_PK] PRIMARY KEY CLUSTERED  ([COST_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CST_DESIGNATOR_COSTS] WITH NOCHECK ADD CONSTRAINT [CST_DESIGNATOR_COSTS_CURR_FK] FOREIGN KEY ([CURRENCY_CODE_ALPHA3]) REFERENCES [dbo].[ACC_CURRENCIES] ([CURRENCY_CODE_ALPHA3])
GO
ALTER TABLE [dbo].[CST_DESIGNATOR_COSTS] WITH NOCHECK ADD CONSTRAINT [CST_DESIGNATOR_COSTS_DS_FK] FOREIGN KEY ([DESIGNATOR_ID]) REFERENCES [dbo].[CST_DESIGNATORS] ([DESIGNATOR_ID])
GO