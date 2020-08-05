CREATE SERVICE [QueueMonitorService]
AUTHORIZATION [dbo]
ON QUEUE [dbo].[QueueMonitorQueue]
(
[http://schemas.microsoft.com/SQL/Notifications/PostEventNotification]
)
GO
