CREATE TYPE [dbo].[ttPaymentMethodList] AS TABLE
(
[PaymentMethod] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PaymentMethodReference] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Priority] [int] NOT NULL
)
GO
GRANT EXECUTE ON TYPE:: [dbo].[ttPaymentMethodList] TO [DataServiceUser] WITH GRANT OPTION
GO
