SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ================================================================================
--  Author:			Mat
--  Create date:	02/07/2019
--  Description:
--      Returns the relevant page of data from a search of tblTransactionSearch.
--		Requires date range.  All other parameters are optional
--		including sort order (which will be Date/Time DESC by default)
--		Anything in the @Search parameter will query the full-text index.  Other
--		parameters are simple column compares.
--
--  Return:			
--      The selected page of transaction data, or an empty recordset
--
--  Change history
--		25/03/2020	- Mat		- Include the Step2 changes to include all transactions, but not if they are
--									already included in a Gateway payment job.
--		19/03/2020	- Mat		- Restructured SearchResults process to improve performance 10 fold.
--		12/02/2020	- Ma		- Added DISTINCT for selecting transactionSearchIds to put into preFilter table
--		04/09/2019	- MA		- Removed AmountReceived from min/max amount transaction filtering
--		17/07/2019	- Mat		- TxStatus is now required as a smallint
--								- TxTypes is a list of TransactionTypes passed in as a table type.
--		05/05/2019	- Mat		- Added MID as a filter and made BID optional
--								  Also added new search logic if BID not provided.
--      02/07/2019  - Mat       - First version
--
-- ================================================================================
CREATE PROCEDURE [dbo].[spTransactionSearch]
	@BusinessId bigint=null,
	@FromDateTime datetime2,
	@ToDateTime datetime2,
	@MerchantId int=null,
	@FromAmount decimal(12,2)=null,
	@ToAmount decimal(12,2)=null,
	@ExactAmount decimal(12,2)=null,
	@Currency char(3)=null,
	@PaymentMethod nvarchar(20)=null,
	@TxStatus smallint=null,
	@TxType [ttTransactionTypeList] null READONLY, -- A list of transaction types to return.  NULL is the same as ALL
	@Channel char(1)=null,
	@SearchString nvarchar(1000)=null,
	@SortBy nvarchar(20)='DateTime',
	@SortOrder nvarchar(10)='Descending',
	@PageNumber int=1,
    @PageSize int=20
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @SQL nvarchar(max)

	IF TRIM(@SearchString)='' SELECT @SearchString=null
	IF @SearchString is not null SELECT @SearchString='"'+@SearchString+'"'

	IF OBJECT_ID('tempdb..#PreFilter') IS NOT NULL DROP TABLE #PreFilter
	CREATE TABLE #PreFilter (TransactionSearchID bigint not null primary key clustered,
		[AmountRequested] decimal(12,2) NULL,
		[AmountReceived] decimal(12,2) NULL,
		[Currency] char(3),
		[TxStatus] smallint,
		[TxType] smallint,
		[Channel] char(1)
	)

	IF OBJECT_ID('tempdb..#MainFilter') IS NOT NULL DROP TABLE #MainFilter
	CREATE TABLE #MainFilter (TransactionSearchID bigint not null primary key clustered)

	-- If we only have dates and a search string, then use FTS first, and join to the main table afterward.
	-- If not, prefilter, then use the FTS at the end.
	IF (@SearchString is not null) AND (
		(@BusinessId is null) AND 
		(@MerchantId is null) AND 
		(@FromAmount is null) AND 
		(@ToAmount is null) AND 
		(@ExactAmount is null) AND 
		(@Currency is null) AND 
		(@PaymentMethod is null) AND 
		(@TxStatus is null) AND 
		(not exists(select * from @TxType)) AND 
		(@Channel is null))
	BEGIN
		-- Just an open ended-search, so skip the filtering
		INSERT INTO #MainFilter
			SELECT TransactionSearchId FROM tblTransactionSearch
			WHERE StartTime>=@FromDateTime AND StartTime<@ToDateTime AND CONTAINS(SearchString,@SearchString)

		-- Now null out the search string, so we don't force an additional CONTAINS check below
		SELECT @SearchString=null
	END
	ELSE
	BEGIN
		-- First limit the search by business,mid and time - main filters, built dynamically to aboid ISNULL checking on every row.
		IF @PaymentMethod is null
		BEGIN
			SELECT @SQL='INSERT INTO #PreFilter SELECT TransactionSearchId,AmountRequested,AmountReceived,Currency,TxStatus,TxType,Channel '+ 
				'FROM tblTransactionSearch WITH (NOLOCK) '+
				'WHERE StartTime>='''+CONVERT(nvarchar(19),@FromDateTime,121)+''' AND StartTime<'''++CONVERT(nvarchar(19),@TODateTime,121)++''' AND '

			IF @BusinessId is not null SELECT @SQL=@SQL+'BusinessId='+CAST(@BusinessId as nvarchar(20))+' AND '
			IF @MerchantId is not null SELECT @SQL=@SQL+'MerchantId='+CAST(@MerchantId as nvarchar(20))+' AND '
		END
		ELSE
		BEGIN
			SELECT @SQL='INSERT INTO #PreFilter SELECT DISTINCT(ts.TransactionSearchId),AmountRequested,AmountReceived,Currency,TxStatus,TxType,Channel '+ 
				'FROM tblTransactionSearch ts WITH (NOLOCK) INNER JOIN tblTransactionSearchPaymentMethods tspm WITH (NOLOCK) '+
				'ON ts.TransactionSearchId=tspm.TransactionSearchId '+
				'WHERE StartTime>='''+CONVERT(nvarchar(19),@FromDateTime,121)+''' AND StartTime<'''++CONVERT(nvarchar(19),@TODateTime,121)++''' AND '+
				'tspm.PaymentMethod='''+@PaymentMethod+''' AND '
			
			IF @BusinessId is not null SELECT @SQL=@SQL+'BusinessId='+CAST(@BusinessId as nvarchar(20))+' AND '
			IF @MerchantId is not null SELECT @SQL=@SQL+'MerchantId='+CAST(@MerchantId as nvarchar(20))+' AND '
		END

		-- Trim trailing AND and execute to populate #PreFilter
		SELECT @SQL=LEFT(@SQL,len(@SQL)-4)
		EXEC(@SQL)

		-- Build a suitable dynamic index based in search criteria.  Faster with no non-clustered index creation
		IF (@FromAmount is null) and (@ToAmount is not null) SELECT @FromAmount=0.00
		IF (@ToAmount is null) and (@FromAmount is not null) SELECT @ToAmount=100000.00

		SELECT @SQL='INSERT INTO #MainFilter SELECT TransactionSearchId FROM #PreFilter WHERE '
		IF (@FromAmount is not null) AND (@ExactAmount is null) 
			SELECT @SQL=@SQL+'(AmountRequested>='+cast(@FromAmount as nvarchar(20))+
							' AND AmountRequested<='+cast(@ToAmount as nvarchar(20))+')   AND '
		IF (@ExactAmount is not null) 
			SELECT @SQL=@SQL+'AmountRequested='+cast(@ExactAmount as nvarchar(20))+'   AND '
		IF (@Currency is not null) SELECT @SQL=@SQL+'Currency='''+@Currency+'''   AND '
		IF (@TxStatus is not null) SELECT @SQL=@SQL+'TxStatus='+cast(@TxStatus as nvarchar(10))+'   AND '
		DECLARE @TxList nvarchar(255)=null
		SELECT @TxList=COALESCE(@TxList + ',', '') + cast(TransactionTypeId as nvarchar(10)) FROM @TxType
		IF (@TxList is not null) SELECT @SQL=@SQL+'TxType IN ('+@TxList+')   AND '
		IF (@Channel is not null) SELECT @SQL=@SQL+'Channel='''+@Channel+'''   AND '

		SELECT @SQL=LEFT(@SQL,len(@SQL)-6)
		EXEC(@SQL)
	END

	IF OBJECT_ID('tempdb..#SearchResults') IS NOT NULL DROP TABLE #SearchResults

	CREATE TABLE #SearchResults(
		[TransactionSearchId] [bigint] NOT NULL PRIMARY KEY CLUSTERED,
		[PrincipalId] [bigint] NULL,
		[StartTime] [datetime2](7) NOT NULL,
		[PaymentJobReference] [nvarchar](255) NULL,
		[CustomerName] [nvarchar](340) NULL,
		[AmountRequested] [decimal](12, 2) NOT NULL,
		[AmountReceived] [decimal](12, 2) NOT NULL,
		[Currency] [char](3) NOT NULL,
		[TxStatus] [int] NOT NULL,
		[TxType] [INT] NOT NULL,
		[Channel] [char](1) NOT NULL,
		[PrimaryMethod] [nvarchar](20) NULL,
		[PrimaryReference] [nvarchar](255) NULL
	)

	IF @SearchString is null
	BEGIN
		-- No full text search, so simple index seek
		INSERT INTO #SearchResults 
			SELECT ts.TransactionSearchId,[PrincipalId],[StartTime],[PaymentJobReference],[CustomerName],[AmountRequested],[AmountReceived],
					[Currency],ts.TxStatus, ts.TxType,[Channel],tspm.PaymentMethod,tspm.PaymentMethodReference
			FROM tblTransactionSearch ts INNER JOIN #MainFilter m on m.TransactionSearchID=ts.TransactionSearchId
				LEFT JOIN tblTransactionSearchPaymentMethods tspm on tspm.TransactionSearchId=m.TransactionSearchId and tspm.[Priority]=1
	END
	ELSE
	BEGIN
		-- Full text search, so need the contains function.
		INSERT INTO #SearchResults 
			SELECT ts.TransactionSearchId,[PrincipalId],[StartTime],[PaymentJobReference],[CustomerName],[AmountRequested],[AmountReceived],
					[Currency],ts.TxStatus, ts.TxType,[Channel],tspm.PaymentMethod,tspm.PaymentMethodReference
			FROM tblTransactionSearch ts INNER JOIN #MainFilter m on m.TransactionSearchID=ts.TransactionSearchId
				LEFT JOIN tblTransactionSearchPaymentMethods tspm on tspm.TransactionSearchId=m.TransactionSearchId and tspm.[Priority]=1
			WHERE CONTAINS(SearchString,@SearchString)
	END

	---- STEP 2: Now remove any entries other than the main payment job IF the payment job entry is being returned by the search.
	DELETE FROM #SearchResults WHERE PaymentJobReference in (SELECT PaymentJobReference FROM #SearchResults WHERE Channel='G') and Channel<>'G'

    DECLARE @totalCount INT;

	-- We need a total count of rows for the pagination
    SELECT @totalCount = COUNT(*) FROM #SearchResults;

	-- Now only return the page we need in the sort order specified, and add other output info for the selected page only.  Datetime is default.
	CREATE TABLE #FullSearchResults(
		[TransactionSearchId] [bigint] NOT NULL,
		[PrincipalId] [bigint] NULL,
		[StartTime] [datetime2](7) NOT NULL,
		[PaymentJobReference] [nvarchar](255) NULL,
		[CustomerName] [nvarchar](340) NULL,
		[AmountRequested] [decimal](12, 2) NOT NULL,
		[AmountReceived] [decimal](12, 2) NOT NULL,
		[Currency] [char](3) NOT NULL,
		[TxStatus] [int] NOT NULL,
		[TxType] [INT] NOT NULL,
		[Channel] [char](1) NOT NULL,
		[PrimaryMethod] [nvarchar](20) NULL,
		[PrimaryReference] [nvarchar](255) NULL,
		[BusinessId] [int] NULL,
		[MerchantId] [int] NULL,
		[GatewayTerminalId] [nvarchar](50) NULL,
		[MerchantReference] [nvarchar](255) NULL,
		[ARN] [nvarchar](32) NULL,
		[TxTypeDescription] [NVARCHAR](50) NULL,
		[GatewayDetailsEndpoint] [nvarchar](400) NULL,
		[PaymentMethods] [nvarchar](1000) NULL
	)
	
	IF @SortOrder='Descending'
	BEGIN
		IF @SortBy='Reference'
			INSERT INTO #FullSearchResults(TransactionSearchId,PrincipalId,StartTime,PaymentJobReference,CustomerName,AmountRequested,
											AmountReceived,Currency,TxStatus,TxType,Channel,PrimaryMethod,PrimaryReference)
			SELECT * FROM #SearchResults
			ORDER BY PrimaryReference DESC OFFSET [dbo].[fsPaginationOffSetValue](@pageNumber, @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY;
		ELSE IF @SortBy='PaymentJobReference'
			INSERT INTO #FullSearchResults(TransactionSearchId,PrincipalId,StartTime,PaymentJobReference,CustomerName,AmountRequested,
											AmountReceived,Currency,TxStatus,TxType,Channel,PrimaryMethod,PrimaryReference)
			SELECT * FROM #SearchResults
			ORDER BY PaymentJobReference DESC OFFSET [dbo].[fsPaginationOffSetValue](@pageNumber, @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY;
		ELSE IF @SortBy='CustomerName'
			INSERT INTO #FullSearchResults(TransactionSearchId,PrincipalId,StartTime,PaymentJobReference,CustomerName,AmountRequested,
											AmountReceived,Currency,TxStatus,TxType,Channel,PrimaryMethod,PrimaryReference)
			SELECT * FROM #SearchResults
			ORDER BY CustomerName DESC OFFSET [dbo].[fsPaginationOffSetValue](@pageNumber, @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY;
		ELSE IF @SortBy='Currency'
			INSERT INTO #FullSearchResults(TransactionSearchId,PrincipalId,StartTime,PaymentJobReference,CustomerName,AmountRequested,
											AmountReceived,Currency,TxStatus,TxType,Channel,PrimaryMethod,PrimaryReference)
			SELECT * FROM #SearchResults
			ORDER BY Currency DESC OFFSET [dbo].[fsPaginationOffSetValue](@pageNumber, @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY;
		ELSE IF @SortBy='AmountRequested'
			INSERT INTO #FullSearchResults(TransactionSearchId,PrincipalId,StartTime,PaymentJobReference,CustomerName,AmountRequested,
											AmountReceived,Currency,TxStatus,TxType,Channel,PrimaryMethod,PrimaryReference)
			SELECT * FROM #SearchResults
			ORDER BY AmountRequested DESC OFFSET [dbo].[fsPaginationOffSetValue](@pageNumber, @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY;
		ELSE IF @SortBy='AmountReceived'
			INSERT INTO #FullSearchResults(TransactionSearchId,PrincipalId,StartTime,PaymentJobReference,CustomerName,AmountRequested,
											AmountReceived,Currency,TxStatus,TxType,Channel,PrimaryMethod,PrimaryReference)
			SELECT * FROM #SearchResults
			ORDER BY AmountReceived DESC OFFSET [dbo].[fsPaginationOffSetValue](@pageNumber, @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY;
		ELSE IF @SortBy='Status'
			INSERT INTO #FullSearchResults(TransactionSearchId,PrincipalId,StartTime,PaymentJobReference,CustomerName,AmountRequested,
											AmountReceived,Currency,TxStatus,TxType,Channel,PrimaryMethod,PrimaryReference)
			SELECT * FROM #SearchResults
			ORDER BY TxStatus DESC OFFSET [dbo].[fsPaginationOffSetValue](@pageNumber, @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY;
		ELSE IF @SortBy='Type'
			INSERT INTO #FullSearchResults(TransactionSearchId,PrincipalId,StartTime,PaymentJobReference,CustomerName,AmountRequested,
											AmountReceived,Currency,TxStatus,TxType,Channel,PrimaryMethod,PrimaryReference)
			SELECT * FROM #SearchResults
			ORDER BY TxType DESC OFFSET [dbo].[fsPaginationOffSetValue](@pageNumber, @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY;
		ELSE IF @SortBy='Method'
			INSERT INTO #FullSearchResults(TransactionSearchId,PrincipalId,StartTime,PaymentJobReference,CustomerName,AmountRequested,
											AmountReceived,Currency,TxStatus,TxType,Channel,PrimaryMethod,PrimaryReference)
			SELECT * FROM #SearchResults
			ORDER BY PrimaryMethod DESC OFFSET [dbo].[fsPaginationOffSetValue](@pageNumber, @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY;
		ELSE IF @SortBy='Channel'
			INSERT INTO #FullSearchResults(TransactionSearchId,PrincipalId,StartTime,PaymentJobReference,CustomerName,AmountRequested,
											AmountReceived,Currency,TxStatus,TxType,Channel,PrimaryMethod,PrimaryReference)
			SELECT * FROM #SearchResults
			ORDER BY Channel DESC OFFSET [dbo].[fsPaginationOffSetValue](@pageNumber, @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY;
		ELSE -- Date by default
			INSERT INTO #FullSearchResults(TransactionSearchId,PrincipalId,StartTime,PaymentJobReference,CustomerName,AmountRequested,
											AmountReceived,Currency,TxStatus,TxType,Channel,PrimaryMethod,PrimaryReference)
			SELECT * FROM #SearchResults
			ORDER BY StartTime DESC OFFSET [dbo].[fsPaginationOffSetValue](@pageNumber, @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY;
	END
	ELSE
	BEGIN
		IF @SortBy='Reference'
			INSERT INTO #FullSearchResults(TransactionSearchId,PrincipalId,StartTime,PaymentJobReference,CustomerName,AmountRequested,
											AmountReceived,Currency,TxStatus,TxType,Channel,PrimaryMethod,PrimaryReference)
			SELECT * FROM #SearchResults
			ORDER BY PrimaryReference ASC OFFSET [dbo].[fsPaginationOffSetValue](@pageNumber, @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY;
		ELSE IF @SortBy='PaymentJobReference'
			INSERT INTO #FullSearchResults(TransactionSearchId,PrincipalId,StartTime,PaymentJobReference,CustomerName,AmountRequested,
											AmountReceived,Currency,TxStatus,TxType,Channel,PrimaryMethod,PrimaryReference)
			SELECT * FROM #SearchResults
			ORDER BY PaymentJobReference ASC OFFSET [dbo].[fsPaginationOffSetValue](@pageNumber, @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY;
		ELSE IF @SortBy='CustomerName'
			INSERT INTO #FullSearchResults(TransactionSearchId,PrincipalId,StartTime,PaymentJobReference,CustomerName,AmountRequested,
											AmountReceived,Currency,TxStatus,TxType,Channel,PrimaryMethod,PrimaryReference)
			SELECT * FROM #SearchResults
			ORDER BY CustomerName ASC OFFSET [dbo].[fsPaginationOffSetValue](@pageNumber, @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY;
		ELSE IF @SortBy='Currency'
			INSERT INTO #FullSearchResults(TransactionSearchId,PrincipalId,StartTime,PaymentJobReference,CustomerName,AmountRequested,
											AmountReceived,Currency,TxStatus,TxType,Channel,PrimaryMethod,PrimaryReference)
			SELECT * FROM #SearchResults
			ORDER BY Currency ASC OFFSET [dbo].[fsPaginationOffSetValue](@pageNumber, @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY;
		ELSE IF @SortBy='AmountRequested'
			INSERT INTO #FullSearchResults(TransactionSearchId,PrincipalId,StartTime,PaymentJobReference,CustomerName,AmountRequested,
											AmountReceived,Currency,TxStatus,TxType,Channel,PrimaryMethod,PrimaryReference)
			SELECT * FROM #SearchResults
			ORDER BY AmountRequested ASC OFFSET [dbo].[fsPaginationOffSetValue](@pageNumber, @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY;
		ELSE IF @SortBy='AmountReceived'
			INSERT INTO #FullSearchResults(TransactionSearchId,PrincipalId,StartTime,PaymentJobReference,CustomerName,AmountRequested,
											AmountReceived,Currency,TxStatus,TxType,Channel,PrimaryMethod,PrimaryReference)
			SELECT * FROM #SearchResults
			ORDER BY AmountReceived ASC OFFSET [dbo].[fsPaginationOffSetValue](@pageNumber, @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY;
		ELSE IF @SortBy='Status'
			INSERT INTO #FullSearchResults(TransactionSearchId,PrincipalId,StartTime,PaymentJobReference,CustomerName,AmountRequested,
											AmountReceived,Currency,TxStatus,TxType,Channel,PrimaryMethod,PrimaryReference)
			SELECT * FROM #SearchResults
			ORDER BY TxStatus ASC OFFSET [dbo].[fsPaginationOffSetValue](@pageNumber, @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY;
		ELSE IF @SortBy='Type'
			INSERT INTO #FullSearchResults(TransactionSearchId,PrincipalId,StartTime,PaymentJobReference,CustomerName,AmountRequested,
											AmountReceived,Currency,TxStatus,TxType,Channel,PrimaryMethod,PrimaryReference)
			SELECT * FROM #SearchResults
			ORDER BY TxType ASC OFFSET [dbo].[fsPaginationOffSetValue](@pageNumber, @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY;
		ELSE IF @SortBy='Method'
			INSERT INTO #FullSearchResults(TransactionSearchId,PrincipalId,StartTime,PaymentJobReference,CustomerName,AmountRequested,
											AmountReceived,Currency,TxStatus,TxType,Channel,PrimaryMethod,PrimaryReference)
			SELECT * FROM #SearchResults
			ORDER BY PrimaryMethod ASC OFFSET [dbo].[fsPaginationOffSetValue](@pageNumber, @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY;
		ELSE IF @SortBy='Channel'
			INSERT INTO #FullSearchResults(TransactionSearchId,PrincipalId,StartTime,PaymentJobReference,CustomerName,AmountRequested,
											AmountReceived,Currency,TxStatus,TxType,Channel,PrimaryMethod,PrimaryReference)
			SELECT * FROM #SearchResults
			ORDER BY Channel ASC OFFSET [dbo].[fsPaginationOffSetValue](@pageNumber, @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY;
		ELSE -- Date by default
			INSERT INTO #FullSearchResults(TransactionSearchId,PrincipalId,StartTime,PaymentJobReference,CustomerName,AmountRequested,
											AmountReceived,Currency,TxStatus,TxType,Channel,PrimaryMethod,PrimaryReference)
			SELECT * FROM #SearchResults
			ORDER BY StartTime ASC OFFSET [dbo].[fsPaginationOffSetValue](@pageNumber, @pageSize) ROWS FETCH NEXT @pageSize ROWS ONLY;
	END

	-- Now update the search results with extra data
	UPDATE #FullSearchResults SET
		BusinessId=x.BusinessId,
		MerchantId=x.MerchantId,
		GatewayTerminalId=x.GatewayTerminalId,
		MerchantReference=x.MerchantReference,
		ARN=x.ARN,
		TxTypeDescription=x.TxTypeDescription,
		GatewayDetailsEndpoint=x.GatewayDetailsEndpoint,
		PaymentMethods=x.PaymentMethods
	FROM
	(SELECT ts.TransactionSearchId,ts.[BusinessId],ts.[MerchantId],ts.[GatewayTerminalId],ts.[MerchantReference],ts.[ARN],tt.TransactionType as 'TxTypeDescription',
			ts.[GatewayDetailsEndpoint], STUFF((
					SELECT N', ' + x.PaymentMethod FROM tblTransactionSearchPaymentMethods x
					WHERE x.TransactionSearchId = ts.TransactionSearchId order by x.[Priority] asc
					FOR XML PATH(''), TYPE).value(N'.[1]', N'nvarchar(1000)'), 1, 2, N'') as 'PaymentMethods'
		FROM tblTransactionSearch ts INNER JOIN #FullSearchResults f on f.TransactionSearchID=ts.TransactionSearchId
		INNER JOIN tlkpTransactionType tt on ts.TxType=tt.TransactionTypeId) as x
	INNER JOIN #FullSearchResults f on f.TransactionSearchId=x.TransactionSearchId

	-- And return the data
	IF @SortOrder='Descending'
	BEGIN
		IF @SortBy='Reference'
			SELECT * FROM #FullSearchResults ORDER BY PrimaryReference DESC 
		ELSE IF @SortBy='PaymentJobReference'
			SELECT * FROM #FullSearchResults ORDER BY PaymentJobReference DESC 
		ELSE IF @SortBy='CustomerName'
			SELECT * FROM #FullSearchResults ORDER BY CustomerName DESC 
		ELSE IF @SortBy='Currency'
			SELECT * FROM #FullSearchResults ORDER BY Currency DESC 
		ELSE IF @SortBy='AmountRequested'
			SELECT * FROM #FullSearchResults ORDER BY AmountRequested DESC 
		ELSE IF @SortBy='AmountReceived'
			SELECT * FROM #FullSearchResults ORDER BY AmountReceived DESC 
		ELSE IF @SortBy='Status'
			SELECT * FROM #FullSearchResults ORDER BY TxStatus DESC 
		ELSE IF @SortBy='Type'
			SELECT * FROM #FullSearchResults ORDER BY TxType DESC 
		ELSE IF @SortBy='Method'
			SELECT * FROM #FullSearchResults ORDER BY PrimaryMethod DESC 
		ELSE IF @SortBy='Channel'
			SELECT * FROM #FullSearchResults ORDER BY Channel DESC 
		ELSE -- Date by default
			SELECT * FROM #FullSearchResults ORDER BY StartTime DESC 
	END
	ELSE
	BEGIN
		IF @SortBy='Reference'
			SELECT * FROM #FullSearchResults ORDER BY PrimaryReference ASC 
		ELSE IF @SortBy='PaymentJobReference'
			SELECT * FROM #FullSearchResults ORDER BY PaymentJobReference ASC 
		ELSE IF @SortBy='CustomerName'
			SELECT * FROM #FullSearchResults ORDER BY CustomerName ASC 
		ELSE IF @SortBy='Currency'
			SELECT * FROM #FullSearchResults ORDER BY Currency ASC 
		ELSE IF @SortBy='AmountRequested'
			SELECT * FROM #FullSearchResults ORDER BY AmountRequested ASC 
		ELSE IF @SortBy='AmountReceived'
			SELECT * FROM #FullSearchResults ORDER BY AmountReceived ASC 
		ELSE IF @SortBy='Status'
			SELECT * FROM #FullSearchResults ORDER BY TxStatus ASC 
		ELSE IF @SortBy='Type'
			SELECT * FROM #FullSearchResults ORDER BY TxType ASC 
		ELSE IF @SortBy='Method'
			SELECT * FROM #FullSearchResults ORDER BY PrimaryMethod ASC 
		ELSE IF @SortBy='Channel'
			SELECT * FROM #FullSearchResults ORDER BY Channel ASC 
		ELSE -- Date by default
			SELECT * FROM #FullSearchResults ORDER BY StartTime ASC 
	END


    -- Return search metrics in second result set
	SELECT
		@pageSize AS ResultsPerPage,
        @pageNumber AS PageNumber,
        @totalCount AS TotalCount

	IF OBJECT_ID('tempdb..#PreFilter') IS NOT NULL DROP TABLE #PreFilter
	IF OBJECT_ID('tempdb..#MainFilter') IS NOT NULL DROP TABLE #MainFilter
	IF OBJECT_ID('tempdb..#SearchResults') IS NOT NULL DROP TABLE #SearchResults
	IF OBJECT_ID('tempdb..#FullSearchResults') IS NOT NULL DROP TABLE #FullSearchResults

END
GO
GRANT EXECUTE ON  [dbo].[spTransactionSearch] TO [DataServiceUser]
GO
