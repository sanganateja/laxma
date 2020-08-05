SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ================================================================================
--	Author:			Mat
--	Create date:	28/02/2019
--	Description:	
--		Retrieves the messages from the CoreMessageQueue whilst handling any
--		Service Broker conversation message behind the scenes.
--
--	Return:			
--		Message as a result set, or nothing
--
--  Change history
--      28/02/2019  - Mat     - First version (based on Alliance)
--      07/06/2019  - Andy A  - Added CHP cost parameters
--
-- ================================================================================
CREATE PROCEDURE [dbo].[spGetCoreMessage] @cv_1 VARCHAR(2000) OUTPUT
AS
BEGIN
    SET @cv_1 = NULL;

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @ConversationHandle uniqueidentifier,@NewConversation uniqueidentifier;
    DECLARE @MessageType sysname;
    DECLARE @messageXML xml;
    DECLARE @ProcessState nvarchar(10)
    DECLARE @TransactionReference nvarchar(50);

    -- First check if we WANT this queue to return data
    SELECT @ProcessState=null
    SELECT @ProcessState=SettingValue from tblGlobalSetting with (nolock) where SettingName='CoreMessageQueue_Process'
		
    -- If there is no setting for this queue, set it to Yes by default
    IF (@ProcessState is null)
    BEGIN
        SET @ProcessState='Yes'
        INSERT INTO tblGlobalSetting(SettingName,SettingValue) VALUES('CoreMessageQueue_Process','Yes')
    END
			
    -- Right, get the message if the flags allow us
    IF (@ProcessState='Yes')
    BEGIN
        BEGIN TRY

            BEGIN TRANSACTION;

            -- Grab the top message using the Queue processing Sproc
            EXEC spMessageProcessor 'CoreMessageQueue',@MessageXML output,@MessageType output,@ConversationHandle output

            -- Empty message means we're all done
            IF (@messagetype is null)
            BEGIN
                IF (XACT_STATE()=1) COMMIT TRANSACTION
                    RETURN
            END

            -- We have a message, so deal with it			
            IF N'CoreMessageMessage' = @messagetype
            BEGIN							
                -- Grab the transaction reference
                SELECT @TransactionReference=@MessageXML.value('(/CAMPostingDetails/tran_ref)[1]', 'nvarchar(50)')

                -- Now simpply return the XML as a result set
                SELECT 
                    @MessageXML.value('(/CAMPostingDetails/event_time)[1]', 'bigint') as 'event_time',
                    @MessageXML.value('(/CAMPostingDetails/event_type)[1]', 'bigint') as 'event_type',
                    @MessageXML.value('(/CAMPostingDetails/tran_ref)[1]', 'nvarchar(50)') as 'tran_ref',
                    @MessageXML.value('(/CAMPostingDetails/first_tran_ref)[1]', 'nvarchar(50)') as 'first_tran_ref',
                    @MessageXML.value('(/CAMPostingDetails/store_id)[1]', 'bigint') as 'store_id',
                    @MessageXML.value('(/CAMPostingDetails/accgrp)[1]', 'nvarchar(32)') as 'accgrp',
                    @MessageXML.value('(/CAMPostingDetails/currency)[1]', 'char(3)') as 'currency',
                    @MessageXML.value('(/CAMPostingDetails/amount)[1]', 'int') as 'amount',
                    @MessageXML.value('(/CAMPostingDetails/acquirer_id)[1]', 'int') as 'acquirer_id',
                    @MessageXML.value('(/CAMPostingDetails/cart_id)[1]', 'nvarchar(255)') as 'cart_id',
                    @MessageXML.value('(/CAMPostingDetails/charging_class)[1]', 'int') as 'charging_class',
                    @MessageXML.value('(/CAMPostingDetails/card_type)[1]', 'bigint') as 'card_type',
                    @MessageXML.value('(/CAMPostingDetails/region)[1]', 'bigint') as 'region',
                    @MessageXML.value('(/CAMPostingDetails/intchg_fee_program)[1]', 'nvarchar(100)') as 'intchg_fee_program',
                    @MessageXML.value('(/CAMPostingDetails/intchg_rate_tier)[1]', 'nvarchar(100)') as 'intchg_rate_tier',
                    @MessageXML.value('(/CAMPostingDetails/intchg_description)[1]', 'nvarchar(100)') as 'intchg_description',
                    @MessageXML.value('(/CAMPostingDetails/txncst_fee_program)[1]', 'nvarchar(100)') as 'txncst_fee_program',
                    @MessageXML.value('(/CAMPostingDetails/txncst_rate_tier)[1]', 'nvarchar(100)') as 'txncst_rate_tier',
                    @MessageXML.value('(/CAMPostingDetails/txncst_description)[1]', 'nvarchar(100)') as 'txncst_description',
                    @MessageXML.value('(/CAMPostingDetails/csv_merchant_country)[1]', 'nvarchar(2)') as 'csv_merchant_country',
                    @MessageXML.value('(/CAMPostingDetails/csv_issuer_country)[1]', 'nvarchar(2)') as 'csv_issuer_country',
                    @MessageXML.value('(/CAMPostingDetails/csv_card_type)[1]', 'nvarchar(50)') as 'csv_card_type',
                    @MessageXML.value('(/CAMPostingDetails/csm_merchant_country)[1]', 'nvarchar(2)') as 'csm_merchant_country',
                    @MessageXML.value('(/CAMPostingDetails/csm_issuer_country)[1]', 'nvarchar(2)') as 'csm_issuer_country',
                    @MessageXML.value('(/CAMPostingDetails/civ_merchant_country)[1]', 'nvarchar(2)') as 'civ_merchant_country',
                    @MessageXML.value('(/CAMPostingDetails/civ_mcc)[1]', 'nvarchar(4)') as 'civ_mcc',
                    @MessageXML.value('(/CAMPostingDetails/civ_issuer_country)[1]', 'nvarchar(2)') as 'civ_issuer_country',
                    @MessageXML.value('(/CAMPostingDetails/civ_fee_scenario)[1]', 'nvarchar(50)') as 'civ_fee_scenario',
                    @MessageXML.value('(/CAMPostingDetails/civ_afs)[1]', 'nvarchar(1)') as 'civ_afs',
                    @MessageXML.value('(/CAMPostingDetails/civ_pid)[1]', 'nvarchar(2)') as 'civ_pid',
                    @MessageXML.value('(/CAMPostingDetails/civ_product_subtype)[1]', 'nvarchar(50)') as 'civ_product_subtype',
                    @MessageXML.value('(/CAMPostingDetails/civ_product_type)[1]', 'nvarchar(50)') as 'civ_product_type',
                    @MessageXML.value('(/CAMPostingDetails/civ_fpi)[1]', 'nvarchar(100)') as 'civ_fpi',
                    @MessageXML.value('(/CAMPostingDetails/civ_reimb_attr)[1]', 'nvarchar(1)') as 'civ_reimb_attr',
                    @MessageXML.value('(/CAMPostingDetails/civ_card_capability_flag)[1]', 'nvarchar(1)') as 'civ_card_capability_flag',
                    @MessageXML.value('(/CAMPostingDetails/civ_pos_terminal_capability)[1]', 'nvarchar(1)') as 'civ_pos_terminal_capability',
                    @MessageXML.value('(/CAMPostingDetails/civ_auth_code)[1]', 'nvarchar(100)') as 'civ_auth_code',
                    @MessageXML.value('(/CAMPostingDetails/civ_pos_entry_mode)[1]', 'nvarchar(2)') as 'civ_pos_entry_mode',
                    @MessageXML.value('(/CAMPostingDetails/civ_cardholder_id_method)[1]', 'nvarchar(1)') as 'civ_cardholder_id_method',
                    @MessageXML.value('(/CAMPostingDetails/civ_moto_eci)[1]', 'nvarchar(100)') as 'civ_moto_eci',
                    @MessageXML.value('(/CAMPostingDetails/civ_pos_env_code)[1]', 'nvarchar(100)') as 'civ_pos_env_code',
                    @MessageXML.value('(/CAMPostingDetails/civ_ati)[1]', 'nvarchar(100)') as 'civ_ati',
                    @MessageXML.value('(/CAMPostingDetails/civ_auth_resp_code)[1]', 'nvarchar(2)') as 'civ_auth_resp_code',
                    @MessageXML.value('(/CAMPostingDetails/civ_cvv_result)[1]', 'nvarchar(100)') as 'civ_cvv_result',
                    @MessageXML.value('(/CAMPostingDetails/civ_timeliness_days)[1]', 'bigint') as 'civ_timeliness_days',
                    @MessageXML.value('(/CAMPostingDetails/civ_chip_terminal_deployment_flag)[1]', 'nvarchar(1)') as 'civ_chip_terminal_deployment_flag',
                    @MessageXML.value('(/CAMPostingDetails/civ_business_application_identifier)[1]', 'nvarchar(100)') as 'civ_business_application_identifier',
                    @MessageXML.value('(/CAMPostingDetails/civ_auth_charac)[1]', 'nvarchar(100)') as 'civ_auth_charac',
                    @MessageXML.value('(/CAMPostingDetails/civ_requested_payment_service)[1]', 'nvarchar(100)') as 'civ_requested_payment_service',
                    @MessageXML.value('(/CAMPostingDetails/civ_dcci)[1]', 'nvarchar(100)') as 'civ_dcci',
                    @MessageXML.value('(/CAMPostingDetails/cim_merchant_country)[1]', 'nvarchar(2)') as 'cim_merchant_country',
                    @MessageXML.value('(/CAMPostingDetails/cim_mcc)[1]', 'nvarchar(4)') as 'cim_mcc',
                    @MessageXML.value('(/CAMPostingDetails/cim_issuer_country)[1]', 'nvarchar(2)') as 'cim_issuer_country',
                    @MessageXML.value('(/CAMPostingDetails/cim_cab_program)[1]', 'nvarchar(100)') as 'cim_cab_program',
                    @MessageXML.value('(/CAMPostingDetails/cim_ird)[1]', 'nvarchar(2)') as 'cim_ird',
                    @MessageXML.value('(/CAMPostingDetails/cim_pos_terminal_input_capability)[1]', 'nvarchar(1)') as 'cim_pos_terminal_input_capability',
                    @MessageXML.value('(/CAMPostingDetails/cim_card_data_input_mode)[1]', 'nvarchar(1)') as 'cim_card_data_input_mode',
                    @MessageXML.value('(/CAMPostingDetails/cim_cardholder_present_data)[1]', 'int') as 'cim_cardholder_present_data',
                    @MessageXML.value('(/CAMPostingDetails/cim_card_present_data)[1]', 'int') as 'cim_card_present_data',
                    @MessageXML.value('(/CAMPostingDetails/cim_cardholder_auth_capability)[1]', 'int') as 'cim_cardholder_auth_capability',
                    @MessageXML.value('(/CAMPostingDetails/cim_cardholder_auth_method)[1]', 'int') as 'cim_cardholder_auth_method',
                    @MessageXML.value('(/CAMPostingDetails/cim_icc)[1]', 'nvarchar(100)') as 'cim_icc',
                    @MessageXML.value('(/CAMPostingDetails/cim_timeliness_days)[1]', 'bigint') as 'cim_timeliness_days',
                    @MessageXML.value('(/CAMPostingDetails/cim_service_code)[1]', 'nvarchar(1)') as 'cim_service_code',
                    @MessageXML.value('(/CAMPostingDetails/cim_acc_funding_source)[1]', 'nvarchar(1)') as 'cim_acc_funding_source',
                    @MessageXML.value('(/CAMPostingDetails/cim_product_type)[1]', 'nvarchar(100)') as 'cim_product_type',
                    @MessageXML.value('(/CAMPostingDetails/cim_card_prog_identifier)[1]', 'nvarchar(3)') as 'cim_card_prog_identifier',
                    @MessageXML.value('(/CAMPostingDetails/cim_gcms_product_identifier)[1]', 'nvarchar(3)') as 'cim_gcms_product_identifier',
                    @MessageXML.value('(/CAMPostingDetails/cim_mti)[1]', 'nvarchar(4)') as 'cim_mti',
                    @MessageXML.value('(/CAMPostingDetails/cim_function_code)[1]', 'nvarchar(3)') as 'cim_function_code',
                    @MessageXML.value('(/CAMPostingDetails/cim_processing_code)[1]', 'nvarchar(2)') as 'cim_processing_code',
                    @MessageXML.value('(/CAMPostingDetails/cim_approval_code)[1]', 'nvarchar(100)') as 'cim_approval_code',
                    @MessageXML.value('(/CAMPostingDetails/cim_corporate_card_common_data)[1]', 'nvarchar(100)') as 'cim_corporate_card_common_data',
                    @MessageXML.value('(/CAMPostingDetails/cim_corporate_line_item_detail)[1]', 'nvarchar(100)') as 'cim_corporate_line_item_detail'
            END

            END CONVERSATION @conversationhandle;
            IF (XACT_STATE()=1) COMMIT TRANSACTION

        END TRY

        -- Otherwise there has been an error in the processing of the conversation.
        -- Use the CATCH handler to deal with it
        BEGIN CATCH
            -- Always rollback to put the message back on the queue
            IF (XACT_STATE()<>0) ROLLBACK TRANSACTION

            -- Now deal with the mess.  Incrementing count in DBLog or use QueueKiller on 3rd attempt
            EXEC spMessageCatchProcessor 'CoreMessageQueue',@ConversationHandle,@MessageType,@MessageXML

        END CATCH
    END

END
GO
