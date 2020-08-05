SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[MONTHLY_FEE_ACTIVE_FOR_OWNER]
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_fee_type_id NUMERIC,
    @p_owner_id NUMERIC
AS
BEGIN

    SET @cv_1 = NULL;

    SELECT mf.MONTHLY_FEE_ID,
           mf.OWNER_ID,
           mf.CURRENCY_CODE_ALPHA3,
           mf.AMOUNT_MINOR_UNITS,
           mf.FEE_TYPE_ID
    FROM dbo.ACC_OWNERS AS o
        JOIN dbo.ACC_ACCOUNT_GROUPS AS charge_ag
            JOIN dbo.ACC_MONTHLY_FEES AS mf
                ON mf.OWNER_ID = charge_ag.OWNER_ID
                   AND mf.CURRENCY_CODE_ALPHA3 = charge_ag.CURRENCY_CODE_ALPHA3
            ON charge_ag.ACCOUNT_GROUP_ID = o.CHARGING_ACCOUNT_GROUP_ID
    WHERE o.OWNER_ID = @p_owner_id
          AND mf.FEE_TYPE_ID = @p_fee_type_id;

    RETURN;

END;
GO
