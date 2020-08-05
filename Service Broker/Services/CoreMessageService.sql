CREATE SERVICE [CoreMessageService]
AUTHORIZATION [dbo]
ON QUEUE [dbo].[CoreMessageQueue]
(
[CoreMessageContract]
)
GO
