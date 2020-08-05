SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[spAccountSeqIncrement]
AS
BEGIN
SET NOCOUNT ON;

                    CREATE TABLE #TEMPSEQTABLE  (seqname VARCHAR(MAX), currvalue BIGINT, incr BIGINT, restartvalue BIGINT) 

                    INSERT INTO #TEMPSEQTABLE (seqname, incr) values ('PRICING_TIER_ALLOW_SEQUENCE' , 1000);
                    INSERT INTO #TEMPSEQTABLE (seqname, incr) values ('PRICING_TIER_MONTH_SEQUENCE' , 1000);
                    INSERT INTO #TEMPSEQTABLE (seqname, incr) values ('PRICING_TIER_SEQUENCE' , 1000);
                    INSERT INTO #TEMPSEQTABLE (seqname, incr) values ('PRICING_TIER_XFER_SEQUENCE' , 1000);
                    INSERT INTO #TEMPSEQTABLE (seqname, incr) values ('PRICING_TURNOVER_BAND_SEQUENCE' , 1000);
                    INSERT INTO #TEMPSEQTABLE (seqname, incr) values ('TRANSACTION_SEQUENCE' , 10000);
                    INSERT INTO #TEMPSEQTABLE (seqname, incr) values ('TRANSFER_FEE_SEQUENCE' , 100);
                    INSERT INTO #TEMPSEQTABLE (seqname, incr) values ('TRANSFER_SEQUENCE' , 10000);
                    INSERT INTO #TEMPSEQTABLE (seqname, incr) values ('MONEYCORP_RETURN_SEQUENCE' , 100);
                    INSERT INTO #TEMPSEQTABLE (seqname, incr) values ('MONEYCORP_RESPONSE_SEQUENCE' , 100);
                    INSERT INTO #TEMPSEQTABLE (seqname, incr) values ('ACC_SESSIONS_SEQUENCE' , 10000);
                    INSERT INTO #TEMPSEQTABLE (seqname, incr) values ('ACC_COMMISSION_POINTS_SEQUENCE' , 100);
                    INSERT INTO #TEMPSEQTABLE (seqname, incr) values ('TXN_ASSOCIATION_SEQUENCE' , 10000);
                    INSERT INTO #TEMPSEQTABLE (seqname, incr) values ('ACC_PARTNERS_SEQUENCE' , 1000);
                    INSERT INTO #TEMPSEQTABLE (seqname, incr) values ('ACC_COMMISSION_PLANS_SEQUENCE' , 10000);
                    INSERT INTO #TEMPSEQTABLE (seqname, incr) values ('ACC_COMMISSION_TEMP_SEQUENCE' , 1000);
                    INSERT INTO #TEMPSEQTABLE (seqname, incr) values ('ACQUIRING_FEE_SEQUENCE' , 1000);
                    INSERT INTO #TEMPSEQTABLE (seqname, incr) values ('FX_RATE_SEQUENCE' , 1000);
                    INSERT INTO #TEMPSEQTABLE (seqname, incr) values ('HIBERNATE_SEQUENCE' , 100000);
                    INSERT INTO #TEMPSEQTABLE (seqname, incr) values ('MONTHLY_ALLOWANCE_SEQUENCE' , 1000);
                    INSERT INTO #TEMPSEQTABLE (seqname, incr) values ('MONTHLY_FEE_SEQUENCE' , 1000);
                    INSERT INTO #TEMPSEQTABLE (seqname, incr) values ('PAYMENT_MESSAGE_SEQUENCE' , 1000);
                    INSERT INTO #TEMPSEQTABLE (seqname, incr) values ('PRICING_SALES_SEQUENCE' , 1000);
                    INSERT INTO #TEMPSEQTABLE (seqname, incr) values ('PRICING_TEMPLATE_SEQUENCE' , 1000);

                    UPDATE #TEMPSEQTABLE SET currvalue=CAST(s.current_value AS BIGINT) FROM #TEMPSEQTABLE tt 
                    JOIN sys.sequences s ON s.name COLLATE DATABASE_DEFAULT = tt.seqname COLLATE DATABASE_DEFAULT
                    
                    UPDATE #TEMPSEQTABLE SET restartvalue=currvalue+incr;

                    SELECT 'ALTER SEQUENCE ' 
                    +  seqname
                    +  ' RESTART WITH '
                    +  CAST(restartvalue AS VARCHAR(max)) + ';' AS [QUERY] FROM #TEMPSEQTABLE;
    
    END
GO
