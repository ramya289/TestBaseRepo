public class Processor_Batch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful{
    public List<String> authNetIds = new List<String>();
    BreadwinnerUtil.AppConfig apc = new BreadwinnerUtil.AppConfig();
    Map<String, BWP_Sync_Details__c> batchRecordsToUpdate = new Map<String, BWP_Sync_Details__c>();
    public String errors;
    public Static Boolean isSyncCompleted;
    public Integer requestRecordsCount;
    public Boolean runThisSyncOnly;
    public String runningObject;
    Exception exceptionInExecute;
    
    public Processor_Batch(List<String> authNetIdsList, BreadwinnerUtil.AppConfig appConfig, String syncObject) {
        if(BreadwinnerUtil.getBWSetting().Active__c){
            apc = appConfig != null ? appConfig : new BreadwinnerUtil.AppConfig();
            runningObject = String.isNotBlank(syncObject) ? syncObject : '';
            if(!authNetIdsList.isEmpty()) {
                authNetIds = new List<String>(authNetIdsList);
            }
        }
    }
    
    public Iterable<String> start(Database.Batchablecontext bc) {
        return authNetIds;
    }
    
    public void execute(Database.BatchableContext bc, List<String> scope) {
        isSyncCompleted = false;
        requestRecordsCount = 0;
        try{
            if(runningObject.containsIgnoreCase(BreadwinnerUtil.OBJ_SYNC_CUSTOMER))
                fetchAuthNetCustomer(scope, apc, requestRecordsCount, errors);
            else if(runningObject.containsIgnoreCase(BreadwinnerUtil.OBJ_SYNC_PAYMENT)){
                Map<String, BWP_Sync_Details__c> batchRecordsMap = new Map<String, BWP_Sync_Details__c>();
                batchRecordsMap = getBatchesToRun(scope);
                syncAuthNetPaymets(batchRecordsMap, apc, requestRecordsCount, errors, batchRecordsToUpdate);
            }
            
        }
        catch(Exception ex) {
            exceptionInExecute = ex;
        }
        
    }
    
    private static void fetchAuthNetCustomer(List<String> custIds, BreadwinnerUtil.AppConfig apc, Integer requestRecordsCount, String errors){
        Map<String, Customer.authNetCustomer> authNetCustomerMapById = new Map<String, Customer.authNetCustomer>();
        for(String custId : custIds){
            Map<String, Object> request = new Map<String, Object>();
            request.put(ProcessorUtil.API_VERSION, ProcessorUtil.VER_1);
            request.put(ProcessorUtil.API_PROCESSOR_ID, apc.accountId);
            request.put(ProcessorUtil.API_ACTION, ProcessorUtil.ACT_FETCH_CUSTOMERS_ALL);
            String requestJSON = Processor_Authorize_Net.getRequestBody(ProcessorUtil.ACT_FETCH_CUSTOMERS_RECENT, custId, apc, '');
            request.put(ProcessorUtil.API_REQUEST_JSON, requestJSON);
            
            Map<String, Object> response = new Map<String, Object>();
            List<ProcessorUtil.Error> apiErrors = (List<ProcessorUtil.Error>) response.get(ProcessorUtil.RESP_API_ERRORS);
            List<ProcessorUtil.Error> processingErrors = (List<ProcessorUtil.Error>) response.get(ProcessorUtil.RESP_PROC_ERRORS);
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
            } 
            else if(response.get(ProcessorUtil.RESP_JSON) != NULL){
                String responseJSON = (String) response.get(ProcessorUtil.RESP_JSON); 
                responseJSON = responseJSON.trim().replace('\uFEFF', '');
                JSONParser parser = JSON.createParser(responseJSON);
                Customer.authNetCustomer authNetcustomer = (Customer.authNetCustomer) parser.readValueAs(Customer.authNetCustomer.class);
                authNetCustomerMapById.put(authNetcustomer.profile.customerProfileId, authNetcustomer);
            }
        }
        if(!(authNetCustomerMapById).isEmpty()){
            Map<String, Object> processorTypeToRecordsMap = new Map<String, Object>();
            processorTypeToRecordsMap.put(ProcessorUtil.PAT_AUTHORIZE_NET, authNetCustomerMapById);
            Processor_Authorize_Net.syncCustomers(processorTypeToRecordsMap, apc, true);
            requestRecordsCount = authNetCustomerMapById.size() > 0 ? authNetCustomerMapById.size() : 0;
        } 
    }
    
    private static void syncAuthNetPaymets(Map<String, BWP_Sync_Details__c> batchRecordsToRun, BreadwinnerUtil.AppConfig apc, Integer requestRecordsCount, String errors, Map<String, BWP_Sync_Details__c> batchRecordsToUpdate){
        Map<String, Charge.AuthNetTransaction> authNetPaymentsMapById = new Map<String, Charge.AuthNetTransaction>();
        List<BWP_Sync_Details__c> batchesToUpdate = new List<BWP_Sync_Details__c>();
        for(String batchId : batchRecordsToRun.keySet()){
            Integer syncPage = Integer.valueOf(batchRecordsToRun.get(batchId).Batch_Records_Sync_Page__c);
            Integer pageNumber = (syncPage != Null && syncPage != 0) ? syncPage : 1;
            Map<String, Object> request = new Map<String, Object>();
            request.put(ProcessorUtil.API_VERSION, ProcessorUtil.VER_1);
            request.put(ProcessorUtil.API_PROCESSOR_ID, apc.accountId);
            request.put(ProcessorUtil.API_ACTION, ProcessorUtil.ACT_FETCH_TRANSACTIONS_ALL);
            String requestJSON = Processor_Authorize_Net.getRequestBody(ProcessorUtil.ACT_FETCH_TRANSACTIONS_ALL, batchId, apc, String.valueOf(pageNumber));
            request.put(ProcessorUtil.API_REQUEST_JSON, requestJSON);
            Map<String, Object> response = new Map<String, Object>();
            List<ProcessorUtil.Error> apiErrors = (List<ProcessorUtil.Error>) response.get(ProcessorUtil.RESP_API_ERRORS);
            List<ProcessorUtil.Error> processingErrors = (List<ProcessorUtil.Error>) response.get(ProcessorUtil.RESP_PROC_ERRORS);
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
            } 
            else if(response.get(ProcessorUtil.RESP_JSON) != NULL){
                String responseJSON = (String) response.get(ProcessorUtil.RESP_JSON); 
                responseJSON = responseJSON.trim().replace('\uFEFF', '');
                JSONParser parser = JSON.createParser(responseJSON);
                Charge.AuthNetTransactions authNetTransactions = (Charge.AuthNetTransactions) parser.readValueAs(Charge.AuthNetTransactions.class);
                System.debug('--totalNumInResultSet---'+authNetTransactions.totalNumInResultSet);
                BWP_Sync_Details__c paymentBatch = new BWP_Sync_Details__c();
                paymentBatch.id = batchRecordsToRun.get(batchId).id;
                paymentBatch.Batch_Id__c = batchId;
                if(authNetTransactions.totalNumInResultSet != 0){  
                    for(Charge.AuthNetTransaction trans : authNetTransactions.transactions){
                        authNetPaymentsMapById.put(trans.transId, trans);
                    }
                    apc.requireNextPaymentSyncRun = TRUE;
                    paymentBatch.Batch_Records_Sync_Page__c = pageNumber + 1;
                }
                batchRecordsToUpdate.put(batchId, paymentBatch);
            }
        }
        
        if(!(authNetPaymentsMapById).isEmpty()){
            Map<String, Object> processorTypeToRecordsMap = new Map<String, Object>();
            processorTypeToRecordsMap.put(ProcessorUtil.PAT_AUTHORIZE_NET, authNetPaymentsMapById);
            Processor_Authorize_Net.syncTransactions(processorTypeToRecordsMap, apc, true);
            requestRecordsCount = authNetPaymentsMapById.size() > 0 ? authNetPaymentsMapById.size() : 0;
        } 
    }
    
    
    public void finish(Database.BatchableContext bc) {
        if(exceptionInExecute!=NULL){
            APICallHandler.userInteractionLogPush(TRUE, 'Historical Sync', 'ERROR' , 'Historical Sync Exception in execute : ' + exceptionInExecute.getMessage() + ' Stack Trace : ' + exceptionInExecute.getStackTraceString());
        }
        try{
            isSyncCompleted = true;
            if(runningObject.containsIgnoreCase(BreadwinnerUtil.OBJ_SYNC_CUSTOMER)){
                apc.requireNextCustomerSyncRun = true;
            }
            if(runningObject.containsIgnoreCase(BreadwinnerUtil.OBJ_SYNC_PAYMENT)){
                SecurityUtil.databaseUpsert(batchRecordsToUpdate.values());
                List<BWP_Sync_Details__c> updateBatchRecords = new list<BWP_Sync_Details__c>();
                apc.requireNextPaymentSyncRun = False;
                isSyncCompleted = true;
                Map<String, BWP_Sync_Details__c> batchesToRun = new Map<String, BWP_Sync_Details__c>();
                for(BWP_Sync_Details__c paymentBatch : batchRecordsToUpdate.values()){
                    if(paymentBatch.Batch_Records_Sync_Page__c != NULL && paymentBatch.Batch_Records_Sync_Page__c > 0){
                        batchesToRun.put(paymentBatch.Batch_Id__c, paymentBatch);
                    }
                    else{
                        BWP_Sync_Details__c updateBatch = new BWP_Sync_Details__c();
                        updateBatch.id = paymentBatch.id;
                        updateBatch.Batch_Records_Sync_Page__c = 0;
                        updateBatchRecords.add(updateBatch);
                    }
                }
                if(!batchesToRun.isEmpty()){
                    apc.requireNextPaymentSyncRun = True;
                    isSyncCompleted = false;
                    List<String> batchIdsToRun = new List<String>();
                    batchIdsToRun.addAll(batchesToRun.keySet());
                    Processor_Batch processorBatch = new Processor_Batch(batchIdsToRun, apc, runningObject);
                    Database.executeBatch(processorBatch);
                }
                SecurityUtil.databaseUpsert(updateBatchRecords);
            }
            if((runningObject.containsIgnoreCase(BreadwinnerUtil.OBJ_SYNC_PAYMENT) && apc.requireNextCustomerSyncRun) || (runningObject.containsIgnoreCase(BreadwinnerUtil.OBJ_SYNC_PAYMENT) && !apc.requireNextPaymentSyncRun)) {
                HistoricalSyncBatch.postSyncUpdates(new List<BreadwinnerUtil.AppConfig>{apc}, runningObject, requestRecordsCount, runThisSyncOnly, isSyncCompleted);
            }
        }
        catch(Exception ex){
            System.debug('Exception in Finish : '+ex.getLineNumber()+' '+ex.getMessage());
        }        
    }
    
    private static Map<String, BWP_Sync_Details__c> getBatchesToRun(List<String> batchIds){
        Map<String, BWP_Sync_Details__c> returnIncompleteBatchMap = new Map<String, BWP_Sync_Details__c>();
        QueryBuilder qb = new QueryBuilder(BWP_Sync_Details__c.SObjectType, true, true, true);
        List<Schema.SObjectField> fieldsList = new List<Schema.SObjectField>{BWP_Sync_Details__c.Batch_Id__c, BWP_Sync_Details__c.Batch_Records_Sync_Page__c};
        qb.addSObjectFields(fieldsList);
        qb.setCondition('Batch_Id__c IN : batchIds');
        qb.setLimit(100);
        List<BWP_Sync_Details__c> existingBatches = Database.query(qb.toSOQL());
        for(BWP_Sync_Details__c batch : existingBatches){
            returnIncompleteBatchMap.put(batch.Batch_Id__c, batch);
        }
        return returnIncompleteBatchMap;
    }
}