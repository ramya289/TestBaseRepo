/*
* Created By  :  Surender & Suchimitha (Dhruvsoft) 
* Description :  This class is to run historical customer sync. It also includes "Sources(Payment Methods)" for each customer. 
* Functionalities : All customers & respective payment methods, and transactions will be fetched and linked accordingly.
*/

public with sharing class HistoricalSyncBatch implements Database.Batchable<BreadwinnerUtil.AppConfig>, Database.AllowsCallouts, Database.Stateful, Schedulable {
    public List<BreadwinnerUtil.AppConfig> appConfigUpdateList = new List<BreadwinnerUtil.AppConfig>();
    public List<BreadwinnerUtil.AppConfig> appConfigList = new List<BreadwinnerUtil.AppConfig>();
    public String runningObjectName;
    Exception exceptionInExecute;
    public Boolean runThisSyncOnly;
    public Integer requestRecordsCount;
    public String errors;
    public Map<String, Set<String>> authNetCustomerIdsMap = new Map<String, Set<String>>(); // Holds Processor specific Customer Ids with key as processor Id, and the Ids can be sent to Processor_Batch to get Customer details.
    public Map<String, Set<String>> authNetBatchIdsMap = new Map<String, Set<String>>(); // Holds Processor specific Transaction Batch Ids with key as processor Id, these can be sent to Processor_Batch to get Transaction details in each Batch

    //Constructor with BreadwinnerUtil.AppConfig input. This input will have updated BreadwinnerUtil.AppConfig data during runtime. It also can be used to run for specific BreadwinnerUtil.AppConfig.
    public HistoricalSyncBatch(String objectName, List<BreadwinnerUtil.AppConfig> appconfigs) {
        if(BreadwinnerUtil.getBWSetting().Active__c){
            for(BreadwinnerUtil.AppConfig apC : appconfigs) {
                if(!apC.needToReconnect && apc.accessToken != NULL) {
                    appConfigList.add(apC);
                }
            }
        }
        runningObjectName = String.isNotBlank(objectName) ? objectName : '';
        runThisSyncOnly = false;
    }
    
    //Default Constructor which runs for all connected ORGs.
    public HistoricalSyncBatch(String objectName) {
        if(BreadwinnerUtil.getBWSetting().Active__c) {
            for(BWP_Processor_Config__c config : BreadwinnerUtil.processorConfigList) {
                if(!config.Need_To_Reconnect__c && config.Access_Token__c != NULL) {
                    appConfigList.add(BreadwinnerUtil.getProcessorConfigWrapper(config));
                }
            }
        }
        runningObjectName = String.isNotBlank(objectName) ? objectName : ''; 
        runThisSyncOnly = false;
    }
    
    //Start method
    public Iterable<BreadwinnerUtil.AppConfig> start(Database.Batchablecontext bc) {
        system.debug('start method');
        system.debug('appConfigList-----'+appConfigList);
        return appConfigList;
    }
    
    public void execute(Database.BatchableContext bc, List<BreadwinnerUtil.AppConfig> scope) {
        BreadwinnerUtil.AppConfig apc = scope[0];
        requestRecordsCount = 0;
        apc.currentRunningClassContext = BreadwinnerUtil.CNTX_HIST_SYNC;
        // Request fields
        Map<String, Object> request = new Map<String, Object>();
        request.put(ProcessorUtil.API_VERSION, ProcessorUtil.VER_1);
        request.put(ProcessorUtil.API_PROCESSOR_ID, apC.accountId);
        
        // Response fields
        Map<String, Object> response = new Map<String, Object>();
        List<ProcessorUtil.Error> apiErrors = (List<ProcessorUtil.Error>) response.get(ProcessorUtil.RESP_API_ERRORS);
        List<ProcessorUtil.Error> processingErrors = (List<ProcessorUtil.Error>) response.get(ProcessorUtil.RESP_PROC_ERRORS);

        if(runningObjectName.containsIgnoreCase(BreadwinnerUtil.OBJ_SYNC_CUSTOMER)){
            try{
                request.put(ProcessorUtil.API_ACTION, ProcessorUtil.ACT_FETCH_CUSTOMERS_ALL);
                if(apc.paymentProcessorType == ProcessorUtil.PAT_STRIPE){
                    Processor_Stripe.FetchRequest fetchRequest = new Processor_Stripe.FetchRequest();
                    if(apC.lastCustomerId != NULL){
                        fetchRequest.starting_after = apC.lastCustomerId;
                    }
                    fetchRequest.stripe_limit = '50';
                    request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(fetchRequest));
                }
                else if(apc.PaymentProcessorType == ProcessorUtil.PAT_BRAINTREE){
                    String requestJSON = Processor_Braintree.getRequestBody(ProcessorUtil.ACT_FETCH_CUSTOMERS_ALL, (String.isNotBlank(apC.lastCustomerId) ? (apC.lastCustomerId) : NULL));
                    request.put(ProcessorUtil.API_REQUEST_JSON, requestJSON);
                }
                else if(apc.PaymentProcessorType == ProcessorUtil.PAT_SQUARE){
                    Processor_Square.FetchRequest fetchRequest = new Processor_Square.FetchRequest();
                    if(apC.lastCustomerId != NULL){
                        fetchRequest.cursor = apC.lastCustomerId;
                    }
                    fetchRequest.square_limit = '50';
                    request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(fetchRequest));
                }
                else if(apc.PaymentProcessorType == ProcessorUtil.PAT_AUTHORIZE_NET){
                    String requestJSON = Processor_Authorize_Net.getRequestBody(ProcessorUtil.ACT_FETCH_CUSTOMERS_ALL, '', apc, '');
                    request.put(ProcessorUtil.API_REQUEST_JSON, requestJSON);
                }
                response = BreadwinnerPaymentsAPI.call(request);
                if(apiErrors != null){
                    for (ProcessorUtil.Error error : apiErrors){
                        errors += error.message;
                    }
                    APICallHandler.userInteractionLogPush(TRUE, 'Historical Sync', 'ERROR', 'Customer Sync Errors: ' + errors);
                } else if (processingErrors != null){
                    for (ProcessorUtil.Error error : processingErrors){
                        errors += error.message;
                    }
                    APICallHandler.userInteractionLogPush(TRUE, 'Historical Sync', 'ERROR', 'Customer Sync Errors: ' + errors);
                } else {
                    if(response.get(ProcessorUtil.RESP_JSON) != NULL){
                        if(apc.PaymentProcessorType == ProcessorUtil.PAT_STRIPE){
                            processCustomerResponse_Stripe(response, apc, requestRecordsCount);
                        }
                        else if(apc.PaymentProcessorType == ProcessorUtil.PAT_BRAINTREE){
                            processCustomerResponse_Braintree(response, apc, requestRecordsCount);
                        }
                        else if(apc.PaymentProcessorType == ProcessorUtil.PAT_SQUARE){
                            processCustomerResponse_Square(response, apc, requestRecordsCount);
                        }
                        else if(apc.PaymentProcessorType == ProcessorUtil.PAT_AUTHORIZE_NET){
                            // Requesting for list of Customer Ids (this request will only return customer Ids, not the full details of customers)
                            processCustomerResponse_AuthNet(response, apc, authNetCustomerIdsMap);
                        }
                    }
                }
            }
            catch(Exception ex) {
                System.debug('Exception occurred while fetching customers from '+apc.paymentProcessorType+'.'+ex.getStackTraceString()+'See '+ex.getLineNumber()+'\n'+ex.getmessage());
                apc.requireNextCustomerSyncRun = False;
                exceptionInExecute = ex;
            }
        }
        else if (runningObjectName.containsIgnoreCase(BreadwinnerUtil.OBJ_SYNC_PAYMENT)) {
            try{
                request.put(ProcessorUtil.API_ACTION, ProcessorUtil.ACT_FETCH_TRANSACTIONS_ALL);
                if(apc.paymentProcessorType == ProcessorUtil.PAT_STRIPE){
                    Processor_Stripe.FetchRequest fetchRequest = new Processor_Stripe.FetchRequest();
                    if(apC.lastPaymentId != NULL){
                        fetchRequest.starting_after = apC.lastPaymentId;
                    }
                    fetchRequest.stripe_limit = '50';
                    request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(fetchRequest));
                }
                else if(apc.PaymentProcessorType == ProcessorUtil.PAT_BRAINTREE){
                    String requestJSON = Processor_Braintree.getRequestBody(ProcessorUtil.ACT_FETCH_TRANSACTIONS_ALL, (String.isNotBlank(apC.lastPaymentId) ? (apC.lastPaymentId) : NULL));
                    request.put(ProcessorUtil.API_REQUEST_JSON, requestJSON);
                }
                else if(apc.PaymentProcessorType == ProcessorUtil.PAT_SQUARE){
                    Processor_Square.FetchRequest fetchRequest = new Processor_Square.FetchRequest();
                    if(apC.lastPaymentId != NULL){
                        fetchRequest.cursor = apC.lastPaymentId;
                    }
                    request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(fetchRequest));
                }
              /*  else if(apc.PaymentProcessorType == ProcessorUtil.PAT_PAYPAL){
                    Processor_PayPal.FetchRequest fetchRequest = new Processor_PayPal.FetchRequest();
                    if(apC.lastPaymentId != NULL)
                        fetchRequest.lastPage = apC.lastPaymentId;

                    fetchRequest.fields = 'transaction_info,payer_info,shipping_info';
                    fetchRequest.page_size = 100;
                    fetchRequest.page = 1;

                    fetchRequest.start_date = json.serialize(System.now().addDays(-30)).remove('"');
                    fetchRequest.end_date = json.serialize(System.now()).remove('"');
                    request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(fetchRequest));
                }*/
                else if(apc.PaymentProcessorType == ProcessorUtil.PAT_AUTHORIZE_NET){
                    String rawAccessToken = '';
                    if(!Test.isRunningTest())
                        rawAccessToken = CryptoUtil.decryptSecrets(apc).accessToken;
                    String firstSettlementDate = json.serialize(System.now().addDays(-30)).remove('"'); 
                    String lastSettlementDate = json.serialize(System.now()).remove('"');
                    if(apc.startDate == null && apc.endDate == null){
                        apc.startDate = DateTime.valueOf(firstSettlementDate.replace('T',' '));
                        apc.endDate = DateTime.valueOf(lastSettlementDate.replace('T',' '));
                    }
                    String requestJSON = '{"getSettledBatchListRequest":{"merchantAuthentication":{"accessToken":"'+rawAccessToken+'"},"firstSettlementDate":"'+firstSettlementDate+'","lastSettlementDate":"'+lastSettlementDate+'"}}';
                    request.put(ProcessorUtil.API_REQUEST_JSON, requestJSON);
                }
                response = BreadwinnerPaymentsAPI.call(request);
                if(apiErrors != null){
                    for (ProcessorUtil.Error error : apiErrors){
                        errors += error.message;
                    }
                    APICallHandler.userInteractionLogPush(TRUE, 'Historical Sync', 'ERROR', 'Payment Sync Errors: ' + errors);
                } else if (processingErrors != null){
                    for (ProcessorUtil.Error error : processingErrors){
                        errors += error.message;
                    }
                    APICallHandler.userInteractionLogPush(TRUE, 'Historical Sync', 'ERROR', 'Payment Sync Errors: ' + errors);

                } else {
                    if(response.get(ProcessorUtil.RESP_JSON) != NULL){
                        if(apc.PaymentProcessorType == ProcessorUtil.PAT_STRIPE){
                            processPaymentResponse_Stripe(response, apc, requestRecordsCount);
                        }
                        if(apc.PaymentProcessorType == ProcessorUtil.PAT_BRAINTREE){
                            processPaymentResponse_Braintree(response, apc, requestRecordsCount);
                        }
                        if(apc.PaymentProcessorType == ProcessorUtil.PAT_SQUARE){
                            processPaymentResponse_Square(response, apc, requestRecordsCount);
                        }
                        /*if(apc.PaymentProcessorType == ProcessorUtil.PAT_PAYPAL){
                            processPaymentResponse_PayPal(response, apc, requestRecordsCount);
                        } */
                        if(apc.PaymentProcessorType == ProcessorUtil.PAT_AUTHORIZE_NET){
                            processPaymentResponse_AuthNet(response, apc, authNetBatchIdsMap);
                        }
                    }
                }
            } catch(Exception ex) {
                System.debug('Exception occurred while fetching transactions from '+apc.paymentProcessorType+'.'+ex.getStackTraceString()+'See '+ex.getLineNumber()+'\n'+ex.getmessage());
                apc.requireNextPaymentSyncRun = false;
                exceptionInExecute = ex;
            }
        }
        appConfigUpdateList.add(apc);
    }
    
    public void finish(Database.BatchableContext BC) {
        system.debug('finish: '+exceptionInExecute);
        
        for(BreadwinnerUtil.AppConfig config : appConfigUpdateList){
            if(config.PaymentProcessorType == ProcessorUtil.PAT_AUTHORIZE_NET && ((runningObjectName.containsIgnoreCase(BreadwinnerUtil.OBJ_SYNC_CUSTOMER) && !authNetCustomerIdsMap.isEmpty()) || (runningObjectName.containsIgnoreCase(BreadwinnerUtil.OBJ_SYNC_PAYMENT) && !authNetBatchIdsMap.isEmpty()))){
                // For Customer Sync, Calling this batch to get each Customer details, and running with batch size as 40 to avoid hitting any limits
                // The batch will loop through each customer id to get the full details
                
                // For Payment/Transaction Sync, calling Processor_Batch, sending list of Batch Ids
                List<String> authNetIds = new List<String>();
                if(runningObjectName.containsIgnoreCase(BreadwinnerUtil.OBJ_SYNC_CUSTOMER)){
                    authNetIds.addAll(authNetCustomerIdsMap.get(config.name));
                } else if(runningObjectName.containsIgnoreCase(BreadwinnerUtil.OBJ_SYNC_PAYMENT) && authNetBatchIdsMap.containsKey(config.Name)){
                    authNetIds.addAll(authNetBatchIdsMap.get(config.Name));
                }
                Processor_Batch processorBatch = new Processor_Batch(authNetIds, config, runningObjectName);
                processorBatch.runThisSyncOnly = runThisSyncOnly;
                Database.executeBatch(processorBatch, 40);
            }
        }
        
        if(exceptionInExecute!=NULL) {
            APICallHandler.userInteractionLogPush(TRUE, 'Historical Sync', 'ERROR' , 'Historical Sync Exception in execute : ' + exceptionInExecute.getMessage() + ' Stack Trace : ' + exceptionInExecute.getStackTraceString());
        }
        postSyncUpdates(appConfigUpdateList, runningObjectName, requestRecordsCount, runThisSyncOnly, false);
    }
    
    // Added this method for reusability, this will update Processor Config after Customer/Payment Sync is completed
    public static void postSyncUpdates(List<BreadwinnerUtil.AppConfig> appConfigUpdateList, String runningObjectName, Integer requestRecordsCount, Boolean runThisSyncOnly, Boolean isSyncCompleted){
        if(BreadwinnerUtil.getBWSetting().Active__c && BreadwinnerUtil.isProcessorConnected()) {
            Map<Id,BWP_Processor_Config__c> appConfigMap = new Map<Id,BWP_Processor_Config__c>();
            
            //Collecting all app config records
            for(BWP_Processor_Config__c ac : BreadwinnerUtil.processorConfigList) {
                appConfigMap.put(ac.Id, ac);
            }
            
            //Lists to separate failed records and app config records for next run.
            List<BreadwinnerUtil.AppConfig> appConfigNeedToRun = new List<BreadwinnerUtil.AppConfig>();
            List<BreadwinnerUtil.AppConfig> failedAppConfigs = new List<BreadwinnerUtil.AppConfig>();
            
            //List to save app config records to database.
            List<BWP_Processor_Config__c> appConfigNeedToUpdate = new List<BWP_Processor_Config__c>();
            for(BreadwinnerUtil.AppConfig appConfigWrapper : appConfigUpdateList) {
                // Below If condition will check for ProcessorType, If ProcessorType is other than Authorize.Net, the processor Config will be updated automatically
                // For Authorize.net, before updating the Processor Config checking for isauthNetCustomerSyncDone to make sure that the Authorize.Net Customer sync is completed
                
                //system.debug('appConfigWrapper.RecordId-----'+appConfigWrapper.RecordId);
                Boolean recordExists = ((String.isNotBlank(appConfigWrapper.RecordId) && (appConfigWrapper.RecordId != NULL)) ? (appConfigMap.containsKey(appConfigWrapper.RecordId) ? true : false) : false);
                BWP_Processor_Config__c appConfigCompleteRecord = recordExists ? appConfigMap.get(appConfigWrapper.RecordId) : new BWP_Processor_Config__c();
                if(appConfigWrapper.requireNextPaymentSyncRun && appConfigWrapper.PaymentProcessorType == ProcessorUtil.PAT_AUTHORIZE_NET && (appConfigWrapper.startDate < appConfigWrapper.endDate)){
                    appConfigCompleteRecord.Start_Date__c = appConfigWrapper.startDate;
                    appConfigCompleteRecord.End_Date__c = appConfigWrapper.endDate;
                }
                else{
                    appConfigCompleteRecord.Start_Date__c = null;
                    appConfigCompleteRecord.End_Date__c = null;
                }
                if(runningObjectName.containsIgnoreCase(BreadwinnerUtil.OBJ_SYNC_CUSTOMER)){
                    System.debug('Customer Sync running at '+System.now());
                    if(appConfigWrapper.requireNextCustomerSyncRun && !appConfigWrapper.needToReconnect) { //if more records
                        appConfigWrapper.isHistoricalCustomerSyncDone = false;
                        system.debug('appConfigWrapper---------'+appConfigWrapper.accountname);
                        appConfigNeedToRun.add(appConfigWrapper);
                    } else if(appConfigWrapper.requireNextCustomerSyncRun && appConfigWrapper.needToReconnect) { // Failed records
                        failedAppConfigs.add(appConfigWrapper);
                    } else {
                        system.debug('customer sync completed for----'+appConfigCompleteRecord.Account_Name__c);
                        appConfigWrapper.isHistoricalCustomerSyncDone = true;
                        APICallHandler.userInteractionLogPush(TRUE, 'Historical Sync', 'FINISHED' , 'Object Name: Customer, Syncing Processor: '+appConfigWrapper.paymentProcessorType+' ('+appConfigWrapper.accountName+'), CurrentPage Parsed Records: '+requestRecordsCount);
                    }
                    if(appConfigWrapper.PaymentProcessorType != ProcessorUtil.PAT_AUTHORIZE_NET || (appConfigWrapper.PaymentProcessorType == ProcessorUtil.PAT_AUTHORIZE_NET && isSyncCompleted)){
                        appConfigCompleteRecord.Historical_Customer_Sync_Last_Run__c = System.now();
                    }
                    appConfigCompleteRecord.Need_To_Reconnect__c = appConfigWrapper.needToReconnect;
                    appConfigNeedToUpdate.add(appConfigCompleteRecord);
                }
                else if(runningObjectName.containsIgnoreCase(BreadwinnerUtil.OBJ_SYNC_PAYMENT)){
                    System.debug('Payment Sync running at '+System.now());
                    System.debug('--appConfigWrapper---'+appConfigWrapper);
                    if(appConfigWrapper.requireNextPaymentSyncRun && !appConfigWrapper.needToReconnect) { //if more records
                        appConfigWrapper.isHistoricalPaymentSyncDone = false;
                        appConfigNeedToRun.add(appConfigWrapper);
                    } else if(appConfigWrapper.requireNextPaymentSyncRun && appConfigWrapper.needToReconnect) { // Failed records
                        failedAppConfigs.add(appConfigWrapper);
                    } else{
                        appConfigWrapper.isHistoricalPaymentSyncDone = true;
                        APICallHandler.userInteractionLogPush(TRUE, 'Historical Sync', 'FINISHED' , 'Object Name: Payment, Syncing Processor: '+appConfigWrapper.paymentProcessorType+' ('+appConfigWrapper.accountName+'), CurrentPage Parsed Records: '+requestRecordsCount);
                    }
                    if(appConfigWrapper.PaymentProcessorType != ProcessorUtil.PAT_AUTHORIZE_NET || (appConfigWrapper.PaymentProcessorType == ProcessorUtil.PAT_AUTHORIZE_NET && isSyncCompleted)){
                        appConfigCompleteRecord.Historical_Payment_Sync_Last_Run__c = System.now();
                    }
                    appConfigCompleteRecord.Need_To_Reconnect__c = appConfigWrapper.needToReconnect;
                    appConfigNeedToUpdate.add(appConfigCompleteRecord);
                }
            }
            BreadwinnerUtil.isBreadwinnerTransaction = true;
            SecurityUtil.databaseUpsert(appConfigNeedToUpdate);
            
            if(!appConfigNeedToRun.isEmpty()) {
                system.debug('appConfigNeedToRun------------'+appConfigNeedToRun);
                if(!Test.isRunningTest()){
                    HistoricalSyncBatch historicalSync = new HistoricalSyncBatch(runningObjectName, appConfigNeedToRun);
                    historicalSync.runThisSyncOnly = runThisSyncOnly ? true : false;
                    Database.executeBatch(historicalSync, 1);
                }
            } else if(appConfigNeedToRun.isEmpty() && appConfigNeedToUpdate.size()>0 && !runThisSyncOnly){ //No more batches to run. So start Next batch. 
                system.debug('appConfigNeedToUpdate[0]----'+appConfigNeedToUpdate[0]);
                if(!Test.isRunningTest() && [SELECT Id, OwnerId FROM CronTrigger WHERE CronJobDetail.Name LIKE '%HistoricalPaymentsSync%'].size() == 0 )
                    System.debug('Ready for Payment sync');
                String getNextSyncObjectName = BreadwinnerUtil.findNextSyncName(runningObjectName);
                if(String.isNotBlank(getNextSyncObjectName) && !BreadwinnerUtil.isBatchRunning(BreadwinnerUtil.CNTX_HIST_SYNC)) {
                    Database.executeBatch(new HistoricalSyncBatch(getNextSyncObjectName), 1);
                }
            }
            
        }
    }
    
    public static void processCustomerResponse_Stripe(Map<String, Object> response, BreadwinnerUtil.AppConfig apc, Integer requestRecordsCount){
        Map<String, Customer.StripeCustomer> stripeCustomerMapById = new Map<String, Customer.StripeCustomer>();
        Map<String, Object> processorTypeToRecordsMap = new Map<String, Object>();
        String responseJSON = (String) response.get(ProcessorUtil.RESP_JSON);
        JSONParser parser = JSON.createParser(responseJSON);
        Processor_Stripe.FetchResponse responseData = (Processor_Stripe.FetchResponse) parser.readValueAs(Processor_Stripe.FetchResponse.class);
        stripeCustomerMapById = responseData.customerMapById;
        if(responseData.requireNextRun){
            apc.lastCustomerId = responseData.last_record_id;
            apc.requireNextCustomerSyncRun = TRUE;
        }
        else{
            apc.lastCustomerId = '';
            apc.requireNextCustomerSyncRun = FALSE;
        }
        if(stripeCustomerMapById != NULL){
            processorTypeToRecordsMap.put(ProcessorUtil.PAT_STRIPE, stripeCustomerMapById);
            requestRecordsCount = stripeCustomerMapById.size() > 0 ? stripeCustomerMapById.size() : 0;
            if(requestRecordsCount > 0)
                Processor_Stripe.syncCustomers(processorTypeToRecordsMap, apC, true);
        }
    }
    public static void processCustomerResponse_Braintree(Map<String, Object> response, BreadwinnerUtil.AppConfig apc, Integer requestRecordsCount){
        Map<String, Customer.BraintreeCustomer> braintreeCustomerMapById = new Map<String, Customer.BraintreeCustomer>();
        Map<String, Object> processorTypeToRecordsMap = new Map<String, Object>();
        String responseJSON = (String) response.get(ProcessorUtil.RESP_JSON);
        JSONParser parser = JSON.createParser(responseJSON);
        Processor_Braintree.FetchResponse responseData = (Processor_Braintree.FetchResponse) parser.readValueAs(Processor_Braintree.FetchResponse.class);
        braintreeCustomerMapById = responseData.customerMapById;
        if(responseData.requireNextRun){
            apc.lastCustomerId = responseData.cursor;
            apc.requireNextCustomerSyncRun = TRUE;
        }
        else{
            apc.lastCustomerId = '';
            apc.requireNextCustomerSyncRun = FALSE;
        }
        if(braintreeCustomerMapById != NULL){
            processorTypeToRecordsMap.put(ProcessorUtil.PAT_BRAINTREE, braintreeCustomerMapById);
            requestRecordsCount = braintreeCustomerMapById.size() > 0 ? braintreeCustomerMapById.size() : 0;
            if(requestRecordsCount > 0)
                Processor_Braintree.syncCustomers(processorTypeToRecordsMap, apC, true);
        }
    }
    public static void processCustomerResponse_Square(Map<String, Object> response, BreadwinnerUtil.AppConfig apc, Integer requestRecordsCount){
        Map<String, Customer.SquareCustomer> squareCustomerMapById = new Map<String, Customer.SquareCustomer>();
        Map<String, Object> processorTypeToRecordsMap = new Map<String, Object>();
        String responseJSON = (String) response.get(ProcessorUtil.RESP_JSON);
        JSONParser parser = JSON.createParser(responseJSON);
        Processor_Square.FetchResponse responseData = (Processor_Square.FetchResponse) parser.readValueAs(Processor_Square.FetchResponse.class);
        squareCustomerMapById = responseData.customerMapById;
        if(responseData.requireNextRun){
            apc.lastCustomerId = responseData.cursor;
            apc.requireNextCustomerSyncRun = TRUE;
        }
        else{
            apc.lastCustomerId = '';
            apc.requireNextCustomerSyncRun = FALSE;
        }
        if(squareCustomerMapById != NULL){
            processorTypeToRecordsMap.put(ProcessorUtil.PAT_SQUARE, squareCustomerMapById);
            requestRecordsCount = squareCustomerMapById.size() > 0 ? squareCustomerMapById.size() : 0;
            if(requestRecordsCount > 0)
                Processor_Square.syncCustomers(processorTypeToRecordsMap, apC, True);
        }
    }
    private static void processCustomerResponse_AuthNet(Map<String, Object> response, BreadwinnerUtil.AppConfig apc, Map<String, Set<String>> authNetCustomerIdsMap){
        String respBody = (String) response.get(ProcessorUtil.RESP_JSON);
        respBody = respBody.trim().replace('\uFEFF', '');
        Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(respBody);
        List<Object> idsList = (List<Object>)bodyMap.get('ids');
        Set<String> authNetIds = new Set<String>();
        for(Object a: idsList){
            authNetIds.add(String.valueOf(a));
        }
        authNetCustomerIdsMap.put(apc.name, authNetIds);
    }
    public static void processPaymentResponse_Stripe(Map<String, Object> response, BreadwinnerUtil.AppConfig apc, Integer requestRecordsCount){
        Map<String, Charge.StripeCharge> stripePaymentMapById = new Map<String, Charge.StripeCharge>();
        Map<String, Object> processorTypeToRecordsMap = new Map<String, Object>();
        String responseJSON = (String) response.get(ProcessorUtil.RESP_JSON);
        JSONParser parser = JSON.createParser(responseJSON);
        Processor_Stripe.FetchResponse responseData = (Processor_Stripe.FetchResponse) parser.readValueAs(Processor_Stripe.FetchResponse.Class);
        stripePaymentMapById = responseData.paymentMapById;
        if(responseData.requireNextRun){
            apc.lastPaymentId = responseData.last_record_id;
            apc.requireNextPaymentSyncRun = TRUE;
        }
        else{
            apc.lastPaymentId = '';
            apc.requireNextPaymentSyncRun = FALSE;
        }
        if(stripePaymentMapById != NULL){
            requestRecordsCount = stripePaymentMapById.size() > 0 ? stripePaymentMapById.size() : 0;
            processorTypeToRecordsMap.put(ProcessorUtil.PAT_STRIPE, stripePaymentMapById);
            if(requestRecordsCount > 0) {
                Processor_Stripe.syncTransactions(processorTypeToRecordsMap, apC);
            }
        }
    }
    public static void processPaymentResponse_Braintree(Map<String, Object> response, BreadwinnerUtil.AppConfig apc, Integer requestRecordsCount){
        Map<String, Charge.BraintreeCharge> braintreePaymentMapById = new Map<String, Charge.BraintreeCharge>();
        Map<String, Object> processorTypeToRecordsMap = new Map<String, Object>();
        String responseJSON = (String) response.get(ProcessorUtil.RESP_JSON);
        JSONParser parser = JSON.createParser(responseJSON);
        Processor_Braintree.FetchResponse responseData = (Processor_Braintree.FetchResponse) parser.readValueAs(Processor_Braintree.FetchResponse.class);
        braintreePaymentMapById = responseData.paymentMapById;
        if(responseData.requireNextRun){
            apc.lastPaymentId = responseData.cursor;
            apc.requireNextCustomerSyncRun = TRUE;
        }
        else{
            apc.lastPaymentId = '';
            apc.requireNextCustomerSyncRun = FALSE;
        }
        if(braintreePaymentMapById != NULL){
            processorTypeToRecordsMap.put(ProcessorUtil.PAT_BRAINTREE, braintreePaymentMapById);
            requestRecordsCount = braintreePaymentMapById.size() > 0 ? braintreePaymentMapById.size() : 0;
            if(requestRecordsCount > 0) {
                Processor_Braintree.syncTransactions(processorTypeToRecordsMap, apC);
            }
        }
        System.debug('--requestRecordsCount--'+requestRecordsCount);
    }
    public static void processPaymentResponse_Square(Map<String, Object> response, BreadwinnerUtil.AppConfig apc, Integer requestRecordsCount){
        Map<String, Charge.SquareCharge> squarePaymentMapById = new Map<String, Charge.SquareCharge>();
        Map<String, Object> processorTypeToRecordsMap = new Map<String, Object>();
        String responseJSON = (String) response.get(ProcessorUtil.RESP_JSON);
        JSONParser parser = JSON.createParser(responseJSON);
        Processor_Square.FetchResponse responseData = (Processor_Square.FetchResponse) parser.readValueAs(Processor_Square.FetchResponse.Class);
        squarePaymentMapById = responseData.paymentMapById;
        if(responseData.requireNextRun){
            apc.lastPaymentId = responseData.cursor;
            apc.requireNextPaymentSyncRun = TRUE;
        }
        else{
            apc.lastPaymentId = '';
            apc.requireNextPaymentSyncRun = FALSE;
        }
        if(squarePaymentMapById != NULL){
            requestRecordsCount = squarePaymentMapById.size() > 0 ? squarePaymentMapById.size() : 0;
            processorTypeToRecordsMap.put(ProcessorUtil.PAT_SQUARE, squarePaymentMapById);
            if(requestRecordsCount > 0) {
                Processor_Square.syncTransactions(processorTypeToRecordsMap, apC);
            }
        }
    }
  /*  public static void processPaymentResponse_PayPal(Map<String, Object> response, BreadwinnerUtil.AppConfig apc, Integer requestRecordsCount){
        Map<String, Charge.TrasactionDetails> paypalCustomerMapById = new Map<String, Charge.TrasactionDetails>();
        Map<String, Charge.TrasactionDetails> paypalPaymentMapById = new Map<String, Charge.TrasactionDetails>();
        Map<String, Object> processorTypeToRecordsMap = new Map<String, Object>();
        String responseJSON = (String) response.get(ProcessorUtil.RESP_JSON);
        JSONParser parser = JSON.createParser(responseJSON);
        Processor_PayPal.FetchResponse responseData = (Processor_PayPal.FetchResponse) parser.readValueAs(Processor_PayPal.FetchResponse.Class);
        paypalCustomerMapById = responseData.customerMapById;
        paypalPaymentMapById = responseData.paymentMapById;
        if(responseData.requireNextRun){
            apc.lastPaymentId = responseData.lastPage;
            apc.requireNextPaymentSyncRun = true;
        }
       if(apc.currentRunningClassContext == BreadwinnerUtil.CNTX_HIST_SYNC){
            Date orgStartDate = Date.today().addMonths(-2);
            DateTime finalDate = DateTime.newInstance(orgStartDate,Time.newInstance(0,0,0,0));
            if(finalDate < responseData.startDate){
                apc.startdate = responseData.startDate;
                apc.endDate = finalDate;
                apc.requireNextPaymentSyncRun = True;
            }
            else{
                apc.lastPaymentId = '';
                apc.requireNextPaymentSyncRun = False;
            }
        }
        else{
            apc.lastPaymentId = '';
            apc.requireNextPaymentSyncRun = False;
        }
        if(paypalCustomerMapById != NULL){
            requestRecordsCount = paypalCustomerMapById.size() > 0 ? paypalCustomerMapById.size() : 0;
            processorTypeToRecordsMap.put(ProcessorUtil.PAT_PAYPAL, paypalCustomerMapById);
            if(requestRecordsCount > 0) {
                Processor_PayPal.syncCustomers(processorTypeToRecordsMap, apC);
            }
        }
        if(paypalPaymentMapById != NULL){
            requestRecordsCount = paypalPaymentMapById.size() > 0 ? paypalPaymentMapById.size() : 0;
            processorTypeToRecordsMap.put(ProcessorUtil.PAT_PAYPAL, paypalPaymentMapById);
            if(requestRecordsCount > 0) {
                Processor_PayPal.syncTransactions(processorTypeToRecordsMap, apC);
            }
        }
    }
   */
    private static void processPaymentResponse_AuthNet(Map<String, Object> response, BreadwinnerUtil.AppConfig apc, Map<String, Set<String>> authNetBatchIdsMap){
        String responseJSON = (String) response.get(ProcessorUtil.RESP_JSON);
        String respBody = responseJSON.trim().replace('\uFEFF', '');
        JSONParser parser = JSON.createParser(respBody);
        Map<String, Object> processorTypeToRecordsMap = new Map<String, Object>();
        Map<String, Charge.AuthNetBatchList> authNetBatchResp =  new Map<String, Charge.AuthNetBatchList>();
        Charge.AuthNetBatchResp batchResp = (Charge.AuthNetBatchResp) parser.readValueAs(Charge.AuthNetBatchResp.Class);
        String code = batchResp.messages.message[0].code; // I00001 = 'Successful', I00004 = 'No records found'
        Date orgStartDate = Date.today().addYears(-2);  // Setting final date to two years in past from today's date, as Authoize.net is storing only two year's of records in the Processor
        DateTime finalDate = DateTime.newInstance(orgStartDate,Time.newInstance(0,0,0,0));
        if(code == 'I00001'){
            for(Charge.AuthNetBatchList batchDetails : batchResp.batchList){
                authNetBatchResp.put(batchDetails.batchId, batchDetails);
            }
        } 
        // checking below condition to get two year's records
        if(finalDate < apc.startDate){
            apc.endDate = apc.startDate;
            apc.startdate = apc.startDate.addMonths(-1);
            apc.requireNextPaymentSyncRun = True;
        }
        else{
            apc.requireNextPaymentSyncRun = False;
        }
        if(!authNetBatchResp.isEmpty()){
            authNetBatchIdsMap.put(apc.name, authNetBatchResp.keySet());
            processorTypeToRecordsMap.put(ProcessorUtil.PAT_AUTHORIZE_NET, authNetBatchResp);
            Processor_Authorize_Net.syncBatchRecords(apc, processorTypeToRecordsMap);
        }
    }
    /* Schedulable - execute */
    public void execute(SchedulableContext sc) {
        if(BreadwinnerUtil.isAdministrator()) {
            if(BreadwinnerUtil.isBreadwinnerActive()) {
                CronTrigger ct = Schema.sObjectType.CronTrigger.isAccessible() ? [SELECT Id, CronExpression FROM CronTrigger WHERE Id =: sc.getTriggerId() LIMIT 1] : new CronTrigger();
                if(ct.CronExpression.containsIgnoreCase('BWPWeeklySync')) {
                    //start the historical batch
                    runHistoricalSyncBatch('');
                }
            }
            else {
                APICallHandler.userInteractionLogPush(FALSE, 'Historical Scheduler', 'INFO', 'Trial or Subscription Expired');
            }
        }
        else {
            APICallHandler.userInteractionLogPush(FALSE, 'Historical Scheduler', 'INFO', 'Running user is not an Administrator');
        }
    }

    /* This method is used to run historical sync batch */
    public static void runHistoricalSyncBatch(String syncName){
        String runningSyncName = String.isNotBlank(syncName) ? syncName : 'Customer';
        try{
            if(BreadwinnerUtil.isBreadwinnerAdministrator() && !BreadwinnerUtil.isBatchRunning(BreadwinnerUtil.CNTX_HIST_SYNC)) {
                HistoricalSyncBatch historicalSync = new HistoricalSyncBatch(runningSyncName);
                historicalSync.runThisSyncOnly = String.isNotBlank(syncName) ? true : false;
                Database.executeBatch(historicalSync, 1); //At a time only one company should be run. Don't make it other than 1.
            }
        }
        catch(exception e){
            APICallHandler.userInteractionLogPush(FALSE, 'Historical Sync', 'ERROR' , 'Error occurred while restarting Historical '+runningSyncName+'Sync ' +e);
        }
    }

    //scheduled weekly Sync
    public static void scheduleWeeklyHistoricalSync() {
        try {
            List<CronTrigger> listCronTrigger = BreadwinnerUtil.getCronTrigger(BreadwinnerUtil.SYNC_CNTX_WEEKLY);
            Boolean scheduleBreadwinnerWeeklySync = true;

            if( listCronTrigger.size() > 0) {
                scheduleBreadwinnerWeeklySync = false;
                if(listCronTrigger.get(0).NextFireTime == null) {
                    scheduleBreadwinnerWeeklySync = true;
                    System.abortJob(listCronTrigger.get(0).Id);
                }
            }
            if(scheduleBreadwinnerWeeklySync) {
                String cronToRunEveryFriday = '0 0 23 ? * FRI * BWPWeeklySync';
                HistoricalSyncBatch hss = new HistoricalSyncBatch('Nothing');
                System.schedule(BreadwinnerUtil.SYNC_CNTX_WEEKLY, cronToRunEveryFriday, hss);
            }
        }
        catch(Exception e) {
            System.debug('Exception while scheduling the Breadwinner Weekly Sync Job' +e);
        }
    }

}