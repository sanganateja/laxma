CREATE TABLE [dbo].[ACC_FRANCHISEES]
(
[OWNER_ID] [bigint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ACC_FRANCHISEES] ADD CONSTRAINT [PK_ACC_FRANCHISEES] PRIMARY KEY CLUSTERED  ([OWNER_ID]) ON [PRIMARY]
GO
