SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[spProcessScheduleFindAll]
    @cv_1 VARCHAR(2000) OUTPUT
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT ProcessScheduleId,
           ScheduleTimeUTC,
           Maturity,
           Remittance,
           Payment
    FROM dbo.tlkpProcessSchedule;

END;
GO
