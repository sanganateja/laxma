CREATE TABLE [dbo].[ACC_EVTPOST_REGISTRY]
(
[ID] [bigint] NOT NULL,
[ACCOUNT_GROUP_ID] [bigint] NOT NULL,
[EVENT_TYPE_ID] [bigint] NOT NULL,
[TRANSFER_TYPE_ID] [bigint] NOT NULL,
[FROM_ACCOUNT_ID] [bigint] NOT NULL,
[FROM_BALANCE] [bigint] NULL,
[FROM_MATURITY_HOURS] [bigint] NULL,
[FROM_MINIMUM_BALANCE] [bigint] NULL,
[TO_ACCOUNT_ID] [bigint] NOT NULL,
[TO_BALANCE] [bigint] NULL,
[TO_MATURITY_HOURS] [bigint] NULL,
[STAMP] [datetime2] NULL,
[FROM_ARREARS_TYPE_ID] [bigint] NULL,
[TO_ARREARS_TYPE_ID] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ACC_EVTPOST_REGISTRY] ADD CONSTRAINT [PK_ACC_EVTPOST_REGISTRY] PRIMARY KEY CLUSTERED  ([ID], [ACCOUNT_GROUP_ID], [EVENT_TYPE_ID], [TRANSFER_TYPE_ID]) WITH (PAD_INDEX=ON, IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
