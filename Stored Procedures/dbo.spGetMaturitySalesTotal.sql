SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[spGetMaturitySalesTotal]
    @cv_1         VARCHAR(2000) OUTPUT,
    @AccountId    BIGINT,
    @MaturityTime DATETIME2
AS
BEGIN
    SET NOCOUNT ON
    SET @cv_1 = NULL;

    SELECT @AccountId AS AccountId,
           ISNULL(COUNT(TRANSFER_ID), 0) AS NumberTransfers,
           ISNULL(SUM(AMOUNT_MINOR_UNITS), 0) AS Balance 
    FROM dbo.ACC_TRANSFERS
    WHERE ACCOUNT_ID = @AccountId
      AND TRANSFER_TYPE_ID = 0   -- Clearing
      AND MATURITY_TIME <= @MaturityTime
      AND MATURITY_TRANSACTION_ID IS NULL;
    
END;
GO
