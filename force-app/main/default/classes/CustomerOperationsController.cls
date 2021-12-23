public with sharing class CustomerOperationsController {

    private Selector_Contact selectorContact = new Selector_Contact();

    public Boolean showMessages                                                  {get; set;}
    public Map<String,RecordMatchWrapper> mapStrCustIdAndCustomer                {get; set;}
    public Map<String,RecordMatchWrapper> mapStrCustIdAndSFRecord                {get; set;}
    public Map<String,RecordMatchWrapper> mapProcessorCustIdAndObjectCopy;
    public Map<String,RecordMatchWrapper> mapProcessorCustIdAndCustomer;
    public List<String> processorCustIdList                                      {get; set;}
    public Boolean isCustomerMatchComplete                                       {get; set;}
    public Boolean isAdministrator                                               {get; set;}
    public BWP_Processor_Config__c appConfig                                     {get; set;}
    public BreadwinnerUtil.AppConfig appC                                        {get;set;}
    public Transient Map<String, String> mapProcessorCustIdAndDefaultAction      {get; set;}
    Map<String,Integer> suggestedMatchPriorityMap;
    public Map<String,BWP_Customer__c> mapProcessorRefIdManualMatchLookupSelector{get; set;}
    public String jsonUserSelectedActions                                        {get; set;}
    public Set<String> processorCustIdSet                                        {get; set;}
    public Integer selectedPageNumber                                            {get; set;}
    public List<String> processorCustIdListCopy                                  {get; set;}
    public Integer customersCount = 0;
    public Integer cPageNo = 0;
    public Boolean isBackgroundjobRunning                                        {get; set;}
    public Boolean restartSync                                                   {get; set;}
    public Boolean noRecordsInProcessor                                          {get; set;}
    public Integer customerNo = 0;
    public Map<String,List<Contact>> mapofContacts;
    public Map<String,List<Contact>> contactsList2                               {get; set;}
    public Map<id,Contact> accountsNameInfo                                      {get; set;}
    public List<String> referenceIdListForCreateNew;
    public Boolean isThereDataQualityIssue                                       {get; set;}
    public String exceptionMessage                                               {get; private set;}
    public String sfMode                                                         {get;set;}
    public String breadwinnerPageName                                            {get;set;}
    public Boolean canPerformBreadwinnerOperations                               {get; private set;}
    public String selectedProcessorId;
    public String selectedMatchType                                              {get;set;}
    public Boolean isCustomerMatchSettingConfigured                              {get; set;}
    public Boolean areRecordTypesEnabled                                         {get;set;}
    public Boolean isDefaultRecordTypeMaster                                     {get;set;}
    public CustomerOperationsController() {
        
        showMessages = True;
        isCustomerMatchComplete = False;
        restartSync = False;
        noRecordsInProcessor =False;
        isCustomerMatchSettingConfigured = FALSE;
        isBackgroundjobRunning = False;
        exceptionMessage = '';
        selectedPageNumber = 1;
        isThereDataQualityIssue = False;
        areRecordTypesEnabled = ProcessorUtil.areRecordTypesEnabled();
        isDefaultRecordTypeMaster = ProcessorUtil.isDefaultRecordTypeIsMaster();
        isAdministrator = BreadwinnerUtil.isAdministrator();
        canPerformBreadwinnerOperations = BreadwinnerUtil.canPerformBreadwinnerOperations();
        Map<String,String> pageParams = ApexPages.currentPage().getParameters();
        selectedProcessorId = String.isNotBlank(pageParams.get('processorId')) ? pageParams.get('processorId') : '';
        selectedMatchType = String.isNotBlank(pageParams.get('customerMatchType')) ? pageParams.get('customerMatchType') : '';
        appConfig = ((String.isNotBlank(selectedProcessorId)) ? (BreadwinnerUtil.getProcessorConfig(selectedProcessorId)) : BreadwinnerUtil.processorConfigList[0]);
        appC = BreadwinnerUtil.getProcessorConfigWrapper(appConfig);
        isCustomerMatchSettingConfigured = (String.isBlank(appC.CustomerMatchConfig) || (String.isNotBlank(appC.CustomerMatchConfig) && appC.CustomerMatchConfig.contains('NO_VALID_PAYMENTS')) ? TRUE : FALSE);
        jsonUserSelectedActions = '';
        referenceIdListForCreateNew = new List<String>();
        mapofContacts=New Map<String, List<Contact>>();
        processorCustIdSet = new Set<String>();
        mapProcessorRefIdManualMatchLookupSelector = new Map<String,BWP_Customer__c>();
        sfMode = BreadwinnerUtil.isLightning() ? 'lightning' : 'classic'; 
        breadwinnerPageName = BreadwinnerUtil.namespaceApi + 'BreadwinnerPayments';
        if(canPerformBreadwinnerOperations) {
            if(appConfig != Null) {
                checkIsHistoricalSyncBatchRunning();
                fetchProcessorCustomers();
                fetchMatchingRecordsFromSF();
            }
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ' Only Administrators can access this page.' ));
        } 
    }
    public void pagingForCustomers() {
        mapProcessorCustIdAndObjectCopy.clear();
        processorCustIdList.clear();
        List<String> strCustomerId = new List<String>();
        strCustomerId.addall(mapProcessorCustIdAndCustomer.keyset());
        integer i=0;
        if(cPageNo ==0) { i=10;}
        if(cPageNo ==1) { i=20;}
        if(cPageNo ==2) { i=20;}
        if(cPageNo > 2) { i=50;}
        
        for(integer j=0; customerNo < customersCount && j<i; j++) {
            mapProcessorCustIdAndObjectCopy.put(strCustomerId[customerNo], mapProcessorCustIdAndCustomer.get(strCustomerId[customerNo]));
            processorCustIdList.add(processorCustIdListCopy[customerNo]);
            customerNo++;
        }
        cPageNo++;
        
        for(String referenceId : mapProcessorCustIdAndObjectCopy.keySet()) {
            mapProcessorRefIdManualMatchLookupSelector.put(referenceId,new BWP_Customer__c());
        }
    }
    
    public void fetchProcessorCustomers() {
        exceptionMessage = '';
        mapProcessorRefIdManualMatchLookupSelector = new Map<String,BWP_Customer__c>();
        try {
            if(appConfig != Null) {
                customerNo = 0;
                mapProcessorCustIdAndCustomer = new Map<String, RecordMatchWrapper> ();
                mapProcessorCustIdAndObjectCopy = new Map<String, RecordMatchWrapper> ();
                processorCustIdList = new List<String>();
                String whereStr = BreadwinnerController.customerMatchQuery(appConfig, selectedMatchType);
                whereStr += ' AND Id NOT IN :processorCustIdSet';
                QueryBuilder qb = new QueryBuilder(BWP_Customer__c.SObjectType, true, true, true);
                qb.addSObjectFields(BWP_Customer__c.SObjectType.getDescribe().fields.getMap().values());
                qb.setCondition(whereStr);
                qb.setOrderBy('Processor_Org_Name__c ASC, Email__c ASC');
                qb.setLimit(100);
                List<BWP_Customer__c> customerList = Database.query(qb.toSOQL());
                for(BWP_Customer__c processorCustomer : customerList) {
                    mapProcessorCustIdAndCustomer.put(processorCustomer.id, new RecordMatchWrapper(processorCustomer));
                    processorCustIdList.add(processorCustomer.id);
                }

                processorCustIdSet.clear();
                processorCustIdSet.addAll(mapProcessorCustIdAndCustomer.keySet());
                customersCount = processorCustIdList.size();
                if(selectedPageNumber <= 1 && customersCount == 0) noRecordsInProcessor = doesCustomersExistsInPaymentProcessor(appC) ? False : True;
                if(mapProcessorCustIdAndCustomer.size() == 0) {
                    if(selectedPageNumber > 0) {
                        isCustomerMatchComplete = True;
                    }else if(!appConfig.Is_Customer_Match_Completed__c) {
                        showMessages = True;
                    }   
                }
                else{
                    processorCustIdListCopy = new  List<String>();
                    processorCustIdListCopy.addall(processorCustIdList);
                    processorCustIdList.clear();
                    if(customerNo < customersCount) {
                        pagingForCustomers();
                    }
                }
            }
        }
        catch (Exception e) {
            System.debug('Exception : ' + e.getStackTraceString());
            APICallHandler.userInteractionLogPush(TRUE, 'Fetching BWP Customers', 'ERROR' , e.getStackTraceString());
        }
    }
    
    public void fetchMatchingRecordsFromSF() {
        //System.debug('fetchMatchingRecordsFromSF');
        mapProcessorCustIdAndDefaultAction = new Map<String, String>();
        try {
            if(appConfig != Null) {

                mapStrCustIdAndSFRecord = new Map<String, RecordMatchWrapper>();
                performNewSuggestedMatch();
                mapStrCustIdAndCustomer = new Map<String, RecordMatchWrapper>();
                mapStrCustIdAndCustomer.putall(mapProcessorCustIdAndObjectCopy);
                
                //-- Create New - Accounts for which no matches where found
                for(String refId: mapProcessorCustIdAndObjectCopy.keySet()) {
                    if(!mapStrCustIdAndSFRecord.containsKey(refId)) {
                        RecordMatchWrapper acc = mapProcessorCustIdAndObjectCopy.get(refId);
                        mapProcessorCustIdAndDefaultAction.put(refId, ProcessorUtil.CMO_CREATE_NEW);
                        mapStrCustIdAndSFRecord.put(refId, acc);
                    }
                }
                isThereDataQualityIssue = False;
                //-- Checking Field Length issues
                for(String xId : mapProcessorCustIdAndObjectCopy.keySet()) {
                    if(mapProcessorCustIdAndDefaultAction.containsKey(xId)) {
                        RecordMatchWrapper acc = mapProcessorCustIdAndObjectCopy.get(xId);
                        if((String.isNotBlank(acc.billingStreet) && acc.billingStreet.length() > 255)
                           ||(String.isNotBlank(acc.billingCity) && acc.billingCity.length() > 40)
                           ||(String.isNotBlank(acc.billingState) && acc.billingState.length() > 20)
                           ||(String.isNotBlank(acc.billingPostalCode) && acc.billingPostalCode.length() > 20)
                           ||(String.isNotBlank(acc.billingCountry) && acc.billingCountry.length() > 40)) {
                               isThereDataQualityIssue = True;
                           }                        
                        if(isThereDataQualityIssue) {
                            break;
                        }
                    }
                } 
            }
        }
        catch (Exception e) {
            System.debug('Exception : ' + e.getStackTraceString());
            //APICallHandler.userInteractionLogPush(FALSE, 'App Config', 'Connected' , 'Connected Processor Info '+config.account_Name__c);
        }
    }
    private void performNewSuggestedMatch() {
        //System.debug('performNewSuggestedMatch');
        Map<String, List<String>> mapCustomerNameAndProcessorCustIdList = new Map<String, List<String>>();
        Map<String, List<String>> mapPhoneAndProcessorCustIdList = new Map<String, List<String>>();
        Map<String, List<String>> mapEmailAndProcessorCustIdList = new Map<String, List<String>>();
        Map<String, List<String>> mapDomainAndProcessorCustIdList = new Map<String, List<String>>();
        Map<String, List<String>> mapStreetAddrAndProcessorCustIdList = new Map<String, List<String>>();
        Map<String, String> mapStreetAddrAndPostCode = new Map<String, String>();
        Map<String, String> mapEmailAddress = new Map<String, String>();
        accountsNameInfo = new Map<id, Contact>();
        Set<String> setProcessorPhoneNumbers = new Set<String>();
        Set<String> setProcessorEmailDomains = new Set<String>();
        suggestedMatchPriorityMap = new Map<String,Integer>();

        //-- Create map of ProcessorAcctIdAndCustomerName And ProcessorAcctIdAndPhone for suggested match
        for(String refId: mapProcessorCustIdAndObjectCopy.keySet()) {
            
            RecordMatchWrapper aw = mapProcessorCustIdAndObjectCopy.get(refId);
            
            //-- create a map of email address for contact's email matching
            if(!String.isBlank(aw.EmailAddress)) {
                mapEmailAddress.put(refId, aw.EmailAddress.ToLowerCase());
            }
            //-- create map for customer name and associated Id of fetched Processor contacts
            Set<String> customerNameSet = new Set<String>();
            
            String customerName =  (String.isNotBlank(aw.firstName) ? (aw.firstName + (String.isNotBlank(aw.lastName) ? (' '+aw.lastName) : '')) : (String.isNotBlank(aw.lastName) ? aw.lastName : aw.name));
            String lowerCaseCustomerName = '';
            
            if( String.isNotBlank(customerName)  && customerName.contains('\\')) {
                customerName = customerName.replace('\\', '%'); 
            }
            
            if(String.isNotBlank(customerName)) { lowerCaseCustomerName = customerName.toLowerCase();}
            
            Set<String> relatedCustomerNameSet = BreadwinnerUtil.getSimilarAccountNameSet(lowerCaseCustomerName);
            
            for(String cN : relatedCustomerNameSet) {                    
                List<String> tempRefIdList1 = mapCustomerNameAndProcessorCustIdList.containsKey(cN) ? mapCustomerNameAndProcessorCustIdList.get(cN) : new List<String>();
                tempRefIdList1.add(refId);
                mapCustomerNameAndProcessorCustIdList.put(cN, tempRefIdList1);
            }
            
            //-- create map for email and associated refId of fetched Processor contacts
            String email = aw.EmailAddress;
            if(String.isNotBlank(email) && email.contains('@')) {
                List<String> tempRefIdList = mapEmailAndProcessorCustIdList.containsKey(email) ? mapEmailAndProcessorCustIdList.get(email) : new List<String>();
                tempRefIdList.add(refId);
                mapEmailAndProcessorCustIdList.put(email, tempRefIdList);
                String domain = email.subStringAfter('@');
                List<String> tempRefIdList3 = mapDomainAndProcessorCustIdList.containsKey(domain) ? mapDomainAndProcessorCustIdList.get(domain) : new List<String>();
                tempRefIdList3.add(refId);
                mapDomainAndProcessorCustIdList.put(domain, tempRefIdList3);
                setProcessorEmailDomains.add('%' + domain +'%');
            }
            
            //-- create map for phone and associated refId of fetched Processor contacts
            String phone = aw.Phone;
            if(String.isNotBlank(phone)) {
                phone = phone.replaceAll(' ', '%').replace('\\', '%');
                setProcessorPhoneNumbers.add('%' + phone.replaceAll('-', '%') + '%');
                String numericPhone = phone.replaceAll('[^0-9]', '');
                List<String> tempRefIdList2 = mapPhoneAndProcessorCustIdList.containsKey(numericPhone) ? mapPhoneAndProcessorCustIdList.get(numericPhone) : new List<String>();
                tempRefIdList2.add(refId);
                mapPhoneAndProcessorCustIdList.put(numericPhone, tempRefIdList2);
            }
            
            //-- create map for street address and associated refId of fetched Processor contacts
            String address = aw.billingStreet;
            if(String.isNotBlank(address)) {
                String addLowerCase = '';
                if (address.contains('%%')) {
                    List<String> listAddresses = address.split('%%');
                    System.debug('listAddresses : ' + listAddresses);
                    addLowerCase = listAddresses.get(0).toLowerCase();
                }
                else{
                    addLowerCase = address.toLowerCase();
                }
                if(String.isNotBlank(addLowerCase)) {
                    addLowerCase = addLowerCase.replace('\\','%');
                    List<String> tempRefIdList4 = mapStreetAddrAndProcessorCustIdList.containsKey(addLowerCase) ? mapStreetAddrAndProcessorCustIdList.get(addLowerCase) : new List<String>();
                    tempRefIdList4.add(refId); 
                    mapStreetAddrAndProcessorCustIdList.put(addLowerCase, tempRefIdList4);
                    mapStreetAddrAndPostCode.put(addLowerCase, aw.billingPostalCode);
                    mapStreetAddrAndPostCode.get(addLowerCase);
                }
            }
        }
        
        Set<String> setCustomerNames = mapCustomerNameAndProcessorCustIdList.keySet();
        Set<String> setStreetAddresses = mapStreetAddrAndProcessorCustIdList.keySet();
        List<String> processorEmails = mapEmailAddress.values();

        if(selectedMatchType == ProcessorUtil.CMT_ACCOUNT){
            Map<String, List<Contact>> emailswithContacts = new Map<String, List<Contact>>();
            Map<String, Set<Account>> emailWithAccounts = new Map<String, Set<Account>>();
            List<Contact> conList = selectorContact.selectWhere('Email IN (\'' + String.join(processorEmails,'\',\'') + '\') AND AccountId != Null',Selector_Contact.ACCT_FIELDS);
            for(Contact contactlist: conList) {
                if(contactlist.email != Null && contactlist.email!='') {
                    List<Contact> cList = emailswithContacts.containsKey(contactlist.Email) ? emailswithContacts.get(contactlist.Email) : new List<Contact>();
                    cList.add(contactlist);
                    emailswithContacts.put(contactlist.Email, cList );
                    Set<Account> accountslist = emailWithAccounts.containskey(contactlist.Email) ? emailWithAccounts.get(contactlist.Email) : new Set<Account>();
                    accountslist.add(new Account(id=contactlist.Accountid));
                    emailWithAccounts.put(contactlist.Email, accountslist);
                    List<Contact> clist2 = mapofContacts.containskey(contactlist.Email) ? mapofContacts.get(contactlist.Email) : new List<Contact>();
                    clist2.add(contactlist);
                    if(clist2.size()>0) {
                        mapofContacts.put(contactlist.Email, clist2);
                    }
                    accountsNameInfo.put(contactlist.Id, contactlist);
                }
            }


            // Migrated query to QueryBuilder
            String whereStr = 'Name LIKE: setCustomerNames OR Phone LIKE: setProcessorPhoneNumbers OR website LIKE: setProcessorEmailDomains OR BillingStreet LIKE: setStreetAddresses';
            QueryBuilder qb = new QueryBuilder(Account.SObjectType, true, true, true);
            qb.addSObjectFields(Selector_Account.FIELD_LIST);
            qb.setCondition(whereStr);
            qb.setLimit(1000);
            List<Account> acctList = Database.query(qb.toSOQL());
            for(Account acctRef: acctList) {
                // Match By customer Name
                matchByName(acctRef, mapCustomerNameAndProcessorCustIdList);
                //Match By Domain
                matchByDomain(acctRef, mapDomainAndProcessorCustIdList);
                //Match By Phone
                matchByPhone(acctRef, mapPhoneAndProcessorCustIdList);
                //Match By Street address
                matchByAddress(acctRef, mapStreetAddrAndProcessorCustIdList);
            }

            contactsList2 = new Map<String, List<Contact>>();
            for(String refId: mapEmailAddress.keyset()) {
                if(!mapStrCustIdAndSFRecord.containsKey(refId)) {
                    if(emailswithContacts.containskey(mapEmailAddress.get(refId))) {
                        Set<Account> accounts2 =  emailWithAccounts.get(mapEmailAddress.get(refId));
                        List<Account> accounts = new List<Account>(); Accounts.addall(accounts2);
                        if(Accounts.size()==1) {
                            mapStrCustIdAndSFRecord.put(refId, new RecordMatchWrapper(accounts[0]));
                            mapProcessorCustIdAndDefaultAction.put(refId, ProcessorUtil.CMO_SUGGESTED_MATCH);
                            suggestedMatchPriorityMap.put(refId, 6);
                            contactsList2.put(refId, mapofContacts.get(mapEmailAddress.get(refId)));
                        }
                    }
                }
            }
        }
        else if(selectedMatchType == ProcessorUtil.CMT_CONTACT){
            // Migrated query to QueryBuilder
            String whereStr = 'Name LIKE: setCustomerNames OR Email IN (\'' + String.join(processorEmails,'\',\'') + '\') OR Phone LIKE: setProcessorPhoneNumbers OR MailingStreet LIKE: setStreetAddresses';
            QueryBuilder qb = new QueryBuilder(Contact.SObjectType, true, true, true);
            qb.addSObjectFields(Selector_Contact.FIELD_LIST);
            qb.setCondition(whereStr);
            qb.setLimit(1000);
            List<Contact> conList = Database.query(qb.toSOQL());
            for(Contact conRef: conList) {
                // Match By customer Name
                matchByName(conRef, mapCustomerNameAndProcessorCustIdList);
                //Match By Email
                matchByEmail(conRef, mapEmailAndProcessorCustIdList);
                //Match By Phone
                matchByPhone(conRef, mapPhoneAndProcessorCustIdList);
                //Match By Street address
                matchByAddress(conRef, mapStreetAddrAndProcessorCustIdList);
            }
        }
    }
    
    public PageReference submitAndNext() {
        
        contactsList2 = new Map<String, List<Contact>>();
        mapofContacts = new Map<String, List<Contact>>();
        if(noRecordsInProcessor) {
            isCustomerMatchComplete=True;
        }
        else{
            //System.debug('jsonUserSelectedActions : ' + jsonUserSelectedActions);
            //map for update 
            List<BWP_Customer__c> strCusUpdateList = new List<BWP_Customer__c>();
            exceptionMessage ='';
            Map<String, SObject> mapStrCusRefIdAndSFRecordInsert = new Map<String, SObject>();
            Map<String,RecordMatchWrapper> mapProcessorCustRefIdAndSFRecordBackupForCreateNew = new Map<String,RecordMatchWrapper>();
            Map<String,BWP_Customer__c> mapProcessorRefIdManualMatchLookupSelectorBackup = new Map<String,BWP_Customer__c>(mapProcessorRefIdManualMatchLookupSelector);
            Integer suggestedMatchCount = 0;
            Integer manualMatchCount = 0;
            Integer createNewCount = 0;
            Integer doNotImportCount = 0;
            Integer missedSCTotalCount = 0;
            JSONParser parser = JSON.createParser(jsonUserSelectedActions);
            while(parser.nextToken() != Null) {
                if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (mapStrCustIdAndSFRecord.containsKey(parser.getText()))) {
                    String processorCustRefId = parser.getText();
                    parser.nextToken();
                    String action = parser.getText();
                    
                    RecordMatchWrapper aw = new RecordMatchWrapper();
                    SObject sfObj = getObjectWrapper(selectedMatchType, mapStrCustIdAndSFRecord.get(processorCustRefId));
                    aw = mapProcessorCustIdAndObjectCopy.get(processorCustRefId);

                    // Create New
                    if(action.equalsIgnoreCase(ProcessorUtil.CMO_CREATE_NEW) && aw != Null) {
                        createNewCount++;
                        mapProcessorCustRefIdAndSFRecordBackupForCreateNew.put(processorCustRefId,aw );
                        mapStrCusRefIdAndSFRecordInsert.put(processorCustRefId, getObjectWrapper(selectedMatchType, aw));
                        referenceIdListForCreateNew.add(processorCustRefId);
                    }
                    
                    //Suggested Match
                    if(action.equalsIgnoreCase(ProcessorUtil.CMO_SUGGESTED_MATCH)) {
                        BWP_Customer__c processorCustomer= new BWP_Customer__c(Id = processorCustRefId);
                        if(selectedMatchType == ProcessorUtil.CMT_ACCOUNT){
                            processorCustomer.Salesforce_Account__c = sfObj.id;
                        }
                        else if(selectedMatchType == ProcessorUtil.CMT_CONTACT){
                            processorCustomer.Salesforce_Contact__c = sfObj.id;
                        }

                        strCusUpdateList.add(processorCustomer);
                        suggestedMatchCount++;
                    }
                    
                    //Manual Match
                    else if(action.equalsIgnoreCase(ProcessorUtil.CMO_MANUAL_MATCH)) {
                        Id recordId;
                        if(selectedMatchType == ProcessorUtil.CMT_ACCOUNT)
                            recordId = mapProcessorRefIdManualMatchLookupSelectorBackup.containsKey(processorCustRefId)? mapProcessorRefIdManualMatchLookupSelectorBackup.get(processorCustRefId).Salesforce_Account__c : Null;
                        if(selectedMatchType == ProcessorUtil.CMT_CONTACT)
                            recordId = mapProcessorRefIdManualMatchLookupSelectorBackup.containsKey(processorCustRefId)? mapProcessorRefIdManualMatchLookupSelectorBackup.get(processorCustRefId).Salesforce_Contact__c : Null;
                        if(recordId != Null) {
                            BWP_Customer__c processorCustomer= new BWP_Customer__c(Id = processorCustRefId);
                            if(selectedMatchType == ProcessorUtil.CMT_ACCOUNT){
                                processorCustomer.Salesforce_Account__c = recordId;
                            }
                            else if(selectedMatchType == ProcessorUtil.CMT_CONTACT){
                                processorCustomer.Salesforce_Contact__c = recordId;
                            }
                            strCusUpdateList.add(processorCustomer);
                            manualMatchCount++;
                        }
                        else{
                            processorCustIdSet.remove(processorCustRefId);
                            //ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.ERROR, 'Please select an account to match.'));
                        }

                    }
                    
                    // Do not Import
                    else if(action.equalsIgnoreCase(ProcessorUtil.CMO_DO_NOT_IMPORT)) {
                        BWP_Customer__c processorCustomer= new BWP_Customer__c(Id = processorCustRefId);
                        doNotImportCount++;
                        if(selectedMatchType == ProcessorUtil.CMT_ACCOUNT){
                            processorCustomer.No_Associated_SF_Account__c = True;
                        }
                        else if(selectedMatchType == ProcessorUtil.CMT_CONTACT){
                            processorCustomer.No_Associated_SF_Contact__c = True;
                        }
                        strCusUpdateList.add(processorCustomer);
                    }  
                }   
            }
            
            if(customerNo<customersCount) {
                pagingForCustomers();
            }
            else{
                selectedPageNumber += 1;
                fetchProcessorCustomers();
            }
            //System.debug(mapStrCusRefIdAndSFRecordInsert.size());
            if(mapStrCusRefIdAndSFRecordInsert.size() > 0) {
                Database.UpsertResult[] srList = SecurityUtil.databaseUpsert(mapStrCusRefIdAndSFRecordInsert.values());
                Set<String> otherExceptionsSet = new Set<String>();
                String duplicateRecords = '';
                String duplicatesExcErrorLog = 'DUPLICATES_DETECTED : Unable to create this : '+selectedMatchType;
                
                //Handle exceptions
                integer siz = srList.size();
                for(Integer i = 0; i< siz; i++) {
                    try {
                        if(!srList[i].isSuccess()) {
                            Database.Error[] errors = srList[i].getErrors();
                            System.debug('The following error has occurred.');                    
                            System.debug('Record fields that affected this error: ' + errors);
                            if(errors.size()>0) {
                                Database.Error firstError = errors.get(0);
                                String tempRefId = referenceIdListForCreateNew.get(i);
                                if(String.valueOf(firstError.getStatusCode())== 'DUPLICATES_DETECTED') {
                                    RecordMatchWrapper temp = mapStrCusRefIdAndSFRecordInsert.containsKey(tempRefId) ? new RecordMatchWrapper(mapStrCusRefIdAndSFRecordInsert.get(tempRefId)) : new RecordMatchWrapper();
                                    for(Database.Error er : errors) {
                                        duplicateRecords += temp.Name+', ';
                                    }
                                }
                                else{
                                    for(Database.Error er : errors) {
                                        otherExceptionsSet.add(er.getStatusCode() + ': ' + er.getMessage());
                                    }
                                }
                                if(mapProcessorCustRefIdAndSFRecordBackupForCreateNew.containsKey(tempRefId)) {
                                    RecordMatchWrapper awTemp = mapProcessorCustRefIdAndSFRecordBackupForCreateNew.get(tempRefId);
                                    awTemp.isUnableToCreateAccount = True;
                                    awTemp.errorMessage = String.valueOf(firstError.getStatusCode())+' '+firstError.getMessage();
                                }
                            }
                        }
                    }
                    catch (Exception e) {
                        System.debug('Exception : ' + e.getMessage());
                        APICallHandler.userInteractionLogPush(FALSE, 'Customer Sync', 'ERROR' , 'Exceptions while Matching BWP Customers : '+e.getmessage());
                    }
                }

                String allErrors = '';
                if(otherExceptionsSet.size()>0) {
                    for(string e : otherExceptionsSet) allErrors +=  e.replaceAll('\r\n', '%%')+' --- ';
                    APICallHandler.userInteractionLogPush(FALSE, 'Customer Sync', 'ERROR' , 'Exceptions while inserting : '+selectedMatchType+'s '+allErrors);
                }
                if(string.isNotBlank(duplicateRecords)){
                    duplicatesExcErrorLog += duplicateRecords;
                    APICallHandler.userInteractionLogPush(FALSE, 'Customer Sync', 'ERROR' , 'Exceptions while inserting: '+selectedMatchType+'s '+duplicatesExcErrorLog);
                }
            }
            else{
                System.debug('Do not have Create and Update Permission on '+selectedMatchType+' Object or No records to insert '+mapStrCusRefIdAndSFRecordInsert.size());
            }
            
            List<String> failedRecordsIdList = new List<String>();
            for (String refId: mapStrCusRefIdAndSFRecordInsert.keySet()) {
                RecordMatchWrapper fetchedProcessorCustomer = mapProcessorCustRefIdAndSFRecordBackupForCreateNew.containsKey(refId) ? mapProcessorCustRefIdAndSFRecordBackupForCreateNew.get(refId) : new RecordMatchWrapper();
                
                if(String.isNotBlank(mapStrCusRefIdAndSFRecordInsert.get(refId).id)) {
                    BWP_Customer__c processorCustomer = new BWP_Customer__c();
                    processorCustomer.Id = refId;
                    if(selectedMatchType == ProcessorUtil.CMT_ACCOUNT){
                        processorCustomer.Salesforce_Account__c = mapStrCusRefIdAndSFRecordInsert.get(refid).id;
                    }
                    else if(selectedMatchType == ProcessorUtil.CMT_CONTACT){
                        processorCustomer.Salesforce_Contact__c = mapStrCusRefIdAndSFRecordInsert.get(refid).id;
                    }
                    strCusUpdateList.add(processorCustomer);
                } 
                else{
                    missedSCTotalCount++;
                    System.debug(missedSCTotalCount);
                    if(!mapProcessorCustIdAndObjectCopy.containsKey(refId)) {
                        failedRecordsIdList.add(refId);
                        mapProcessorCustIdAndObjectCopy.put(refId,fetchedProcessorCustomer);
                        system.debug('Account failed:::'+fetchedProcessorCustomer);
                        mapProcessorRefIdManualMatchLookupSelector.put(refId,new BWP_Customer__c());
                        processorCustIdSet.add(refId);
                    }
                }
            }
            if(missedSCTotalCount > 0) {
                exceptionMessage = 'Breadwinner was unable to create '+ missedSCTotalCount+' Customer'+(missedSCTotalCount >1 ?  's' : '') +' in the last page. Please check if there are any Validation Rules or Triggers on '+selectedMatchType;
                List<String> tempList = new List<String>();
                tempList.addAll(failedRecordsIdList);
                tempList.addAll(processorCustIdList);
                processorCustIdList = tempList;
                isCustomerMatchComplete = False;
            }

            SecurityUtil.dmlUpdate(strCusUpdateList);

            if(String.isNotBlank(selectedMatchType) && String.isBlank(appConfig.Customer_Match_Type__c)){
                appConfig.Customer_Match_Type__c = selectedMatchType;
                BreadwinnerUtil.isBreadwinnerTransaction = true;
                SecurityUtil.dmlUpdate(appConfig);
            }
        }
        if(isCustomerMatchComplete) {
            noRecordsInProcessor = True;
            appConfig.Is_Customer_Match_Completed__c=True;
            BreadwinnerUtil.isBreadwinnerTransaction = true;
            SecurityUtil.dmlUpdate(appConfig);
            restartHistoricalSync();
            HourlySyncBatch.scheduleBreadwinnerHourlySync(15, true);
            APICallHandler.userInteractionLogPush(FALSE, 'Customers Matching', 'Success' ,  'BWP Customers to Salesforce Accounts Mapping is done');
        }
        else{
            //fetch Matching Records From Salesforce
            fetchMatchingRecordsFromSF();
        }
        referenceIdListForCreateNew = new List<String>();
        return Null;
    }
    
    public void checkIsHistoricalSyncBatchRunning() {
        try { 
            if(BreadwinnerUtil.isBatchRunning(BreadwinnerUtil.CNTX_HIST_SYNC)) {
                isBackgroundjobRunning = True;
                noRecordsInProcessor = False;
            }
        }
        catch (Exception e) {
            System.debug('Exception : ' + e.getMessage());
        }
    }
    
    public void restartHistoricalSync() {
        try {
            if(isAdministrator && !BreadwinnerUtil.isBatchRunning(BreadwinnerUtil.CNTX_HIST_SYNC)) {
                Database.executeBatch(new HistoricalSyncBatch(BreadwinnerUtil.OBJ_SYNC_CUSTOMER), 1);
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ' A background job to import your BWP Customers is in progress, please try again later.' ));
            restartSync = false;
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ' '+e.getMessage()));
        }
    }

    public boolean doesCustomersExistsInPaymentProcessor(BreadwinnerUtil.AppConfig apcWrap){
        Boolean recordsExistsinProcessor = FALSE;
        Integer requestRecordsCount = 0;
        Map<String, Object> request = new Map<String, Object>();
        request.put(ProcessorUtil.API_PROCESSOR_ID, apcWrap.accountId);
        request.put(ProcessorUtil.API_ACTION, ProcessorUtil.ACT_FETCH_CUSTOMERS_ALL);
        request.put(ProcessorUtil.API_VERSION, ProcessorUtil.VER_1);
        Map<String, Object> response = new Map<String, Object>();
        if(apcWrap.PaymentProcessorType == ProcessorUtil.PAT_STRIPE){
            Processor_Stripe.FetchRequest fetchRequest = new Processor_Stripe.FetchRequest();
            fetchRequest.stripe_limit = '1';
            request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(fetchRequest)); 
            response = BreadwinnerPaymentsAPI.call(request); 
            if(response.get(ProcessorUtil.RESP_JSON) != NULL){
                String responseJSON = (String) response.get(ProcessorUtil.RESP_JSON);
                JSONParser parser = JSON.createParser(responseJSON);
                Processor_Stripe.FetchResponse responseData = (Processor_Stripe.FetchResponse) parser.readValueAs(Processor_Stripe.FetchResponse.class);
                requestRecordsCount = responseData.customerMapById.size() > 0 ? responseData.customerMapById.size() : 0;
            }
        }
        else if(apcWrap.PaymentProcessorType == ProcessorUtil.PAT_BRAINTREE){
            String requestJSON = Processor_Braintree.getRequestBody(ProcessorUtil.ACT_FETCH_CUSTOMERS_ALL, '');
            request.put(ProcessorUtil.API_REQUEST_JSON, requestJSON);
            response = BreadwinnerPaymentsAPI.call(request); 
            if(response.get(ProcessorUtil.RESP_JSON) != NULL){
                String responseJSON = (String) response.get(ProcessorUtil.RESP_JSON);
                JSONParser parser = JSON.createParser(responseJSON);
                Processor_Braintree.FetchResponse responseData = (Processor_Braintree.FetchResponse) parser.readValueAs(Processor_Braintree.FetchResponse.class);
                requestRecordsCount = responseData.customerMapById.size() > 0 ? responseData.customerMapById.size() : 0;
            }
        }
        else if(apcWrap.PaymentProcessorType == ProcessorUtil.PAT_SQUARE){
            Processor_Square.FetchRequest fetchRequest = new Processor_Square.FetchRequest();
            fetchRequest.square_limit = '1';
            request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(fetchRequest)); 
            response = BreadwinnerPaymentsAPI.call(request); 
            if(response.get(ProcessorUtil.RESP_JSON) != NULL){
                String responseJSON = (String) response.get(ProcessorUtil.RESP_JSON);
                JSONParser parser = JSON.createParser(responseJSON);
                Processor_Square.FetchResponse responseData = (Processor_Square.FetchResponse) parser.readValueAs(Processor_Square.FetchResponse.class);
                requestRecordsCount = responseData.customerMapById.size() > 0 ? responseData.customerMapById.size() : 0;
            }
        }

        if(requestRecordsCount > 0) recordsExistsinProcessor = TRUE;
        return recordsExistsinProcessor;
    }
    public void matchByName(SObject ref, Map<String, List<String>> mapCustomerNameAndProcessorCustIdList){
        String recordName = (String)ref.get('Name');
        String lowerCaseRecordName = String.isNotBlank(recordName) ? recordName.replace('\\','%').toLowerCase() : '';
        Set<String> relatedRecordNameSet = BreadwinnerUtil.getSimilarAccountNameSet(lowerCaseRecordName);
        for(String name : relatedRecordNameSet) {
            if(mapCustomerNameAndProcessorCustIdList.containsKey(name)) {
                for(String refId : mapCustomerNameAndProcessorCustIdList.get(name)) {
                    if(!mapStrCustIdAndSFRecord.containsKey(refId) || name == lowerCaseRecordName || (suggestedMatchPriorityMap.containsKey(refId) && suggestedMatchPriorityMap.get(refId) >1 )) {
                        if(name != lowerCaseRecordName || (name == lowerCaseRecordName && !suggestedMatchPriorityMap.containsKey(refId)) || (name == lowerCaseRecordName && suggestedMatchPriorityMap.containsKey(refId) && suggestedMatchPriorityMap.get(refId) >=2 )) {
                            mapStrCustIdAndSFRecord.put(refId, new RecordMatchWrapper(ref));
                            mapProcessorCustIdAndDefaultAction.put(refId, ProcessorUtil.CMO_SUGGESTED_MATCH);
                            suggestedMatchPriorityMap.put(refId,1);
                        }
                    }
                }
            }
        }
    }
    
    public void matchByEmail(SObject ref, Map<String, List<String>> mapEmailAndProcessorCustIdList){
        String email = (String)ref.get('Email');
        email = String.isNotBlank(email) ? email : '';
        if(String.isNotBlank(email) && mapEmailAndProcessorCustIdList.containsKey(email)) {
            for(String refId : mapEmailAndProcessorCustIdList.get(email)) {
                if(!mapStrCustIdAndSFRecord.containsKey(refId) || (suggestedMatchPriorityMap.containsKey(refId) && suggestedMatchPriorityMap.get(refId) >2 )) {
                    mapStrCustIdAndSFRecord.put(refId, new RecordMatchWrapper(ref));
                    mapProcessorCustIdAndDefaultAction.put(refId, ProcessorUtil.CMO_SUGGESTED_MATCH);
                    suggestedMatchPriorityMap.put(refId, 2);
                }
            }
        }
    }
    public void matchByDomain(SObject ref, Map<String, List<String>> mapDomainAndProcessorCustIdList){
        String domain = '';
        String website = (String)ref.get('Website');
        if (String.isNotBlank(website)) {
            domain = website.replaceAll('https://', '').replaceAll('http://', '').replaceAll('www.', '').replaceAll('products.', '');
            if(domain.contains('/')) {domain = domain.left(domain.indexOf('/'));}
            domain = domain.trim();
        }
        if(mapDomainAndProcessorCustIdList.containsKey(domain)) {
            for(String refId : mapDomainAndProcessorCustIdList.get(domain)) {
                if(!mapStrCustIdAndSFRecord.containsKey(refId) || (suggestedMatchPriorityMap.containsKey(refId) && suggestedMatchPriorityMap.get(refId) >2 )) {
                    mapStrCustIdAndSFRecord.put(refId, new RecordMatchWrapper(ref));
                    mapProcessorCustIdAndDefaultAction.put(refId, ProcessorUtil.CMO_SUGGESTED_MATCH);
                    suggestedMatchPriorityMap.put(refId, 2);
                }
            }
        }
    }
    public void matchByPhone(SObject ref, Map<String, List<String>> mapPhoneAndProcessorCustIdList){
        String phone = (String)ref.get('Phone');
        phone = String.isNotBlank(phone) ? phone.replaceAll('[^0-9]', '') : '';
        if(String.isNotBlank(phone) && mapPhoneAndProcessorCustIdList.containsKey(phone)) {
            for(String refId : mapPhoneAndProcessorCustIdList.get(phone)) {
                if(!mapStrCustIdAndSFRecord.containsKey(refId) || (suggestedMatchPriorityMap.containsKey(refId) && suggestedMatchPriorityMap.get(refId) >3 )) {
                    mapStrCustIdAndSFRecord.put(refId, new RecordMatchWrapper(ref));
                    mapProcessorCustIdAndDefaultAction.put(refId, ProcessorUtil.CMO_SUGGESTED_MATCH);
                    suggestedMatchPriorityMap.put(refId, 3);
                }
            }
        }
    }
    public void matchByAddress(SObject ref, Map<String, List<String>> mapStreetAddrAndProcessorCustIdList){
        Map<String, Object> sfRecord = ref != NULL ? ref.getPopulatedFieldsAsMap() : new Map<String, Object>();
        String street = sfRecord.containsKey('BillingStreet') ? (String)sfRecord.get('BillingStreet') : sfRecord.containsKey('MailingStreet') ? (String)sfRecord.get('MailingStreet') : '';
        street = String.isNotBlank(street) ? street.toLowerCase() : '';
        if(String.isNotBlank(street) && mapStreetAddrAndProcessorCustIdList.containsKey(street.replace('\\','%'))) {
            for(String refId : mapStreetAddrAndProcessorCustIdList.get(street.replace('\\','%'))) {
                if(!mapStrCustIdAndSFRecord.containsKey(refId)) {
                    mapStrCustIdAndSFRecord.put(refId, new RecordMatchWrapper(ref));
                    mapProcessorCustIdAndDefaultAction.put(refId, ProcessorUtil.CMO_SUGGESTED_MATCH);
                    suggestedMatchPriorityMap.put(refId, 4);
                }
            }
        }
    }

    public SObject getObjectWrapper(String syncObject, RecordMatchWrapper aw){
        SObject sObj;
        if(syncObject == ProcessorUtil.CMT_ACCOUNT){
            Account account = new Account();
            if( areRecordTypesEnabled && !isDefaultRecordTypeMaster ){
                String accDefaultRecordType = ProcessorUtil.getDefaultAccountRecordType();
                ID chosenRecordTypeId = String.isNotBlank(accDefaultRecordType) ? (ID)accDefaultRecordType : '';
                if(String.isNotBlank(chosenRecordTypeId)) account.put('RecordTypeId', ''+chosenRecordTypeId);
                if(ProcessorUtil.getIsPersonRecordType(chosenRecordTypeId)){
                    account.put('LastName',aw.name);
                }
                else{
                    account.Name = aw.name;
                }
            }
            else{
                account.Name = aw.name;
            }
            account.id = aw.id;
            account.Phone = aw.phone;
            account.BillingStreet = aw.billingStreet;
            account.BillingCity = aw.billingCity;
            account.BillingState = aw.billingState;
            account.BillingCountry = aw.billingCountry;
            account.BillingPostalCode = aw.billingPostalCode;
            sObj = account;
        }
        if(syncObject == ProcessorUtil.CMT_CONTACT){
            Contact contact = new Contact();
            contact.id = aw.id;
            contact.LastName = aw.lastName != null ? aw.lastName : aw.firstName != null ? aw.firstName : aw.name;
            contact.FirstName = contact.LastName != aw.firstName ? aw.firstName : '';
            contact.Phone = aw.phone;
            contact.Email = aw.emailAddress;
            contact.MailingStreet = aw.billingStreet;
            contact.MailingCity = aw.billingCity;
            contact.MailingState = aw.billingState;
            contact.MailingCountry = aw.billingCountry;
            contact.MailingPostalCode = aw.billingPostalCode;
            sObj = contact;
        }
        return sObj;
    }

    // Used to Store Account or Contact record values
    public class RecordMatchWrapper{
        public Boolean isPerson {get;set;}
        public String salutation {get;set;}
        public String name {get;set;}
        public String firstName {get;set;}
        public String LastName {get;set;}
        public String jobTitle {get;set;}
        public String companyName {get;set;}
        public String phone {get;set;}
        public String website {get;set;}
        public String emailAddress {get;set;}
        public String billingStreet{get;set;}
        public String billingCity {get;set;}
        public String billingState {get;set;}
        public String billingCountry {get;set;}
        public String billingPostalCode {get;set;}
        public String customerId {get;set;}
        public String id;
        public Boolean isUnableToCreateAccount{
            get{
                return (isUnableToCreateAccount != Null) && (isUnableToCreateAccount);
            }
            set;
        }
        public String errorMessage {get; set;}

        public RecordMatchWrapper(){}

        public RecordMatchWrapper(BWP_Customer__c cust){
            this.isPerson = False;
            this.name = cust.Customer_Name__c;
            this.firstName = cust.First_Name__c;
            this.LastName = cust.Last_Name__c ;
            this.customerId = cust.Processor_Customer_Id__c;
            this.companyName = cust.Processor_Org_Name__c;
            this.phone= cust.Customer_Phone__c;
            this.emailAddress = cust.Email__c;
            String street =String.isNotBlank(cust.Billing_Street_Address_1__c) ? cust.Billing_Street_Address_1__c+' ' : '';
            street += String.isNotBlank(cust.Billing_Street_Address_2__c) ? cust.Billing_Street_Address_2__c : '';
            this.billingStreet = street;
            this.billingCity = cust.Billing_City__c;
            this.billingState= cust.Billing_State__c;
            this.billingCountry = cust.Billing_Country__c;
            this.billingPostalCode= cust.Billing_Postal_Code__c;
        }

        public RecordMatchWrapper(SObject sfRec){
            Map<String, Object> sfRecord = sfRec != NULL ? sfRec.getPopulatedFieldsAsMap() : new Map<String, Object>();
            this.id = sfRecord.containsKey('Id') ? (ID)sfRecord.get('Id') : NULL;
            this.name = sfRecord.containsKey('Name') ? (String)sfRecord.get('Name') : '';
            this.firstName = sfRecord.containsKey('FirstName') ? (String)sfRecord.get('FirstName') : '';
            this.LastName = sfRecord.containsKey('LastName') ? (String)sfRecord.get('LastName') : '';
            this.website = sfRecord.containsKey('Website') ? (String)sfRecord.get('Website') : '';
            this.phone = sfRecord.containsKey('Phone') ? (String)sfRecord.get('Phone') : '';
            this.emailAddress = sfRecord.containsKey('Email') ? (String)sfRecord.get('Email') : '';
            this.billingStreet = sfRecord.containsKey('BillingStreet') ? (String)sfRecord.get('BillingStreet') : sfRecord.containsKey('MailingStreet') ? (String)sfRecord.get('MailingStreet') : '';
            this.billingCity = sfRecord.containsKey('BillingCity') ? (String)sfRecord.get('BillingCity') : sfRecord.containsKey('MailingCity') ? (String)sfRecord.get('MailingCity') : '';
            this.billingState = sfRecord.containsKey('BillingState') ? (String)sfRecord.get('BillingState') : sfRecord.containsKey('MailingState') ? (String)sfRecord.get('MailingState') : '';
            this.billingCountry = sfRecord.containsKey('BillingCountry') ? (String)sfRecord.get('BillingCountry') : sfRecord.containsKey('MailingCountry') ? (String)sfRecord.get('MailingCountry') : '';
            this.billingPostalCode = sfRecord.containsKey('BillingPostalCode') ? (String)sfRecord.get('BillingPostalCode') : sfRecord.containsKey('MailingPostalCode') ? (String)sfRecord.get('MailingPostalCode') : '';
        }
    }
    
}