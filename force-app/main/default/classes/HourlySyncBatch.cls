/*
* Created By  :  Surender & Suchimitha (Dhruvsoft) 
* Description :  This class is to run hourly sync, which will run for each 15 minutes. It also includes sources(Payment Methods),payments for each customer. 
* Functionalities : All customers & respective payment methods, and transactions will be fetched and linked accordingly.
*/
public with sharing class HourlySyncBatch implements Database.Batchable<BreadwinnerUtil.AppConfig>, Database.AllowsCallouts, Database.Stateful, Schedulable {
    public List<BreadwinnerUtil.AppConfig> appConfigUpdateList = new List<BreadwinnerUtil.AppConfig>();
    public List<BreadwinnerUtil.AppConfig> appConfigList = new List<BreadwinnerUtil.AppConfig>();
    public String runningObject;
    Exception exceptionInExecute;
    public Integer requestRecordsCount;
    public String errors;

    //Constructor with BreadwinnerUtil.AppConfig input. This input will have updated BreadwinnerUtil.AppConfig data during runtime. It also can be used to run for specific BreadwinnerUtil.AppConfig.
    public HourlySyncBatch(String objectName, List<BreadwinnerUtil.AppConfig> appconfigs) {
        if(BreadwinnerUtil.getBWSetting().Active__c) {
            for(BreadwinnerUtil.AppConfig apC : appconfigs) {
                if(!apC.needToReconnect && apc.accessToken != NULL) {
                    appConfigList.add(apC);
                }
            }
        }
        runningObject = String.isNotBlank(objectName) ? objectName : '';
        system.debug('appConfigList----'+appConfigList);
    }
    
    //Default Constructor which runs for all AppConfigs.
    public HourlySyncBatch(String objectName) {
        if(BreadwinnerUtil.getBWSetting().Active__c) {
            for(BWP_Processor_Config__c config : BreadwinnerUtil.processorConfigList) {
                if(!config.Need_To_Reconnect__c && config.Access_Token__c != NULL) {
                    appConfigList.add(BreadwinnerUtil.getProcessorConfigWrapper(config));
                }
            }
        } 
        runningObject = String.isNotBlank(objectName) ? objectName : '';
        system.debug('appConfigList----'+appConfigList);
    }
    
    //Start method
    public Iterable<BreadwinnerUtil.AppConfig> start(Database.Batchablecontext bc) {
        system.debug('start method');
        system.debug('appConfigs------'+appConfigList);
        return appConfigList;
    }
    
    public void execute(Database.BatchableContext bc, List<BreadwinnerUtil.AppConfig> scope) {
        system.debug('execute method-----------------');
        BreadwinnerUtil.AppConfig apc = scope[0];
        requestRecordsCount = 0;
        apc.currentRunningClassContext = BreadwinnerUtil.CNTX_HOUR_SYNC;
        Long lastHour; 
        String endPoint;
        // Request fields
        Map<String, Object> request = new Map<String, Object>();
        request.put(ProcessorUtil.API_VERSION, ProcessorUtil.VER_1);
        request.put(ProcessorUtil.API_PROCESSOR_ID, apC.accountId);

        // Response fields
        Map<String, Object> response = new Map<String, Object>();
        List<ProcessorUtil.Error> apiErrors = (List<ProcessorUtil.Error>) response.get(ProcessorUtil.RESP_API_ERRORS);
        List<ProcessorUtil.Error> processingErrors = (List<ProcessorUtil.Error>) response.get(ProcessorUtil.RESP_PROC_ERRORS);
        if(apc.PaymentProcessorType != ProcessorUtil.PAT_AUTHORIZE_NET){        
        if(runningObject == BreadwinnerUtil.OBJ_SYNC_CUSTOMER) {
          try {
                request.put(ProcessorUtil.API_ACTION, ProcessorUtil.ACT_FETCH_CUSTOMERS_ALL);
                if(apc.paymentProcessorType == ProcessorUtil.PAT_STRIPE){
                    Processor_Stripe.FetchRequest fetchRequest = new Processor_Stripe.FetchRequest();
                    DateTime lastHourDateTime = apc.hourlyCustomerSyncLastRun != null ? apc.hourlyCustomerSyncLastRun.addMinutes(-20) : System.now().addMinutes(-200);
                    fetchRequest.createdGreaterThanOrEqual = String.valueOf(lastHourDateTime);
                    if(apC.lastCustomerId != NULL){
                        fetchRequest.starting_after = apC.lastCustomerId;
                    }
                    fetchRequest.stripe_limit = '50';
                    request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(fetchRequest));
                }

                else if(apc.PaymentProcessorType == ProcessorUtil.PAT_BRAINTREE){
                    Datetime hourlySyncDatetime;
                    String requestJSON = Processor_Braintree.getRequestBody(ProcessorUtil.ACT_FETCH_CUSTOMERS_RECENT, (String.isNotBlank(apc.lastCustomerId) ? (apc.lastCustomerId) : null));
                    String reqBodyWithFilters = '';
                    hourlySyncDatetime = apc.hourlyCustomerSyncLastRun != null ? (apc.hourlyCustomerSyncLastRun.addMinutes(-20)) : (System.now().addMinutes(-20));
                    reqBodyWithFilters += '"variables": { "input": { "createdAt": { "greaterThanOrEqualTo": "'+(hourlySyncDatetime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'+\'00:00'))+'"';
                    reqBodyWithFilters += ',"lessThanOrEqualTo": "'+(datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'+\'00:00'))+'"';
                    reqBodyWithFilters +=  '} } } }';
                    requestJSON += reqBodyWithFilters;
                    request.put(ProcessorUtil.API_REQUEST_JSON, requestJSON);
                }
                else if(apc.PaymentProcessorType == ProcessorUtil.PAT_SQUARE){
                    Processor_Square.FetchRequest fetchRequest = new Processor_Square.FetchRequest();
                    String beginTime = apc.hourlyCustomerSyncLastRun != null ? String.valueOf(json.serialize(apc.hourlyCustomerSyncLastRun.addMinutes(-20))) : String.valueOf(json.serialize(datetime.now().addMinutes(-200)));
                    if(apC.lastCustomerId != NULL){
                        fetchRequest.cursor = apC.lastCustomerId;
                    }
                    fetchRequest.square_limit = '50';
                    fetchRequest.begin_time = beginTime;
                    request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(fetchRequest));
                }
                response = BreadwinnerPaymentsAPI.call(request);
                if(apiErrors != null){
                    for (ProcessorUtil.Error error : apiErrors){
                        errors += error.message;
                    }
                    APICallHandler.userInteractionLogPush(TRUE, 'Hourly Sync', 'ERROR', 'Customer Sync Errors: ' + errors);
                } else if (processingErrors != null){
                    for (ProcessorUtil.Error error : processingErrors){
                        errors += error.message;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,error.code + ' '+ error.message));
                    }
                    APICallHandler.userInteractionLogPush(TRUE, 'Hourly Sync', 'ERROR', 'Customer Sync Errors: ' + errors);
                } else {
                    if(response.get(ProcessorUtil.RESP_JSON) != NULL){
                        if(apc.PaymentProcessorType == ProcessorUtil.PAT_STRIPE){
                            HistoricalSyncBatch.processCustomerResponse_Stripe(response, apc, requestRecordsCount);
                        }
                        else if(apc.PaymentProcessorType == ProcessorUtil.PAT_BRAINTREE){
                            HistoricalSyncBatch.processCustomerResponse_Braintree(response, apc, requestRecordsCount);
                        }
                        else if(apc.PaymentProcessorType == ProcessorUtil.PAT_SQUARE){
                            HistoricalSyncBatch.processCustomerResponse_Square(response, apc, requestRecordsCount);
                        }
                    }
                }
            } catch(Exception ex) {
                System.debug('Exception occurred while fetching customers from Stripe.'+ex.getStackTraceString()+'\n'+ex.getMessage());
                apc.requireNextCustomerSyncRun = false;
                exceptionInExecute = ex;
            }
        } else if(runningObject == BreadwinnerUtil.OBJ_SYNC_PAYMENT) {
          try{
                request.put(ProcessorUtil.API_ACTION, ProcessorUtil.ACT_FETCH_TRANSACTIONS_ALL);
                if(apc.paymentProcessorType == ProcessorUtil.PAT_STRIPE){
                    Processor_Stripe.FetchRequest fetchRequest = new Processor_Stripe.FetchRequest();
                    DateTime lastHourDateTime = apc.hourlyPaymentSyncLastRun != null ? apc.hourlyPaymentSyncLastRun.addMinutes(-20) : System.now().addMinutes(-200);
                    fetchRequest.createdGreaterThanOrEqual = String.valueOf(lastHourDateTime);
                    if(apC.lastPaymentId != NULL){
                        fetchRequest.starting_after = apC.lastPaymentId;
                    }
                    fetchRequest.stripe_limit = '1';
                    request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(fetchRequest));
                }
                else if(apc.PaymentProcessorType == ProcessorUtil.PAT_BRAINTREE){
                    Datetime hourlySyncDatetime;
                    String requestJSON = Processor_Braintree.getRequestBody(ProcessorUtil.ACT_FETCH_TRANSACTIONS_RECENT, (String.isNotBlank(apc.lastPaymentId) ? (apc.lastPaymentId) : null));
                    String reqBodyWithFilters = '';
                    hourlySyncDatetime = apc.hourlyPaymentSyncLastRun != null ? (apc.hourlyPaymentSyncLastRun.addMinutes(-20)) : (System.now().addMinutes(-20));
                    reqBodyWithFilters += '"variables": { "input": { "createdAt": { "greaterThanOrEqualTo": "'+(hourlySyncDatetime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'+\'00:00'))+'"';
                    reqBodyWithFilters += ',"lessThanOrEqualTo": "'+(datetime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'+\'00:00'))+'"';
                    reqBodyWithFilters +=  '} } } }';
                    requestJSON += reqBodyWithFilters;
                    request.put(ProcessorUtil.API_REQUEST_JSON, requestJSON);
                }
                else if(apc.PaymentProcessorType == ProcessorUtil.PAT_SQUARE){
                    Processor_Square.FetchRequest fetchRequest = new Processor_Square.FetchRequest();
                    String beginTime = apc.hourlyPaymentSyncLastRun != null ? String.valueOf(json.serialize(apc.hourlyPaymentSyncLastRun.addMinutes(-20))).remove('"') : String.valueOf(json.serialize(datetime.now().addMinutes(-200))).remove('"');
                    if(apC.lastCustomerId != NULL){
                        fetchRequest.cursor = apC.lastCustomerId;
                    }
                    fetchRequest.begin_time = beginTime;
                    fetchRequest.end_time = (json.serialize(System.now()).remove('"'));
                    request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(fetchRequest));
                }
              	/*else if(apc.PaymentProcessorType == ProcessorUtil.PAT_PAYPAL){
                    String beginTime = apc.hourlyPaymentSyncLastRun != null ? String.valueOf(json.serialize(apc.hourlyPaymentSyncLastRun.addMinutes(-20))).remove('"') : String.valueOf(json.serialize(datetime.now().addMinutes(-200))).remove('"');
                    Processor_PayPal.FetchRequest fetchRequest = new Processor_PayPal.FetchRequest();
                    if(apC.lastPaymentId != NULL)
                        fetchRequest.lastPage = apC.lastPaymentId;
                    fetchRequest.fields = 'transaction_info,payer_info,shipping_info';
                    fetchRequest.start_date = beginTime;
                    fetchRequest.end_date = (json.serialize(System.now()).remove('"'));
                    request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(fetchRequest));
                } */
                response = BreadwinnerPaymentsAPI.call(request);
                if(apiErrors != null){
                    for (ProcessorUtil.Error error : apiErrors){
                        errors += error.message;
                    }
                    APICallHandler.userInteractionLogPush(TRUE, 'Hourly Sync', 'ERROR', 'Payment Sync Errors: ' + errors);
                } else if (processingErrors != null){
                    for (ProcessorUtil.Error error : processingErrors){
                        errors += error.message;
                    }
                    APICallHandler.userInteractionLogPush(TRUE, 'Hourly Sync', 'ERROR', 'Payment Sync Errors: ' + errors);
                } else {
                    if(response.get(ProcessorUtil.RESP_JSON) != NULL){
                        if(apc.PaymentProcessorType == ProcessorUtil.PAT_STRIPE){
                            HistoricalSyncBatch.processPaymentResponse_Stripe(response, apc, requestRecordsCount);
                        }
                        if(apc.PaymentProcessorType == ProcessorUtil.PAT_BRAINTREE){
                            HistoricalSyncBatch.processPaymentResponse_Braintree(response, apc, requestRecordsCount);
                        }
                        if(apc.PaymentProcessorType == ProcessorUtil.PAT_SQUARE){
                            HistoricalSyncBatch.processPaymentResponse_Square(response, apc, requestRecordsCount);
                        }
                        /*if(apc.PaymentProcessorType == ProcessorUtil.PAT_PAYPAL){
                            HistoricalSyncBatch.processPaymentResponse_PayPal(response, apc, requestRecordsCount);
                        } */
                    }
                }

            } catch(Exception ex) {
                System.debug('Exception occurred while fetching transactions from '+apc.paymentProcessorType+'.'+ex.getStackTraceString()+'See '+ex.getLineNumber()+'\n'+ex.getmessage());
                apc.requireNextPaymentSyncRun = false;
                exceptionInExecute = ex;
            }
        }
        }
        appConfigUpdateList.add(apc);
    }
    
    public void finish(Database.BatchableContext BC) {
        system.debug('finish method--------------');
        if(exceptionInExecute!=NULL){
            APICallHandler.userInteractionLogPush(TRUE, 'Historical Sync', 'ERROR' , 'Historical Sync Exception in execute : ' + exceptionInExecute.getMessage() + ' Stack Trace : ' + exceptionInExecute.getStackTraceString());
        }
        if(BreadwinnerUtil.getBWSetting().Active__c && BreadwinnerUtil.isProcessorConnected()) {
            Map<ID,BWP_Processor_Config__c> appConfigMap = new Map<ID,BWP_Processor_Config__c>();
            
            //Collecting all app config records
            for(BWP_Processor_Config__c ac : BreadwinnerUtil.processorConfigList) {
                appConfigMap.put(ac.Id, ac);
            }
            
            //Lists to seperate failed records and app config records for next run.
            List<BreadwinnerUtil.AppConfig> appConfigNeedToRun = new List<BreadwinnerUtil.AppConfig>();
            List<BreadwinnerUtil.AppConfig> failedAppConfigs = new List<BreadwinnerUtil.AppConfig>();
            
            List<BWP_Processor_Config__c> appConfigNeedToUpdate = new List<BWP_Processor_Config__c>(); //List to save app config records to database.
            
            for(BreadwinnerUtil.AppConfig appConfigWrapper : appConfigUpdateList) {
                Boolean recordExists = 
                    appConfigWrapper.RecordId != NULL &&
                    appConfigMap.containsKey(appConfigWrapper.RecordId);
                BWP_Processor_Config__c appConfigCompleteRecord = recordExists ? appConfigMap.get(appConfigWrapper.RecordId) : new BWP_Processor_Config__c();
                
                if(runningObject.containsIgnoreCase(BreadwinnerUtil.OBJ_SYNC_CUSTOMER)){
                    System.debug('Customer Sync running at '+System.now());
                    if(appConfigWrapper.requireNextCustomerSyncRun && !appConfigWrapper.needToReconnect) { //if more records
                        appConfigWrapper.isHourlyCustomerSyncDone = false;
                        appConfigNeedToRun.add(appConfigWrapper);
                    } else if(appConfigWrapper.requireNextCustomerSyncRun && appConfigWrapper.needToReconnect) { // Failed records
                        failedAppConfigs.add(appConfigWrapper);
                    } else {
                        APICallHandler.userInteractionLogPush(TRUE, 'Hourly Sync', 'FINISHED' , 'Object Name: Customer, Syncing Processor: '+appConfigWrapper.paymentProcessorType+' ('+appConfigWrapper.accountName+'), Requested LastSyncDateTime: '+appConfigCompleteRecord.Hourly_Customer_Sync_Last_Run__c+', CurrentPage Parsed Records: '+requestRecordsCount);
                    }
                    appConfigCompleteRecord.Hourly_Customer_Sync_Last_Run__c = System.now();
                    appConfigCompleteRecord.Need_To_Reconnect__c = appConfigWrapper.needToReconnect;
                    appConfigNeedToUpdate.add(appConfigCompleteRecord);
                    
                }else if(runningObject.containsIgnoreCase(BreadwinnerUtil.OBJ_SYNC_PAYMENT)){
                    
                    if(appConfigWrapper.requireNextPaymentSyncRun && !appConfigWrapper.needToReconnect) { //if more records
                        system.debug('need transaction sync run');
                        appConfigWrapper.isHourlyPaymentSyncDone = false;
                        appConfigNeedToRun.add(appConfigWrapper);
                    } else if(appConfigWrapper.requireNextPaymentSyncRun && appConfigWrapper.needToReconnect) { // Failed records
                        failedAppConfigs.add(appConfigWrapper);
                    } else {
                        //appConfigCompleteRecord.Is_Hourly_Payment_Sync_Done__c = true;
                        APICallHandler.userInteractionLogPush(TRUE, 'Hourly Sync', 'FINISHED' , 'Object Name: Payment, Syncing Processor: '+appConfigWrapper.paymentProcessorType+' ('+appConfigWrapper.accountName+'), Requested LastSyncDateTime: '+appConfigCompleteRecord.Hourly_Payment_Sync_Last_Run__c+', CurrentPage Parsed Records: '+requestRecordsCount);
                    }
                    appConfigCompleteRecord.Hourly_Payment_Sync_Last_Run__c = System.now();
                    appConfigCompleteRecord.Need_To_Reconnect__c = appConfigWrapper.needToReconnect;
                    appConfigNeedToUpdate.add(appConfigCompleteRecord);
                }
                //Refresh the Access Token
                if(!Test.isRunningTest()) {
                    checkAndRefreshAccessToken(BreadwinnerUtil.processorConfigList);
                }
            }
            BreadwinnerUtil.isBreadwinnerTransaction = true;
            SecurityUtil.databaseUpsert(appConfigNeedToUpdate);
            
            if(!appConfigNeedToRun.isEmpty()) {
                system.debug('execute---another');
                if(!Test.isRunningTest()){
                    HourlySyncBatch hourlySync = new HourlySyncBatch(runningObject, appConfigNeedToRun);
                    Database.executeBatch(hourlySync, 1);
                }
            } else if(appConfigNeedToRun.isEmpty() && appConfigNeedToUpdate.size()>0) { //No more batches to run. So start transactions batch.
                if(!BreadwinnerUtil.isBatchRunning(BreadwinnerUtil.CNTX_HOUR_SYNC)) {
                    System.debug('Ready for Payment sync');
                    String getNextSyncObjectName = BreadwinnerUtil.findNextSyncName(runningObject);
                    if(String.isNotBlank(getNextSyncObjectName)) {
                        Database.executeBatch(new HourlySyncBatch(getNextSyncObjectName), 1);
                    } else {
                        scheduleBreadwinnerHourlySync(15, true);
                    }
                }
            }
        }
    }
    
    /* Schedulable - execute */
    public void execute(SchedulableContext sc) {
        BreadwinnerUtil.deleteConfigsWhenSandboxRefresh();
        if(BreadwinnerUtil.isAdministrator()) {
            if(BreadwinnerUtil.isBreadwinnerActive()) {
                runHourlySyncBatch();
            }
            else {
                APICallHandler.userInteractionLogPush(FALSE, 'Hourly Scheduler', 'INFO', 'Trial or Subscription Expired');
            }
        }
        else {
            APICallHandler.userInteractionLogPush(FALSE, 'Hourly Scheduler', 'INFO', 'Running user is not an Administrator');
        }
    }

    /* This method is used to run hourly sync batch */
    public static void runHourlySyncBatch(){
        try{
            if(BreadwinnerUtil.isBreadwinnerAdministrator() && !BreadwinnerUtil.isBatchRunning(BreadwinnerUtil.CNTX_HOUR_SYNC)) {
                HourlySyncBatch hourlySync = new HourlySyncBatch(BreadwinnerUtil.OBJ_SYNC_CUSTOMER);
                Database.executeBatch(hourlySync, 1); //At a time only one company should be run. Don't make it other than 1.
            }
        }
        catch(Exception e){
            APICallHandler.userInteractionLogPush(false, 'Hourly Sync', 'ERROR' , 'Error occurred while restarting Hourly Sync ' +e);
        }
    }

    public static void scheduleBreadwinnerHourlySync(Integer minutes, Boolean abortExistedJobs) {
        if(BreadwinnerUtil.isBreadwinnerAdministrator()) {
            try {
                List<CronTrigger> existedScheduledJobs = BreadwinnerUtil.getCronTrigger(BreadwinnerUtil.SYNC_CNTX_HOURLY);

                if(existedScheduledJobs.size()>0 && abortExistedJobs) {
                    for(CronTrigger ct : existedScheduledJobs) {
                        System.abortJob(ct.id); //-- Abort the pending jobs
                    }
                }
                if(existedScheduledJobs.size() == 0 || abortExistedJobs) {
                    DateTime nextScheduleTime = System.now().addMinutes(minutes);
                    String CronExpression = '0 ' + nextScheduleTime.minute() + ' ' + nextScheduleTime.hour() + ' ' + nextScheduleTime.day() + ' ' + nextScheduleTime.month() + ' ? ' + nextScheduleTime.year() + ' BreadwinnerSync';
                    HourlySyncBatch hourlySync = new HourlySyncBatch(BreadwinnerUtil.OBJ_SYNC_CUSTOMER);
                    System.schedule(BreadwinnerUtil.SYNC_CNTX_HOURLY + System.now(), CronExpression, hourlySync);
                }
            }
            catch(Exception e) {
                System.debug('Exception occured while scheduling Breadwinner Hourly Sync: ' + e.getMessage());
            }
        }
    }

    //This method is used to check the Access token status
    public static void checkAndRefreshAccessToken(List<BWP_Processor_Config__c> procConfigList){
        for(BWP_Processor_Config__c appC : procConfigList){
            if(appC.Payment_Processor_Type__c == ProcessorUtil.PAT_SQUARE){
                DateTime expiryDate = (appC.Access_Token_Expiry_Date__c).addDays(-10);
                if(System.now() >= expiryDate){
                    Processor_Square.refreshAccessToken(appC);
                }
            }
            if(appC.Payment_Processor_Type__c == ProcessorUtil.PAT_PAYPAL || appC.Payment_Processor_Type__c == ProcessorUtil.PAT_AUTHORIZE_NET){
                if(appC.Access_Token_Expiry_Date__c != NULL){
                    DateTime expiryDate = appC.Payment_Processor_Type__c == ProcessorUtil.PAT_AUTHORIZE_NET ? (appC.Access_Token_Expiry_Date__c).addHours(-1) : (appC.Access_Token_Expiry_Date__c).addHours(-2);
                    if(System.now() >= expiryDate){
                        if(appC.Payment_Processor_Type__c == ProcessorUtil.PAT_PAYPAL)
                            Processor_PayPal.refreshAccessToken(appC);
                        else if(appC.Payment_Processor_Type__c == ProcessorUtil.PAT_AUTHORIZE_NET)
                            Processor_Authorize_Net.refreshAccessToken(appC);
                    }
                }
            }
        }
    }

}