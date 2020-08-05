CREATE TABLE [dbo].[tlkpArrearsType]
(
[ArrearsTypeId] [bigint] NOT NULL,
[ArrearsTypeName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tlkpArrearsType] ADD CONSTRAINT [PK__tlkpArre__8769E04DCBB7AB21] PRIMARY KEY CLUSTERED  ([ArrearsTypeId]) ON [PRIMARY]
GO
