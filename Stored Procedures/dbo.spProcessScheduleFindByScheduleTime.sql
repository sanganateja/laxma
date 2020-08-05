SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[spProcessScheduleFindByScheduleTime]
    @cv_1 VARCHAR(2000) OUTPUT,
    @ScheduleTime DATETIME2
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT ProcessScheduleId,
           ScheduleTimeUTC,
           Maturity,
           Remittance,
           Payment
    FROM dbo.tlkpProcessSchedule
    WHERE ScheduleTimeUTC = CONVERT(Time, @ScheduleTime);

END;
GO
