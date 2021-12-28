public class RecordCreationExtension {

    Selector_Account selectorAccount = new Selector_Account();
    Selector_Contact selectorContact = new Selector_Contact();
    Selector_BWP_Customer selectorCustomer = new Selector_BWP_Customer();
    Selector_BWP_Payment_Method selectorPaymentMethod = new Selector_BWP_Payment_Method();
    Selector_BWP_Transaction selectorTransaction = new Selector_BWP_Transaction();

    // New Customer, Transaction and Payment Method Page variables, to help identify next step/redirection
    public static final String CUST_FROM_TRANSACTION = 'customerPageFromNewTransaction';
    public static final String PAYMETHOD_FROM_TRANSACTION = 'paymentMethodPageFromNewTransaction';
    public static final String CUST_FROM_PAYMETHOD = 'customerPageFromNewPayMethod';
    public static final String NEW_PAYMETHOD = 'isCreatePayMethodPage';
    
    // Varibales to identify current running page
    public static final String PG_CUSTOMER = 'Customer';
    public static final String PG_PAYMENTMETHOD = 'Payment Method';
    public static final String PG_TRANSACTION = 'Transaction';
    
    public String PMType                                        {get; set;}
    public Boolean ShowTokenSetion                              {get; set;}
    public Boolean cardPanel                          		    {get; set;}
    public Boolean bankPanel                     				{get; set;}
    public String PMTokenValue                                  {get; set;}
    public String PMErrorValue                                  {get; set;}
    public Boolean doNotAddPM                                   {get; set;}
    
    public Boolean customerPage                                 {get; set;}
    public Boolean paymentMethodPage                            {get; set;}
    public Boolean transactionPage                              {get; set;}
    public BWP_Customer__c  newCustomer                         {get; set;}
    public BWP_Processor_Config__c payConfig                    {get; set;}
    public List<SelectOption> listOfPaymentMethods              {get; set;}
    
    // Custom Guided Wizard Variables
    private Map<String, String> currentpageParams;
    private Boolean isCustomURL;
    private String parentId;
    private String orgObjFieldOnTxn;
    private List<String> cURLParamsList = new List<String> {'originating_record', 'parent_id', 'payment_amount', 'payment_currency', 'payment_description'};
    private String cPageParams = '';
    public String testingPage                                                     {get; private set;}
    public sObject sObj                                                           {get; private set;}    
    public String parentField                                                     {get; private set;}
    public String paymentAmountField                                              {get; private set;}
    public String paymentCurrencyField                                            {get; private set;}
    public String paymentDescriptionField                                         {get; private set;}
    public String originatingObjName                                              {get; private set;}
    public Id originatingRecordId;
    private String originatingObjLabel;
    //Custom Guided Wizard Params end 

    public String selectedCon                                                    {get; set;}
    public Boolean initialized                                                   {get; set;}
    public Boolean activeSubscription                                            {get; set;}
    
    public List<SelectOption> TaxStatus{
        get{
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('none','Taxable'));
            options.add(new SelectOption('exempt','Exempt'));
            options.add(new SelectOption('reverse','Reverse Charge'));
            return options;
        }
        private set;
    }

    public static List<SelectOption> PaymentMethodOptions{
        get{
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption(ProcessorUtil.PM_Card,'Card'));
            options.add(new SelectOption(ProcessorUtil.PM_Bank,'Bank Account'));
            return options;
        }
        private set;
    }

    public String PageException                                                    {get; set;}
    
    public String selectedRecordId                                                  {get; private set;}    //useful to retrieve related Customers of a selected Account/Contact
    public Boolean notInitializedWithAccount                                        {get; set;}
    public boolean unMatchedAccount                                                 {get; set;}
    
    // New Transaction related Fields
    public BWP_Transaction__c newTransaction 										{get; set;}
    public BWP_Payment_Method__c newPayMethod 									    {get; set;}
    public Account selectedAccount													{get; set;}
    public Contact selectedContact													{get; set;}
    public String selectedBWPCustomer												{get; set;}
    public String createdPayMethodId												{get; set;}
    public List<SelectOption> allPaymentsMethodsList                                {get; set;}
    public String selectedPaymentMethod                           					{get; set;}
    public String errorMessage														{get; set;}
    public String defaultSelection {
        get{
            if(selectedAccount != null && selectedAccount.BWP_Customers__r != null && selectedAccount.BWP_Customers__r.size()>0){
                return selectedAccount.BWP_Customers__r[0].Processor_Customer_Id__c;
            }
            else if(selectedContact != null && selectedContact.BWP_Customers__r != null && selectedContact.BWP_Customers__r.size()>0){
                return selectedContact.BWP_Customers__r[0].Processor_Customer_Id__c;
            }
            else {
                return 'createNewBWPCustomer';
            }
        }
        private set;
    }

    private Map<String, BWP_Payment_Method__c> paymentMethodsMap;
    public Boolean isCreateCustomerPage												{get; set;}
    public Boolean isCreatePayMethodPage                                            {get; set;}
    public Boolean newCustomerPageFromTransaction									{get; set;}
    public Boolean newCustomerPageFromPaymentMethod                                 {get; set;}
    public Boolean newPaymentMethodPageFromTransaction								{get; set;}
    public Boolean paymentMethodFromNewPaymentMethodPage                            {get; set;}
    public Boolean isCustomerCreated												{get; set;}
    public Boolean isCustomerSelected												{get; set;}
    public Boolean isPaymentMethodCreated											{get; set;}
    public Boolean isBankAccountCreated												{get; set;}
    public Boolean isBankAccountVerified											{get; set;}
    public Decimal firstDeposit                                  					{get; set;}
    public Decimal secondDeposit                                 					{get; set;}
    public Boolean isPaymentMethodSelected											{get; set;}
    public BWP_Customer__c customerInfo 											{get; set;}
    public BWP_Payment_Method__c paymentMethodInfo                                  {get; set;}
    /* Bank Payment Method Fields */
    public String bankPMCountry                                                     {get; set;}
    public String bankPMCurrency                                                    {get; set;}
    public String bankPMAccountHolderName                                           {get; set;}
    public String bankPMAccountHolderType                                           {get; set;}
    public String bankPMAccountNumber                                               {get; set;}
    public String bankPMRoutingNumber                                               {get; set;}
    public String bankPMConfirmAccountNumber                                        {get; set;}
    public String bankPMBankAccountType                                             {get; set;}
    public String bankPMBusinessOwnerName                                           {get; set;}
    public String bankPMIndividualOwnerFirstName                                    {get; set;}
    public String bankPMIndividualOwnerLastName                                     {get; set;}
    public Boolean bankPMBusinessName                                               {get; set;}
    public Boolean bankPMIndividualName                                             {get; set;}
    
    public String squareCardErrors										     		{get; set;}
    public String idempotencyKey													{get; set;}
    
    private Breadwinner_Settings__c bwSetting;
    private Map<String, BWP_Processor_Config__c> payConfigMap;

    public String selectedProcessorAccountType                                      {get; set;}
    public List<SelectOption> connectedProcessorsList                               {get; set;}
    public Boolean isProcessorConnected                                             {get; private set;}
    public Boolean isMultiProcessorEnabled                                          {get; set;}
    public String selectedProcessorName                                             {get; set;}
    public String selectedProcessorAccountName                                      {get; set;}
    public Boolean isPaymentFromStandardNewButton                                   {get; set;}
    public Boolean isPayMethodFromStandardNewButton                                 {get; set;}
    public Boolean isBreadwinnerAdministrator                                       {get; private set;}
    public Boolean isBreadwinnerReadOnlyMode                                        {get; private set;}
    public Boolean hasMultiplePmTypes												{get; set;}
    // Card Input Fields
    public String cardNumber                                                         {get; set;}
    public String cardHolderName                                                     {get; set;}
    public String cardExpiryMonth                                                    {get; set;}
    public String cardExpiryYear                                                     {get; set;}
    public String cardCVC                                                            {get; set;}
    public String cardStreetLine1                                                    {get; set;}
    public String cardStreetLine2                                                    {get; set;}
    public String cardCity                                                           {get; set;}
    public String cardState                                                          {get; set;}
    public String cardPostalCode                                                     {get; set;}
    public String cardCountry                                                        {get; set;}

    public String cardCreationKey                                                    {get; set;}
    public decimal chargeTaxAmount                                                  {get; set;}
    public Boolean chargeIsTaxExempt                                                {get; set;}
    public Boolean isBankAuthAccepted                                               {get; set;}
    public String authorizeBankMessage                                              {get; set;}
    public Boolean isChargeSuccess;
    public String customerMatchType                                                 {get; set;}
    public String selectedObject                                                 	{get; set;}
    public RecordCreationExtension(ApexPages.StandardController controller) {
        isBreadwinnerAdministrator = BreadwinnerUtil.isBreadwinnerAdministrator();
        List<BWP_Processor_Config__c> payConfigList = BreadwinnerUtil.processorConfigList;
        isCreateCustomerPage = false;
        isCreatePayMethodPage = false;
        paymentMethodPage  = false;
        transactionPage = false;
        customerPage = true;
        isCustomURL = false;
        testingPage = 'false';
        // Card Input Fields
        cardNumber = '';
        cardHolderName = '';
        cardExpiryMonth = '';
        cardExpiryYear = '';
        cardCVC = '';
        cardStreetLine1 = '';
        cardStreetLine2 = '';
        cardCity = '';
        cardState = '';
        cardPostalCode = '';
        cardCountry = '';
        isChargeSuccess = false;
        isBankAuthAccepted = false;
        hasMultiplePmTypes = false;
        authorizeBankMessage = '';
        isPaymentFromStandardNewButton = false;
        isProcessorConnected = true;
        if(payConfigList.isEmpty()){
            isProcessorConnected = false;
            errorMessage = 'Please connect to a Payment Processor from the setup section of Breadwinner tab.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,' '+errorMessage));
            return;
        }
        String pageName = ApexPages.currentPage().getUrl().split('apex/')[1];
        isCreateCustomerPage = pageName.containsIgnoreCase('CreateCustomer');
        isCreatePayMethodPage = pageName.containsIgnoreCase('CreatePaymentMethod');
        payConfig = payConfigList[0];
        selectedProcessorName = String.isNotBlank(payConfig.Name) ? payConfig.Name : '';
        selectedProcessorAccountName = String.isNotBlank(payConfig.Account_Name__c) ? payConfig.Account_Name__c : '';
        selectedProcessorAccountType = String.isNotBlank(payConfig.Payment_Processor_Type__c) ? payConfig.Payment_Processor_Type__c : '';
        bwSetting =  BreadwinnerUtil.getBWSetting();
        isBreadwinnerReadOnlyMode = bwSetting.Read_Only_Mode__c;
        hasMultiplePmTypes = hasMultiplePmTypes(selectedProcessorAccountType);
        system.debug('page name------'+pageName);
        if(isCreateCustomerPage){
            newCustomer = (BWP_Customer__c)controller.getRecord();
            selectedObject = newCustomer.Salesforce_Account__c != null ? ProcessorUtil.CMT_ACCOUNT : newCustomer.Salesforce_Contact__c != null ? ProcessorUtil.CMT_CONTACT : '';
            newCustomerPageFromTransaction = pageName.containsIgnoreCase(CUST_FROM_TRANSACTION);
            newPaymentMethodPageFromTransaction = pageName.containsIgnoreCase(PAYMETHOD_FROM_TRANSACTION);
            newCustomerPageFromPaymentMethod = pageName.containsIgnoreCase(CUST_FROM_PAYMETHOD);
            paymentMethodFromNewPaymentMethodPage = pageName.containsIgnoreCase(NEW_PAYMETHOD);
            if(newCustomerPageFromTransaction || newCustomerPageFromPaymentMethod){
                customerPage = true;
            }
            else if(newPaymentMethodPageFromTransaction || paymentMethodFromNewPaymentMethodPage){
                customerPage = false;
                paymentMethodPage = true;
                selectedBWPCustomer = String.isNotBlank(ApexPages.currentPage().getParameters().get('selectedBWPCustomer')) ? (ApexPages.currentPage().getParameters().get('selectedBWPCustomer')) : '';
                selectedProcessorName = String.isNotBlank(ApexPages.currentPage().getParameters().get('processorName')) ? (ApexPages.currentPage().getParameters().get('processorName')) : '';
                payConfig = BreadwinnerUtil.getProcessorConfig(selectedProcessorName);
                customerInfo = queryCustomerInfo(selectedBWPCustomer);
                hasMultiplePmTypes = hasMultiplePmTypes(customerInfo.Processor_Type__c);
                authorizeBankMessage = authorizeBankMessage(customerInfo);
                if(customerInfo.Processor_Type__c ==  ProcessorUtil.PAT_SQUARE)
                    cardCreationKey = Processor_Square.getClientId(payConfig.Live_Mode__c == True ? 'live' : 'test');
                else if(customerInfo.Processor_Type__c ==  ProcessorUtil.PAT_STRIPE || customerInfo.Processor_Type__c ==  ProcessorUtil.PAT_BRAINTREE)
                    cardCreationKey = String.isNotBlank(payConfig.Card_Creation_Key__c) ? (payConfig.Card_Creation_Key__c) : '';
                
            }
        }
        else if(isCreatePayMethodPage){
            newPayMethod = (BWP_Payment_Method__c)controller.getRecord();
            selectedObject = newPayMethod.Salesforce_Account__c != null ? ProcessorUtil.CMT_ACCOUNT : newPayMethod.Salesforce_Contact__c != null ? ProcessorUtil.CMT_CONTACT : '';
            newCustomer = new BWP_Customer__c();
        }
        else{
            newTransaction = (BWP_Transaction__c)controller.getRecord();
            selectedObject = newTransaction.Salesforce_Account__c != null ? ProcessorUtil.CMT_ACCOUNT : newTransaction.Salesforce_Contact__c != null ? ProcessorUtil.CMT_CONTACT : '';
            newCustomer = new BWP_Customer__c();
        }
        notInitializedWithAccount = false;
        connectedProcessorsList = new List<SelectOption>();
        isMultiProcessorEnabled = bwSetting.Multi_Processor_Enabled__c;
        listOfPaymentMethods = new List<SelectOption>();
        isCustomerCreated = false;
        isCustomerSelected = false;
        isPaymentMethodCreated = false;
        isPaymentMethodSelected = false;
        isBankAccountCreated = false;
        isBankAccountVerified = false;
        createdPayMethodId = '';
        firstDeposit = 0;
        secondDeposit = 0;
        payConfigMap = new Map<String, BWP_Processor_Config__c>();
        paymentMethodInfo = new BWP_Payment_Method__c();
        for(BWP_Processor_Config__c config : payConfigList){
            if(String.isNotBlank(config.Customer_Match_Type__c)){
                customerMatchType = config.Customer_Match_Type__c;
            }
            payConfigMap.put(config.Provider_ID__c, config);
            connectedProcessorsList.add(new SelectOption(config.Provider_ID__c, config.Payment_Processor_Type__c+' - '+(String.isNotBlank(config.Account_Name__c) ? config.Account_Name__c : config.Provider_ID__c)));
        }           
        selectedObject = String.isNotBlank(selectedObject) ? selectedObject : String.isNotBlank(customerMatchType) ? customerMatchType : ProcessorUtil.CMT_ACCOUNT;
        customerMatchType = String.isNotBlank(customerMatchType) ? customerMatchType : selectedObject;
        currentPageParams = ApexPages.currentPage().getParameters();
        orgObjFieldOnTxn = '';
        if(isCreateCustomerPage){
            customerMatchTypeError(PG_CUSTOMER, selectedObject, customerMatchType);
            newTransaction = new BWP_Transaction__c();
            newTransaction.Amount__c = 0;
            if(currentPageParams.containsKey('originating_record') && currentPageParams.containsKey('parent_id')) {
                isCustomURL = TRUE;
                handleCustomURL();
            }
            newPayMethod = new BWP_Payment_Method__c();
            ShowTokenSetion = true;
            cardPanel = true;
            bankPanel = false;
            PMType = ProcessorUtil.PM_CARD;
            PageException = '';
            unMatchedAccount = false;
            doNotAddPM = false;
            bankPMCountry = 'US';
            bankPMCurrency = 'USD';
            bankPMAccountHolderName = '';
            bankPMAccountHolderType = '';
            bankPMAccountNumber = '';
            bankPMRoutingNumber = '';
            bankPMBusinessOwnerName = '';
            bankPMBankAccountType = 'checking';
            bankPMIndividualOwnerFirstName = '';
            bankPMIndividualOwnerLastName = '';
            bankPMBusinessName = true;
            bankPMIndividualName = false;
            errorMessage = '';
            squareCardErrors = '';
            idempotencyKey = '';
            getSelectedRecordId(newCustomer.Salesforce_Account__c, newCustomer.Salesforce_Contact__c, getCurrentPageRecordId());
            querySelectedobject(selectedRecordId);            
            if(String.isBlank(selectedRecordId)){
                notInitializedWithAccount = true;
            }
        }
        else if(isCreatePayMethodPage){
            isPayMethodFromStandardNewButton = false;
            selectedBWPCustomer = String.isNotBlank(defaultSelection) ? defaultSelection : '';
            paymentMethodsMap = new Map<String, BWP_Payment_Method__c>();
            getSelectedRecordId(newPayMethod.Salesforce_Account__c, newPayMethod.Salesforce_Contact__c, getCurrentPageRecordId());
            querySelectedobject(selectedRecordId);
            if(String.isBlank(selectedRecordId)){
                isPayMethodFromStandardNewButton = true;
            }
            customerMatchTypeError(PG_PAYMENTMETHOD, selectedObject, customerMatchType);
        }
        else{
            selectedBWPCustomer = String.isNotBlank(defaultSelection) ? defaultSelection : '';
            paymentMethodsMap = new Map<String, BWP_Payment_Method__c>();
            if(currentPageParams.containsKey('originating_record') && currentPageParams.containsKey('parent_id')) {
                if(currentPageParams.containsKey('testing')) testingPage = currentPageParams.get('testing');
                isCustomURL = TRUE;
                handleCustomURL();
            }          
            getSelectedRecordId(newTransaction.Salesforce_Account__c, newTransaction.Salesforce_Contact__c, getCurrentPageRecordId());
            querySelectedobject(selectedRecordId);
            if(String.isBlank(selectedRecordId)){
                isPaymentFromStandardNewButton = true;
            }
            customerMatchTypeError(PG_TRANSACTION, selectedObject, customerMatchType);
        }
    }
    public void handleCustomURL(){
        List<Schema.SObjectField> sObjectFieldsList = new List<Schema.SObjectField>();
        originatingRecordId = currentpageParams.get('originating_record').replace('/','').trim();
        Schema.SObjectType sobjectType = originatingRecordId.getSObjectType();
        originatingObjName = sobjectType.getDescribe().getName();
        originatingObjLabel = sobjectType.getDescribe().getLabel();
        Map<String, SObjectField> fieldMap = sobjectType.getDescribe().fields.getMap();
        sObjectFieldsList.add(fieldMap.get('Name'));
        for(String paramName : cURLParamsList){
            String fieldReference = currentPageParams.get(paramName);
            cPageParams += '&'+paramName+ '=' +fieldReference;
            if(paramName != 'originating_record' && String.isNotBlank(fieldReference)) {
                fieldReference = fieldReference.toLowerCase().trim();
                SobjectField sObjField = fieldMap.get(fieldReference);
                sObjectFieldsList.add(sObjField);
            }
        }

        QueryBuilder qb = new QueryBuilder(sobjectType, true, true, true);
        qb.addSObjectFields(sObjectFieldsList);
        String whereStr = 'id =\''+originatingRecordId+'\'';
        qb.setCondition(whereStr);
        List<SObject> sObjList = Database.query(qb.toSOQL());
        sObj = sObjList[0];

        SObjectType schemaType = Schema.getGlobalDescribe().get(newTransaction.getSObjectType().getDescribe().getName());
        Map<String, SObjectField> txnFields = schemaType.getDescribe().fields.getMap();
        for(Schema.SObjectField sfield : txnFields.values()) {
            Schema.DescribeFieldResult dfield = sfield.getDescribe();
            if(dfield.getType() == Schema.DisplayType.REFERENCE) {
                if(String.valueof(dfield.getReferenceTo()).replace('(','').replace(')','') == originatingObjName) orgObjFieldOnTxn = dfield.getName();
            }
        }
        
        parentField = currentPageParams.get('parent_id');
        paymentAmountField = currentPageParams.get('payment_amount');
        paymentCurrencyField = currentPageParams.get('payment_currency');
        paymentDescriptionField = currentPageParams.get('payment_description');

        parentId = (String)sObj.get(parentField);
        if(parentId.startsWith('001') && customerMatchType == ProcessorUtil.CMT_ACCOUNT){
            newTransaction.Salesforce_Account__c = (Id)parentId;
        }
        else if(parentId.startsWith('003') && customerMatchType == ProcessorUtil.CMT_CONTACT){
            newTransaction.Salesforce_Contact__c = (Id)parentId;
        }

        newTransaction.Amount__c = String.isNotBlank(paymentAmountField) && Sobj.get(paymentAmountField)!=NULL ? (Decimal)sObj?.get(paymentAmountField) : 0;
        newTransaction.Description__c = String.isNotBlank(paymentDescriptionField) && Sobj.get(paymentDescriptionField)!=NULL ? (String)sObj?.get(paymentDescriptionField) : '';
        newTransaction.Currency__c = String.isNotBlank(paymentCurrencyField) && Sobj.get(paymentCurrencyField)!=NULL ? ((String)sObj?.get(paymentCurrencyField)).toLowerCase().trim() : '';
    }
    public static String getCurrentPageRecordId(){
        return (String.isNotBlank(ApexPages.currentPage().getParameters().get('recordId')) ? ApexPages.currentPage().getParameters().get('recordId') : '');
    }
    public void getSelectedRecordId(String accountId, String contactId, String recordId){
        selectedRecordId = (String.isNotBlank(accountId) ? accountId : ((String.isNotBlank(contactId) ? contactId : (recordId != null ? recordId : ''))));
    }
    public void querySelectedobject(String selectedRecordId){
        if(String.isNotBlank(selectedRecordId)){
            if(selectedRecordId.startsWith('001') && customerMatchType == ProcessorUtil.CMT_ACCOUNT){
                querySelectedAccount(selectedRecordId); 
            }
            else if(selectedRecordId.startsWith('003') && customerMatchType == ProcessorUtil.CMT_CONTACT){
                querySelectedContact(selectedRecordId);
            }
        }
    }
    public void standardNewPaymentButtonToCreateNewCustomer(){
        isPaymentFromStandardNewButton = false;
        system.debug('isPaymentFromStandardNewButton-----'+isPaymentFromStandardNewButton);
    }
    public void standardNewPayMethodButtonToCreateNewCustomer(){
        isPayMethodFromStandardNewButton = false;
    }
    public void updateOrgDetails(){
        if(String.isNotBlank(selectedProcessorName)){
            payConfig = BreadwinnerUtil.getProcessorConfig(selectedProcessorName);
            selectedProcessorAccountName =  String.isNotBlank(payConfig.Account_Name__c) ? (payConfig.Account_Name__c) : '';
            selectedProcessorAccountType = String.isNotBlank(payConfig.Payment_Processor_Type__c) ? (payConfig.Payment_Processor_Type__c) : '';
        }
    }
    public void querySelectedAccount(String selectedRecordId){

        List<String> appConfigList = new List<String>();
        appConfigList.addAll(payConfigMap.keySet());

        String customerWhere = 'Processor_Org_Id__c IN (\'' + String.join(appConfigList,'\',\'') + '\')';

        selectedAccount = selectorAccount.selectById_WithCustomers(new Set<String>{selectedRecordId},customerWhere)[0];

        selectedBWPCustomer = String.isNotBlank(defaultSelection) ? defaultSelection : '';
        if(selectedAccount != NULL){
            newCustomer.Customer_Name__c = String.isNotBlank(selectedAccount.Name) ? selectedAccount.Name : '';
            newCustomer.Last_Name__c = String.isNotBlank(selectedAccount.Name) ? selectedAccount.Name : '';
            newCustomer.Billing_Street_Address_1__c = String.isNotBlank(selectedAccount.BillingStreet) ? selectedAccount.BillingStreet : '';
            newCustomer.Billing_City__c = String.isNotBlank(selectedAccount.BillingCity) ? selectedAccount.BillingCity : '';
            newCustomer.Billing_State__c = String.isNotBlank(selectedAccount.BillingState) ? selectedAccount.BillingState :'';
            newCustomer.Billing_Country__c = String.isNotBlank(selectedAccount.BillingCountry) ? selectedAccount.BillingCountry : '';
            newCustomer.Billing_Postal_Code__c = String.isNotBlank(selectedAccount.BillingPostalCode) ? selectedAccount.BillingPostalCode : '';
            newCustomer.Salesforce_Account__c = String.isNotBlank(selectedRecordId) ? selectedRecordId : '';
        }
    }

    public void querySelectedContact(String selectedRecordId){
        List<String> appConfigList = new List<String>();
        appConfigList.addAll(payConfigMap.keySet());
        String customerWhere = 'Processor_Org_Id__c IN (\'' + String.join(appConfigList,'\',\'') + '\')';
        selectedContact = selectorContact.selectById_WithCustomers(new Set<String>{selectedRecordId},customerWhere)[0];
        selectedBWPCustomer = String.isNotBlank(defaultSelection) ? defaultSelection : '';
        if(selectedContact != NULL){
            newCustomer.First_Name__c =  String.isNotBlank(selectedContact.FirstName) ? selectedContact.FirstName : ''; 
            newCustomer.Last_Name__c =  String.isNotBlank(selectedContact.LastName) ? selectedContact.LastName : ''; 
            newCustomer.Billing_Street_Address_1__c = String.isNotBlank(selectedContact.MailingStreet) ? selectedContact.MailingStreet : '';
            newCustomer.Billing_City__c = String.isNotBlank(selectedContact.MailingCity) ? selectedContact.MailingCity : '';
            newCustomer.Billing_State__c = String.isNotBlank(selectedContact.MailingState) ? selectedContact.MailingState :'';
            newCustomer.Billing_Country__c = String.isNotBlank(selectedContact.MailingCountry) ? selectedContact.MailingCountry : '';
            newCustomer.Billing_Postal_Code__c = String.isNotBlank(selectedContact.MailingPostalCode) ? selectedContact.MailingPostalCode : '';
            newCustomer.Salesforce_Contact__c = String.isNotBlank(selectedRecordId) ? selectedRecordId : '';
        }
    }
    public BWP_Customer__c queryCustomerInfo(String customerRefId){
        BWP_Customer__c customerInfo = selectorCustomer.selectByProcessorCustomerId(new Set<String>{customerRefId}, 1)[0];
        selectedProcessorAccountType = customerInfo.Processor_Type__c;
        return customerInfo;
    }
    public pagereference redirectToPaymentMethodPage(){
        if(selectedBWPCustomer != 'createNewBWPCustomer'){
            customerPage = false;
            paymentMethodPage = true;
            isCustomerSelected = true;
            listOfPaymentMethods = getListOfPaymentMethods(selectedBWPCustomer);
            customerInfo = selectorCustomer.selectByProcessorCustomerId_WithPaymentMethods(new Set<String>{selectedBWPCustomer},1,50)[0];
            selectedProcessorName = customerInfo.Processor_Org_Id__c;
            if(String.isNotBlank(customerInfo.Default_Source__c)){
                selectedPaymentMethod = customerInfo.Default_Source__c;
            }
            else if(!listOfPaymentMethods.isEmpty()){
            	selectedPaymentMethod = String.ValueOf(listOfPaymentMethods[0].getValue());
            }
            else{
                selectedPaymentMethod = 'createNewBWPPaymentMethod';
            }
            if(String.isNotBlank(selectedPaymentMethod) && paymentMethodsMap.get(selectedPaymentMethod) == null){
                selectedPaymentMethod = 'createNewBWPPaymentMethod';
            }
            if(isCreatePayMethodPage){
                isCustomerSelected = true;
                PageReference pageRef = new PageReference('/apex/CreateCustomer?'+NEW_PAYMETHOD+'=true&testing=false'+(String.isNotBlank(selectedBWPCustomer) ? ('&selectedBWPCustomer='+selectedBWPCustomer) : '')+(String.isNotBlank(selectedProcessorName) ? ('&processorName='+selectedProcessorName) : '')+(isCustomURL ? cPageParams : ''));
                return pageRef;
            }
            system.debug('default source---'+customerInfo.Default_Source__c);
            system.debug('customer related prceossor id-------'+selectedProcessorName);
            //listOfPaymentMethods = getlistOfPaymentMethods(selectedBWPCustomer);
        }
        else if(isCreatePayMethodPage && selectedBWPCustomer == 'createNewBWPCustomer'){
            customerPage = true;
            PageReference pageRef = new PageReference('/apex/CreateCustomer?'+CUST_FROM_PAYMETHOD+'=true'+(String.isNotBlank(selectedRecordId) ? ('&recordId='+selectedRecordId) : '')+(isCustomURL ? cPageParams : ''));
            return pageRef; 
        }
        else{
            customerPage = true;
            PageReference pageRef = new PageReference('/apex/CreateCustomer?'+CUST_FROM_TRANSACTION+'=true'+(String.isNotBlank(selectedRecordId) ? ('&recordId='+selectedRecordId) : '')+(isCustomURL ? cPageParams : ''));
            return pageRef;
        }
        return null;
    } 
    public pagereference redirectToTransactionPage(){
        if(selectedPaymentMethod != 'createNewBWPPaymentMethod'){
            paymentMethodPage = false;
            transactionPage = true;
            isPaymentMethodSelected = true;
            listOfPaymentMethods = getListOfPaymentMethods(selectedBWPCustomer);
            system.debug('selectedPaymentMethod------------'+selectedPaymentMethod);
            paymentMethodInfo = selectorPaymentMethod.selectByProcessorId(selectedPaymentMethod,1)[0];
        }
        else{
            selectedProcessorName = selectorCustomer.selectByProcessorCustomerId(new Set<String>{selectedBWPCustomer},1)[0].Processor_Org_Id__c;
            PageReference pageRef = new PageReference('/apex/CreateCustomer?'+PAYMETHOD_FROM_TRANSACTION+'=true&testing=false'+(String.isNotBlank(selectedBWPCustomer) ? ('&selectedBWPCustomer='+selectedBWPCustomer) : '')+(String.isNotBlank(selectedProcessorName) ? ('&processorName='+selectedProcessorName) : '')+(isCustomURL ? cPageParams : ''));
            return pageRef;
        }
        return null;
    }
    public List<SelectOption> getListOfPaymentMethods(String customerProcessorId){
        List<SelectOption> paymentMethods = new List<SelectOption>();
        paymentMethodsMap = new Map<String, BWP_Payment_Method__c>();
        List<BWP_Payment_Method__c> pmList = selectorPaymentMethod.selectWhere('Customer__r.Processor_Customer_Id__c = \'' + customerProcessorId + '\'');
        for(BWP_Payment_Method__c paymentMethod: pmList){
            if(paymentMethod.Type__c == ProcessorUtil.PM_CARD){
                paymentMethodsMap.put(paymentMethod.Processor_Id__c, paymentMethod);
                paymentMethods.add(new SelectOption(paymentMethod.Processor_Id__c, paymentMethod.Card_Brand__c+'  ....'+PaymentMethod.Last_4_digits__c+'  '+PaymentMethod.Expiry_Month__c+'/'+PaymentMethod.Expiry_Year__c));
            }
            else if(paymentMethod.Type__c == ProcessorUtil.PM_BANK && paymentMethod.Card_Status__c == 'Verified'){
                paymentMethodsMap.put(paymentMethod.Processor_Id__c, paymentMethod);
                paymentMethods.add(new SelectOption(paymentMethod.Processor_Id__c, paymentMethod.Bank_Name__c+ '   ' + '••••' + paymentMethod.Last_4_digits__c ));
            }
        }
        return paymentMethods;
    }
    public void updateSelectedPaymentMethodDetails(){
        paymentMethodInfo = selectorPaymentMethod.selectByProcessorId(selectedPaymentMethod, 1)[0];
    }
    public pageReference chargeCustomer(){
        try{
            ProcessorUtil.originatingObjFieldToIdMap = new Map<String, Id>(); // Map of originating object field API name to value
            payConfig = BreadwinnerUtil.getProcessorConfig(selectedProcessorName);
            Map<String,Object> request = new Map<String,Object>();
            Map<String,Object> response = new Map<String,Object>();
            request.put(ProcessorUtil.API_ACTION, ProcessorUtil.ACT_CHARGE_PROCESSOR);
            request.put(ProcessorUtil.API_VERSION, ProcessorUtil.VER_1);
            request.put(ProcessorUtil.API_PROCESSOR_ID,payConfig.Provider_ID__c);

            if(newTransaction.Amount__c == null || newTransaction.Amount__c <= 0){
                errorMessage = ' Amount must be greater than 0.';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));
                return null;
            }
            if(String.isNotBlank(orgObjFieldOnTxn)) {
                ProcessorUtil.originatingObjFieldToIdMap.put(orgObjFieldOnTxn,originatingRecordId);
            }
            BWP_Payment_Method__c payMethodInfo = String.isNotBlank(selectedPaymentMethod) ? paymentMethodsMap.get(selectedPaymentMethod) : new BWP_Payment_Method__c();
            chargeInfo chargeInfo = new chargeInfo(payMethodInfo.Processor_Customer_Id__c, payMethodInfo.Processor_Id__c, payMethodInfo.Type__c, newTransaction.Amount__c, newTransaction.Currency__c, newTransaction.Description__c, chargeIsTaxExempt, chargeTaxAmount, idempotencyKey);
            if(customerInfo.Processor_Type__c == ProcessorUtil.PAT_STRIPE){
                if(String.isNotBlank(newTransaction.Description__c) && newTransaction.Description__c.length()>=1000){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' Description must be at most 1000 characters'));
                }
                if (ApexPages.hasMessages(ApexPages.Severity.ERROR)){
                    return null;
                }
                response = chargeCustomer_Stripe(request, chargeInfo);
            }
            else if(customerInfo.Processor_Type__c == ProcessorUtil.PAT_BRAINTREE){
                response = chargeCustomer_Braintree(request, chargeInfo);
            }
            else if(customerInfo.Processor_Type__c == ProcessorUtil.PAT_SQUARE){
                response = chargeCustomer_Square(request, chargeInfo);
            }
            isChargeSuccess = ProcessorUtil.isValidResponse(response);
            if(isChargeSuccess){
                APICallHandler.userInteractionLogPush(FALSE, 'Payment Created', ((String.isNotBlank(originatingObjName) && String.isNotBlank(originatingObjLabel)) ? (originatingObjLabel + ' (' + originatingObjName + ')') : (String.isNotBlank(selectedRecordId) ? customerMatchType : 'BWP Customer')), 'A new '+customerInfo.Processor_Type__c+' Payment is created from Breadwinner Payments');
                List<ProcessorUtil.TransactionWrapper> transactionResp = (List<ProcessorUtil.TransactionWrapper>) response.get(ProcessorUtil.PAYMENT_RESP);
                BWP_Transaction__c newTransaction = selectorTransaction.selectByProcessorId(new Set<String>{transactionResp[0].processorId}, null)[0];
				return new PageReference('/' + newTransaction.Id);
            }
            else{
                processResponseFailure(response);
            }
        } catch(Exception e){
            System.debug('Exception'+e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' '+e.getMessage()));
            APICallHandler.userInteractionLogPush(false, 'Create Payment', 'ERROR', 'Exception: '+e.getMessage());
        }
        return null;    
    }
    public static Map<String,Object> chargeCustomer_Stripe(Map<String,Object> request, chargeInfo chargeInfo){
        Charge.StripeCharge ch = new Charge.StripeCharge();
        ch.amount = chargeInfo.amount > 0 ? chargeInfo.amount : 0;
        ch.customer = chargeInfo.customerId;
        ch.stripe_currency = string.isNotBlank(chargeInfo.chargeCurrency) ? chargeInfo.chargeCurrency : '';
        ch.description = chargeInfo.description;
        ch.paymentMethod = chargeInfo.payMethodId;
        ch.paymentMethodType = chargeInfo.payMethodType;
        Map<String, List<Charge.StripeCharge>> chargeMap = new Map<String, List<Charge.StripeCharge>>();
        chargeMap.put('charge', new List<Charge.StripeCharge>{ch});
        
        request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(chargeMap));
        System.debug('ChargeCustomer request: ' + request);
        
        Map<String, Object> response =  BreadwinnerPaymentsAPI.call(request);
        System.debug('ChargeCustomer response: ' + response);
                
        return response;
    }
    public static Map<String,Object> chargeCustomer_Braintree(Map<String,Object> request, chargeInfo chargeInfo){
        Charge.BraintreeCharge ch = new Charge.BraintreeCharge();
        Charge.Amount amount = new Charge.Amount();  
        amount.value = String.valueOf(chargeInfo.amount);
        ch.amount = amount;
        Charge.Customer customer = new Charge.Customer(); 
        customer.id = chargeInfo.customerId;
        ch.customer = customer;
        Charge.PaymentMethod paymentMethod = new Charge.PaymentMethod(); 
        paymentMethod.id = chargeInfo.payMethodId;
        ch.paymentMethod = paymentMethod;
        Charge.TransactionTaxInput transactionTaxInput = new Charge.TransactionTaxInput(); 
        Charge.Amount taxAmount = new Charge.Amount();  
        taxAmount.value = String.valueOf(chargeInfo.taxAmount);
        transactionTaxInput.taxAmount =  taxAmount;
        transactionTaxInput.taxExempt = chargeInfo.isChargeExept;
        ch.transactionTaxInput = transactionTaxInput;
        Map<String, List<Charge.BraintreeCharge>> chargeMap = new Map<String, List<Charge.BraintreeCharge>>();
        chargeMap.put('charge', new List<Charge.BraintreeCharge>{ch});
        
        request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(chargeMap));
        
        System.debug('ChargeCustomer request: ' + request);
        Map<String, Object> response =  BreadwinnerPaymentsAPI.call(request);
        System.debug('ChargeCustomer response: ' + response);
        
        return response;
    }
    public static Map<String,Object> chargeCustomer_Square(Map<String,Object> request, chargeInfo chargeInfo){
        Charge.SquareCharge ch = new Charge.SquareCharge();
        Charge.Money money = new Charge.Money();
        money.amount =  chargeInfo.amount > 0 ? chargeInfo.amount*100 : 0;
        money.square_currency = string.isNotBlank(chargeInfo.chargeCurrency) ? chargeInfo.chargeCurrency.toUppercase() : '';
        ch.amount_money = money;
        ch.customer_id = chargeInfo.customerId;
        ch.source_id = chargeInfo.payMethodId;
        ch.idempotency_key = chargeInfo.keyValue;
        
        Map<String, List<Charge.SquareCharge>> chargeMap = new Map<String, List<Charge.SquareCharge>>();
        chargeMap.put('charge', new List<Charge.SquareCharge>{ch});
        
        request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(chargeMap));
        System.debug('ChargeCustomer request: ' + request);
        
        Map<String, Object> response =  BreadwinnerPaymentsAPI.call(request);
        System.debug('ChargeCustomer response: ' + response);
                
        return response;
    }
    
    public pageReference createCustomer(){
        try{
            Map<String,Object> request = new Map<String,Object>();
            request.put(ProcessorUtil.API_ACTION,ProcessorUtil.ACT_CREATE_CUSTOMER);
            request.put(ProcessorUtil.API_VERSION, ProcessorUtil.VER_1);
            request.put(ProcessorUtil.API_PROCESSOR_ID,payConfig.Provider_ID__c);
            
            Map<String,Object> response = new Map<String,Object>();
            
            if(!ensureValidEmail(newCustomer.Email__c)){
                errorMessage = ' The email address is invalid.';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));
                return null;
            }
            if (selectedProcessorAccountType == ProcessorUtil.PAT_STRIPE) {
                response = createCustomer_Stripe(request);
            }
            else if (selectedProcessorAccountType == ProcessorUtil.PAT_BRAINTREE) {
                response = createCustomer_Braintree(request);
            }
            else if (selectedProcessorAccountType == ProcessorUtil.PAT_SQUARE) {
                response = createCustomer_Square(request);
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' Breadwinner doesn\'t support the creation of Customer for the Processor ' + selectedProcessorAccountType));
                return null;
            }

            if(isCustomerCreated){
                List<ProcessorUtil.CustomerWrapper> customerResp = (List<ProcessorUtil.CustomerWrapper>) response.get(ProcessorUtil.CUST_RESP);
                if(customerResp != NULL){
                    paymentMethodPage = true;
                    customerPage = false;
                    if(!payConfig.Is_Customer_Match_Completed__c && String.isBlank(payConfig.Customer_Match_Type__c)){
                        payConfig.Customer_Match_Type__c = customerMatchType;
                        BreadwinnerUtil.isBreadwinnerTransaction = True;
                        SecurityUtil.dmlUpdate(payConfig);
                    }
                    customerInfo = selectorCustomer.selectByProcessorCustomerId(new Set<String>{customerResp[0].processorCustomerId},1)[0];
                    if(customerMatchType == ProcessorUtil.CMT_CONTACT && String.isNotBlank(selectedRecordId)) {
                        customerInfo.Salesforce_Contact__c = selectedRecordId;
                    }
                    if(newCustomer.Salesforce_Contact__c != null){
                        customerInfo.Salesforce_Contact__c = newCustomer.Salesforce_Contact__c;
                    }
                    SecurityUtil.dmlUpdate(customerInfo);
                    if(payConfig.Payment_Processor_Type__c ==  ProcessorUtil.PAT_SQUARE){
                        cardCreationKey = Processor_Square.getClientId(payConfig.Live_Mode__c == True ? 'live' : 'test');
                    }
                    if(payConfig.Payment_Processor_Type__c ==  ProcessorUtil.PAT_STRIPE || payConfig.Payment_Processor_Type__c ==  ProcessorUtil.PAT_BRAINTREE){
                        cardCreationKey = String.isNotBlank(payConfig.Card_Creation_Key__c) ? payConfig.Card_Creation_Key__c : '';
                    }
                    hasMultiplePmTypes = hasMultiplePmTypes(selectedProcessorAccountType);
                    selectedBWPCustomer = customerInfo.Processor_Customer_Id__c;
                    selectedProcessorName = customerInfo.Processor_Org_Id__c;
                    authorizeBankMessage = authorizeBankMessage(customerInfo);
                    APICallHandler.userInteractionLogPush(FALSE, 'Customer Created', ((String.isNotBlank(originatingObjName) && String.isNotBlank(originatingObjLabel)) ? (originatingObjLabel + ' (' + originatingObjName + ')') : (String.isNotBlank(selectedRecordId) ? customerMatchType : 'BWP Customer')), 'A new '+selectedProcessorAccountType+' Customer is created from Breadwinner Payments');

                }
            }
            else{
                 processResponseFailure(response);
            }
            return null;
        }
        catch(exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' '+e.getMessage()));
            APICallHandler.userInteractionLogPush(false, 'Create Customer', 'ERROR', 'Exception: '+e.getMessage());
            system.debug(e.getStackTraceString());
            return null;
        }
    }
    private Map<String,Object> createCustomer_Stripe(Map<String,Object> request){
        Customer.StripeCustomer stripeCustomer = new Customer.StripeCustomer();
        Map<String, Object> response = new Map<String, Object>();
        if(newCustomer != NULL){
            stripeCustomer.name = newCustomer.Customer_Name__c;
            stripeCustomer.email = newCustomer.Email__c;
            stripeCustomer.phone = newCustomer.Customer_Phone__c;
            stripeCustomer.description = newCustomer.Description__c;
            if(String.isNotBlank(newCustomer.Invoice_Prefix__c))
                stripeCustomer.invoice_prefix = newCustomer.Invoice_Prefix__c;
            list<string> languages =new list<string>();
            if(String.isNotBlank(newCustomer.Language__c)){
                languages.add(newCustomer.Language__c);
                StripeCustomer.preferred_locales = languages;
            }
            Customer.Address Address = new Customer.Address();
            Address.line1 = newCustomer.Billing_Street_Address_1__c;
            Address.line2 = newCustomer.Billing_Street_Address_2__c;
            Address.city = newCustomer.Billing_City__c;
            Address.state = newCustomer.Billing_State__c;
            Address.country = newCustomer.Billing_Country__c;
            Address.postal_code = newCustomer.Billing_Postal_Code__c;
            stripeCustomer.Address = Address;
            if(String.isNotBlank(newCustomer.Salesforce_Account__c) )
                stripeCustomer.accountId = newCustomer.Salesforce_Account__c;
            if(String.isNotBlank(newCustomer.Tax_Id__c) && String.isNotBlank(newCustomer.Tax_Type__c)){
                Customer.Tax_Info taxInfo = new Customer.Tax_Info();
                if((newCustomer.Tax_Type__c).contains('eu_vat')) taxInfo.stripe_type = 'eu_vat';
                else taxInfo.stripe_type = newCustomer.Tax_Type__c;
                taxInfo.value = newCustomer.Tax_Id__c;
                stripeCustomer.Tax_Info = taxInfo;
            }
            stripeCustomer.tax_exempt = String.isNotBlank(newCustomer.Tax_Exempt__c)? newCustomer.Tax_Exempt__c: 'none';
            Map<String, Object> requestMap = new Map<String, Object>();
            requestMap.put('customer', new List<Customer.StripeCustomer>{stripeCustomer});

            request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(requestMap));
            System.debug('Stripe CreateCustomer request: ' + request);
            response =  BreadwinnerPaymentsAPI.call(request);
            System.debug('Stripe CreateCustomer response: ' + response);

            isCustomerCreated = ProcessorUtil.isValidResponse(response);
        }
        else{
            customerPage = true;paymentMethodPage  = false; 
        }
        return response;
    }
    private Map<String,Object> createCustomer_Braintree(Map<String,Object> request){
        Customer.BraintreeCustomer braintreeCustomer = new Customer.BraintreeCustomer();
        Map<String, Object> response = new Map<String, Object>();
        if(newCustomer != NULL){
            braintreeCustomer.firstName = newCustomer.First_Name__c;
            braintreeCustomer.lastName = newCustomer.Last_Name__c;
            braintreeCustomer.email = newCustomer.Email__c;
            braintreeCustomer.phoneNumber = newCustomer.Customer_Phone__c;
            braintreeCustomer.company = newCustomer.Company__c;
            if(String.isNotBlank(newCustomer.Salesforce_Account__c)) {
                braintreeCustomer.accountId = newCustomer.Salesforce_Account__c;
            }
            Map<String, Object> requestMap = new Map<String, Object>();
            requestMap.put('customer', new List<Customer.BraintreeCustomer>{braintreeCustomer});

            request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(requestMap));
            System.debug('Braintree CreateCustomer request: ' + request);
            response =  BreadwinnerPaymentsAPI.call(request);
            System.debug('Braintree CreateCustomer response: ' + response);

            isCustomerCreated = ProcessorUtil.isValidResponse(response);
        }
        else{
            customerPage = true;paymentMethodPage  = false;
        }
        return response;
    }
    private Map<String,Object> createCustomer_Square(Map<String,Object> request){
        Customer.SquareCustomer squareCustomer = new Customer.SquareCustomer();
        Map<String, Object> response = new Map<String, Object>();
        BreadwinnerPaymentsAPI.RequestObject req = new  BreadwinnerPaymentsAPI.RequestObject();
        if(newCustomer != NULL){
            squareCustomer.given_name = newCustomer.First_Name__c;
            squareCustomer.family_name = newCustomer.Last_Name__c;
            squareCustomer.email_address = newCustomer.Email__c;
            squareCustomer.phone_number = newCustomer.Customer_Phone__c;
            squareCustomer.company_name = newCustomer.Company__c;
            squareCustomer.note = newCustomer.Description__c;
            if(String.isNotBlank(newCustomer.Salesforce_Account__c) )
                squareCustomer.accountId = newCustomer.Salesforce_Account__c;

            Map<String, Object> requestMap = new Map<String, Object>();
            requestMap.put('customer', new List<Customer.SquareCustomer>{squareCustomer});

            request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(requestMap));
            System.debug('Square CreateCustomer request: ' + request);
            response =  BreadwinnerPaymentsAPI.call(request);
            System.debug('Square CreateCustomer response: ' + response);

            isCustomerCreated = ProcessorUtil.isValidResponse(response);
        }
        else{
            customerPage = true;paymentMethodPage  = false;
        }
        return response;
    }
    
    public pageReference createPaymentMethod(){
        payConfig = BreadwinnerUtil.getProcessorConfig(selectedProcessorName);
        cardInfo cInfo;
        bankAccountInfo bankInfo;
        if(PMType == ProcessorUtil.PM_CARD){
            cardAddress cAddress = new cardAddress(cardStreetLine1, cardStreetLine2, cardCity, cardState, cardCountry, cardPostalCode);
            cInfo = new cardInfo(selectedBWPCustomer, cardNumber, cardExpiryMonth, cardExpiryYear, cardCVC, cardHolderName, PMTokenValue, cAddress);
        }
        else if(PMType == ProcessorUtil.PM_BANK){
            errorMessage = validateBankAccount(payConfig.Payment_Processor_Type__c, bankPMAccountHolderName, bankPMRoutingNumber, bankPMAccountNumber);
            if(String.isNotBlank(errorMessage)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' '+ errorMessage));
                return null;
            }
            List<BWP_Customer__c> customerList = selectorCustomer.selectByProcessorCustomerId(new Set<String>{selectedBWPCustomer}, 1);
            String company = customerList.size()> 0 ? customerList[0].Company__c : ''; 
            String accountType = payConfig.Payment_Processor_Type__c == ProcessorUtil.PAT_STRIPE ? bankPMAccountHolderType : bankPMBankAccountType; 
            bankInfo = new bankAccountInfo(selectedBWPCustomer, bankPMCountry, bankPMCurrency, bankPMAccountHolderName, accountType, bankPMAccountNumber, bankPMRoutingNumber, bankPMBusinessOwnerName, bankPMIndividualOwnerFirstName, bankPMIndividualOwnerLastName, company);
        }
        
        Map<String,Object> request = new Map<String,Object>();
        Map<String, Object> response = new Map<String, Object>();
        request.put(ProcessorUtil.API_ACTION, (PMType == ProcessorUtil.PM_CARD ? (payConfig.Payment_Processor_Type__c != ProcessorUtil.PAT_BRAINTREE ? ProcessorUtil.ACT_UPDATE_CUSTOMER : ProcessorUtil.ACT_CREATE_CARD_TOKEN) : ProcessorUtil.ACT_CREATE_BANK_TOKEN));
        request.put(ProcessorUtil.API_VERSION, ProcessorUtil.VER_1);
        request.put(ProcessorUtil.API_PROCESSOR_ID,payConfig.Provider_ID__c);
      
        if(payConfig.Payment_Processor_Type__c == ProcessorUtil.PAT_STRIPE){
            if(PMType == ProcessorUtil.PM_CARD){
                response = createCard_Stripe(request, cInfo);
            }
            else if(PMType == ProcessorUtil.PM_BANK){
                if (String.isBlank(bankPMConfirmAccountNumber)){
                    errorMessage = 'Please confirm Bank Account Number.';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' '+ errorMessage));
                    return null;
                }
                if(!isBankAuthAccepted){
                    errorMessage = bankAuthMessage();
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' '+ errorMessage));
                    return null;
                }
                response = createBankAccount_Stripe(request, bankInfo);
            }
        }
        else if(payConfig.Payment_Processor_Type__c == ProcessorUtil.PAT_BRAINTREE){
            if(PMType == ProcessorUtil.PM_CARD){
                response = createCard_Braintree(request, cInfo);
            }
            else if(PMType == ProcessorUtil.PM_BANK){
                errorMessage = validateBraintreeOwner(bankPMAccountHolderType, bankPMBusinessOwnerName, bankPMIndividualOwnerFirstName,  bankPMIndividualOwnerLastName);
                if(String.isNotBlank(errorMessage)){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ' '+ errorMessage));
                    return null;
                }
                if(!isBankAuthAccepted){
                    errorMessage = bankAuthMessage();
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ' '+ errorMessage));
                    return null;
                }
                response = createBankAccount_Braintree(request, bankInfo);
            }
        }
        else if(payConfig.Payment_Processor_Type__c == ProcessorUtil.PAT_SQUARE){
            if(String.isBlank(squareCardErrors) && String.isBlank(cardPostalCode) && String.isNotBlank(PMTokenValue)){
                errorMessage = 'Please enter valid Postal Code in More Options section';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' '+ errorMessage));
                return null;
            }
            if(String.isBlank(squareCardErrors) && String.isNotBlank(PMTokenValue))
                response = createCard_Square(request, cInfo);
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' Creation of Payment Method via Breadwinner Payments has not been enabled for this Processor Type. Please contact Breadwinner Support for more information.'));
            return null;
        }
        isPaymentMethodCreated = ProcessorUtil.isValidResponse(response);
        isBankAccountCreated = PMType == ProcessorUtil.PM_BANK ? isPaymentMethodCreated : false;
        if(isPaymentMethodCreated){
            paymentMethodPage = false;
            transactionPage = true;
            if(PMType == ProcessorUtil.PM_BANK){
                transactionPage = false;
            }
            listOfPaymentMethods = new List<SelectOption>();
            listOfPaymentMethods = getListOfPaymentMethods(selectedBWPCustomer);
         
            List<ProcessorUtil.PaymentMethodWrapper> payMethodList = (List<ProcessorUtil.PaymentMethodWrapper>) response.get(ProcessorUtil.PAYMETHOD_RESP);
            Set<String> createdPayMethodIds = new Set<String>();
            for(ProcessorUtil.PaymentMethodWrapper payMethod : payMethodList){
                createdPayMethodIds.add(payMethod.processorId);                
            }
            APICallHandler.userInteractionLogPush(false, 'Payment Method Created', ((String.isNotBlank(originatingObjName) && String.isNotBlank(originatingObjLabel)) ? (originatingObjLabel +' ('+originatingObjName+')') : (String.isNotBlank(selectedRecordId) ? customerMatchType : 'BWP Customer')), 'A new '+payConfig.Payment_Processor_Type__c+' Payment Method is created from Breadwinner Payments');
            newPayMethod = selectorPaymentMethod.selectByProcessorId(createdPayMethodIds,1)[0];
            paymentMethodInfo = newPayMethod;
            selectedPaymentMethod = newPayMethod.Processor_Id__c;
            createdPayMethodId = newPayMethod.Processor_Id__c;
            if(newCustomerPageFromPaymentMethod || paymentMethodFromNewPaymentMethodPage){
                return new PageReference('/' + newPayMethod.Id);
            }
            System.debug('--createdPayMethodId--'+createdPayMethodId);
        }
        else if(!response.isEmpty()){
            processResponseFailure(response);
        }
        return null;
    }
    public static Map<String,Object> createCard_Stripe(Map<String,Object> request, cardInfo cInfo){
        Customer.StripeCustomer customer = new Customer.StripeCustomer();
        customer.Id = cInfo.custId;
        customer.source = cInfo.tokenValue;
        List<Customer.Source> datalist = new list<Customer.Source>();
        Customer.Source data = new Customer.Source();
        data.name = cInfo.cardHolderName;
        data.address_line1 = cInfo.address.cardStreetLine1;
        data.address_line2 = cInfo.address.cardStreetLine2;
        data.address_city = cInfo.address.cardCity;
        data.address_state = cInfo.address.cardState;
        data.address_country = cInfo.address.cardCountry;
        data.address_zip = cInfo.address.cardPostalCode;
        datalist.add(data);
        Customer.Sources data2 = new  Customer.Sources();
        data2.data = datalist;
        customer.Sources = data2;
        
        Map<String, List<Customer.StripeCustomer>> customerMap = new Map<String, List<Customer.StripeCustomer>>();
        customerMap.put('customer', new List<Customer.StripeCustomer>{customer});
        
        request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(customerMap));
        
        Map<String, Object> response =  BreadwinnerPaymentsAPI.call(request);
        System.debug('Payment Method response: ' + response);
        return response;
    }
    public static Map<String,Object> createCard_Braintree(Map<String,Object> request, cardInfo cInfo){
        Customer.BraintreeCustomer customer = new Customer.BraintreeCustomer();
        customer.id = cInfo.custId;
        customer.paymentMethodId =  cInfo.tokenValue;
        Map<String, List<Customer.BraintreeCustomer>> customerMap = new Map<String, List<Customer.BraintreeCustomer>>();
        customerMap.put('customer', new List<Customer.BraintreeCustomer>{customer});
        
        request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(customerMap));
        
        Map<String, Object> response =  BreadwinnerPaymentsAPI.call(request);
        System.debug('Payment Method response: ' + response);
                
        return response;
    }
    public static Map<String,Object> createCard_Square(Map<String,Object> request, cardInfo cInfo){
        Customer.SquareCustomer customer = new Customer.SquareCustomer();
        customer.id = cInfo.custId;
        List<Customer.SquareCard> cards = new List<Customer.SquareCard>();
        Customer.SquareCard card = new Customer.SquareCard();
        card.card_nonce = cInfo.tokenValue;
        card.cardholder_name = cInfo.cardHolderName;
        
        Customer.SquareAddress address = new Customer.SquareAddress();
        address.address_line_1 = cInfo.address.cardStreetLine1;
        address.address_line_2 = cInfo.address.cardStreetLine2;
        address.locality = cInfo.address.cardCity;
        address.administrative_district_level_1 = cInfo.address.cardState;
        address.country = cInfo.address.cardCountry;
        address.postal_code = cInfo.address.cardPostalCode;
        card.billing_address = address;
        
        cards.add(card);
        customer.cards = cards;
        Map<String, Object> requestMap = new Map<String, Object>();
        
        requestMap.put('customer', new List<Customer.SquareCustomer>{customer});
        request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(requestMap));
        request.put(ProcessorUtil.API_ACTION, ProcessorUtil.ACT_CREATE_CARD_TOKEN);
        Map<String, Object> response =  BreadwinnerPaymentsAPI.call(request);
        System.debug('Payment Method response: ' + response);
                
        return response;
    }
    
    public static Map<String,Object> createBankAccount_Stripe(Map<String,Object> request, bankAccountInfo bankAccInfo){
        Customer.StripeCustomer customer = new Customer.StripeCustomer();
        customer.Id = bankAccInfo.customerId;
        List<Customer.Source> datalist = new  list<Customer.Source>();
        Customer.Source data = new Customer.Source();
        data.country = bankAccInfo.bankCountry;
        data.stripe_currency = bankAccInfo.bankCurrency;
        data.account_holder_name = bankAccInfo.bankccountHolderName;
        data.account_holder_type = bankAccInfo.bankAccountHolderType;
        data.account_number = bankAccInfo.bankAccountNumber;              
        data.routing_number = bankAccInfo.bankRoutingNumber;
        datalist.add(data);
        Customer.Sources data2= new  Customer.Sources();                    
        data2.data = datalist;                    
        customer.Sources = data2;
        Map<String, List<Customer.StripeCustomer>> customerMap = new Map<String, List<Customer.StripeCustomer>>();
        customerMap.put('customer', new List<Customer.StripeCustomer>{customer});
        
        request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(customerMap));
        
        Map<String, Object> response =  BreadwinnerPaymentsAPI.call(request);
        System.debug('Payment Method response: ' + response);
        
        return response;
    }
    public static Map<String,Object> createBankAccount_Braintree(Map<String,Object> request, bankAccountInfo bankAccInfo){
        Customer.BraintreeCustomer customer = new Customer.BraintreeCustomer();
        customer.id = bankAccInfo.customerId;
        customer.company = bankAccInfo.company;
        List<Customer.PaymentMethodDetails> datalist = new  list<Customer.PaymentMethodDetails>();
        Customer.PaymentMethodDetails cardDetails = new Customer.PaymentMethodDetails();
        cardDetails.accountNumber = bankAccInfo.bankAccountNumber.replaceAll('(\\s+)', '');   
        cardDetails.routingNumber = bankAccInfo.bankRoutingNumber.replaceAll('(\\s+)', '');
        cardDetails.accountType = bankAccInfo.bankAccountHolderType.toUppercase();
        if(String.isNotBlank(bankAccInfo.businessOwnerName)){
            Customer.BusinessOwner businessOwnerName = new Customer.BusinessOwner();
            businessOwnerName.businessName = bankAccInfo.businessOwnerName;
            cardDetails.businessOwner = businessOwnerName;
        }
        if(String.isNotBlank(bankAccInfo.individualOwnerFirstName) && String.isNotBlank(bankAccInfo.individualOwnerLastName)){
            Customer.IndividualOwner individualOwnerName = new Customer.IndividualOwner();
            individualOwnerName.firstName = bankAccInfo.individualOwnerFirstName;
            individualOwnerName.lastName = bankAccInfo.individualOwnerLastName;
            cardDetails.individualOwner = individualOwnerName;
        }
        datalist.add(cardDetails);
        customer.paymentMethodDetails = datalist;
        Map<String, List<Customer.BraintreeCustomer>> customerMap = new Map<String, List<Customer.BraintreeCustomer>>();
        customerMap.put('customer', new List<Customer.BraintreeCustomer>{customer});
        
        request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(customerMap));
        
        Map<String, Object> response =  BreadwinnerPaymentsAPI.call(request);
        System.debug('Payment Method response: ' + response);
        
        return response;
    }
    
    public pageReference verifyBankAccount(){
        try{
            payConfig = BreadwinnerUtil.getProcessorConfig(selectedProcessorName);
            Map<String, Object> response = new Map<String, Object>();

            verifyInfo verifyInfo= new verifyInfo(selectedBWPCustomer, createdPayMethodId, firstDeposit, secondDeposit);

            response = verifyBank(payConfig.Provider_ID__c, verifyInfo);
            
            isBankAccountVerified = ProcessorUtil.isValidResponse(response);
            if(isBankAccountVerified){
                String resp = (String) response.get(ProcessorUtil.RESP_JSON);
                JSONParser parser = JSON.createParser(resp);
                BWP_Payment_Method__c PayMethod = selectorPaymentMethod.selectByProcessorId(createdPayMethodId, 1)[0];
                if(payConfig.Payment_Processor_Type__c == ProcessorUtil.PAT_STRIPE){
                    Customer.Source source = (Customer.Source) parser.readValueAs(Customer.Source.Class);
                    BWP_Payment_Method__c updatePayMethod = new BWP_Payment_Method__c(id = PayMethod.id, Card_Status__c = source.status.capitalize());
                    SecurityUtil.dmlUpdate(updatePayMethod);
                }
                listOfPaymentMethods = getListOfPaymentMethods(selectedBWPCustomer);
                selectedPaymentMethod = PayMethod.Processor_Id__c;
                isBankAccountCreated = false;
                paymentMethodPage = false;
                transactionPage = true;
            }
            else{
                processResponseFailure(response);
            }
        }
        catch(Exception ex){
            isBankAccountVerified = false;
            System.debug('Exception occurred while Verifying Bank Account in '+payConfig.Payment_Processor_Type__c+'.'+ex.getStackTraceString()+'\n'+ex.getmessage());
            APICallHandler.userInteractionLogPush(false, 'Verify Bank Account', 'ERROR', 'Exception: '+ex.getMessage());
        }
        return null;
    }
    
    public static Map<String, Object> verifyBank(String processorId, verifyInfo verifyInfo){

        Map<String,Object> request = new Map<String,Object>();
        request.put(ProcessorUtil.API_ACTION,ProcessorUtil.ACT_VERIFY_BANKACCOUNT);
        request.put(ProcessorUtil.API_VERSION, ProcessorUtil.VER_1);
        request.put(ProcessorUtil.API_PROCESSOR_ID, processorId);

        Customer.verifyBankAccount verify = new Customer.verifyBankAccount();
        verify.customerId = verifyInfo.customerId;
        verify.bankId = verifyInfo.payMethodId;
        verify.firstDeposit = verifyInfo.firstDeposit;
        verify.secondDeposit = verifyInfo.secondDeposit;
        Map<String, List<Customer.verifyBankAccount>> verifyMap = new Map<String, List<Customer.verifyBankAccount>>();

        verifyMap.put('verify', new List<Customer.verifyBankAccount>{verify});
        request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(verifyMap));

        System.debug('VerifyBank Account request: ' + request);
        Map<String, Object> response =  BreadwinnerPaymentsAPI.call(request);
        System.debug('VerifyBank Account response: ' + response);
        return response;
    }

    public void processResponseFailure(Map<String,Object> response){
        List<ProcessorUtil.Error> apiErrors = (List<ProcessorUtil.Error>) response.get(ProcessorUtil.RESP_API_ERRORS);
        List<ProcessorUtil.Error> processingErrors = (List<ProcessorUtil.Error>) response.get(ProcessorUtil.RESP_PROC_ERRORS);
        errorMessage = '';
        String createdInstance = (response.get(ProcessorUtil.API_ACTION) == ProcessorUtil.ACT_CREATE_CUSTOMER ? 'Create Customer' : response.get(ProcessorUtil.API_ACTION) == ProcessorUtil.ACT_CHARGE_PROCESSOR ? 'Create Payment' : response.get(ProcessorUtil.API_ACTION) == ProcessorUtil.ACT_VERIFY_BANKACCOUNT ?  'Verify Bank Account' : 'Create Payment Method');
        if(apiErrors != null){
            for (ProcessorUtil.Error error : apiErrors){
                errorMessage += error.message;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' '+ error.message));
            }
            APICallHandler.userInteractionLogPush(FALSE, createdInstance, 'ERROR', 'Exception: '+errorMessage);
        }
        else if (processingErrors != null){
            for (ProcessorUtil.Error error : processingErrors){
                errorMessage += error.message;
            }
            if(response.get(ProcessorUtil.API_ACTION) == ProcessorUtil.ACT_CHARGE_PROCESSOR && errorMessage.contains('Read timed out')){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'We attempted to process the card but were unable to confirm transaction due to the following error: Read timed out'));
                APICallHandler.userInteractionLogPush(FALSE, 'Create Payment', 'PEX', 'Exception: '+errorMessage);
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' '+ errorMessage.capitalize()));
                APICallHandler.userInteractionLogPush(FALSE, createdInstance, 'ERROR', 'Exception: '+errorMessage);
            }
        }
    }
    
    public void clearPMValues(){
        // Card fields
        cardHolderName = '';
        cardNumber = '';
        cardExpiryMonth = '';
        cardExpiryYear = '';
        cardCVC = '';
        cardHolderName = '';
        cardStreetLine1 = '';
        cardStreetLine2 = '';
        cardCity = '';
        cardState = '';
        cardPostalCode = '';
        cardCountry = '';
        // Bank account fields
        bankPMCountry = 'US';
        bankPMCurrency = 'USD';
        bankPMAccountHolderName = '';
        bankPMAccountHolderType = 'business';
        bankPMAccountNumber = '';   
        bankPMConfirmAccountNumber = '';           
        bankPMRoutingNumber = '';
        bankPMBusinessOwnerName = '';
        bankPMIndividualOwnerFirstName = '';
        bankPMIndividualOwnerLastName = '';
        isBankAuthAccepted = false;
        changeOwner();
    }
    public PageReference redirectToNewTransactionPage(){
        testingPage='false';
        return null;
    }
    public pagereference createPayment(){
        createCustomer();
        if(isCustomerCreated){
            customerPage = false;
            paymentMethodPage  = false;
            transactionPage = true;
        }
        return null;
    }
    
    public void changingPM(){
        if(PMType== ProcessorUtil.PM_CARD){cardPanel = true;bankPanel=false;}
        if(PMType!= ProcessorUtil.PM_CARD){bankPanel = true;cardPanel=false;}
    }
    public void changeOwner(){
        if(bankPMAccountHolderType == 'business'){bankPMBusinessName = true; bankPMIndividualName = false; }
        if(bankPMAccountHolderType == 'individual'){bankPMIndividualName = true; bankPMBusinessName = false; }
        bankPMBusinessOwnerName = '';
        bankPMIndividualOwnerFirstName = '';
        bankPMIndividualOwnerLastName = '';
    }
    public void cancel(){
        this.PMTokenValue=null;
        this.PMErrorValue = '';
        ShowTokenSetion = false;
        bankPanel=false;
        bankPMAccountHolderName = '';
        bankPMRoutingNumber ='';
        bankPMAccountNumber='';
        bankPMConfirmAccountNumber='';
        unMatchedAccount=false;
        PMType=ProcessorUtil.PM_CARD;
        cardPanel = true;
        doNotAddPM=true;
    }    
    public List<SelectOption> getTaxTypes()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- None --'));
        options.add(new SelectOption('eu_vat_AT', 'AT VAT'+'   ' +'••••'+ '   '+'Austria'));
        options.add(new SelectOption('au_abn',    'AU ABN'+'   ' +'••••'+ '   '+'Australia'));
        options.add(new SelectOption('eu_vat_BE', 'BE VAT'+'   ' +'••••'+ '   '+'Belgium'));
        options.add(new SelectOption('eu_vat_BG', 'BG VAT'+'   ' +'••••'+ '   '+'Bulgaria'));
        options.add(new SelectOption('ch_vat',    'CH VAT'+'   ' +'••••'+ '   '+'Switzerland'));
        options.add(new SelectOption('eu_vat_CY', 'CY VAT'+'   ' +'••••'+ '   '+'Cyprus'));
        options.add(new SelectOption('eu_vat_CZ', 'CZ VAT'+'   ' +'••••'+ '   '+'Czech Republic'));
        options.add(new SelectOption('eu_vat_DE', 'DE VAT'+'   ' +'••••'+ '   '+'Germany'));
        options.add(new SelectOption('eu_vat_DK', 'DK VAT'+'   ' +'••••'+ '   '+'Denmark'));
        options.add(new SelectOption('eu_vat_EE', 'EE VAT'+'   ' +'••••'+ '   '+'Estonia'));
        options.add(new SelectOption('eu_vat_ES', 'ES VAT'+'   ' +'••••'+ '   '+'Spain'));
        options.add(new SelectOption('eu_vat_FI', 'FI VAT'+'   ' +'••••'+ '   '+'Finland'));
        options.add(new SelectOption('eu_vat_FR', 'FR VAT'+'   ' +'••••'+ '   '+'France'));
        options.add(new SelectOption('eu_vat_GB', 'GB VAT'+'   ' +'••••'+ '   '+'United Kingdom'));
        options.add(new SelectOption('eu_vat_GR', 'GR VAT'+'   ' +'••••'+ '   '+'Greece'));
        options.add(new SelectOption('eu_vat_HR', 'HR VAT'+'   ' +'••••'+ '   '+'Croatia'));
        options.add(new SelectOption('eu_vat_HU', 'HU VAT'+'   ' +'••••'+ '   '+'Hungary'));
        options.add(new SelectOption('eu_vat_IE', 'IE VAT'+'   ' +'••••'+ '   '+'Ireland'));
        options.add(new SelectOption('in_gst',    'IN GST'+'   ' +'••••'+ '   '+'India'));
        options.add(new SelectOption('eu_vat_IT', 'IT VAT'+'   ' +'••••'+ '   '+'Italy'));
        options.add(new SelectOption('eu_vat_LT', 'LT VAT'+'   ' +'••••'+ '   '+'Lithuania'));
        options.add(new SelectOption('eu_vat_LU', 'LU VAT'+'   ' +'••••'+ '   '+'Luxembourg'));
        options.add(new SelectOption('eu_vat_LV', 'LV VAT'+'   ' +'••••'+ '   '+'Latvia'));
        options.add(new SelectOption('eu_vat_MT', 'MT VAT'+'   ' +'••••'+ '   '+'Malta'));
        options.add(new SelectOption('mx_rfc',    'MX RFC'+'   ' +'••••'+ '   '+'Mexico'));
        options.add(new SelectOption('eu_vat_NL', 'NL VAT'+'   ' +'••••'+ '   '+'Netherlands'));
        options.add(new SelectOption('no_vat',    'NO VAT'+'   ' +'••••'+ '   '+'Norway'));
        options.add(new SelectOption('nz_gst',    'NZ GST'+'   ' +'••••'+ '   '+'New Zealand'));
        return options;
    }
    
    public List<SelectOption> getLanguages() {
        return RecordInfoExtension.getLanguages();
    }
    public List<SelectOption> getCurrencies() {
        return BreadwinnerUtil.getStripeCurrencies();
    }
    
    public void next(){
        customerPage =true;
    }
    
    public void showPaymentMethodPanel(){
        customerPage = false;
        paymentMethodPage = true;
        transactionPage = false;
        isPaymentMethodSelected = false;
        errorMessage = '';
        newTransaction.Amount__c = 0;
        newTransaction.Description__c = '';
        chargeTaxAmount = 0;
        chargeIsTaxExempt = false;
        
    }
    public void showCustomerPanel(){
        customerPage = true;
        paymentMethodPage = false;
        transactionPage = false;
        isCustomerSelected = false;
    }
    public PageReference cancelProcess(){
        if(isCreateCustomerPage){
            if(originatingRecordId != NULL)
                return new PageReference('/' + originatingRecordId);
            else if(newCustomer.Salesforce_Account__c!= NULL)
                return new PageReference('/' + newCustomer.Salesforce_Account__c);
            else if(newCustomer.Salesforce_Contact__c!= NULL)
                return new PageReference('/' + newCustomer.Salesforce_Contact__c);
            else if(newCustomerPageFromPaymentMethod)
                return new PageReference('/'+BWP_Payment_Method__c.SObjectType.getDescribe().getKeyPrefix()+'/o');
            else if(newCustomerPageFromTransaction)
                return new PageReference('/'+BWP_Transaction__c.SObjectType.getDescribe().getKeyPrefix()+'/o');
            else if(!newPaymentMethodPageFromTransaction && !paymentMethodFromNewPaymentMethodPage)
                return new PageReference('/'+BWP_Customer__c.SObjectType.getDescribe().getKeyPrefix()+'/o');
        }
        else if(isCreatePayMethodPage){
            if(newPayMethod.Salesforce_Account__c!= NULL)
                return new PageReference('/' + newPayMethod.Salesforce_Account__c);
            else if(newPayMethod.Salesforce_Contact__c!= NULL)
                return new PageReference('/' + newPayMethod.Salesforce_Contact__c);
            else{
                Schema.DescribeSObjectResult result = BWP_Payment_Method__c.SObjectType.getDescribe();
                return new PageReference('/'+result.getKeyPrefix()+'/o');
            }
        }
        else{
            if(originatingRecordId != NULL)
                return new PageReference('/' + originatingRecordId);
            else if(newTransaction.Salesforce_Account__c != NULL){
                return new PageReference('/' + newTransaction.Salesforce_Account__c);
            }
            else if(newTransaction.Salesforce_Contact__c!= NULL){
                return new PageReference('/' + newTransaction.Salesforce_Contact__c);
            }
            else if(newTransaction != NULL){
                Schema.DescribeSObjectResult result = BWP_Transaction__c.SObjectType.getDescribe();
                return new PageReference('/'+result.getKeyPrefix()+'/o');
            }
        }
        return null;
    }
    public Boolean ensureValidEmail(String email){
        if (String.isBlank(email)){
            //if the email is blank then we assume it is valid
            return true;
        }
        Boolean res = true;
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
        if (!MyMatcher.matches()) 
            res = false;
        return res;
    }
    public void customerMatchTypeError(String pageName, String selectedObject,  String customerMatchType){
        if(selectedObject != customerMatchType){
            String errMsg = ' You can only create a ' + (pageName == PG_CUSTOMER ? PG_CUSTOMER : (pageName == PG_PAYMENTMETHOD ? PG_PAYMENTMETHOD : PG_TRANSACTION)) + ' from ' + (customerMatchType == ProcessorUtil.CMT_ACCOUNT ? 'an Account' : 'a Contact');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, errMsg));
        }
    }
    public void confirmAccountNumber(){
        if(String.isNotblank(bankPMAccountNumber) && String.isNotblank(bankPMConfirmAccountNumber))
            unMatchedAccount = bankPMAccountNumber == bankPMConfirmAccountNumber ? false : true;
    }
    public static String bankAuthMessage(){
        return 'Please click the \" I accept \" checkbox as proof of authorization';
    }
    public static String authorizeBankMessage(BWP_Customer__c customer){
        String message;
        if(customer.Processor_Type__c == ProcessorUtil.PAT_STRIPE){
            message = 'By clicking "Add Bank Account", I authorize "'+customer.Processor_Type__c+'", on behalf of "'+UserInfo.getOrganizationName()+'" (i) to verify my bank account information using bank information and consumer reports and (ii) to debit my bank account.';
        }
        if(customer.Processor_Type__c == ProcessorUtil.PAT_BRAINTREE){
            message = 'By clicking "Add Bank Account", I authorize "'+customer.Processor_Type__c+'", on behalf of "'+((String.isNotBlank(customer.Company__c) || customer.Company__c != null ) ? customer.Company__c : UserInfo.getOrganizationName())+'" (i) to verify my bank account information using bank information and consumer reports and (ii) to debit my bank account.';
        }
        return message;
    }
    public static string validateBraintreeOwner(String accountHolderType, String businessOwnerName, String individualOwnerFirstName, String individualOwnerLastName){
        String errorMessage = '';
        if(accountHolderType == 'business' && String.isBlank(businessOwnerName)){
            errorMessage = 'Please specify Business Name';
        }
        if(accountHolderType == 'individual' && (String.isBlank(individualOwnerFirstName) || String.isBlank(individualOwnerLastName))){
            errorMessage = 'Please specify both First Name and Last Name';
        }
        return errorMessage;
    }
    public static Boolean hasMultiplePmTypes(String processorType){
        return Schema.SObjectType.BWP_Transaction__c.isCreateable() & ProcessorUtil.processorsWithMultiplePmTypes.contains(processorType);
    }
    public static String validateCard(String cardNumber, String cardExpiryMonth, String cardExpiryYear){
        List<String> errorsList = new List<String>();
        String errorMessage = '';
        if (String.isBlank(cardNumber)){
            errorsList.add('card number');
        }
        if (String.isBlank(cardExpiryMonth)){
            errorsList.add('expiration month');
        }
        if (String.isBlank(cardExpiryYear)) {
            errorsList.add('expiration year');
        }
        errorMessage = errorMessage(errorsList);
        return errorMessage;
    }
    public static String validateBankAccount(String processorType, String accountHolderName, String routingNumber, String accountNumber){
        List<String> errorsList = new List<String>();
        String errorMessage = '';
        if(processorType == ProcessorUtil.PAT_STRIPE){
            if (String.isBlank(accountHolderName))
                errorsList.add('Account holder name'); 
        }
        if (String.isBlank(routingNumber))
            errorsList.add('Routing number');
        if (String.isBlank(accountNumber))
            errorsList.add('Bank Account Number');
        errorMessage = errorMessage(errorsList);
        return errorMessage;
    }
    public static String errorMessage(List<String> errorsList){
        String missingParams = '';
        String errorMessage = '';
        if (errorsList.size() > 0){
            for (String err : errorsList){
                missingParams += err + ', ';
            }
        }
        if(String.isNotBlank(missingparams)){
            string params = missingparams.endsWith(', ') ? missingparams.removeEnd(', ') : missingparams;
            errorMessage = 'Please enter valid '+params+'.';
        }
        return errorMessage;
    }
    public class cardInfo{
        public string custId;
        public string cardNumber;
        public string cardExpiryMonth;
        public string cardExpiryYear;
        public string cardCVC;
        public string cardHolderName;
        public string tokenValue;
        public cardAddress address;

        public cardInfo(string customerId, string cardNumber, string cardExpiryMonth,string cardExpiryYear, string cardCVC, string cardHolderName, String token, cardAddress address){
            this.custId = customerId;
            this.cardNumber = cardNumber;
            this.cardExpiryMonth = cardExpiryMonth;
            this.cardExpiryYear = cardExpiryYear;
            this.cardCVC = cardCVC;
            this.cardHolderName = cardHolderName;
            this.tokenValue = token;
            this.address = address;
        }
    }
    public class cardAddress{
        public string cardStreetLine1;
        public string cardStreetLine2;
        public string cardCity;
        public string cardState;
        public string cardCountry;
        public string cardPostalCode;

        public cardAddress(string cardStreetLine1, string cardStreetLine2, string cardCity, string cardState, string cardCountry, string cardPostalCode){
            this.cardStreetLine1 = cardStreetLine1;
            this.cardStreetLine2 = cardStreetLine2;
            this.cardCity = cardCity;
            this.cardState = cardState;
            this.cardCountry = cardCountry;
            this.cardPostalCode = cardPostalCode;
        }
    }

    public class bankAccountInfo{
        public String customerId;
        public String bankCountry;
        public String bankCurrency;
        public String bankccountHolderName;
        public String bankAccountHolderType;
        public String bankAccountNumber;
        public String bankRoutingNumber;
        public String businessOwnerName;
        public String individualOwnerFirstName;
        public String individualOwnerLastName;
        public String company;

        public bankAccountInfo(String customerId, String bankCountry, String bankCurrency, String accountHolderName, String acountHolderType, String accountNumber, String routingNumber, String businessOwnerName, String individualOwnerFirstName, String individualOwnerLastName, String company){
            this.customerId = customerId;
            this.bankCountry = bankCountry;
            this.bankCurrency = bankCurrency;
            this.bankccountHolderName = accountHolderName;
            this.bankAccountHolderType = acountHolderType;
            this.bankAccountNumber = accountNumber;
            this.bankRoutingNumber = routingNumber;
            this.businessOwnerName = businessOwnerName;
            this.individualOwnerFirstName = individualOwnerFirstName;
            this.individualOwnerLastName = individualOwnerLastName;
            this.company = company;
        }
    }

    public class verifyInfo{
        public String customerId;
        public String payMethodId;
        public Decimal firstDeposit;
        public Decimal secondDeposit;

        public verifyInfo(String custId, String payMethodId, Decimal firstDeposit, Decimal secondDeposit){
            this.customerId = custId;
            this.payMethodId = payMethodId;
            this.firstDeposit = firstDeposit;
            this.secondDeposit = secondDeposit;
        }
    }

    public class chargeInfo{
        public string customerId;
        public string payMethodId;
        public string payMethodType;
        public decimal amount;
        public string chargeCurrency;
        public string description;
        public boolean isChargeExept;
        public decimal taxAmount;
        public string keyValue;

        public chargeInfo(string custId, string payMethodId, string payMethodType, decimal amount, string chargeCurrency, string description, boolean isChargeExept, decimal taxAmount, string keyValue){
            this.customerId = custId;
            this.payMethodId = payMethodId;
            this.payMethodType = payMethodType;
            this.amount = amount;
            this.chargeCurrency = chargeCurrency;
            this.description = description;
            this.isChargeExept = isChargeExept;
            this.taxAmount = taxAmount;
            this.keyValue = keyValue;
        }
    }
}