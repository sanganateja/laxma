SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[COUNTRY_MONITOR_CREATE]
    @p_country_id NUMERIC,
    @p_creation_date DATETIME2(6),
    @p_description NVARCHAR(2000),
    @p_monitor_id NUMERIC
AS
BEGIN
    INSERT dbo.ACC_COUNTRY_MONITORS
    (
        MONITOR_ID,
        COUNTRY_ID,
        DESCRIPTION,
        CREATION_DATE
    )
    VALUES
    (@p_monitor_id, @p_country_id, @p_description, @p_creation_date);
END;
GO
