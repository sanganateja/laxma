CREATE SERVICE [AccountsInboundService]
AUTHORIZATION [dbo]
ON QUEUE [dbo].[AccountsInboundQueue]
(
[InterDBContract]
)
GO
GRANT SEND ON SERVICE:: [AccountsInboundService] TO [CoreSBUser]
GO
