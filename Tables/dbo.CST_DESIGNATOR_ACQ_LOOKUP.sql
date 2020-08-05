CREATE TABLE [dbo].[CST_DESIGNATOR_ACQ_LOOKUP]
(
[LOOKUP_ID] [bigint] NOT NULL,
[FEE_PROGRAM] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RATE_TIER] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[INTERCHANGE_DESCRIPTION] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DESIGNATOR_ID] [bigint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CST_DESIGNATOR_ACQ_LOOKUP] ADD CONSTRAINT [CST_DESIGNATOR_ACQ_LOOKUP_PK] PRIMARY KEY CLUSTERED  ([LOOKUP_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [CST_DESIGNATOR_ACQ_LOOKUP_UI] ON [dbo].[CST_DESIGNATOR_ACQ_LOOKUP] ([FEE_PROGRAM], [RATE_TIER], [INTERCHANGE_DESCRIPTION]) WITH (PAD_INDEX=ON) ON [INDEX]
GO
ALTER TABLE [dbo].[CST_DESIGNATOR_ACQ_LOOKUP] WITH NOCHECK ADD CONSTRAINT [CST_DESIG_ACQ_LOOKUP_DS_FK] FOREIGN KEY ([DESIGNATOR_ID]) REFERENCES [dbo].[CST_DESIGNATORS] ([DESIGNATOR_ID])
GO
