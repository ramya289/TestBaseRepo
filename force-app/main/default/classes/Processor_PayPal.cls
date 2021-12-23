public with sharing class Processor_PayPal extends Processor{
    
    private static Selector_BWP_Customer selectorCustomer = new Selector_BWP_Customer();
    private static Selector_BWP_Transaction selectorTransaction = new Selector_BWP_Transaction();
    
    //PayPal Endpoints
    public static String paypalBaseUrl ='https://api.paypal.com';
    public static String paypalTestBaseUrl = 'https://api.sandbox.paypal.com';
    public static String paypalAuthorizationUrl = 'https://www.paypal.com';
    public static String paypalTestAuthorizationUrl = 'https://www.sandbox.paypal.com';

    BWP_Processor_Config__c apc;
    BreadwinnerUtil.AppConfig apcWrapper;
    
    public Processor_PayPal(String paypalAccountId) {
        apc = BreadwinnerUtil.getProcessorConfig(paypalAccountId);
        if (apc == null) {
            throw new ProcessorUtil.InvalidAccountConfigurationException('Invalid PayPal ORG Id provided.');
        }
        apcWrapper = BreadwinnerUtil.getProcessorConfigWrapper(apc);
    }
    
  /*  public override ProcessorUtil.ResponseObject fetchTransactions(String requestJSON){
        return fetchTransactions(apcWrapper, requestJSON);
    }

    @TestVisible
        System.debug('---in fetchPayments--');
    private static ProcessorUtil.ResponseObject fetchTransactions(BreadwinnerUtil.AppConfig apcWrapper, String requestJSON) {
        ProcessorUtil.ResponseObject response = new ProcessorUtil.ResponseObject();
        response.errors = new List<ProcessorUtil.Error>();
        FetchRequest filters = (FetchRequest)System.JSON.deserialize(requestJSON, FetchRequest.class);
        String endPoint = getEndpointBaseUrl(apcWrapper) + '/v1/reporting/transactions';
        endPoint += '?fields=' + filters.fields;
        endPoint += '&page_size=' + filters.page_size;
        endPoint += '&page=' + filters.page;
        endPoint += '&start_date=' + filters.start_date;
        endPoint += '&end_date=' + filters.end_date;
        if(String.isNotBlank(filters.lastPage))
            endPoint = endPoint.replace('page='+filters.page, 'page='+(Integer.ValueOf(filters.lastPage)+1));
        
        if(apcWrapper.requireNextPaymentSyncRun && apcWrapper.startDate != null  && apcWrapper.endDate != null){
            endPoint = endpoint.replace(endPoint.substringAfter('start_date'), '='+json.serialize(apcWrapper.startDate.addDays(-30)).remove('"')+'&end_date='+json.serialize(apcWrapper.startDate).remove('"'));
        }
        System.debug('--endPoint--'+endPoint);
        HttpResponse res = APICallHandler.getList(apcWrapper, 'GET', endPoint, '');
        System.debug('--res body--'+res.getBody());
        response.status = String.valueOf(res.getStatusCode());
        
        if (res.getStatusCode() == 200) {
            FetchResponse fetchResponse = new FetchResponse();
            fetchResponse = parsePayments(res.getBody());
            response.responseJSON = JSON.serializePretty(fetchResponse);
            
        } else {
            apcWrapper.needToReconnect = true;
            apcWrapper.requireNextPaymentSyncRun = false;
            String Action_Type = apcWrapper.currentRunningClassContext == BreadwinnerUtil.CNTX_HIST_SYNC ? 'Historical Sync':(apcWrapper.currentRunningClassContext == BreadwinnerUtil.CNTX_HOUR_SYNC ? 'Hourly Sync':'Fetching Transactions');
                APICallHandler.userInteractionLogPush(true, Action_Type, 'ERROR' , 'Response for Processor Org Name('+apcWrapper.accountName+'): Status Code: '+res.getStatusCode()+' Response Body: '+res.getBody() );
            
            JSONParser parser = JSON.createParser(res.getBody());
            ProcessorUtil.Error error = (ProcessorUtil.Error) parser.readValueAs(ProcessorUtil.Error.class);
            response.errors.add(error);
        }
        
        return response;
    }
    
    public static BreadwinnerUtil.AppConfig syncCustomers(Map<String, Object> processorToCustomerMap, BreadwinnerUtil.AppConfig appConfig) {
        try {
            System.debug('---in syncCustomers--');
            if(String.isBlank(appConfig.customerSyncConfig) || ((String.isNotBlank(appConfig.customerSyncConfig) && (appConfig.customerSyncConfig != 'NONE')))  && appConfig.currentRunningClassContext != BreadwinnerUtil.CNTX_BWAPI)
                processorToCustomerMap = excludeCustomers(processorToCustomerMap, appConfig);
            
            Breadwinner_Settings__c bwSetting = BreadwinnerUtil.getBWSetting();
            Map<String, Charge.TrasactionDetails> backuppaypalIdCustomerMap =  new Map<String, Charge.TrasactionDetails>();
            Map<String, Charge.TrasactionDetails> paypalIdCustomerMap =  (Map<String, Charge.TrasactionDetails>) processorToCustomerMap.get(ProcessorUtil.PAT_PAYPAL);
            backuppaypalIdCustomerMap.putAll(paypalIdCustomerMap);
            List<BWP_Customer__c> customerUpsertList = new List<BWP_Customer__c> ();
            Map<String, BWP_Customer__c> customerUpsertMap = new Map<String, BWP_Customer__c>();
            Map<String,BWP_Customer__c> existingSFCustomersMap = new Map<String,BWP_Customer__c>();
            if(paypalIdCustomerMap != null){
                //Holding existing customer records in Salesforce
                for(BWP_Customer__c cus : selectorCustomer.selectByProcessorCustomerId(paypalIdCustomerMap.keySet(), 45000))
                    existingSFCustomersMap.put(cus.Processor_Customer_Id__c,cus);
            }
            Map<Id,Boolean> recordTypeIdToIsPersonTypeMap = ProcessorUtil.getIsPersonRTMap();
            Boolean areRecordTypesEnabled = ProcessorUtil.areRecordTypesEnabled();
            Boolean isDefaultRecordTypeMaster = ProcessorUtil.isDefaultRecordTypeIsMaster();
            //-- Map to store Processor Account Id and new SF Account to be inserted
            Map<String, Account> mapCustomerIdAndNewSFAccount = new Map<String, Account>();
            
            Set<String> customerNameSet = new Set<String>();
            Set<String> customerEmailSet = new Set<String>();
            
            for(String ContactId : paypalIdCustomerMap.keySet()){       
                if(!existingSFCustomersMap.containsKey(ContactId) || (existingSFCustomersMap.containsKey(ContactId) && existingSFCustomersMap.get(ContactId).Salesforce_Account__c == NULL && !existingSFCustomersMap.get(ContactId).No_Associated_SF_Account__c )){
                    Charge.TrasactionDetails sc = paypalIdCustomerMap.get(ContactId);     
                    String customerName = (String.isNotBlank(sc.payer_info.payer_name.given_name) ? (sc.payer_info.payer_name.given_name + (String.isNotBlank(sc.payer_info.payer_name.surname) ? (' '+sc.payer_info.payer_name.surname) : '')) : (String.isNotBlank(sc.payer_info.payer_name.surname) ? sc.payer_info.payer_name.surname : (String.isNotBlank(sc.payer_info.payer_name.alternate_full_name) ? sc.payer_info.payer_name.alternate_full_name : '')));
                    if(String.isNotBlank(customerName)){        
                        String ContactName = customerName.toLowerCase().replace('\\', '%');      
                        Set<String> relatedNameSet = BreadwinnerUtil.getSimilarAccountNameSet(ContactName);     
                        customerNameSet.addAll(relatedNameSet);     
                    }
                    else if(String.isNotBlank(sc.payer_info.email_address)){
                        String ContactEmail = sc.payer_info.email_address.toLowerCase().replace('\\', '%');      
                        Set<String> relatedNameSet = BreadwinnerUtil.getSimilarAccountNameSet(ContactEmail);     
                        customerNameSet.addAll(relatedNameSet);
                    }
                    if(ProcessorUtil.arePersonAccountsEnabled() && String.isNotBlank(sc.payer_info.email_address)){
                        String email = sc.payer_info.email_address.toLowerCase().replace('\\', '%');
                        customerEmailSet.add(email);
                    }
                }
            }
            ///account fetch
            Map<String,Account> nameToAccountMap = new Map<String,Account>();
            Map<String,Account> personAccountEmailToAccountMap= new Map<String,Account>();
            List<String> referenceIdListForCreateNew = new List<string>();
            
            for(Account a : ProcessorUtil.getAccountsForCustomerSync(customerNameSet, customerEmailSet)){
                String lowerCaseName = a.Name.toLowerCase().replace('\\', '%');
                Set<String> relatedAccountNameSet = BreadwinnerUtil.getSimilarAccountNameSet(lowerCaseName);
                for(String accName: relatedAccountNameSet){
                    nameToAccountMap.put(accName, a);
                }
                if(ProcessorUtil.arePersonAccountsEnabled()){
                    string personEmail = string.valueOf(a.get('PersonEmail'));
                    if(string.isNotBlank(personEmail)){
                        personEmail=personEmail.toLowerCase().replace('\\', '%');
                        personAccountEmailToAccountMap.put(personEmail, a);
                    }
                }
            }
            
            system.debug('appConfig.isCustomerMatchComplete'+appConfig.isCustomerMatchComplete);
            system.debug('appConfig.currentRunningClassContext'+appConfig.currentRunningClassContext);
            if(appConfig.isCustomerMatchComplete && appConfig.currentRunningClassContext != BreadwinnerUtil.CNTX_BWAPI){
                for(String refId : paypalIdCustomerMap.keySet()){
                    Charge.TrasactionDetails cw = paypalIdCustomerMap.get(refId);
                    String cName = (String.isNotBlank(cw.payer_info.payer_name.given_name) ? (cw.payer_info.payer_name.given_name + (String.isNotBlank(cw.payer_info.payer_name.surname) ? (' '+cw.payer_info.payer_name.surname) : '')) : (String.isNotBlank(cw.payer_info.payer_name.surname) ? cw.payer_info.payer_name.surname : (String.isNotBlank(cw.payer_info.payer_name.alternate_full_name) ? cw.payer_info.payer_name.alternate_full_name : '')));
                    ID accID;
                    if(!existingSFCustomersMap.containsKey(refId) || (existingSFCustomersMap.containsKey(refId) && existingSFCustomersMap.get(refId).Salesforce_Account__c == NULL && !existingSFCustomersMap.get(refId).No_Associated_SF_Account__c )){
                        string customerNameLowerCase = (String.isNotBlank(cName)) ? (cName).toLowerCase().replace('\\', '%') : (String.isNotBlank(cw.payer_info.email_address) ? (cw.payer_info.email_address.toLowerCase().replace('\\', '%')) : '');
                            // first check with person account email then with company name if person accounts are enabled
                            String personEmail = String.isNotBlank(cw.payer_info.email_address) ? (cw.payer_info.email_address.toLowerCase().replace('\\', '%')) : '';
                        //first check with Person accounts enabled
                        if((ProcessorUtil.arePersonAccountsEnabled() && personAccountEmailToAccountMap.containsKey(personEmail)) || nameToAccountMap.containsKey(customerNameLowerCase)){
                            system.debug('existed accounts');
                            if(ProcessorUtil.arePersonAccountsEnabled() && personAccountEmailToAccountMap.containsKey(personEmail)){
                                accID = personAccountEmailToAccountMap.get(personEmail).Id;
                            }
                            else if(nameToAccountMap.containsKey(customerNameLowerCase) ){
                                accID = nameToAccountMap.get(customerNameLowerCase).Id;
                            }
                        }
                    }
                    
                    if(String.isNotBlank(cw.transaction_info.paypal_account_id)) {
                        // Querying existing PayPal Customer if any or creating new one
                        BWP_Customer__c customerSf = existingSFCustomersMap.get(cw.transaction_info.paypal_account_id) != null ? existingSFCustomersMap.get(cw.transaction_info.paypal_account_id) : new BWP_Customer__c();
                        customerSf = constructPayPalCustomer(customerSf, cw, appConfig);
                        if(!existingSFCustomersMap.containsKey(refId) || (existingSFCustomersMap.containsKey(refId) && existingSFCustomersMap.get(refId).Salesforce_Account__c == NULL && !existingSFCustomersMap.get(refId).No_Associated_SF_Account__c )) customerSf.Salesforce_Account__c = customerSf.Salesforce_Account__c != null ? customerSf.Salesforce_Account__c : accID;
                        customerUpsertList.add(customerSf);
                        customerUpsertMap.put(refId, customerSf);
                        paypalIdCustomerMap.remove(refId);
                    }
                    
                    if(accID == NULL && (!existingSFCustomersMap.containsKey(refId) || (existingSFCustomersMap.containsKey(refId) && existingSFCustomersMap.get(refId).Salesforce_Account__c == NULL && !existingSFCustomersMap.get(refId).No_Associated_SF_Account__c ))){
                        // Create New accounts
                        system.debug('new accounts');
                        String customerName = (String.isNotBlank(cName) ? cName : (String.isNotBlank(cw.payer_info.email_address) ? cw.payer_info.email_address : ''));
                        Account acctRef = new Account();
                        
                        if(areRecordTypesEnabled && !isDefaultRecordTypeMaster ){
                            String accDefaultRecordType = ProcessorUtil.getDefaultAccountRecordType();                            
                            ID chosenRecordTypeId = String.isNotBlank(accDefaultRecordType) ? (ID)accDefaultRecordType : '';
                            
                            system.debug('chosenRecordTypeId: '+chosenRecordTypeId);
                            
                            if(String.isNotBlank(chosenRecordTypeId)) acctRef.put('RecordTypeId', ''+chosenRecordTypeId);
                            if(ProcessorUtil.arePersonAccountsEnabled() && recordTypeIdToIsPersonTypeMap.containsKey(chosenRecordTypeId) && recordTypeIdToIsPersonTypeMap.get(chosenRecordTypeId)){
                                acctRef.put('LastName',customerName);
                            }
                            else{
                                acctRef.Name = customerName;
                            }
                        }
                        else{
                            acctRef.Name = customerName;
                        }
                        
                        if(cw.shipping_info != NULL){
                            acctRef.BillingStreet = cw.shipping_info.line1.replaceAll('%%', '\r\n');
                            acctRef.BillingCity = cw.shipping_info.city;
                            acctRef.BillingState = cw.shipping_info.state;
                            acctRef.BillingCountry = cw.shipping_info.country_code;
                            acctRef.BillingPostalCode = cw.shipping_info.postal_code;
                        } 
                        
                        acctRef.Description = 'This Salesforce Account was created by Breadwinner.';
                        //Do field Truncation
                        if(string.isNotBlank(acctRef.BillingStreet) && acctRef.BillingStreet.length() > 255) acctRef.BillingStreet = acctRef.BillingStreet.left(255);
                        if(string.isNotBlank(acctRef.BillingCity) && acctRef.BillingCity.length() > 40) acctRef.BillingCity = acctRef.BillingCity.left(40);
                        if(string.isNotBlank(acctRef.BillingState) && acctRef.BillingState.length() > 20) acctRef.BillingState = acctRef.BillingState.left(20);
                        if(string.isNotBlank(acctRef.BillingPostalCode) && acctRef.BillingPostalCode.length() > 20) acctRef.BillingPostalCode = acctRef.BillingPostalCode.left(20);
                        if(string.isNotBlank(acctRef.BillingCountry) && acctRef.BillingCountry.length() > 40) acctRef.BillingCountry = acctRef.BillingCountry.left(40);
                        
                        mapCustomerIdAndNewSFAccount.put(refId,acctRef);
                        referenceIdListForCreateNew.addAll(mapCustomerIdAndNewSFAccount.keySet());
                    }
                } 
                List<Account> accountsFailedList = new List<Account>();
                Set<String> otherExceptionsSet = new Set<String>();
                Map<String,Account> mapCustomerIdAndFailedAccounts = new Map<String,Account>();
                long longTime = system.now().getTime()/1000;
                string errorMessage;
                String duplicateAccounts = '';
                String duplicatesExcErrorLog = 'DUPLICATES_DETECTED : Unable to create this Accounts : ';
                //Handle Exceptions and State&Country picklists
                if(!mapCustomerIdAndNewSFAccount.isEmpty()){
                    System.debug('syncCustomers - upsert new: ' + mapCustomerIdAndNewSFAccount);
                    Database.UpsertResult[]  ur1List = SecurityUtil.databaseUpsert(mapCustomerIdAndNewSFAccount.values());
                    
                    //Handle exceptions
                    for(Integer i = 0; i< ur1List.size(); i++){
                        if(!ur1List[i].isSuccess()){
                            Database.Error[] errors = ur1List[i].getErrors();
                            Database.Error firstError = errors.get(0);
                            if( string.valueOf(firstError.getStatusCode())== 'FIELD_INTEGRITY_EXCEPTION' && ProcessorUtil.areStateAndCountryPicklistsEnabled()){
                                Account temp = mapCustomerIdAndNewSFAccount.get(referenceIdListForCreateNew.get(i));
                                
                                temp.BillingState = null;
                                for(String field : firstError.getFields()){
                                    if(field.equalsIgnoreCase('BillingCountry')){
                                        temp.BillingCountry = null;
                                    }
                                }
                                //if(errors.get(0).getFields().get(0) == 'BillingCountry')temp.BillingCountry = null;
                                temp.Description = 'This Salesforce Account was created by Breadwinner.';
                                mapCustomerIdAndFailedAccounts.put(referenceIdListForCreateNew.get(i), temp);
                            }
                            else{
                                if(string.valueOf(firstError.getStatusCode())== 'DUPLICATES_DETECTED'){
                                    Account temp = mapCustomerIdAndNewSFAccount.get(referenceIdListForCreateNew.get(i));
                                    for(Database.Error er : errors){
                                        duplicateAccounts += temp.Name+', ';
                                    }
                                }else{
                                    for(Database.Error er : errors)
                                        otherExceptionsSet.add(er.getStatusCode() + ': ' + er.getMessage());
                                }
                            }
                        }
                    }
                    system.debug(mapCustomerIdAndFailedAccounts);
                    System.debug('syncCustomers - upsert failed: ' + mapCustomerIdAndNewSFAccount);
                    Database.UpsertResult[] upsertResultList = SecurityUtil.databaseUpsert(mapCustomerIdAndFailedAccounts.values());
                    // Iterate through each returned result
                    for (Database.UpsertResult ur : upsertResultList) {
                        if (!ur.isSuccess()) {
                            // Operation failed, so get all errors
                            for(Database.Error er : ur.getErrors()) {
                                otherExceptionsSet.add(er.getStatusCode() + ': ' + er.getMessage());
                            }
                        }
                    }
                    
                    for(string refIdOfNewInsert : mapCustomerIdAndFailedAccounts.keySet()){
                        mapCustomerIdAndNewSFAccount.put(refIdOfNewInsert, mapCustomerIdAndFailedAccounts.get(refIdOfNewInsert));
                    }
                }else{
                    System.debug('Do not have Create and Update Permission on Account Object');
                }
                
                for(String refId : mapCustomerIdAndNewSFAccount.keySet()){
                    if(customerUpsertMap.containsKey(refId)){
                        BWP_Customer__c customerSf = customerUpsertMap.get(refId);
                        customerSf.Salesforce_Account__c = mapCustomerIdAndNewSFAccount.get(refId).Id;
                        customerUpsertMap.put(refId, customerSF);
                        customerUpsertList.add(customerSf);
                    }
                }
            }
            else{
                // If Account Match is not completed, sync the customers without accounts
                for(String refId : paypalIdCustomerMap.keySet()){
                    Charge.TrasactionDetails customer = paypalIdCustomerMap.get(refId);
                    if(String.isNotBlank(customer.transaction_info.paypal_account_id)) {
                        BWP_Customer__c customerSf = existingSFCustomersMap.get(customer.transaction_info.paypal_account_id) != null ? existingSFCustomersMap.get(customer.transaction_info.paypal_account_id) : new BWP_Customer__c();
                        customerSf = constructPayPalCustomer(customerSf, customer, appConfig); 
                        if(BreadwinnerUtil.accountId != null)
                            customerSf.Salesforce_Account__c = BreadwinnerUtil.accountId;
                        customerUpsertMap.put(refId, customerSF);
                        customerUpsertList.add(customerSf);
                    }
                }
            }
            system.debug('customer: ' + customerUpsertMap);
            Set<ID> updatedCustomers = new Set<ID>();
            Database.UpsertResult[] results = SecurityUtil.databaseUpsert(customerUpsertMap.values(),BWP_Customer__c.Processor_Customer_Id__c);
            
            if (results != null){
                for (Database.UpsertResult result : results) {
                    if (result.isSuccess()) {
                        updatedCustomers.add(result.getId());
                    }
                }
            }
            system.debug('updated Customers----'+updatedCustomers);
        }
        catch(Exception ex) {
            System.debug('Customer Sync failed for '+appConfig.Name +' while syncing. \n' +ex.getStackTraceString()+'\n'+ex.getMessage());
            APICallHandler.userInteractionLogPush(TRUE, 'Customer Sync', 'ERROR' , 'Customer Sync failed for '+appConfig.Name +' while syncing. \n' +ex.getStackTraceString()+'\n'+ex.getMessage());
        }
        
        return appConfig;
    }
    
    public static Map<String, Object> syncTransactions(Map<String, Object> processorIdToPaymentMap, BreadwinnerUtil.AppConfig appConfig) {
        Map<String, Object> returnMap = new Map<String, Object>();
        
        // Map to store the Payment Id and related Customer Id
        Set<String> successfulPaymentsCustomerIdSet = new Set<String>();
        Map<String, Charge.TrasactionDetails> paypalIdPaymentMap =  (Map<String, Charge.TrasactionDetails>) processorIdToPaymentMap.get(ProcessorUtil.PAT_PAYPAL);
        if(paypalIdPaymentMap == null) {
            return returnMap;
        }
        List<BWP_Transaction__c> payments = new List<BWP_Transaction__c>();
        Map<String,BWP_Transaction__c> existingSFPaymentsMap = new Map<String,BWP_Transaction__c>();
        List<BWP_Customer__c> customerInfo = new List<BWP_Customer__c>();
        List<BWP_Transaction__c> existingList = selectorTransaction.selectByProcessorId(paypalIdPaymentMap.keySet(), new List<String>{'Source__r.Id'});
        for(BWP_Transaction__c trxn : existingList) {
            BWP_Transaction__c txn = new BWP_Transaction__c(id = trxn.id, Processor_Id__c = trxn.Processor_Id__c);
            existingSFPaymentsMap.put(txn.Processor_Id__c, txn);
        }
        try{
            // Boolean to check the syncing of failed Payments
            Boolean doNotImportCustomerAndFailedPayments = (String.isBlank(appConfig.customerMatchConfig) || (String.isNotBlank(appConfig.customerMatchConfig) && (appConfig.customerMatchConfig.contains('NO_VALID_PAYMENTS')))) ? TRUE : FALSE;
            
            Set<String> customerIdSet = new Set<String>();
            for (Charge.TrasactionDetails pw : paypalIdPaymentMap.values()) {
                customerIdSet.add(pw.transaction_info.paypal_account_id);
            }
            
            // Create a map of customers
            Map<String, BWP_Customer__c> customerMapByProcessorCustomerId = new Map<String, BWP_Customer__c>();
            List<BWP_Customer__c> customerList = selectorCustomer.selectByProcessorCustomerId(customerIdSet,null);
            for (BWP_Customer__c customer : customerList) {
                customerMapByProcessorCustomerId.put(customer.Processor_Customer_Id__c, customer);
            }
            
            for (Charge.TrasactionDetails pw : paypalIdPaymentMap.values()) {
                BWP_Transaction__c transactionSf = existingSFPaymentsMap.get(pw.transaction_info.transaction_id) != null ? existingSFPaymentsMap.get(pw.transaction_info.transaction_id) : new BWP_Transaction__c();
                BWP_Customer__c customer = String.isNotBlank(pw.transaction_info.paypal_account_id) ? customerMapByProcessorCustomerId.get(pw.transaction_info.paypal_account_id) : null;
                if(customer != null && String.isNotBlank(customer.Id))
                    transactionSf.Customer__c = customer.Id;
                transactionSf.Processor_Customer_Id__c = String.isNotBlank(pw.transaction_info.paypal_account_id) ? pw.transaction_info.paypal_account_id  : '';
                
                // TODO: In order to decide which trasactions to sync to Salesforce, study about Transaction codes 
                if(!pw.transaction_info.transaction_event_code.contains('T15')){
               // if((!pw.transaction_info.transaction_event_code.contains('T15') && pw.transaction_info.fee_amount != null) || (pw.transaction_info.paypal_reference_id == null && pw.transaction_info.fee_amount != null)){
                    transactionSf = constructPayPalTransaction(transactionSf, pw, appConfig); 
                }
                if (doNotImportCustomerAndFailedPayments && transactionSf.Status__c == 'Succeeded') {
                    if(String.isNotBlank(transactionSf.Customer__c)){
                        successfulPaymentsCustomerIdSet.add(transactionSf.Customer__c);
                    }
                }
                if ((doNotImportCustomerAndFailedPayments ? (transactionSf.Status__c == 'Succeeded' ? TRUE : FALSE) : TRUE)){
                    payments.add(transactionSf);
                }  
            } 
            Database.UpsertResult[] urList = SecurityUtil.databaseUpsert(payments,BWP_Transaction__c.Processor_Id__c);
            List<String> errorList = BreadwinnerUtil.checkForUpsertErrors(urList);
            if (! errorList.isEmpty()){
                returnMap.put('errors', errorList);
                System.debug('--errors--'+errorList);
            }
            
            system.debug('payments-------'+payments);
            if (doNotImportCustomerAndFailedPayments && Schema.sObjectType.BWP_Customer__c.isCreateable() && Schema.sObjectType.BWP_Customer__c.isUpdateable()) {
                if (!successfulPaymentsCustomerIdSet.isEmpty()) {
                    List<BWP_Customer__c> customerUpdateList = new List<BWP_Customer__c>();
                    for (BWP_Customer__c succesfulPaymentscustomer : selectorCustomer.selectById(successfulPaymentsCustomerIdSet)) {
                        succesfulPaymentscustomer.Has_Successful_Payments__c = TRUE;
                        customerUpdateList.add(succesfulPaymentscustomer);
                    }
                    SecurityUtil.dmlUpdate(customerUpdateList);
                }
            }
        }
        catch(Exception Ex) {
            System.debug('Payments Sync failed for '+appConfig.Name +' while syncing. \n' +ex.getStackTraceString());
            APICallHandler.userInteractionLogPush(TRUE, 'Customer Sync', 'ERROR' , 'Payments Sync failed for '+appConfig.Name +' while syncing. \n' +ex.getStackTraceString());
        }
        return returnMap;
    }
    
    private static Map<String, Object> excludeCustomers(Map<String, Object> processorToCustomerMap, BreadwinnerUtil.AppConfig appConfig){
        
        Map<String, Object> returnProcessorToCustomerMap = new Map<String, Object>();
        String customerSyncConfigValue = '';
        customerSyncConfigValue = String.isNotBlank(appConfig.customerSyncConfig) ? appConfig.customerSyncConfig : 'NONAME_AND_NOEMAIL';
        Map<String, Charge.TrasactionDetails> paypalIdCustomerMap =  (Map<String, Charge.TrasactionDetails>) processorToCustomerMap.get(ProcessorUtil.PAT_PAYPAL);
        
        // Excluding PayPal Customers based on configuration values from Breadwinner Payments page
        if(!paypalIdCustomerMap.isEmpty()){
            for(String contactId : paypalIdCustomerMap.keySet()){
                Charge.TrasactionDetails sc = paypalIdCustomerMap.get(contactId);
                Boolean excludeCustomer = false;
                String cName = (String.isNotBlank(sc.payer_info.payer_name.given_name) ? (sc.payer_info.payer_name.given_name + (String.isNotBlank(sc.payer_info.payer_name.surname) ? (' '+sc.payer_info.payer_name.surname) : '')) : (String.isNotBlank(sc.payer_info.payer_name.surname) ? sc.payer_info.payer_name.surname : ''));
                if(customerSyncConfigValue.contains('NONAME_AND_NOEMAIL') && String.isBlank(cName) && String.isBlank(sc.payer_info.email_address)){
                    excludeCustomer = true;
                }
                else if(customerSyncConfigValue.contains('NO_NAME') && (String.isBlank(cName))){
                    excludeCustomer = true;
                }
                else if(customerSyncConfigValue.contains('NO_EMAIL') && String.isBlank(sc.payer_info.email_address)){
                    excludeCustomer = true;
                }
                if(excludeCustomer){
                    paypalIdCustomerMap.remove(contactId);
                }
            }
        }
        if(!paypalIdCustomerMap.isEmpty()){
            returnprocessorToCustomerMap.put(ProcessorUtil.PAT_PAYPAL, paypalIdCustomerMap);
        }
        return returnprocessorToCustomerMap;
    }
    
    public static FetchResponse parsePayments(String responseBody) {	
        Map<String, Charge.TrasactionDetails> paypalIdToPaymentMap = new Map<String, Charge.TrasactionDetails>();
        Map<String, Charge.TrasactionDetails> paypalIdToCustomerMap = new Map<String, Charge.TrasactionDetails>();
        FetchResponse response = new FetchResponse();
        try{	
            JSONParser parser = JSON.createParser(responseBody);
            Charge.PayPalTransactions paymentsResp = (Charge.PayPalTransactions) parser.readValueAs(Charge.PayPalTransactions.Class);
            if(paymentsResp != NULL){
                for (Charge.TrasactionDetails payment : paymentsResp.transaction_details){
                    paypalIdToPaymentMap.put(payment.transaction_info.transaction_id, payment);
                    if(payment.transaction_info.paypal_account_id != null)
                        paypalIdToCustomerMap.put(payment.transaction_info.paypal_account_id, payment);
                }
            }
            if(paymentsResp.total_pages > paymentsResp.page){
                response.lastPage = String.valueOf(paymentsResp.page);
                response.requireNextRun=true;
                System.debug('total pages greater than page---'+response.requireNextRun);
            }
            else{
                response.startDate = paymentsResp.start_date;
                response.endDate = paymentsResp.end_date;
                response.lastPage = '';
                response.requireNextRun=false;
                System.debug('-startDate-'+response.startDate+'-requireNextRun-'+response.requireNextRun);
            }
            System.debug('-paypalIdToCustomerMap--'+paypalIdToCustomerMap);
            System.debug('-paypalIdToPaymentMap--'+paypalIdToPaymentMap);
            response.customerMapById = paypalIdToCustomerMap;
            response.paymentMapById = paypalIdToPaymentMap;
        } catch(Exception ex) {	
            System.debug('Customer Sync failed for while parsing. \n' +ex.getStackTraceString());	
            APICallHandler.userInteractionLogPush(TRUE, 'Customer Sync', 'ERROR' , 'Customer Sync failed for while parsing. \n' +ex.getStackTraceString());	
        }	
        return response;	
        
    }
    
    public static BWP_Customer__c constructPayPalCustomer(BWP_Customer__c customerSf, Charge.TrasactionDetails cw, BreadwinnerUtil.AppConfig appConfig){
        if(customerSf.Id == null){
            customerSf.Created_Via__c = (appConfig.currentRunningClassContext == BreadwinnerUtil.CNTX_HIST_SYNC ? 'Historical Sync' : (appConfig.currentRunningClassContext == BreadwinnerUtil.CNTX_HOUR_SYNC ? 'Regular Sync' : (appConfig.currentRunningClassContext == BreadwinnerUtil.CNTX_BWAPI ? 'Breadwinner API' : '')));
        }
        customerSf.Customer_ID__c = cw.transaction_info.paypal_account_id+'-'+appConfig.PaymentProcessorType+'-'+appConfig.accountId;
        customerSf.Customer_Name__c = (String.isNotBlank(cw.payer_info.payer_name.given_name) ? (cw.payer_info.payer_name.given_name + (String.isNotBlank(cw.payer_info.payer_name.surname) ? (' '+cw.payer_info.payer_name.surname) : '')) : (String.isNotBlank(cw.payer_info.payer_name.surname) ? cw.payer_info.payer_name.surname : (String.isNotBlank(cw.payer_info.payer_name.alternate_full_name) ? cw.payer_info.payer_name.alternate_full_name : '')));
        customerSf.Name = (String.isNotBlank(customerSf.Customer_Name__c) ? customerSf.Customer_Name__c : ((String.isNotBlank(cw.payer_info.email_address) ? cw.payer_info.email_address : (String.isNotBlank(cw.transaction_info.paypal_account_id) ? cw.transaction_info.paypal_account_id : ''))));
        customerSf.First_Name__c = cw.payer_info.payer_name.given_name;
        customerSf.Last_Name__c = cw.payer_info.payer_name.surname;
        customerSf.Processor_Type__c = appConfig.PaymentProcessorType;
        customerSf.Processor_Org_Id__c = appConfig.accountId;
        customerSf.Processor_Org_Name__c = appConfig.accountName;
        customerSf.Livemode__c = appConfig.liveMode == TRUE ? TRUE : FALSE;
        customerSf.Email__c = cw.payer_info.email_address;
        customerSf.Processor_Customer_Id__c = cw.transaction_info.paypal_account_id;
        customerSf.Reference_Id__c = cw.transaction_info.transaction_id;
        //customerSf.Company__c = cw.company_name;
        
        //Billing Address
        if(cw.shipping_info != null) {
            customerSf.Billing_Street_Address_1__c = cw.shipping_info.line1;
            customerSf.Billing_Street_Address_2__c = cw.shipping_info.line2;
            customerSf.Billing_City__c = cw.shipping_info.city;
            customerSf.Billing_State__c = cw.shipping_info.state; 
            customerSf.Billing_Country__c =  cw.shipping_info.country_code;
            customerSf.Billing_Postal_Code__c = cw.shipping_info.postal_code;
            
        }
        return customerSf;
    }
    
    public static BWP_Transaction__c constructPayPalTransaction(BWP_Transaction__c transactionSf, Charge.TrasactionDetails pw, BreadwinnerUtil.AppConfig appConfig){
        if(transactionSf.Id == null){
            transactionSf.Created_Via__c = (appConfig.currentRunningClassContext == BreadwinnerUtil.CNTX_HIST_SYNC ? 'Historical Sync' : (appConfig.currentRunningClassContext == BreadwinnerUtil.CNTX_HOUR_SYNC ? 'Regular Sync' : (appConfig.currentRunningClassContext == BreadwinnerUtil.CNTX_BWAPI ? 'Breadwinner API' : '')));
        }
        transactionSf.Processor_Id__c = pw.transaction_info.transaction_id; 
        transactionSf.Processor_Type__c = appConfig.PaymentProcessorType;
        transactionSf.Processor_Org_Id__c = appConfig.accountId;
        if (pw.transaction_info.transaction_amount != null) {  
            transactionSf.Application_Fee__c = (pw.transaction_info.transaction_amount.value)/100;
        }    
        if (pw.transaction_info.fee_amount != null) {  
            transactionSf.Processing_Fee__c = (pw.transaction_info.fee_amount.value)/100;
        } 
        if ((transactionSf.Application_Fee__c !=null && transactionSf.Processing_Fee__c != null)) {
            transactionSf.Amount__c = transactionSf.Application_Fee__c +  transactionSf.Processing_Fee__c;
        }
        if (pw.transaction_info.transaction_amount != null) {
            transactionSf.Currency__c = String.isNotBlank(pw.transaction_info.transaction_amount.currency_code) ? (pw.transaction_info.transaction_amount.currency_code).toUpperCase() : '';
        }
        if (String.isNotBlank(pw.transaction_info.transaction_status)) {
            if(pw.transaction_info.transaction_status =='S')
                transactionSf.Status__c = 'Succeeded';
            if(pw.transaction_info.transaction_status =='P')
                transactionSf.Status__c = 'Pending';
            if(pw.transaction_info.transaction_status =='D')
                transactionSf.Status__c = 'Denied';
            if(pw.transaction_info.transaction_status =='F')
                transactionSf.Status__c = 'Partially Refunded';
            if(pw.transaction_info.transaction_status =='V')
                transactionSf.Status__c = 'Reversed';
        }
        DateTime createdDateTime = (DateTime) JSON.deserialize('"' + pw.transaction_info.transaction_updated_date + '"', DateTime.class);
        transactionSf.Created_Date_in_Processor__c = createdDateTime;
        if(pw.shipping_info != null) {
            transactionSf.Billing_Street_Address_1__c = pw.shipping_info.line1;
            transactionSf.Billing_Street_Address_2__c = pw.shipping_info.line2;
            transactionSf.Billing_City__c = pw.shipping_info.city;
            transactionSf.Billing_State__c = pw.shipping_info.state; 
            transactionSf.Billing_Country__c =  pw.shipping_info.country_code;
            transactionSf.Billing_Postal_Code__c = pw.shipping_info.postal_code;
        }
        return transactionSf;
    }
    */
    /**
*  Builds URL to perform authorization with PayPal in live mode. Test credentials will be used.
*
*  @return String
**/
    public static String getAuthUrl(){
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        String sfMode = BreadwinnerUtil.isLightning() ? 'lightning' : 'classic';
        String redirectURL = ProcessorUtil.REDIRECT_URL;
        String clientId = getClientId('live');
        string stateValue = '{"SFMode":"' + sfMode + '","ProMode":"live","ProType":"PayPal","Callback":"' + sfdcBaseURL + '/apex/' + BreadwinnerUtil.namespaceApi + 'BreadwinnerPayments"}';
        return paypalAuthorizationUrl + '/signin/authorize?flowEntry=static&client_id=' + EncodingUtil.urlEncode((String.isNotBlank(clientId) ? clientId : ''),'UTF-8') + '&response_type=code&scope=openid profile https://uri.paypal.com/payments/payouts https://uri.paypal.com/services/paypalattributes&redirect_uri='+ redirectURL + '&state=' + stateValue;
    }
    
    /**
*  Builds URL to perform authorization with PayPal in test mode. Test credentials will be used.
*
*  @return String
**/
    public static String  getTestAuthUrl(){
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        String sfMode = BreadwinnerUtil.isLightning() ? 'lightning' : 'classic';
        String redirectURL = ProcessorUtil.REDIRECT_URL;
        String clientId = getClientId('test');
        string stateValue = '{"SFMode":"' + sfMode + '","ProMode":"test","ProType":"PayPal","Callback":"' + sfdcBaseURL + '/apex/' + BreadwinnerUtil.namespaceApi + 'BreadwinnerPayments"}';
        return paypalTestAuthorizationUrl + '/signin/authorize?flowEntry=static&client_id=' + EncodingUtil.urlEncode((String.isNotBlank(clientId) ? clientId : ''),'UTF-8') + '&response_type=code&scope=openid profile https://uri.paypal.com/payments/payouts https://uri.paypal.com/services/paypalattributes&redirect_uri=' + redirectURL + '&state=' + stateValue;
        
    }
    
    //This method is used to get the PayPal client Id
    private static String getClientId(String connectionType){
        String returnClientId = '';
        String developerName = (connectionType == 'test' ? 'PayPal_Test_Credentials' : 'PayPal_Credentials');
        if(Schema.sObjectType.Breadwinner_Payments_Metadata__mdt.isAccessible()) {
            Breadwinner_Payments_Metadata__mdt paypalCredential = [SELECT Id, Key__c, Secret__c, DeveloperName FROM Breadwinner_Payments_Metadata__mdt WHERE DeveloperName =:developerName LIMIT 1];
            returnClientId = paypalCredential.Key__c;
        }
        return returnClientId;
    }
    
    //This method is used to get the PayPal client Secret
    private static String getClientSecret(String connectionType){
        String returnClientSecret = '';
        String developerName = (connectionType == 'test' ? 'PayPal_Test_Credentials' : 'PayPal_Credentials');
        if(Schema.sObjectType.Breadwinner_Payments_Metadata__mdt.isAccessible()) {
            Breadwinner_Payments_Metadata__mdt paypalCredential = [SELECT Id, Key__c, Secret__c, DeveloperName FROM Breadwinner_Payments_Metadata__mdt WHERE DeveloperName =:developerName LIMIT 1];
            returnClientSecret = paypalCredential.Secret__c;
        }
        return returnClientSecret;
    }
    
    public static void saveAppCredentials(String connectionMode, BWP_Processor_Config__c config) {
        System.debug('-connectionMode--'+connectionMode);
        PayPalTokenInfo tokenResponse = new PayPalTokenInfo();
        String code = Apexpages.currentPage().getParameters().get('code');
        if(String.isNotBlank(code)){
            code = String.escapeSingleQuotes(code);
        }
        String endPoint = '';
        String reqBody = '';
        endPoint = (connectionMode == 'live' ? paypalBaseUrl : paypalTestBaseUrl);
        endPoint = endPoint + '/v1/oauth2/token';
        reqBody = 'grant_type=authorization_code&code='+code;
        
        Blob headerValue = Blob.valueOf((getClientId(connectionMode)) + ':' + (getClientSecret(connectionMode)));
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod('POST');
        request.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(headerValue));
        if(String.isNotBlank(reqBody)){
            request.setBody(reqBody);
        }
        System.debug('--request--'+request);
        HttpResponse response = http.send(request);
        String responseStr = response.getBody().replaceAll('"expires_in"', '"expires_at"');
        system.debug('resoponse---->>>'+response.getBody());
        if (response.getStatusCode() == 200) {
            // Deserializing the response
            tokenResponse = (PayPalTokenInfo)JSON.deserialize(responseStr, PayPalTokenInfo.class);
            String accountName = '';
            String accountCurrency = '';
            String merchantId = '';
            String endPointMerchantDetails = (connectionMode == 'live' ? paypalBaseUrl : paypalTestBaseUrl);
            endPointMerchantDetails = endPointMerchantDetails + '/v1/identity/oauth2/userinfo?schema=paypalv1.1';
            HttpResponse accRes = new HttpResponse();
            // Request to get PayPal Account Details
            accRes = APICallHandler.getProcessorConnectionInfo(endPointMerchantDetails, 'GET', tokenResponse.access_token, '');
            system.debug('accresp---------'+accRes);
            if(accRes.getStatusCode() == 200){
                system.debug('accresp-----'+accRes.getBody());
                Map<String, Object> accResponse = (Map<String, Object>)JSON.deserializeUntyped(accRes.getBody());
                accountName = (accResponse.get('name')).toString();
                merchantId = (accResponse.get('payer_id')).toString();
            }
            config = BreadwinnerUtil.getProcessorConfig(tokenResponse.merchant_id);
            system.debug('config----'+config);
            system.debug('accont name----'+accountName);
            config.Account_Name__c = String.isNotBlank(accountName) ? accountName : '';
            if (tokenResponse.access_token != null) {
                config.Access_token__c = tokenResponse.access_token;
                if(String.isNotBlank(tokenResponse.expires_at)){
                    config.Access_Token_Expiry_Date__c = system.now().addSeconds(Integer.valueOf(tokenResponse.expires_at));
                }
                config.Live_Mode__c = (connectionMode == 'live' ? TRUE : FALSE);
                config.Refresh_Token__c = tokenResponse.refresh_token;
                config.Provider_ID__c = merchantId;
                config.Name = tokenResponse.merchant_id;
                config.Need_to_reconnect__c = false;
                config.Payment_Processor_Type__c = ProcessorUtil.PAT_PAYPAL;
                if(config.Customer_Sync_Config__c == NULL)
                    config.Customer_Sync_Config__c = 'NONAME_AND_NOEMAIL';
                if(config.Customer_Match_Config__c == NULL)
                    config.Customer_Match_Config__c = 'NO_VALID_PAYMENTS';

                config = CryptoUtil.encryptSecrets(config);
                BreadwinnerUtil.upsertAppConfig(config);
                //Running Historical Sync
                HistoricalSyncBatch historicalSync = new HistoricalSyncBatch('Payment');
                Database.executeBatch(historicalSync, 1);
                APICallHandler.userInteractionLogPush(false, 'Historical Sync', 'Restarted', 'Historical Sync is restarted automatically after connection/reconnection');
                
            }
        }
        else{
            throw new ProcessorUtil.ConnectionException('Error occurred while connecting with PayPal.');
        }
        
    }
    
    //This method is used to Refresh the Access Token
    public static void refreshAccessToken(BWP_Processor_Config__c appConfig){
        try{
            BreadwinnerUtil.AppConfig appConfigWrapper = new BreadwinnerUtil.AppConfig();
            appConfigWrapper = BreadwinnerUtil.getProcessorConfigWrapper(appConfig);
            BreadwinnerUtil.AppConfig ac = CryptoUtil.decryptSecrets(appConfigWrapper);
            HttpResponse response = new HttpResponse();
            String endPoint = '';
            String reqBody = '';
            String connectionType = ac.livemode ? 'live' : 'test';
            endPoint = ac.livemode ? paypalBaseUrl : paypalTestBaseUrl;
            endPoint = endPoint + '/v1/oauth2/token';
            reqBody = 'grant_type=refresh_token&refresh_token='+ ac.refreshToken;
            Blob headerValue = Blob.valueOf(getClientId(connectionType) + ':' + getClientSecret(connectionType));
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endPoint);
            request.setMethod('POST');
            request.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(headerValue));
            if(String.isNotBlank(reqBody)){
                request.setBody(reqBody);
            }
            response = http.send(request);
            String responseStr = response.getBody().replaceAll('"expires_in"', '"expires_at"');
            system.debug('response-----'+response);
            system.debug('resoponse---->>>'+response.getBody());
            PayPalTokenInfo tokenResponse = new PayPalTokenInfo();
            if(response.getStatusCode() == 200){
                tokenResponse = (PayPalTokenInfo)JSON.deserialize(responseStr, PayPalTokenInfo.class);
                system.debug('tokenrsponse----'+tokenResponse);
                APICallHandler.userInteractionLogPush(TRUE, 'Refresh Access Token', 'SUCCESS' , 'Successfully Refreshed Access Token for the PayPal Account '+appConfig.Account_Name__c);
                if(tokenResponse.access_token != null) {
                    appConfig.Access_token__c = tokenResponse.access_token;
                    if(String.isNotBlank(tokenResponse.expires_at)){
                        appConfig.Access_Token_Expiry_Date__c = system.now().addSeconds(Integer.valueOf(tokenResponse.expires_at));
                    }
                    appConfig = CryptoUtil.encryptSecrets(appConfig);
                    BreadwinnerUtil.isBreadwinnerTransaction = true;
                    SecurityUtil.dmlUpsert(appConfig);
                }
            }
            else{
                APICallHandler.userInteractionLogPush(TRUE, 'Refresh Access Token', 'ERROR' , 'Failed to Refresh Access Token for the PayPal Account '+appConfig.Account_Name__c+'. Error'+response.getBody());
            }
        }
        
        catch(Exception e){
            System.debug('Error occured while refreshing the Access Token from PayPal.'+e.getStackTraceString());
            APICallHandler.userInteractionLogPush(TRUE, 'Refresh Access Token', 'ERROR' , e.getmessage());
        }
    }
    
    public static String getEndpointBaseUrl(BreadwinnerUtil.AppConfig appConfig){
        return appConfig.livemode ? paypalBaseUrl : paypalTestBaseUrl;
    }
    
    //PayPal Token Info Wrapper
    public class PayPalTokenInfo {
        public String access_token;
        public String token_type;
        public String expires_at;
        public String merchant_id;
        public String refresh_token;
    }
    public class FetchRequest {
        public String fields;
        public Integer page_size;
        public Integer page;
        public String lastPage;
        public String start_date;
        public String end_date;
    }
    
    public class FetchResponse {
        public String lastPage;
        public Boolean requireNextRun;
        public DateTime startDate;
        public DateTime endDate;
        public Map<String, Charge.TrasactionDetails> customerMapById;
        public Map<String, Charge.TrasactionDetails> paymentMapById;
    }
}