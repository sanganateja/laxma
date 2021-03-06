CREATE TABLE [dbo].[ACC_MONEYCORP_RESPONSES]
(
[MONEYCORP_RESPONSE_ID] [bigint] NOT NULL,
[CLIENT_FUND_LINE_ID] [bigint] NULL,
[CLIENT_FUND_LINE_TYPE_NAME] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CURRENCY_CODE] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AMOUNT] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CREATED_ON] [datetime2] (0) NULL,
[CLIENT_REFERENCE] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PAYMENT_STATUS_NAME] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BANKING_DETAILS_ID] [bigint] NULL,
[SORT_CODE] [int] NULL,
[ACCOUNT_NUMBER] [int] NULL,
[IBAN] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BANKING_DETAILS_STATUS_NAME] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[COUNTRY_NAME] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OVERALL_PAYMENT_STATUS] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CURRENT_BALANCE] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ACCOUNT_NAME] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ACCOUNT_DESCRIPTION] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SWIFT_REFERENCE] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EXTERNAL_SYSTEM_REFERENCE] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FILE_NAME] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROCESSED_ON] [datetime2] (0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ACC_MONEYCORP_RESPONSES] ADD CONSTRAINT [PK_ACC_MONEYCORP_RESPONSES] PRIMARY KEY CLUSTERED  ([MONEYCORP_RESPONSE_ID]) ON [PRIMARY]
GO
