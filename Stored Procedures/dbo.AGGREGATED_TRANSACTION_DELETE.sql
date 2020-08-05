SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[AGGREGATED_TRANSACTION_DELETE]
    @p_source_ref /* These parameters correspond to the java entity variables annotated with @Id.   Order is important! The following order must be the REVERSE of the order   in which the variables are defined in the java entity.*/ NVARCHAR(2000),
    @p_event_date DATETIME2(6),
    @p_account_group_id NUMERIC
AS
BEGIN
    DELETE dbo.ACC_AGGREGATED_TRANSACTIONS
    WHERE ACC_AGGREGATED_TRANSACTIONS.ACCOUNT_GROUP_ID = @p_account_group_id
          AND ACC_AGGREGATED_TRANSACTIONS.EVENT_DATE = @p_event_date /* Needs to be passed correctly (ie. not TRUNCed in here).*/
          AND ACC_AGGREGATED_TRANSACTIONS.SOURCE_REF = @p_source_ref;
END;
GO
