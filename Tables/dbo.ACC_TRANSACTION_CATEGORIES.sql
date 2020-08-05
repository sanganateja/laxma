CREATE TABLE [dbo].[ACC_TRANSACTION_CATEGORIES]
(
[TRANSACTION_CATEGORY_CODE] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NAME] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ACC_TRANSACTION_CATEGORIES] ADD CONSTRAINT [ACC_TR_CATEGORY_PK] PRIMARY KEY CLUSTERED  ([TRANSACTION_CATEGORY_CODE]) ON [PRIMARY]
GO
