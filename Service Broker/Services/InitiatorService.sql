CREATE SERVICE [InitiatorService]
AUTHORIZATION [dbo]
ON QUEUE [dbo].[InitiatorQueue]
(
[CoreMessageContract]
)
GO
