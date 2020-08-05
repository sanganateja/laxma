CREATE QUEUE [dbo].[InitiatorQueue] 
WITH STATUS=ON, 
RETENTION=OFF,
POISON_MESSAGE_HANDLING (STATUS=ON), 
ACTIVATION (
STATUS=ON, 
PROCEDURE_NAME=[dbo].[spMessageProcessorInitiatorQueue], 
MAX_QUEUE_READERS=5, 
EXECUTE AS N'ServiceBrokerUser'
)
ON [PRIMARY]
GO