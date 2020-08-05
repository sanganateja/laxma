CREATE TABLE [dbo].[tlkpProcessSchedule]
(
[ProcessScheduleId] [bigint] NOT NULL,
[ScheduleTimeUTC] [time] NOT NULL,
[Maturity] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Remittance] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Payment] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tlkpProcessSchedule] ADD CONSTRAINT [PK__tlkpProc__48EB997160F2CE47] PRIMARY KEY CLUSTERED  ([ProcessScheduleId]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tlkpProcessSchedule_ScheduleTimeUTC] ON [dbo].[tlkpProcessSchedule] ([ScheduleTimeUTC]) ON [PRIMARY]
GO
