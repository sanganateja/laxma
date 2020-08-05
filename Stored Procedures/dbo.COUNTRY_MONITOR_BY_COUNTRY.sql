SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[COUNTRY_MONITOR_BY_COUNTRY]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_country_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    /*
      *   SSMA warning messages:
      *   O2SS0204: Subqueries with ROWNUM emulation may have unnecessary columns.
      */

    SELECT SSMAROWNUM.MONITOR_ID,
           SSMAROWNUM.COUNTRY_ID,
           SSMAROWNUM.DESCRIPTION,
           SSMAROWNUM.CREATION_DATE
    FROM
    (
        SELECT MONITOR_ID,
               COUNTRY_ID,
               DESCRIPTION,
               CREATION_DATE,
               COUNTRY_ID$2,
               ROW_NUMBER() OVER (ORDER BY SSMAPSEUDOCOLUMN) AS ROWNUM
        FROM
        (
            SELECT cm.MONITOR_ID,
                   cm.COUNTRY_ID,
                   cm.DESCRIPTION,
                   cm.CREATION_DATE,
                   cm.COUNTRY_ID AS COUNTRY_ID$2,
                   0 AS SSMAPSEUDOCOLUMN
            FROM dbo.ACC_COUNTRY_MONITORS AS cm
            WHERE cm.COUNTRY_ID = @p_country_id
                  AND 1 = 1
        ) AS SSMAPSEUDO
    ) AS SSMAROWNUM
    WHERE SSMAROWNUM.COUNTRY_ID = @p_country_id
          AND SSMAROWNUM.ROWNUM = 1;

    RETURN;

END;
GO
