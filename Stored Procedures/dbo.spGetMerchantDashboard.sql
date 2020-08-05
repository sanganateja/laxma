SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Stored Procedure

-- ================================================================================	
--	Author:			SOS	
--	Create date:	04/04/2019	
--	Description:		
--		Gets the Dashboard 'report' for a merchant/currency 
--	
--	Return:	
--		Merchant transaction data
--	
--  Change history	
--		18/10/2019 -	MA	- First version     (from GW provided SQL)
--		05/12/2019 -	AB	- Updated as per ACQ-2952 to account for daylight savings time
--		12/15/2019 -	AB	- Updated date field names
--	
-- ================================================================================	
CREATE PROCEDURE [dbo].[spGetMerchantDashboard]
    @MerchantId BIGINT,
    @Currency NVARCHAR(3) = 'GBP',
	@Datapoints ttDatapointList READONLY
AS
BEGIN

	DECLARE @StartDate DATETIME2 = (SELECT MIN(StartDate) FROM @Datapoints), 
			@EndDate DATETIME2 = (SELECT MAX(EndDate) FROM @Datapoints)

    SELECT dp.StartDate,
		   dp.EndDate,
           ISNULL(SUM(AmountRequested), 0) AS Revenue,
           ISNULL(COUNT(TransactionSearchId), 0) AS Volume
    FROM @Datapoints dp
        LEFT JOIN tblTransactionSearch ts WITH
        (NOLOCK)
            ON ts.StartTime >= dp.StartDate
               AND ts.StartTime < dp.EndDate
               AND MerchantId = @MerchantId
               AND Currency = @Currency
    WHERE dp.EndDate IS NOT NULL
    GROUP BY dp.StartDate, dp.EndDate
    ORDER BY dp.StartDate;

    SELECT @MerchantId AS MerchantId,
           @StartDate AS StartDate,
		   @EndDate AS EndDate,
           @Currency AS Currency,
           ISNULL(SUM(AmountRequested), 0) AS TotalRevenue,
           ISNULL(COUNT(TransactionSearchId), 0) AS TotalVolume,
           ISNULL((SUM(AmountRequested) / COUNT(TransactionSearchId)), 0) AverageSpend
    FROM tblTransactionSearch ts
    WHERE ts.StartTime >= @StartDate
          AND ts.StartTime < @EndDate
          AND MerchantId = @MerchantId
          AND Currency = @Currency;
END;
GO
GRANT EXECUTE ON  [dbo].[spGetMerchantDashboard] TO [DataServiceUser]
GO
