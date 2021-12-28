public with sharing class Processor_Authorize_Net extends Processor{
    
    private static Selector_BWP_Customer selectorCustomer = new Selector_BWP_Customer();
    private static Selector_BWP_Payment_Method selectorPaymentMethod = new Selector_BWP_Payment_Method();
    private static Selector_BWP_Transaction selectorTransaction = new Selector_BWP_Transaction();
    
    //Authorize.Net Endpoints
    public static String authorizeNetAuthorizationUrl = 'https://account.authorize.net/oauth/authorize';
    public static String authorizeNetTestAuthorizationUrl = 'https://sandbox.authorize.net/oauth/authorize';
    public static String authorizeNetTokenUrl = 'https://access.authorize.net/oauth/v1/token';
    public static String authorizeNetTestTokenUrl  = 'https://accesstest.authorize.net/oauth/v1/token';
    public static String authorizeNetBaseUrl = 'https://api.authorize.net/xml/v1/request.api';
    public static String authorizeNetTestBaseUrl = 'https://apitest.authorize.net/xml/v1/request.api';

    BWP_Processor_Config__c apc;
    BreadwinnerUtil.AppConfig apcWrapper;

    public Processor_Authorize_Net(String authorizeNetAccountId) {
        apc = BreadwinnerUtil.getProcessorConfig(authorizeNetAccountId);
        if (apc == null) {
            throw new ProcessorUtil.InvalidAccountConfigurationException('Invalid Authorize.Net ORG Id provided.');
        }
        apcWrapper = BreadwinnerUtil.getProcessorConfigWrapper(apc);
    }
    
    public override ProcessorUtil.ResponseObject fetchCustomers(String requestJSON) {
        return fetchCustomers(apcWrapper, requestJSON);
    }
    
    public override ProcessorUtil.ResponseObject fetchTransactions(String requestJSON) {
        return fetchTransactions(apcWrapper, requestJSON);
    }
    
    @TestVisible
    private static ProcessorUtil.ResponseObject fetchCustomers(BreadwinnerUtil.AppConfig apcWrapper, String requestJSON){
        ProcessorUtil.ResponseObject response = new ProcessorUtil.ResponseObject();
        response.errors = new List<ProcessorUtil.Error>();
        List<Customer.authNetCustomer> customersList = new List<Customer.authNetCustomer>();
        HttpResponse res = APICallHandler.post(apcWrapper, 'POST', getEndpointBaseUrl(apcWrapper), requestJSON, '');
        response.status = String.valueOf(res.getStatusCode());
        if (res.getStatusCode() == 200) {
            response.responseJSON = res.getBody();
            
        } else {
            apcWrapper.needToReconnect = true;
            apcWrapper.requireNextCustomerSyncRun = false;
            String Action_Type = ProcessorUtil.getLogAction(apcWrapper.currentRunningClassContext, 'Fetching Customers');
            APICallHandler.userInteractionLogPush(true, Action_Type, 'ERROR' , 'Response for Processor Org Name('+apcWrapper.accountName+'): Status Code: '+res.getStatusCode()+' Response Body: '+res.getBody() );
            
            JSONParser parser = JSON.createParser(res.getBody());
            ProcessorUtil.Error error = (ProcessorUtil.Error) parser.readValueAs(ProcessorUtil.Error.class);
            response.errors.add(error);
        }
        return response;
    }
    
    @TestVisible
    private static ProcessorUtil.ResponseObject fetchTransactions(BreadwinnerUtil.AppConfig apcWrapper, String requestJSON){
        ProcessorUtil.ResponseObject response = new ProcessorUtil.ResponseObject();
        response.errors = new List<ProcessorUtil.Error>();
        if(requestJSON.containsIgnoreCase('getSettledBatchListRequest')){
            if(apcWrapper.requireNextPaymentSyncRun && apcWrapper.startDate != null  && apcWrapper.endDate != null){
                requestJSON = requestJSON.replace(requestJSON.substringAfter('"firstSettlementDate"'), ':'+json.serialize(apcWrapper.startDate)+',"lastSettlementDate":'+json.serialize(apcWrapper.endDate)+'}}');
            }
        }
        HttpResponse res = APICallHandler.post(apcWrapper, 'POST', getEndpointBaseUrl(apcWrapper), requestJSON, '');
        response.status = String.valueOf(res.getStatusCode());
        if (res.getStatusCode() == 200) {
            response.responseJSON = res.getBody();
        } else {
            apcWrapper.needToReconnect = true;
            apcWrapper.requireNextCustomerSyncRun = false;
            String Action_Type = ProcessorUtil.getLogAction(apcWrapper.currentRunningClassContext, 'Fetching Batch Ids');
            APICallHandler.userInteractionLogPush(true, Action_Type, 'ERROR' , 'Response for Processor Org Name('+apcWrapper.accountName+'): Status Code: '+res.getStatusCode()+' Response Body: '+res.getBody() );
            
            JSONParser parser = JSON.createParser(res.getBody());
            ProcessorUtil.Error error = (ProcessorUtil.Error) parser.readValueAs(ProcessorUtil.Error.class);
            response.errors.add(error);
        }
        return response;
    }
    /* Commenting this as we have removed the BWP_Sync_Details object and Processor_Batch class
    //*** Saving the Authorize.Net customers and related payment methods to SF. Orphan records will not be saved.
    public static ProcessorUtil.ResponseObject syncCustomers(Map<String, Object> processorToCustomerMap, BreadwinnerUtil.AppConfig appConfig, Boolean addToSalesforce) {
        ProcessorUtil.ResponseObject responseObj = new ProcessorUtil.ResponseObject();
        List<ProcessorUtil.CustomerWrapper> customerList = new List<ProcessorUtil.CustomerWrapper>();
        List<ProcessorUtil.PaymentMethodWrapper> payMethodList = new List<ProcessorUtil.PaymentMethodWrapper>();
        try {
            String paymentProcessorType = '';
            Breadwinner_Settings__c bwSetting = BreadwinnerUtil.getBWSetting();
            Map<String, Customer.authNetCustomer> authNetIdCustomerMap =  new Map<String, Customer.authNetCustomer>();
            Map<String, Customer.authNetCustomer> backupAuthNetIdCustomerMap = new Map<String, Customer.authNetCustomer>();
            authNetIdCustomerMap = (Map<String, Customer.authNetCustomer>) processorToCustomerMap.get(ProcessorUtil.PAT_AUTHORIZE_NET);
            paymentProcessorType = ProcessorUtil.PAT_AUTHORIZE_NET;
            backupAuthNetIdCustomerMap.putAll(authNetIdCustomerMap);
            
            List<BWP_Customer__c> customerUpsertList = new List<BWP_Customer__c> ();
            Map<String, BWP_Customer__c> customerUpsertMap = new Map<String, BWP_Customer__c>();
            Map<String, BWP_Payment_Method__c> sourcesMap = new Map<String, BWP_Payment_Method__c>();
            Map<String,BWP_Customer__c> existingSFCustomersMap = new Map<String,BWP_Customer__c>();
            Map<String,BWP_Payment_Method__c> existingSFPaymentMethodsMap = new Map<String,BWP_Payment_Method__c>();
            Set<String> receivedPaymentMethodsIdSet = new Set<String>();
            
            if(authNetIdCustomerMap != null){
                //Holding existing customer records in Salesforce
                for(BWP_Customer__c cus : selectorCustomer.selectByProcessorCustomerId(authNetIdCustomerMap.keySet(), 45000))
                    existingSFCustomersMap.put(cus.Processor_Customer_Id__c,cus);
                
                //Holding existing payment method records in Salesforce
                for(Customer.authNetCustomer cus : authNetIdCustomerMap.values()) {
                    if(cus.profile.paymentProfiles != null){
                        for(Customer.AuthNetPaymentProfiles paymentProfile : cus.profile.paymentProfiles) {
                            receivedPaymentMethodsIdSet.add(paymentProfile.customerPaymentProfileId);
                        }
                    }
                }
                //Holding existing Payment method records in Salesforce
                for(BWP_Payment_Method__c pm : selectorPaymentMethod.selectByProcessorId(receivedPaymentMethodsIdSet, 45000)){
                    BWP_Payment_Method__c payMethod = new BWP_Payment_Method__c(id = pm.id, Processor_Id__c = pm.Processor_Id__c);
                    existingSFPaymentMethodsMap.put(payMethod.Processor_Id__c, payMethod);
                }
            }
            
            Boolean areRecordTypesEnabled = ProcessorUtil.areRecordTypesEnabled();
            Boolean isDefaultRecordTypeMaster = ProcessorUtil.isDefaultRecordTypeIsMaster();
            
            //-- Map to store Processor Account Id and new SF Account to be inserted
            Map<String, Account> mapCustomerIdAndNewSFAccount = new Map<String, Account>();
            Map<String, Contact> mapCustomerIdAndNewSFContact = new Map<String, Contact>();
            Set<String> customerNameSet = new Set<String>();
            Set<String> customerEmailSet = new Set<String>();
            for(String custId : authNetIdCustomerMap.keySet()){
                if(!existingSFCustomersMap.containsKey(custId) || (existingSFCustomersMap.containsKey(custId) && existingSFCustomersMap.get(custId).Salesforce_Account__c == NULL && !existingSFCustomersMap.get(custId).No_Associated_SF_Account__c )){
                    Customer.AuthNetCustomer ac = authNetIdCustomerMap.get(custId);
                    ProcessorUtil.getExistingRecordsSet('', ac.profile.email, customerNameSet, customerEmailSet);
                }
            }
            if(appConfig.isCustomerMatchComplete && appConfig.customerMatchType == ProcessorUtil.CMT_ACCOUNT && appConfig.currentRunningClassContext != BreadwinnerUtil.CNTX_BWAPI){
                system.debug('account match is already completed');
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
                for(String refId : authNetIdCustomerMap.keySet()){
                    Customer.authNetCustomer cw = authNetIdCustomerMap.get(refId);
                    ID accID;
                    if(!existingSFCustomersMap.containsKey(refId) || (existingSFCustomersMap.containsKey(refId) && existingSFCustomersMap.get(refId).Salesforce_Account__c == NULL && !existingSFCustomersMap.get(refId).No_Associated_SF_Account__c )){
                        string customerNameLowerCase = (String.isNotBlank(cw.profile.email) ? (cw.profile.email.toLowerCase().replace('\\', '%')) : '');
                        // first check with person account email then with company name if person accounts are enabled
                        String personEmail = String.isNotBlank(cw.profile.email) ? (cw.profile.email.toLowerCase().replace('\\', '%')) : '';
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
                    
                    if(String.isNotBlank(cw.profile.customerProfileId)) {
                        // Querying existing Authorize.Net Customer if any or creating new one
                        BWP_Customer__c customerSf = existingSFCustomersMap.get(cw.profile.customerProfileId) != null ? existingSFCustomersMap.get(cw.profile.customerProfileId) : new BWP_Customer__c();
                        customerSf = constructAuthNetCustomer(customerSf, cw, appConfig);
                        if(!existingSFCustomersMap.containsKey(refId) || (existingSFCustomersMap.containsKey(refId) && existingSFCustomersMap.get(refId).Salesforce_Account__c == NULL && !existingSFCustomersMap.get(refId).No_Associated_SF_Account__c )) customerSf.Salesforce_Account__c = customerSf.Salesforce_Account__c != null ? customerSf.Salesforce_Account__c : accID;
                        customerUpsertList.add(customerSf);
                        customerUpsertMap.put(refId, customerSf);
                        authNetIdCustomerMap.remove(refId);
                        for (Customer.AuthNetPaymentProfiles paymentProfile : cw.profile.paymentProfiles) {
                            // Querying existing Authorize.Net Payment Profile if any or creating new one
                            BWP_Payment_Method__c paymentProfileSf =  existingSFPaymentMethodsMap.get(paymentProfile.customerPaymentProfileId) != null ? existingSFPaymentMethodsMap.get(paymentProfile.customerPaymentProfileId) : new BWP_Payment_Method__c();
                            paymentProfileSf.Customer__r = new BWP_Customer__c(Processor_Customer_Id__c = cw.profile.customerProfileId);
                            paymentProfileSf.Processor_Customer_Id__c = cw.profile.customerProfileId;
                            paymentProfileSf.Salesforce_Account__c = String.isNotBlank(customerSf.Salesforce_Account__c) ? customerSf.Salesforce_Account__c : accID;
                            paymentProfileSf = constructAuthNetPaymentMethod(paymentProfileSf, paymentProfile, appConfig);
                            sourcesMap.put(paymentProfile.customerPaymentProfileId, paymentProfileSf);
                        }
                    }
                    
                    if(accID == NULL && (!existingSFCustomersMap.containsKey(refId) || (existingSFCustomersMap.containsKey(refId) && existingSFCustomersMap.get(refId).Salesforce_Account__c == NULL && !existingSFCustomersMap.get(refId).No_Associated_SF_Account__c ))){
                        // Create New accounts
                        system.debug('new accounts');
                        String customerName = (String.isNotBlank(cw.profile.email) ? cw.profile.email : '');
                        Account acctRef = new Account();
                        
                        if( areRecordTypesEnabled && !isDefaultRecordTypeMaster ){
                            String accDefaultRecordType = ProcessorUtil.getDefaultAccountRecordType();
                            ID chosenRecordTypeId = String.isNotBlank(accDefaultRecordType) ? (ID)accDefaultRecordType : '';
                            
                            system.debug('chosenRecordTypeId: '+chosenRecordTypeId);
                            
                            if(String.isNotBlank(chosenRecordTypeId)) acctRef.put('RecordTypeId', ''+chosenRecordTypeId);
                            if(ProcessorUtil.getIsPersonRecordType(chosenRecordTypeId)){
                                acctRef.put('LastName',customerName);
                            }
                            else{
                                acctRef.Name = customerName;
                            }
                        }
                        else{
                            acctRef.Name = customerName;
                        }
                        
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
                if(!mapCustomerIdAndNewSFAccount.isEmpty() && schema.SobjectType.Account.isCreateable() && schema.SobjectType.Account.isUpdateable()){
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
            else if(appConfig.isCustomerMatchComplete && appConfig.customerMatchType == ProcessorUtil.CMT_CONTACT && appConfig.currentRunningClassContext != BreadwinnerUtil.CNTX_BWAPI){
                system.debug('contact match is already completed');
                ///contact fetch
                Map<String,Contact> nameToContactMap = new Map<String,Contact>();
                Map<String,Contact> emailToContactMap= new Map<String,Contact>();
                List<String> referenceIdListForCreateNew = new List<string>();
                
                for(Contact con : ProcessorUtil.getContactsForCustomerSync(customerNameSet, customerEmailSet)){
                    String lowerCaseName = con.Name.toLowerCase().replace('\\', '%');
                    Set<String> relatedAccountNameSet = BreadwinnerUtil.getSimilarAccountNameSet(lowerCaseName);
                    for(String accName: relatedAccountNameSet){
                        nameToContactMap.put(accName, con);
                    }
                    if(String.isNotBlank(con.Email)){
                        string email = con.Email.toLowerCase().replace('\\', '%');
                        emailToContactMap.put(email, con);
                    }
                }
                for(String refId : authNetIdCustomerMap.keySet()){
                    Customer.AuthNetCustomer cw = authNetIdCustomerMap.get(refId);
                    ID conID;
                    if(!existingSFCustomersMap.containsKey(refId) || (existingSFCustomersMap.containsKey(refId) && existingSFCustomersMap.get(refId).Salesforce_Contact__c == NULL && !existingSFCustomersMap.get(refId).No_Associated_SF_Contact__c )){
                        string customerNameLowerCase =(String.isNotBlank(cw.profile.email) ? (cw.profile.email.toLowerCase().replace('\\', '%')) : '');
                        String email = String.isNotBlank(cw.profile.email) ? (cw.profile.email.toLowerCase().replace('\\', '%')) : '';
                        if(emailToContactMap.containsKey(email) || nameToContactMap.containsKey(customerNameLowerCase)){
                            system.debug('existed contacts');
                            if(emailToContactMap.containsKey(email)){
                                conID = emailToContactMap.get(email).Id;
                            }
                            else if(nameToContactMap.containsKey(customerNameLowerCase) ){
                                conID = nameToContactMap.get(customerNameLowerCase).Id;
                            }
                        }
                    }
                    
                    if(String.isNotBlank(cw.profile.customerProfileId)) {
                        // Querying existing Authorize.Net Customer if any or creating new one
                        BWP_Customer__c customerSf = existingSFCustomersMap.get(cw.profile.customerProfileId) != null ? existingSFCustomersMap.get(cw.profile.customerProfileId) : new BWP_Customer__c();
                        customerSf = constructAuthNetCustomer(customerSf, cw, appConfig);
                        if(!existingSFCustomersMap.containsKey(refId) || (existingSFCustomersMap.containsKey(refId) && existingSFCustomersMap.get(refId).Salesforce_Contact__c == NULL && !existingSFCustomersMap.get(refId).No_Associated_SF_Contact__c )) customerSf.Salesforce_Contact__c = customerSf.Salesforce_Contact__c != null ? customerSf.Salesforce_Contact__c : conID;
                        customerUpsertList.add(customerSf);
                        customerUpsertMap.put(refId, customerSf);
                        authNetIdCustomerMap.remove(refId);
                        for (Customer.AuthNetPaymentProfiles paymentProfile : cw.profile.paymentProfiles) {
                            // Querying existing Authorize.Net Payment Method if any or creating new one
                            BWP_Payment_Method__c paymentProfileSf =  existingSFPaymentMethodsMap.get(paymentProfile.customerPaymentProfileId) != null ? existingSFPaymentMethodsMap.get(paymentProfile.customerPaymentProfileId) : new BWP_Payment_Method__c();
                            paymentProfileSf.Customer__r = new BWP_Customer__c(Processor_Customer_Id__c = cw.profile.customerProfileId);
                            paymentProfileSf.Processor_Customer_Id__c = cw.profile.customerProfileId;
                            paymentProfileSf.Salesforce_Contact__c = String.isNotBlank(customerSf.Salesforce_Contact__c) ? customerSf.Salesforce_Contact__c : conID;
                            paymentProfileSf = constructAuthNetPaymentMethod(paymentProfileSf, paymentProfile, appConfig);
                            sourcesMap.put(paymentProfile.customerPaymentProfileId, paymentProfileSf);
                        }
                    }
                    
                    if(conID == NULL && (!existingSFCustomersMap.containsKey(refId) || (existingSFCustomersMap.containsKey(refId) && existingSFCustomersMap.get(refId).Salesforce_Contact__c == NULL && !existingSFCustomersMap.get(refId).No_Associated_SF_Contact__c ))){
                        // Create New contacts
                        String customerName = (String.isNotBlank(cw.profile.email) ? cw.profile.email : '');
                        Contact conRef = new Contact();
                        conRef.LastName = customerName;
                        conRef.Email = (String.isNotBlank(cw.profile.email) ? cw.profile.email : '');
                        
                        conRef.Description = 'This Salesforce Contact was created by Breadwinner.';
                        mapCustomerIdAndNewSFContact.put(refId,conRef);
                        referenceIdListForCreateNew.addAll(mapCustomerIdAndNewSFContact.keySet());
                    }
                }
                
                Set<String> otherExceptionsSet = new Set<String>();
                Map<String,Contact> mapCustomerIdAndFailedContacts = new Map<String,Contact>();
                long longTime = system.now().getTime()/1000;
                string errorMessage;
                String duplicateContacts = '';
                String duplicatesExcErrorLog = 'DUPLICATES_DETECTED : Unable to create this Contacts : ';
                if(!mapCustomerIdAndNewSFContact.isEmpty() && schema.SobjectType.Contact.isCreateable() && schema.SobjectType.Contact.isUpdateable()){
                    Database.UpsertResult[]  ur1List = SecurityUtil.databaseUpsert(mapCustomerIdAndNewSFContact.values());
                    
                    //Handle exceptions
                    for(Integer i = 0; i< ur1List.size(); i++){
                        if(!ur1List[i].isSuccess()){
                            Database.Error[] errors = ur1List[i].getErrors();
                            Database.Error firstError = errors.get(0);
                            if(string.valueOf(firstError.getStatusCode())== 'DUPLICATES_DETECTED'){
                                Contact temp = mapCustomerIdAndNewSFContact.get(referenceIdListForCreateNew.get(i));
                                for(Database.Error er : errors){
                                    duplicateContacts += temp.Name+', ';
                                }
                            }else{
                                for(Database.Error er : errors)
                                    otherExceptionsSet.add(er.getStatusCode() + ': ' + er.getMessage());
                            }
                        }
                    }
                    system.debug(mapCustomerIdAndNewSFContact);
                    Database.UpsertResult[] upsertResultList = SecurityUtil.databaseUpsert(mapCustomerIdAndNewSFContact.values());
                    // Iterate through each returned result
                    for (Database.UpsertResult ur : upsertResultList) {
                        if (!ur.isSuccess()) {
                            // Operation failed, so get all errors
                            for(Database.Error er : ur.getErrors()) {
                                otherExceptionsSet.add(er.getStatusCode() + ': ' + er.getMessage());
                            }
                        }
                    }
                    
                    for(string refIdOfNewInsert : mapCustomerIdAndFailedContacts.keySet()){
                        mapCustomerIdAndNewSFContact.put(refIdOfNewInsert, mapCustomerIdAndFailedContacts.get(refIdOfNewInsert));
                    }
                }else{
                    System.debug('Do not have Create and Update Permission on Contact Object');
                }
                for(String refId : mapCustomerIdAndNewSFContact.keySet()){
                    if(customerUpsertMap.containsKey(refId)){
                        BWP_Customer__c customerSf = customerUpsertMap.get(refId);
                        customerSf.Salesforce_Contact__c = mapCustomerIdAndNewSFContact.get(refId).Id;
                        customerUpsertMap.put(refId, customerSF);
                        customerUpsertList.add(customerSf);
                    }
                }
            }
            else{
                // If Customer Match is not completed, sync the customers without accounts/contacts
                for(String refId : authNetIdCustomerMap.keySet()){
                    Customer.authNetCustomer customer = authNetIdCustomerMap.get(refId);
                    if(String.isNotBlank(customer.profile.customerProfileId)) {
                        // Querying existing Authorize.Net Customer if any or creating new one
                        BWP_Customer__c customerSf = existingSFCustomersMap.get(customer.profile.customerProfileId) != null ? existingSFCustomersMap.get(customer.profile.customerProfileId) : new BWP_Customer__c();
                        customerSf = constructAuthNetCustomer(customerSf, customer, appConfig);
                        if(BreadwinnerUtil.accountId != null)
                            customerSf.Salesforce_Account__c = BreadwinnerUtil.accountId;
                        if(customer.profile.paymentProfiles != null){
                            for (Customer.AuthNetPaymentProfiles paymentProfile : customer.profile.paymentProfiles) {
                                // Querying existing Authorize.Net Payment Method if any or creating new one
                                BWP_Payment_Method__c srcSf =  existingSFPaymentMethodsMap.get(paymentProfile.customerPaymentProfileId) != null ? existingSFPaymentMethodsMap.get(paymentProfile.customerPaymentProfileId) : new BWP_Payment_Method__c();
                                srcSf.Customer__r = new BWP_Customer__c(Processor_Customer_Id__c = customer.profile.customerProfileId);
                                srcSf.Processor_Customer_Id__c = customer.profile.customerProfileId;
                                if(String.isNotBlank(customerSf.Salesforce_Account__c))
                                    srcSf.Salesforce_Account__c = customerSf.Salesforce_Account__c;
                                if(String.isNotBlank(customerSf.Salesforce_Contact__c))
                                    srcSf.Salesforce_Contact__c = customerSf.Salesforce_Contact__c;
                                srcSf = constructAuthNetPaymentMethod(srcSf, paymentProfile, appConfig);
                                sourcesMap.put(paymentProfile.customerPaymentProfileId, srcSf);
                            }
                        }
                        
                        customerUpsertMap.put(refId, customerSF);
                        customerUpsertList.add(customerSf);
                    }
                }
            }
            
            Set<Id> updatedCustomerIdSet = new Set<Id>();
            if(!customerUpsertMap.isEmpty()){
                responseObj.customerList = ProcessorUtil.upsertAndReturnCustomerList(customerUpsertMap.values(), updatedCustomerIdSet, addToSalesforce);
            }
            
            if(!sourcesMap.isEmpty()){
                responseObj.paymentMethodList = ProcessorUtil.upsertAndReturnPaymentMethodList(sourcesMap.values());
            }
            
            Set<String> allPMsToKeep = new Set<String>();
            allPMsToKeep.addAll(existingSFPaymentMethodsMap.keySet());
            for(BWP_Payment_Method__c src : sourcesMap.values()){
                allPMsToKeep.add(src.Processor_Id__c);
            }
            ProcessorUtil.removePaymentsThatDoNotBelong(updatedCustomerIdSet, allPMsToKeep, appConfig.name);
        }
        catch(Exception ex) {
            System.debug('Customer Sync failed for '+appConfig.Name +' while syncing. \n' +ex.getStackTraceString()+'\n'+ex.getMessage());
            APICallHandler.userInteractionLogPush(TRUE, 'Customer Sync', 'ERROR' , 'Customer Sync failed for '+appConfig.Name +' while syncing. \n' +ex.getStackTraceString()+'\n'+ex.getMessage());
        }
        return responseObj;
    }
    
    // Saving the Authorize.Net Trasanctions to SF. by deafult only Successful Trasanctions are saved
    public static List<ProcessorUtil.TransactionWrapper> syncTransactions(Map<String, Object> processorIdToPaymentMap, BreadwinnerUtil.AppConfig appConfig, Boolean addToSalesforce) {
        List<ProcessorUtil.TransactionWrapper> rtnList = new List<ProcessorUtil.TransactionWrapper>();
        Map<String, Object> returnMap = new Map<String, Object>();
        Set<String> successfulPaymentsCustomerIdSet = new Set<String>();
        Map<String, Charge.AuthNetTransaction> authNetIdPaymentMap = (Map<String, Charge.AuthNetTransaction>) processorIdToPaymentMap.get(ProcessorUtil.PAT_AUTHORIZE_NET);
        if(authNetIdPaymentMap == null) {
            return rtnList;
        }
        
        Map<String, BWP_Transaction__c> upsertMapByRefId = new Map<String, BWP_Transaction__c>();
        Map<String,BWP_Transaction__c> existingSFPaymentsMap = new Map<String,BWP_Transaction__c>();
        for(BWP_Transaction__c trxn : selectorTransaction.selectByProcessorId(authNetIdPaymentMap.keySet(), new List<String>{'Source__r.Id'})) {
            BWP_Transaction__c txn = new BWP_Transaction__c(id = trxn.id, Processor_Id__c = trxn.Processor_Id__c);
            existingSFPaymentsMap.put(txn.Processor_Id__c, txn);
        }
        
        try{
            // Boolean to check the syncing of failed Payments
            Boolean doNotImportCustomerAndFailedPayments = (String.isBlank(appConfig.customerMatchConfig) || (String.isNotBlank(appConfig.customerMatchConfig) && (appConfig.customerMatchConfig.contains('NO_VALID_PAYMENTS')))) ? TRUE : FALSE;

            Set<String> customerIdSet = new Set<String>();
            Set<String> paymentMethodIdSet = new Set<String>();
            // Create a customerIdSet & paymentIdSet to be used in a query later
            for (Charge.AuthNetTransaction at : authNetIdPaymentMap.values()) {
                if(at.profile !=  null){
                    customerIdSet.add(at.profile.customerProfileId);
                    paymentMethodIdSet.add(at.profile.customerPaymentProfileId);
                }
            }
			
             // Create a map of customers
            Map<String, BWP_Customer__c> customerMapByProcessorCustomerId = new Map<String, BWP_Customer__c>();
            List<BWP_Customer__c> customerList = selectorCustomer.selectByProcessorCustomerId(customerIdSet,null);
            for (BWP_Customer__c customer : customerList) {
                customerMapByProcessorCustomerId.put(customer.Processor_Customer_Id__c, customer);
            }
            // Create a map of Payment Methods
            Map<String, BWP_Payment_Method__c> paymentMethodMapByProcessorId = new Map<String, BWP_Payment_Method__c>();
            List<BWP_Payment_Method__c> pmList = selectorPaymentMethod.selectByProcessorId(paymentMethodIdSet,new List<String>{});
            for (BWP_Payment_Method__c pm : pmList) {
                paymentMethodMapByProcessorId.put(pm.Processor_Id__c, pm);
            }
            for (Charge.AuthNetTransaction at : authNetIdPaymentMap.values()) {
                BWP_Transaction__c transactionSf = existingSFPaymentsMap.get(at.transId) != null ? existingSFPaymentsMap.get(at.transId) : new BWP_Transaction__c();

                if(at.profile != null){
                    BWP_Customer__c customer = customerMapByProcessorCustomerId.get(at.profile.customerProfileId);
                    BWP_Payment_Method__c paymentMethod = paymentMethodMapByProcessorId.get(at.profile.customerPaymentProfileId);
    
                    
                    if (customer != NULL) {
                        transactionSf.Customer__c = customer.Id;
                        transactionSf.Salesforce_Account__c = String.isNotBlank(customer.Salesforce_Account__c) ? customer.Salesforce_Account__c : NULL;
                        transactionSf.Salesforce_Contact__c = String.isNotBlank(customer.Salesforce_Contact__c) ? customer.Salesforce_Contact__c : NULL;
                    }
                    
                    if(paymentMethod != NULL && String.isNotBlank(paymentMethod.Id))
                        transactionSf.Source__c = paymentMethod.Id;
                }
                
                transactionSf = constructAuthNetTransaction(transactionSf, at, appConfig);
                if (doNotImportCustomerAndFailedPayments && transactionSf.Status__c == ProcessorUtil.CHARGE_SUCCEEDED) {
                    if(String.isNotBlank(transactionSf.Customer__c)){
                        successfulPaymentsCustomerIdSet.add(transactionSf.Customer__c);
                    }
                }

                if (String.isNotBlank(transactionSf.customer__c) && (doNotImportCustomerAndFailedPayments ? (transactionSf.Status__c == 'Succeeded' ? TRUE : FALSE) : TRUE)){
                    upsertMapByRefId.put(transactionSf.Processor_Id__c, transactionSf);
                }
            }
            if(!upsertMapByRefId.isEmpty()){
                rtnList = ProcessorUtil.upsertAndReturnPaymentList(upsertMapByRefId.values());
            }
            
            if(doNotImportCustomerAndFailedPayments && !successfulPaymentsCustomerIdSet.isEmpty()){
                ProcessorUtil.updateSuccessfulPaymentsCustomers(doNotImportCustomerAndFailedPayments, successfulPaymentsCustomerIdSet);
            }
            
        }
        catch(Exception ex){
            System.debug('Payments Sync failed for '+appConfig.Name +' while syncing. \n' +ex.getStackTraceString());
            APICallHandler.userInteractionLogPush(TRUE, 'Payment Sync', 'ERROR' , 'Payments Sync failed for '+appConfig.Name +' while syncing. \n' +ex.getStackTraceString());
        }
        return rtnList;
    }

    public static void syncBatchRecords(BreadwinnerUtil.AppConfig apc, Map<String, Object> processorTypeToRecordsMap){
        Map<String, Charge.AuthNetBatchList> authNetBatchResp = (Map<String, Charge.AuthNetBatchList>) processorTypeToRecordsMap.get(ProcessorUtil.PAT_AUTHORIZE_NET);
		Set<String> batchIds = authNetBatchResp.keySet();
        try{
            Map<String, BWP_Sync_Details__c> batchUpsertMap = new Map<String, BWP_Sync_Details__c> ();    
            Map<String, BWP_Sync_Details__c> existingBatchRecords = new Map<String, BWP_Sync_Details__c>();  
            QueryBuilder qb = new QueryBuilder(BWP_Sync_Details__c.SObjectType, true, true, true);
            List<Schema.SObjectField> fieldsList = new List<Schema.SObjectField>{BWP_Sync_Details__c.Batch_Id__c, BWP_Sync_Details__c.Batch_Records_Sync_Page__c};
            qb.addSObjectFields(fieldsList);
            qb.setCondition('Batch_Id__c IN : batchIds');
            qb.setLimit(100);
            List<BWP_Sync_Details__c> existingBatches = Database.query(qb.toSOQL());
            for(BWP_Sync_Details__c batch : existingBatches){
                existingBatchRecords.put(batch.Batch_Id__c, batch);
            }
            for(String refId : authNetBatchResp.keySet()){
                Charge.AuthNetBatchList batch = authNetBatchResp.get(refId);
                BWP_Sync_Details__c paymentBatch = existingBatchRecords.get(batch.batchId) != null ? existingBatchRecords.get(batch.batchId) : new BWP_Sync_Details__c();
                paymentBatch.Batch_Id__c = batch.batchId;
                batchUpsertMap.put(paymentBatch.Batch_Id__c, paymentBatch);
            }
           SecurityUtil.databaseUpsert(batchUpsertMap.values());
        }
        catch(Exception ex){
            System.debug(' Batch Sync failed for '+apc.Name +' while syncing. \n' +ex.getStackTraceString());
            APICallHandler.userInteractionLogPush(TRUE, 'Payment Sync', 'ERROR' , 'Payments Sync failed for '+apc.Name +' while syncing. \n' +ex.getStackTraceString());
        }
    }
    
    // This method is used to convert the Authorize.Net Customer wrapper to Authorize.Net Customer record.
    private static BWP_Customer__c constructAuthNetCustomer(BWP_Customer__c customerSf, Customer.AuthNetCustomer cw, BreadwinnerUtil.AppConfig appConfig){
        if(customerSf.Id == null){
            customerSf.Created_Via__c = BreadwinnerUtil.getCreatedViaValue(appConfig.currentRunningClassContext);
        }
        customerSf.Customer_ID__c = cw.profile.customerProfileId+'-'+appConfig.PaymentProcessorType+'-'+appConfig.accountId;
        customerSf.Processor_Type__c = appConfig.PaymentProcessorType;
        customerSf.Processor_Org_Id__c = appConfig.accountId;
        customerSf.Processor_Org_Name__c = appConfig.accountName;
        customerSf.Livemode__c = appConfig.livemode;
        customerSf.Processor_Customer_Id__c = cw.profile.customerProfileId;
        
        customerSf.Name = (String.isNotBlank(cw.profile.email) ? cw.profile.email : ((String.isNotBlank(cw.profile.merchantCustomerId) ? cw.profile.merchantCustomerId : (String.isNotBlank(cw.profile.customerProfileId) ? cw.profile.customerProfileId : ''))));
        customerSf.Customer_Name__c = customerSf.Name;
        customerSf.Email__c = cw.profile.email;
        customerSf.Description__c = cw.profile.description;
        
        return customerSf;
    }
    
    // This method is used to convert the Authorize.Net Payment Profile wrapper to  Authorize.Net Payment Method record.
    @TestVisible
    private static BWP_Payment_Method__c constructAuthNetPaymentMethod(BWP_Payment_Method__c srcSf, Customer.AuthNetPaymentProfiles src, BreadwinnerUtil.AppConfig appConfig){
        if(srcSf.Id == null){
            srcSf.Created_Via__c = BreadwinnerUtil.getCreatedViaValue(appConfig.currentRunningClassContext);
        }
        
        srcSf.Processor_Type__c = appConfig.PaymentProcessorType;
        srcSf.Processor_Org_Id__c = appConfig.accountId;
        srcSf.LiveMode__c = appConfig.livemode;
        srcSf.Processor_Id__c = src.customerPaymentProfileId;
        
        if(src.billTo != null){
            srcSf.Address_Line1__c = src.billTo.address;
            srcSf.City__c = src.billTo.city;
            srcSf.State__c = src.billTo.state;
            srcSf.Zip_Code__c = src.billTo.zip;
            srcSf.Country__c = src.billTo.country;
        }
        
        if(src.payment.creditCard != null){
            srcSf.Card_Brand__c = src.payment.creditCard.cardType; //"cardType": "Visa"
            srcSf.Expiry_Month__c = src.Payment.creditCard.expirationDate.right(2); // "expirationDate" : "2025-12"
            srcSf.Expiry_Year__c = src.Payment.creditCard.expirationDate.left(4); // "expirationDate" : "2025-12"
            srcSf.Last_4_digits__c = src.Payment.creditCard.cardNumber.right(4); // "cardNumber": "XXXX1111",
            srcSf.Type__c = ProcessorUtil.PM_CARD;
        }
        else  if(src.payment.bankAccount != null){
            srcSf.Bank_Account_Holder_Name__c = src.payment.bankAccount.nameOnAccount;
            srcSf.Bank_Name__c =  src.payment.bankAccount.bankName;
            srcSf.Last_4_digits__c = src.payment.bankAccount.accountNumber.right(4); // "accountNumber": "XXXX6789",
            srcSf.Routing_Number__c = src.payment.bankAccount.routingNumber; // "routingNumber": "XXXX2882",
            srcSf.Type__c = ProcessorUtil.PM_BANK;
        }
        return srcSf;
    }
    
    private static BWP_Transaction__c constructAuthNetTransaction(BWP_Transaction__c transactionSf, Charge.AuthNetTransaction at, BreadwinnerUtil.AppConfig appConfig){
        if(transactionSf.Id == null){
            transactionSf.Created_Via__c = BreadwinnerUtil.getCreatedViaValue(appConfig.currentRunningClassContext);
        }

        transactionSf.Processor_Id__c = at.transId;
        transactionSf.Amount__c = at.settleAmount;
        transactionSf.Processor_Type__c = appConfig.PaymentProcessorType;
        transactionSf.Processor_Org_Id__c = appConfig.accountId;
        Datetime createdDateTime = (Datetime) JSON.deserialize('"' + at.submitTimeUTC + '"', Datetime.class);
        transactionSf.Created_Date_in_Processor__c = createdDateTime;
        if(at.profile != null){
            transactionSf.Processor_Customer_Id__c = at.profile.customerProfileId;
        }
        if (String.isNotBlank(at.transactionStatus)) {
            transactionSf.Status__c = at.transactionStatus == 'settledSuccessfully' ? ProcessorUtil.CHARGE_SUCCEEDED : at.transactionStatus;
        }

        return transactionSf;
    }

    //  This method is to contrust requestBody required for each Customer
    public static String getRequestBody (String typeOfAction, String custId, BreadwinnerUtil.AppConfig apcWrapper, String offSet) {
        String rawAccessToken = '';
        if(!Test.isRunningTest())
             rawAccessToken = CryptoUtil.decryptSecrets(apcWrapper).accessToken;
        String requestBody; // for each request the access token is required in request body and also in request header
        if (typeOfAction == ProcessorUtil.ACT_FETCH_CUSTOMERS_ALL) {
            requestBody = '{"getCustomerProfileIdsRequest":{"merchantAuthentication":{"accessToken": "'+rawAccessToken+'"}}}';
        } else if (typeOfAction == ProcessorUtil.ACT_FETCH_CUSTOMERS_RECENT) {
            requestBody = '{"getCustomerProfileRequest":{"merchantAuthentication":{"accessToken": "'+rawAccessToken+'"},"customerProfileId":"'+custId+'","unmaskExpirationDate" :"true","includeIssuerInfo":"true"}}';
        } else if(typeOfAction == ProcessorUtil.ACT_FETCH_TRANSACTIONS_ALL){
            requestBody = '{"getTransactionListRequest":{"merchantAuthentication":{"accessToken": "'+rawAccessToken+'"},"batchId":"'+custId+'","sorting":{"orderBy":"submitTimeUTC","orderDescending":"true"},"paging":{"limit":"20","offset":"'+offSet+'"}}}';
        }
        return requestBody;
    }*/
    
    public static String getEndpointBaseUrl(BreadwinnerUtil.AppConfig appConfig){
        return appConfig.livemode ? authorizeNetBaseUrl : authorizeNetTestBaseUrl;
    }
    
  // Builds URL to perform authorization with Authorize.Net in live mode.
    public static String getAuthUrl(){
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm().removeStart('https://');
        String sfMode = BreadwinnerUtil.isLightning() ? 'lightning' : 'classic';
        String redirectURL = ProcessorUtil.REDIRECT_URL;
        String clientId = getClientId('live');
        String stateValue = '{SFMode:' + sfMode + ',ProMode:live,ProType:Authorize.Net,Callback:' + sfdcBaseURL + '/apex/' + BreadwinnerUtil.namespaceApi + 'BreadwinnerPayments}';
        return authorizeNetAuthorizationUrl + '?sub=oauth&client_id=' + EncodingUtil.urlEncode((String.isNotBlank(clientId) ? clientId : ''),'UTF-8') + '&state=' + stateValue + '&scope=read,write&redirect_uri=' + redirectURL;
    }
    
 // Builds URL to perform authorization with Authorize.Net in test mode. Test credentials will be used.
    public static String getTestAuthUrl(){
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm().removeStart('https://'); 
        String sfMode = BreadwinnerUtil.isLightning() ? 'lightning' : 'classic';
        String redirectURL = ProcessorUtil.REDIRECT_URL;
        String clientId = getClientId('test');
        String stateValue = '{SFMode:' + sfMode + ',ProMode:test,ProType:Authorize.Net,Callback:' + sfdcBaseURL + '/apex/' + BreadwinnerUtil.namespaceApi + 'BreadwinnerPayments}';
    	return authorizeNetTestAuthorizationUrl+'?sub=oauth&client_id=' + EncodingUtil.urlEncode((String.isNotBlank(clientId) ? clientId : ''),'UTF-8') + '&state=' + stateValue + '&scope=read,write&redirect_uri=' + redirectURL;
    }

    //This method is used to get the Authorize.Net client Id
    public static String getClientId(String connectionType){
        String returnClientId = '';
        String developerName = (connectionType == 'test' ? 'AuthorizeNet_Test_Credentials' : 'AuthorizeNet_Credentials');
        if(Schema.sObjectType.Breadwinner_Payments_Metadata__mdt.isAccessible()) {
            Breadwinner_Payments_Metadata__mdt authNetCredential = [SELECT Id, Key__c, Secret__c, DeveloperName FROM Breadwinner_Payments_Metadata__mdt WHERE DeveloperName =:developerName LIMIT 1];
            returnClientId = authNetCredential.Key__c;
        }
        return returnClientId;
    }
    
    //This method is used to get the Authorize.Net client Secret
    private static String getClientSecret(String connectionType){
        String returnClientSecret = '';
        String developerName = (connectionType == 'test' ? 'AuthorizeNet_Test_Credentials' : 'AuthorizeNet_Credentials');
        if(Schema.sObjectType.Breadwinner_Payments_Metadata__mdt.isAccessible()) {
            Breadwinner_Payments_Metadata__mdt authNetCredential = [SELECT Id, Key__c, Secret__c, DeveloperName FROM Breadwinner_Payments_Metadata__mdt WHERE DeveloperName =:developerName LIMIT 1];
            returnClientSecret = authNetCredential.Secret__c;
        }
        return returnClientSecret;
    }

    // To save Processor details in Processor Config Object
    public static void saveAppCredentials(String connectionMode, BWP_Processor_Config__c config) {
        String code = ApexPages.currentPage().getParameters().get('code');
        String accountName = '';
        String accountCurrency = '';
        if(String.isNotBlank(code)){
            code = String.escapeSingleQuotes(code);
        }
        String endPoint = connectionMode == 'test' ? authorizeNetTestTokenUrl : authorizeNetTokenUrl;
        endPoint +=  '?code=' + code + '&grant_type=authorization_code';
        endPoint +=  '&client_id=' +(getClientId(connectionMode));
        endPoint +=  '&client_secret=' +(getClientSecret(connectionMode));
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        
        HttpResponse res = new HttpResponse();
        try {
            res = new HTTP().send(req);
        } catch (Exception ex){
            System.debug('ex: ' + ex.getMessage());
        }
        
        System.debug('=='+res.getBody());
        AuthorizeNetTokenInfo tokenResponse = new AuthorizeNetTokenInfo();
        if (res.getStatusCode() == 200) {

            //deserializing the response
            tokenResponse = (AuthorizeNetTokenInfo)JSON.deserialize(res.getBody(), AuthorizeNetTokenInfo.class);

            String accessToken = tokenResponse.access_token;
            HttpRequest request = new HttpRequest();
            request.setEndpoint(authorizeNetTestBaseUrl);
            request.setMethod('POST');
            String body = '{"getMerchantDetailsRequest": {"merchantAuthentication": {"accessToken": "'+accessToken+'"}}}';
            request.setBody(body);
            HttpResponse resp = new HttpResponse();
            try {
                resp = new Http().send(request);
            }catch (Exception ex) {
                System.debug('ex: ' + ex.getMessage());
            }

            system.debug('response----'+resp.getBody());
            String respBody = resp.getBody().trim().replace('\uFEFF', '');
            AuthNetAccountInfo accInfo = (AuthNetAccountInfo)JSON.deserialize(respBody, AuthNetAccountInfo.class);
            accountName =  accInfo.merchantName;
            accountCurrency = accInfo.currencies[0];

            config = BreadwinnerUtil.getProcessorConfig(accInfo.publicClientKey);
            System.debug('config--------------'+config);
            config.Account_Name__c = String.isNotBlank(accountName) ? accountName : '';
            config.Default_Currency__c = String.isNotBlank(accountCurrency) ? accountCurrency : '';
            if (tokenResponse.access_token != null) {
                if(tokenResponse.expires_in != null){
                    config.Access_Token_Expiry_Date__c = system.now().addSeconds(Integer.valueOf(tokenResponse.expires_in));
                }
                config.Access_Token__c = tokenResponse.access_token;
                config.Refresh_Token__c = tokenResponse.refresh_token;
                config.Scope__c = tokenResponse.scope;
                config.Live_Mode__c = accInfo.isTestMode;
                config.Name =  accInfo.publicClientKey;
                config.Provider_ID__c = accInfo.publicClientKey;
                config.Need_To_Reconnect__c = false;
                config.Payment_Processor_Type__c = ProcessorUtil.PAT_AUTHORIZE_NET;
                if (config.Customer_Sync_Config__c == null) {
                    config.Customer_Sync_Config__c = 'NONAME_AND_NOEMAIL';
                }
                if (config.Customer_Match_Config__c == null) {
                    config.Customer_Match_Config__c = 'NO_VALID_PAYMENTS';
                }
                config = CryptoUtil.encryptSecrets(config);
                BreadwinnerUtil.upsertAppConfig(config);
                
                //Running Historical Sync
                HistoricalSyncBatch historicalSync = new HistoricalSyncBatch(BreadwinnerUtil.OBJ_SYNC_CUSTOMER);
                Database.executeBatch(historicalSync, 1);
                APICallHandler.userInteractionLogPush(false, 'Historical Sync', 'Restarted', 'Historical Sync is restarted automatically after connection/reconnection');
            }
        } else {
            throw new ProcessorUtil.ConnectionException('Error occurred while connecting with Authorize.Net.');
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
            String connectionMode = ac.livemode ? 'live' : 'test';
            endPoint = ac.livemode ? authorizeNetTokenUrl : authorizeNetTestTokenUrl;
            endPoint +=  '?grant_type=refresh_token';
            endPoint +=  '&client_id=' +(getClientId(connectionMode));
            endPoint +=  '&client_secret=' +(getClientSecret(connectionMode));
            endPoint +=  '&refresh_token=' +ac.refreshToken;
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPoint);
            req.setMethod('POST');
            
            HttpResponse res = new HttpResponse();
            try {
                res = new HTTP().send(req);
            } catch (Exception ex){
                System.debug('ex: ' + ex.getMessage());
            }
            
            AuthorizeNetTokenInfo tokenResponse = new AuthorizeNetTokenInfo();
            if (res.getStatusCode() == 200) {
                tokenResponse = (AuthorizeNetTokenInfo)JSON.deserialize(res.getBody(), AuthorizeNetTokenInfo.class);
                APICallHandler.userInteractionLogPush(TRUE, 'Refresh Access Token', 'SUCCESS' , 'Successfully Refreshed Access Token for the Authorize.Net Account '+appConfig.Account_Name__c);
                if(tokenResponse.access_token != null) {
                    appConfig.Access_token__c = tokenResponse.access_token;
                    appConfig.Refresh_token__c = tokenResponse.refresh_token;
                    appConfig.Scope__c = tokenResponse.scope;
                    if(tokenResponse.expires_in != null){
                        appConfig.Access_Token_Expiry_Date__c = system.now().addSeconds(Integer.valueOf(tokenResponse.expires_in));
                    }
                    appConfig = CryptoUtil.encryptSecrets(appConfig);
                    BreadwinnerUtil.isBreadwinnerTransaction = true;
                    SecurityUtil.dmlUpsert(appConfig);
                }
            }
            else{
                APICallHandler.userInteractionLogPush(TRUE, 'Refresh Access Token', 'ERROR' , 'Failed to Refresh Access Token for the Authorize.Net Account '+appConfig.Account_Name__c+'. Error'+response.getBody());
            }
        }
        
        catch(Exception e){
            System.debug('Error occured while refreshing the Access Token from Authorize.Net.'+e.getStackTraceString());
            APICallHandler.userInteractionLogPush(TRUE, 'Refresh Access Token', 'ERROR' , e.getmessage());
        }
    }
    
    //Authorize.Net Token info wrapper
    private class AuthorizeNetTokenInfo {
        public String access_token;
        public String refresh_token;
        public String token_type;
        public String scope;
        public Integer expires_in;
        public Integer refresh_token_expires_in;
    }
    
    //Authorize.Net Account info wrapper
    public class AuthNetAccountInfo{
        public Boolean isTestMode;
        public String merchantName;
        public String publicClientKey;
        public List<String> paymentMethods;
        public List<String> currencies;
    }
}