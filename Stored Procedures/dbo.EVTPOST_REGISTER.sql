SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE   PROCEDURE [dbo].[EVTPOST_REGISTER]
(
    @cv_1 VARCHAR(2000) OUTPUT,
    @p_registry_id BIGINT,
    @p_accgrp_id BIGINT,
    @p_evttype_id BIGINT,
    @p_accfromtype_id BIGINT = NULL,
    @p_acctotype_id BIGINT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_registry_id BIGINT;
    SET @cv_1 = NULL;

    IF @p_registry_id IS NULL
        SELECT @v_registry_id = NEXT VALUE FOR dbo.HIBERNATE_SEQUENCE;
    ELSE
        SELECT @v_registry_id = @p_registry_id;

    WITH accgrp_postrules
    AS (SELECT @p_accgrp_id AS account_group_id,
               EVENT_TYPE_ID,
               TRANSFER_TYPE_ID,
               FROM_ACCOUNT_TYPE_ID,
               TO_ACCOUNT_TYPE_ID,
               ACCOUNT_GROUP_TYPE,
               FROM_ACCOUNT_ARREARS_TYPE_ID,
               TO_ACCOUNT_ARREARS_TYPE_ID
        FROM ACC_POSTING_RULES pr
        WHERE EVENT_TYPE_ID = @p_evttype_id
          AND @p_accgrp_id IS NOT NULL
          AND FROM_ACCOUNT_TYPE_ID = ISNULL(@p_accfromtype_id, FROM_ACCOUNT_TYPE_ID)
          AND TO_ACCOUNT_TYPE_ID = ISNULL(@p_acctotype_id, TO_ACCOUNT_TYPE_ID))
    INSERT INTO ACC_EVTPOST_REGISTRY
    (
        ID,
        ACCOUNT_GROUP_ID,
        EVENT_TYPE_ID,
        TRANSFER_TYPE_ID,
        FROM_ACCOUNT_ID,
        FROM_BALANCE,
        FROM_ARREARS_TYPE_ID,
        FROM_MATURITY_HOURS,
        FROM_MINIMUM_BALANCE,
        TO_ACCOUNT_ID,
        TO_BALANCE,
        TO_ARREARS_TYPE_ID,
        TO_MATURITY_HOURS,
        STAMP
    )
    SELECT @v_registry_id AS id,
           ag_pr.account_group_id AS account_group_id,
           ag_pr.EVENT_TYPE_ID AS event_type_id,
           ag_pr.TRANSFER_TYPE_ID AS transfer_type_id,
           from_acc.ACCOUNT_ID AS from_account_id,
           NULL AS from_balance,
           ag_pr.FROM_ACCOUNT_ARREARS_TYPE_ID from_arrears_type_id,
           from_acc.MATURITY_HOURS AS from_maturity_hours,
           from_par.MIN_BALANCE_MINOR_UNITS AS from_min_acc_bal,
           to_acc.ACCOUNT_ID AS to_account_id,
           NULL AS to_balance,
           ag_pr.TO_ACCOUNT_ARREARS_TYPE_ID AS to_arrears_type_id,
           to_acc.MATURITY_HOURS AS to_maturity_hours,
           GETDATE()
    FROM accgrp_postrules ag_pr JOIN ACC_ACCOUNTS from_acc WITH (NOLOCK) ON from_acc.ACCOUNT_GROUP_ID = ag_pr.account_group_id AND from_acc.ACCOUNT_TYPE_ID = ag_pr.FROM_ACCOUNT_TYPE_ID
                                JOIN ACC_ACCOUNTS to_acc WITH (NOLOCK)   ON to_acc.ACCOUNT_GROUP_ID = ag_pr.account_group_id   AND to_acc.ACCOUNT_TYPE_ID = ag_pr.TO_ACCOUNT_TYPE_ID
                                JOIN ACC_ACCOUNT_GROUPS accgrp           ON accgrp.ACCOUNT_GROUP_ID = ag_pr.account_group_id   AND accgrp.ACCOUNT_GROUP_TYPE = ag_pr.ACCOUNT_GROUP_TYPE
                                JOIN ACC_POSTING_ACCOUNT_RULES to_par    ON to_par.EVENT_TYPE_ID = ag_pr.EVENT_TYPE_ID    AND to_par.ACCOUNT_TYPE_ID = ag_pr.TO_ACCOUNT_TYPE_ID     AND to_par.ACCOUNT_GROUP_TYPE = ag_pr.ACCOUNT_GROUP_TYPE
                                JOIN ACC_POSTING_ACCOUNT_RULES from_par  ON from_par.EVENT_TYPE_ID = ag_pr.EVENT_TYPE_ID  AND from_par.ACCOUNT_TYPE_ID = ag_pr.FROM_ACCOUNT_TYPE_ID AND from_par.ACCOUNT_GROUP_TYPE = ag_pr.ACCOUNT_GROUP_TYPE;

    SELECT @v_registry_id AS id;

END;
GO
