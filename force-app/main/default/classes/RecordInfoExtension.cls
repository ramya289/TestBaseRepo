public with sharing class RecordInfoExtension{

    private static Selector_BWP_Customer selectorCustomer = new Selector_BWP_Customer();
    private static Selector_BWP_Payment_Method selectorPaymentMethod = new Selector_BWP_Payment_Method();
    private static Selector_BWP_Transaction selectorTransaction = new Selector_BWP_Transaction();

    public BWP_Processor_Config__c config                               {get; set;}
    public ID recordId                                                 {get; set;}
    public Sobject sObj                                                {get; set;}
    public String logoPath                                             {get; set;}
    public Boolean showBWLayout                                        {get; set;}    
    
    public BWP_Customer__c customer                              {get; set;}
    public BWP_Payment_Method__c paymethod                       {get; set;}
    public BWP_Transaction__c transactionInfo                        {get; set;}    
    public Decimal firstDeposit                                  {get; set;}
    public Decimal secondDeposit                                 {get; set;}
    public String defaultSourceBrand                             {get; set;}
    public String defaultSourceNumber                            {get; set;}
    public List<BWP_Payment_Method__c> paymentsCardList          {get; set;}
    public List<BWP_Payment_Method__c> paymentsBankList          {get; set;}
    public List<BWP_Payment_Method__c> paymentsOtherList         {get; set;}
    
    
    public List<TransactionWrapper> transactionsList                     {get; set;} 
    public Map<String, BWP_Payment_Method__c > paymentMethodsMap;
    public Decimal chargeAmount                                        {get; set;}
    public String chargingDescription                                  {get; set;}
    public Boolean isChargeSuccess                                     {get; set;}
    
    public List<SelectOption> allPaymentsMethodsList           {get;set;}
    public String selectedPaymentMethod                           {get;set;}
    public String defaultPaymentMethod;
    
    public String appNameSpace;
    public String chargeMessage                                    {get; set;}
    string sObjName;
    
    public String newPMType                                         {get; set;}
    public Boolean cardPanel                                        {get; set;}
    public boolean bankPanel                                        {get; set;}
    
    public BWP_Transaction__c createdTransactionInfo                        {get; set;}
    
    
    public string bankPMAccountHolderName                                {get; set;}
    public string bankPMAccountHolderType                                {get; set;}
    public string bankPMAccountNumber                                     {get; set;}
    public string bankPMRoutingNumber                                     {get; set;}
    public string bankPMConfirmAccountNumber                                 {get; set;}
    public string bankPMCountry                                            {get; set;}
    public string bankPMCurrency                                         {get; set;}
    public Boolean isPaymentMethodCreated                                       {get; set;}
    public string PMmessage                                          {get; set;}
    public string PMTokenValue                                       {get; set;}
    public boolean unMatchedAccount                                  {get; set;}
    public String selectedCurrency									 {get; set;}
    public Boolean isZeroDecimalCurrency                             {get; set;}
    public Boolean isEditSuccess                                     {get; set;}
    public Boolean isVerifySuccess                                   {get; set;}
    public String editCustomerErrors                                 {get; set;}
    public String verifyACHErrors                                 	 {get; set;}
    public BWP_Customer__c editCustomerInfo                          {get; set;} 
    public Id customerId                                             {get; set;}
    public Boolean isBreadwinnerReadOnlyMode                         {get; set;}
    public Boolean isCustomerRelatedOrgConnected                     {get; set;}
    public Breadwinner_Settings__c bwSetting;
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
    public String processorCustomerId;

    public decimal chargeTaxAmount                                                   {get; set;}
    public Boolean chargeIsTaxExempt                                                 {get; set;}
    public Boolean canCreatePaymentMethod                                            {get; set;}
    public Boolean canCreateTransaction                                                  {get; set;}
    public Boolean hasMultiplePmTypes                                                {get; set;}

    public Boolean canUpdateCustomer                                                 {get; set;}
    public string bankPMBankAccountType                                				 {get; set;}
    public string bankPMBusinessOwnerName                                				 {get; set;}
    public string bankPMIndividualOwnerFirstName                         				 {get; set;}
    public string bankPMIndividualOwnerLastName                          				 {get; set;}
    public Boolean bankPMBusinessName                                    				 {get; set;}
    public Boolean bankPMIndividualName                                  				 {get; set;}
    public String squareCardErrors										     		 {get; set;}
    public String idempotencyKey													 {get; set;}

    public Boolean isBankAuthAccepted                                                {get; set;}
    public String authorizeBankMessage                                               {get; set;}
    public String customermatchType                                                  {get; set;}
    public Boolean showShippingAddress                                               {get; set;}
    public String cardCreationKey                                                    {get; set;}
    // This is used so we can dump debug statements to the screen into a hidden field
    // since we can't get debug info from the RC package.
    public String debugTextArea {get; set;}
    public Boolean getIsDebugMode(){
        return ApexPages.currentPage().getParameters().get('debug') != null ? ApexPages.currentPage().getParameters().get('debug') == 'true' : false;
    }

    public RecordInfoExtension(ApexPages.StandardController stdController) {
        try{
            processorCustomerId = '';
            recordId = String.escapeSingleQuotes(stdController.getId());
            appNameSpace = BreadwinnerUtil.namespace!='' ? BreadwinnerUtil.namespace+'__' : '';//BreadwinnerUtil.isBreadwinnerPaymentsInstalled ? (BreadwinnerUtil.namespace!='' ? BreadwinnerUtil.namespace+'__' : '') : '';
            bwSetting =  BreadwinnerUtil.getBWSetting();
            isBreadwinnerReadOnlyMode = bwSetting.Read_Only_Mode__c;
            Boolean isMultiProcessorEnabled =  bwSetting.Multi_Processor_Enabled__c;
            transactionsList =new List<TransactionWrapper>();
            createdTransactionInfo = new BWP_Transaction__c();
            paymentsCardList = new List<BWP_Payment_Method__c>();
            paymentsBankList = new List<BWP_Payment_Method__c>();
            paymentsOtherList = new List<BWP_Payment_Method__c>();
            editCustomerInfo = new BWP_Customer__c();
            defaultSourceBrand = '';
            defaultSourceNumber = '';
            selectedPaymentMethod = '';
            chargeMessage = '';
            PMmessage = '';
            newPMType = 'card';bankPanel = false;cardPanel = true;
            bankPMBankAccountType = 'checking';bankPMBusinessName = true;bankPMIndividualName = false;
            squareCardErrors = '';
            idempotencyKey = '';
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
            chargeTaxAmount = 0;
            chargeIsTaxExempt = FALSE;
            isBankAuthAccepted = false;
            authorizeBankMessage = '';
            allPaymentsMethodsList = new List<SelectOption>();
            //allPaymentsMethodsList.add(new SelectOption('none', '-- Choose a Payment method --'));
            paymentMethodsMap = new Map<String, BWP_Payment_Method__c> ();
            unMatchedAccount = false;
            chargeAmount = 0.00;
            firstDeposit = 0;
            secondDeposit = 0;
            
            chargingDescription = '';
            selectedCurrency = '';
            logoPath='Breadwinner_Payments/images/Card_Images/';
            isZeroDecimalCurrency = false;
            isEditSuccess = false;
            isVerifySuccess = false;
            isCustomerRelatedOrgConnected = true;
            editCustomerErrors = '';
            verifyACHErrors = '';
            canCreatePaymentMethod = false;
            canCreateTransaction = false;
            hasMultiplePmTypes = false;
            canUpdateCustomer = false;
            showShippingAddress = false;
            Map<String, BWP_Processor_Config__c> appConfigMap = new Map<String, BWP_Processor_Config__c>();
            for(BWP_Processor_Config__c appC : BreadwinnerUtil.processorConfigList){
                if(String.isNotBlank(appC.Customer_Match_Type__c)){
                    customerMatchType = appC.Customer_Match_Type__c;
                }
                appConfigMap.put(appC.Provider_Id__c, appC);
                if(!isMultiProcessorEnabled)
                    break;
            }
            //recordId = ApexPages.currentPage().getParameters().get('id');  
            showBWLayout = ApexPages.currentPage().getParameters().get('showBWLayout')!=null &&Boolean.valueof(ApexPages.currentPage().getParameters().get('showBWLayout'))? true:false;
            List<String> zeroDecimalCurrenciesList = BreadwinnerUtil.getZeroDecimalStripeCurrencies();
            config = BreadwinnerUtil.processorConfigList.size() > 0 ? BreadwinnerUtil.processorConfigList[0] : new BWP_Processor_Config__c();
            if(!showBWLayout){
                showBWLayout = (Apexpages.CurrentPage().getparameters().get('sfdc.override')!=null) ? (Apexpages.CurrentPage().getparameters().get('sfdc.override')=='1') : FALSE;
            }

            isChargeSuccess = false;
            isPaymentMethodCreated = false;
            defaultPaymentMethod = '';
            sObj = recordId.getsobjecttype().newSObject();
            sObjName = recordId.getsobjecttype().getDescribe().getname();
            
            bankPMAccountHolderName = '';bankPMAccountNumber = '';bankPMConfirmAccountNumber = '';bankPMCountry = 'US';bankPMCurrency = 'USD';bankPMRoutingNumber = '';bankPMBusinessOwnerName = '';bankPMIndividualOwnerFirstName = '';bankPMIndividualOwnerLastName = '';

            if(showBWLayout){
                String pmQuery;
                DescribeSObjectResult objDef = recordId.getsobjecttype().getDescribe();
                Map<String, SObjectField> fields = objDef.fields.getMap();
                List<string> xfields = new List<string>();xfields.addall(fields.keyset());
                String customFields = '';
                if(sObjName ==appNameSpace+'BWP_Customer__c'){customFields = ' ,Salesforce_Account__r.Name, Salesforce_Contact__r.Name FROM BWP_Customer__c WHERE Id=:recordId LIMIT 1';}
                else if(sObjName ==appNameSpace+'BWP_Payment_Method__c'){customFields = ',Customer__r.Processor_Customer_Id__c,Customer__r.Name,Customer__r.Email__c,Customer__r.Customer_Name__c, Customer__r.First_Name__c, Customer__r.Last_Name__c FROM BWP_Payment_Method__c WHERE Id=:recordId LIMIT 1';}
                else if( sObjName ==appNameSpace+'BWP_Transaction__c'){customFields = ',Customer__r.Name,Customer__r.Customer_Name__c,Customer__r.Email__c,Source__r.Card_Brand__c,Source__r.Last_4_digits__c,Source__r.Type__c,Source__r.Bank_Account_Holder_Name__c,Source__r.Bank_Name__c,Source__r.Account_Number__c FROM BWP_Transaction__c WHERE Id=:recordId LIMIT 1';}

                pmQuery = 'SELECT '+((xfields.size()>0)?(String.join(xfields, ', ')):'') + customFields;
                system.debug('pmQuery: ' + pmQuery);
                //TODO: migrate to QueryBuilder
                sObj= Database.query(pmQuery);
                String processorId = String.valueOf(sobj.get('Processor_Org_Id__c'));
                config = BreadwinnerUtil.getProcessorConfig(processorId);
                isCustomerRelatedOrgConnected = String.isNotBlank(processorId) && appConfigMap.containsKey(processorId);
                if(sObjName == appNameSpace+'BWP_Customer__c'){
                    customer = (BWP_Customer__c)sobj;
                    System.debug('--customer--'+customer);
                    customerId = customer.id;
                    processorCustomerId = customer.Processor_Customer_Id__c;
                    paymethod = new BWP_Payment_Method__c();
                    canCreatePaymentMethod = canCreatePaymentMethod(customer.Processor_Type__c);
                    canCreateTransaction = canCreateTransaction(customer.Processor_Type__c);
                    hasMultiplePmTypes = RecordCreationExtension.hasMultiplePmTypes(customer.Processor_Type__c);
                    canUpdateCustomer = canUpdateCustomer(customer.Processor_Type__c);
                    showShippingAddress = (String.isNotBlank(customer.Shipping_Street_Address_1__c) || String.isNotBlank(customer.Shipping_Street_Address_2__c) || String.isNotBlank(customer.Shipping_State__c) || String.isNotBlank(customer.Shipping_City__c) || String.isNotBlank(customer.Shipping_Country__c) || String.isNotBlank(customer.Shipping_Postal_Code__c)) ? True : False;
                    fetchCustomerRelatedPaymentMethods();
                    updateSelectedPaymentMethodDetails();
                    authorizeBankMessage = RecordCreationExtension.authorizeBankMessage(customer);
                    if (schema.SobjectType.BWP_Transaction__c.isAccessible()) {
                        List<String> relatedList = new List<String>{
                            'Source__r.Name',
                            'Source__r.Type__c',
                            'Source__r.Account_Number__c',
                            'Source__r.Bank_Name__c',
                            'Source__r.Card_Brand__c',
                            'Source__r.Last_4_digits__c'
                        };
                        List<BWP_Transaction__c> trxnsList = selectorTransaction.selectByCustomerId(new Set<String>{recordId},relatedList,1000);
                        transactionsList = getTransactionWrapperRecords(trxnsList);
                    }
                    for (BWP_Payment_Method__c card: paymentsCardList) {
                        allPaymentsMethodsList.add(new SelectOption(card.Id, card.Card_Brand__c + '   ' + '••••' + card.Last_4_digits__c + ' ' + card.Expiry_Month__c + ' / ' + card.Expiry_Year__c));
                    }
                    for (BWP_Payment_Method__c card: paymentsBankList) {
                        if(card.Card_Status__c == 'Verified')
                            allPaymentsMethodsList.add(new SelectOption(card.Id, card.Bank_Name__c+ '   ' + '••••' + card.Last_4_digits__c ));
                    }
                    for (BWP_Payment_Method__c card: paymentsOtherList) {
                        if(card.type__c == ProcessorUtil.PM_ACH_CREDIT)
                            allPaymentsMethodsList.add(new SelectOption(card.Id, 'ACH Credit Transfer'+ '   ••••' +  (string.isNotBlank(card.Account_Number__c)&&card.Account_Number__c.length()>3? card.Account_Number__c.substring(card.Account_Number__c.length() - 3) : '')));
                    }
                    APICallHandler.userInteractionLogPush(true, 'page visit', 'Customer Page' , 'Visited Customer view page');
                    if(!isCustomerRelatedOrgConnected)
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ' Please connect to a '+customer.Processor_Type__c+' Account ('+customer.Processor_Org_Name__c+') from the Setup section of Breadwinner Payments Tab.'));

                    cardCreationKey = config.Payment_Processor_Type__c ==  ProcessorUtil.PAT_SQUARE ? Processor_Square.getClientId(config.Live_Mode__c == True ? 'live' : 'test') : '';
                    if(config.Payment_Processor_Type__c ==  ProcessorUtil.PAT_STRIPE ||  config.Payment_Processor_Type__c ==  ProcessorUtil.PAT_BRAINTREE)
                        cardCreationKey =  String.isNotBlank(config.Card_Creation_Key__c) ? config.Card_Creation_Key__c : '';
                }
                if(sObjName == appNameSpace+'BWP_Payment_Method__c'){
                    paymethod = (BWP_Payment_Method__c) sobj;
                    canCreateTransaction = canCreateTransaction(paymethod.Processor_Type__c);
                    if(string.isNotBlank(paymethod.Card_Brand__c)){
                        String cardBrand = '';
                        cardBrand = (paymethod.Card_Brand__c.replaceAll( '\\s+', ''));
                        if(cardBrand.contains('_')){
                            cardBrand = (cardBrand.replaceAll( '_', ''));
                        }
                        logoPath += cardBrand.toLowerCase()+'.png';
                    } 
                    List<BWP_Transaction__c> trxnList = selectorTransaction.selectBySourceId(new Set<String>{recordId}, 1000);
                    transactionsList = getTransactionWrapperRecords(trxnList);
                    APICallHandler.userInteractionLogPush(true, 'page visit', 'Payment Method Page' , 'Visited Payment Method view page');  
                    if(!isCustomerRelatedOrgConnected)
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ' Please connect to a related '+paymethod.Processor_Type__c+' Account from the Setup section of Breadwinner Payments Tab.'));
                }
                if(sObjName == appNameSpace+'BWP_Transaction__c'){
                    transactionInfo = (BWP_Transaction__c)sobj;
                    if(string.isNotBlank(transactionInfo.Source__r.Card_Brand__c)){
                        String cardBrand = '';
                        cardBrand = (transactionInfo.Source__r.Card_Brand__c.replaceAll( '\\s+', ''));
                        if(cardBrand.contains('_')){
                            cardBrand = (cardBrand.replaceAll( '_', ''));
                        }
                        logoPath += cardBrand.toLowerCase()+'.png';
                    }
                    datetime paymenttime = transactionInfo.createdDate;
                    datetime addMinToPaymentTime = paymenttime.addMinutes(1);
                    system.debug('paymenttime-----'+paymenttime);
                    system.debug('addMinToPaymentTime-----'+addMinToPaymentTime);
                    system.debug('system.now()----'+system.now());
                    if(String.isNotBlank(transactionInfo.Currency__c)){
                        for(String zerodecimalcurreny: zeroDecimalCurrenciesList){
                            if(zerodecimalcurreny == (transactionInfo.Currency__c).toLowerCase()){
                                isZeroDecimalCurrency = true;
                            }
                        }
                    }
                    if(System.Now() < addMinToPaymentTime && transactionInfo.Created_Via__c == BreadwinnerUtil.CNTX_BW){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,' The charge was successfully applied.'));
                    }
                    APICallHandler.userInteractionLogPush(true, 'page visit', 'Transaction Page' , 'Visited Transaction view page');
                    //if(!isCustomerRelatedOrgConnected)
                    // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ' Please connect to a related '+payment.Processor_Type__c+' Account from the Setup section of Breadwinner Payments Tab.'));
                }
            }
        }
        catch(exception e){
            APICallHandler.userInteractionLogPush(true, 'Records View', 'ERROR' , e.getmessage()+''+e.getStackTraceString());
        }
    }
    public void fetchCustomerRelatedPaymentMethods(){

        List<String> relatedList = new List<String>{
            'Customer__r.Processor_Customer_Id__c'
        };
        List<BWP_Payment_Method__c> pmList = selectorPaymentMethod.selectByCustomerId(new Set<Id>{recordId}, relatedList,1000);
        for (BWP_Payment_Method__c pay: pmList) {

            if (pay.Type__c == ProcessorUtil.PM_CARD) {
                paymentsCardList.add(pay);
            } else if (pay.Type__c == ProcessorUtil.PM_BANK) {
                paymentsBankList.add(pay);
            } else {
                paymentsOtherList.add(pay);
            }
            paymentMethodsMap.put(pay.Id, pay);
            system.debug('transaction----'+pay.Processor_Id__c);
            if (customer != NULL && String.isNotBlank(customer.Default_Source__c)) {
                if (customer.Default_Source__c == pay.Processor_Id__c) {
                    defaultSourceNumber = pay.Last_4_digits__c != null ? String.Valueof(pay.Last_4_digits__c) : pay.Account_Number__c;
                    defaultSourceBrand = string.isNotBlank(pay.Card_Brand__c) ? pay.Card_Brand__c : 'others';
                    if (defaultSourceBrand != 'others') {
                        String cardBrand = '';
                        cardBrand = (defaultSourceBrand.replaceAll( '\\s+', ''));
                        if(cardBrand.contains('_')){
                            cardBrand = (cardBrand.replaceAll( '_', ''));
                        }
                        if(!logoPath.contains('.png'))
                            logoPath += cardBrand.toLowerCase()+'.png';
                    }
                    selectedPaymentMethod = String.isNotBlank(selectedPaymentMethod) ? selectedPaymentMethod : ((pay.Type__c == ProcessorUtil.PM_BANK ? (pay.Card_Status__c == 'Verified' ? pay.Id : null) : pay.Id));
                    defaultPaymentMethod = String.isNotBlank(defaultPaymentMethod) ? defaultPaymentMethod : ((pay.Type__c == ProcessorUtil.PM_BANK ? (pay.Card_Status__c == 'Verified' ? pay.Id : null) : pay.Id));
                }
            }
        }

    }
    public void updateSelectedPaymentMethodDetails(){
        BWP_Payment_Method__c paymentMethod = new BWP_Payment_Method__c();
        if(String.isNotBlank(selectedPaymentMethod)){
            payMethod = selectorPaymentMethod.selectById(new Set<String>{selectedPaymentMethod})[0];
        }
        else if((!paymentsCardList.isEmpty()) || (!paymentsBankList.isEmpty()) || (!paymentsOtherList.isEmpty())){
            system.debug('else condition----');
            paymentMethod = selectorPaymentMethod.selectByCustomerId(new Set<Id>{customer.Id},new List<String>{},1)[0];
            if((paymentMethod.Type__c == ProcessorUtil.PM_BANK ? (paymentMethod.Card_Status__c == 'Verified' ? true : false) : true)){
                payMethod = paymentMethod;
            }
            else{
                system.debug('cards details-----'+paymentsCardList.size());
                if(!paymentsCardList.isEmpty()){
                    payMethod = paymentsCardList.get(0);
                }
                system.debug('paymethod----'+payMethod);
            }
            selectedPaymentMethod = String.isNotBlank(payMethod.Id) ? payMethod.Id : null;
        }
    }
    public void chargeCustomer(){
        //paymethod
        fetchCustomerRelatedPaymentMethods();
        chargeMessage = '';
        try{
            Map<String,Object> request = new Map<String,Object>();
            Map<String,Object> response = new Map<String,Object>();
            request.put(ProcessorUtil.API_ACTION, ProcessorUtil.ACT_CHARGE_PROCESSOR);
            request.put(ProcessorUtil.API_VERSION, ProcessorUtil.VER_1);
            request.put(ProcessorUtil.API_PROCESSOR_ID, config.Provider_ID__c);
            BWP_Payment_Method__c paymethod = sObjName == appNameSpace+'BWP_Customer__c' && selectedPaymentMethod!=null ? paymentMethodsMap.get(selectedPaymentMethod) :paymethod;
            RecordCreationExtension.chargeInfo chargeInfo = new RecordCreationExtension.chargeInfo(paymethod.Processor_Customer_Id__c, paymethod.Processor_Id__c, paymethod.Type__c, chargeAmount, selectedCurrency, chargingDescription, chargeIsTaxExempt, chargeTaxAmount, idempotencyKey);
            if(chargeAmount <= 0){
                chargeMessage = 'Amount must be greater than 0';   
            }
            else{
                if(config.Payment_Processor_Type__c == ProcessorUtil.PAT_STRIPE){
                    if(chargingDescription.length()<=1000 ){
                        chargeMessage = chargingDescription.length()>1000? ' Invalid string: Description must be at most 1000 characters': ' Please provide valid Amount';
                    }
                    response = RecordCreationExtension.chargeCustomer_Stripe(request, chargeInfo);
                }
                else if(config.Payment_Processor_Type__c == ProcessorUtil.PAT_BRAINTREE){
                    response = RecordCreationExtension.chargeCustomer_Braintree(request, chargeInfo);
                }
                else if(config.Payment_Processor_Type__c == ProcessorUtil.PAT_SQUARE){
                    response = RecordCreationExtension.chargeCustomer_Square(request, chargeInfo);
                }
            }
            isChargeSuccess = ProcessorUtil.isValidResponse(response);
            if(isChargeSuccess){
                List<ProcessorUtil.TransactionWrapper> transactionResp = (List<ProcessorUtil.TransactionWrapper>) response.get(ProcessorUtil.PAYMENT_RESP);
                createdTransactionInfo = selectorTransaction.selectByProcessorId(new Set<String>{transactionResp[0].processorId}, null)[0];
                APICallHandler.userInteractionLogPush(false, 'Payment Created', 'Customer Layout', 'A new '+config.Payment_Processor_Type__c+' Transaction is created from Breadwinner Payments');
                chargeMessage = '';
            }
            else{
                processResponseFailure(response);
            }
        }catch(Exception ex){
            chargeMessage = ex.getmessage();
            System.debug('Exception occurred while creating Transaction in '+config.Payment_Processor_Type__c+'.'+ex.getStackTraceString()+'\n'+ex.getmessage());
            APICallHandler.userInteractionLogPush(false, 'Create Payment', 'ERROR', 'Exception: '+ex.getMessage());
        }
    }
    
    public void updateCustomer(){
        editCustomerErrors ='';
        isEditSuccess = false;
        if(Test.isRunningTest()){
            customer = selectorCustomer.selectById(new Set<String>{recordId})[0];
        }
        Map<String,Object> request = new Map<String,Object>();
        request.put(ProcessorUtil.API_ACTION,ProcessorUtil.ACT_UPDATE_CUSTOMER);
        request.put(ProcessorUtil.API_VERSION, ProcessorUtil.VER_1);
        request.put(ProcessorUtil.API_PROCESSOR_ID, config.Provider_ID__c);
        Map<String,Object> response = new Map<String,Object>();
        if(customer.Processor_Type__c == ProcessorUtil.PAT_STRIPE){
            response = updateCustomer_Stripe(request, customer);
        }
        else if(customer.Processor_Type__c == ProcessorUtil.PAT_BRAINTREE){
            response = updateCustomer_Braintree(request, customer);
        }
        else if(customer.Processor_Type__c == ProcessorUtil.PAT_SQUARE){
            response= updateCustomer_Square(request, customer);
        }
        if(isEditSuccess){
            APICallHandler.userInteractionLogPush(false, 'Customer Updated', 'Customer Layout', 'A '+customer.Processor_Type__c+' Customer is updated from Breadwinner Payments');
        }
        else{
            processResponseFailure(response);
        }
        System.debug('--isEditSuccess-'+isEditSuccess+'--editCustomerErrors--'+editCustomerErrors);
    }
    
    public Map<String,Object> updateCustomer_Stripe(Map<String, Object> request, BWP_Customer__c customer){
        Map<String, Object> response = new Map<String, Object>();
        Customer.StripeCustomer StripeCustomer = new Customer.StripeCustomer();
        StripeCustomer.id = customer.Processor_Customer_Id__c;
        StripeCustomer.name = customer.Customer_Name__c;
        StripeCustomer.email = customer.Email__c;
        StripeCustomer.phone = customer.Customer_Phone__c;
        StripeCustomer.description = customer.Description__c;
        if(String.isNotBlank(customer.Invoice_Prefix__c))
            StripeCustomer.invoice_prefix = customer.Invoice_Prefix__c;
        
        list<string> languages = new list<string>();
        if(String.isNotBlank(customer.Language__c)){
            languages.add(customer.Language__c);
            StripeCustomer.preferred_locales = languages;
        }
        Customer.Address Address = new Customer.Address();
        Address.line1 = customer.Billing_Street_Address_1__c;
        Address.line2 = customer.Billing_Street_Address_2__c;
        Address.city = customer.Billing_City__c;
        Address.state = customer.Billing_State__c;
        Address.country = customer.Billing_Country__c;
        Address.postal_code = customer.Billing_Postal_Code__c;
        StripeCustomer.Address = Address; 
        
        Map<String, List<Customer.StripeCustomer>> customerMap = new Map<String, List<Customer.StripeCustomer>>();
        customerMap.put('customer', new List<Customer.StripeCustomer>{stripeCustomer});
        
        request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(customerMap));
        System.debug('Stripe UpdateCustomer request: ' + request);
        response =  BreadwinnerPaymentsAPI.call(request);
        System.debug('Stripe UpdateCustomer response: ' + response);
        
        isEditSuccess = ProcessorUtil.isValidResponse(response);
        return response;
    }
    
    public Map<String,Object> updateCustomer_Braintree(Map<String, Object> request, BWP_Customer__c customer){
        Customer.BraintreeCustomer braintreeCustomer = new Customer.BraintreeCustomer();
        Map<String, Object> response = new Map<String, Object>();
        braintreeCustomer.id = customer.Processor_Customer_Id__c;
        braintreeCustomer.firstName = customer.First_Name__c;
        braintreeCustomer.lastName = customer.Last_Name__c;
        braintreeCustomer.email = customer.Email__c;
        braintreeCustomer.phoneNumber = customer.Customer_Phone__c;
        braintreeCustomer.company = customer.Company__c;
        
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('customer', new List<Customer.BraintreeCustomer>{braintreeCustomer});
        
        request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(requestMap));
        System.debug('Braintree UpdateCustomer request: ' + request);
        response =  BreadwinnerPaymentsAPI.call(request);
        System.debug('Braintree UpdateCustomer response: ' + response);
        
        isEditSuccess = ProcessorUtil.isValidResponse(response);
        return response;
    }
    
    public Map<String,Object> updateCustomer_Square(Map<String, Object> request, BWP_Customer__c customer){
        Customer.SquareCustomer squareCustomer = new Customer.SquareCustomer();
        Map<String, Object> response = new Map<String, Object>();
        squareCustomer.id = customer.Processor_Customer_Id__c;
        squareCustomer.given_name = String.isNotBlank(customer.First_Name__c) ? customer.First_Name__c : '';
        squareCustomer.family_name = String.isNotBlank(customer.Last_Name__c) ? customer.Last_Name__c : '';
        squareCustomer.email_address = customer.Email__c;
        squareCustomer.phone_number = customer.Customer_Phone__c;
        squareCustomer.company_name = String.isNotBlank(customer.Company__c) ? customer.Company__c : '';
        squareCustomer.note = customer.Description__c;
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('customer', new List<Customer.SquareCustomer>{squareCustomer});
        
        request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(requestMap));
        System.debug('Square UpdateCustomer request: ' + request);
        response =  BreadwinnerPaymentsAPI.call(request);
        System.debug('Square UpdateCustomer response: ' + response);
        
        isEditSuccess = ProcessorUtil.isValidResponse(response);
        return response;
    }
    
    public Pagereference verifyBankAccount(){
        verifyACHErrors ='';
        isVerifySuccess = false;
        try{
            RecordCreationExtension.verifyInfo verifyInfo = new RecordCreationExtension.verifyInfo(paymethod.Processor_Customer_Id__c, paymethod.Processor_Id__c, firstDeposit, secondDeposit);
           
            Map<String, Object> response = RecordCreationExtension.verifyBank(config.Provider_ID__c, verifyInfo);

            List<ProcessorUtil.Error> apiErrors = (List<ProcessorUtil.Error>) response.get(ProcessorUtil.RESP_API_ERRORS);
            List<ProcessorUtil.Error> processingErrors = (List<ProcessorUtil.Error>) response.get(ProcessorUtil.RESP_PROC_ERRORS);

            if(apiErrors != null){
                isVerifySuccess = false;
                for (ProcessorUtil.Error error : apiErrors){
                    verifyACHErrors += error.message;
                }
                APICallHandler.userInteractionLogPush(false, 'Verify Bank Account', 'ERROR', 'Exception: '+verifyACHErrors);
            } else if (processingErrors != null){
                isVerifySuccess = false;
                for (ProcessorUtil.Error error : processingErrors){
                    verifyACHErrors += error.message;
                }
                APICallHandler.userInteractionLogPush(false, 'Verify Bank Account', 'ERROR', 'Exception: '+verifyACHErrors);
            } else {
                if(response.get(ProcessorUtil.RESP_STATUS) == '200'){
                    isVerifySuccess = true;
                    String resp = (String) response.get(ProcessorUtil.RESP_JSON);
                    JSONParser parser = JSON.createParser(resp);
                    BWP_Payment_Method__c updatePayMethod = new BWP_Payment_Method__c(id = paymethod.id, Processor_Id__c = paymethod.Processor_Id__c);
                    if(config.Payment_Processor_Type__c == ProcessorUtil.PAT_STRIPE){
                        Customer.Source source = (Customer.Source) parser.readValueAs(Customer.Source.Class);
                        updatePayMethod.Card_Status__c = source.status.capitalize();
                    }
                   if(config.Payment_Processor_Type__c == ProcessorUtil.PAT_BRAINTREE){
                       Customer.BraintreeCustomer customer = (Customer.BraintreeCustomer) parser.readValueAs(Customer.BraintreeCustomer.Class);
                       for(Customer.paymentMethodEdges src : customer.paymentMethods.edges){
                           if(updatePayMethod.Processor_Id__c == src.node.id && src.node.details.verified == 'true'){
                               updatePayMethod.Card_Status__c = 'Verified';
                           }
                       }
                   }
                    SecurityUtil.dmlUpdate(updatePayMethod);
                    paymethod =  selectorPaymentMethod.selectByProcessorId(new Set<String>{updatePayMethod.Processor_Id__c},1)[0];
                    APICallHandler.userInteractionLogPush(false, 'Bank Account Verified', 'Payment Method Layout', 'A Bank Account is Verified from Breadwinner Payments');
                    return new PageReference('/' + paymethod.Id);
                }
            }
        }
        catch(Exception ex){
            isVerifySuccess = false;
            verifyACHErrors = ex.getmessage();
            System.debug('Exception occurred while Verifying Bank Account in '+config.Payment_Processor_Type__c+'.'+ex.getStackTraceString()+'\n'+ex.getmessage());
            APICallHandler.userInteractionLogPush(false, 'Verify Bank Account', 'ERROR', 'Exception: '+ex.getMessage());
        }
        return null;  
    }
    public static List<SelectOption> getLanguages()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- None --'));
        String languagesList = 'English:English;Arabic:Arabic;Danish:Danish;Dutch:Dutch;Finnish:Finnish;French:French;German:German;Hebrew:Hebrew;Italian:Italian;Japanese:Japanese;Norwegian:Norwegian;Spanish:Spanish;Swedish:Swedish';
        for(string languageval : languagesList.split(';')) {
            options.add(new SelectOption(languageval.substringAfter(':'), languageval.substringBefore(':')));// 
        } 
        return options;
    }
    public PageReference renderpage(){
        try {
            chargeAmount = 0;
            chargingDescription = '';
            chargeMessage = '';
            PMmessage = '';
            newPMType = 'card';
            system.debug('selectedPaymentMethod-------' + selectedPaymentMethod);

            if (isChargeSuccess || isPaymentMethodCreated) {
                transactionsList = new List<TransactionWrapper>();
                paymentsCardList = new List<BWP_Payment_Method__c>();
                paymentsBankList = new List<BWP_Payment_Method__c>();
                paymentsOtherList = new List<BWP_Payment_Method__c>();
                allPaymentsMethodsList = new List<SelectOption>();
                if (sObjName == appNameSpace + 'BWP_Customer__c') {
                    List<String> relatedFields = new List<String>{
                        'Source__r.Name',
                        'Source__r.Type__c',
                        'Source__r.Account_Number__c',
                        'Source__r.Bank_Name__c',
                        'Source__r.Card_Brand__c',
                        'Source__r.Last_4_digits__c'
                    };
                    List<BWP_Transaction__c> trxnList = selectorTransaction.selectByCustomerId(new Set<String>{recordId}, relatedFields, 1000);
                    transactionsList = getTransactionWrapperRecords(trxnList); 
                    List<BWP_Payment_Method__c> pmList = selectorPaymentMethod.selectByCustomerId(new Set<Id>{recordId}, new List<String>{}, 1000);
                    for (BWP_Payment_Method__c pay : pmList) {

                        if (pay.Type__c == ProcessorUtil.PM_CARD) {
                            paymentsCardList.add(pay);
                        } else if (pay.Type__c == ProcessorUtil.PM_BANK) {
                            paymentsBankList.add(pay);
                        } else {
                            paymentsOtherList.add(pay);
                        }
                    }
                    for (BWP_Payment_Method__c card : paymentsCardList) {
                        allPaymentsMethodsList.add(new SelectOption(card.Id, card.Card_Brand__c + '   ' + '••••' + card.Last_4_digits__c + ' ' + card.Expiry_Month__c + ' / ' + card.Expiry_Year__c));
                    }
                    for (BWP_Payment_Method__c card : paymentsBankList) {
                        if (card.Card_Status__c == 'Verified')
                            allPaymentsMethodsList.add(new SelectOption(card.Id, card.Bank_Name__c + '   ' + '••••' + card.Last_4_digits__c));
                    }
                    for (BWP_Payment_Method__c card : paymentsOtherList) {
                        if (card.type__c == ProcessorUtil.PM_ACH_CREDIT)
                            allPaymentsMethodsList.add(new SelectOption(card.Id, 'ACH Credit Transfer' + '   ••••' + (string.isNotBlank(card.Account_Number__c) && card.Account_Number__c.length() > 3 ? card.Account_Number__c.substring(card.Account_Number__c.length() - 3) : '')));
                    }

                }
                else if (sObjName == appNameSpace + 'BWP_Payment_Method__c') {
                    List<BWP_Transaction__c> trxnList = selectorTransaction.selectBySourceId(new Set<String>{recordId}, 1000);
                    transactionsList = getTransactionWrapperRecords(trxnList);
                }
                isChargeSuccess = false;
            }
            selectedPaymentMethod = defaultPaymentMethod;
            updateSelectedPaymentMethodDetails();
        } catch (Exception ex) {
            System.debug('Exception occurred while trying to render the page.' + ex.getStackTraceString() + '\n' + ex.getMessage());
            APICallHandler.userInteractionLogPush(false, 'RenderPage', 'ERROR', 'Exception: ' + ex.getMessage());
            //This is temporary as we do some debugging
            throw ex;
        }

        return null;
    }
    public void changingPM(){
        if(newPMType == ProcessorUtil.PM_CARD) {cardPanel = true; bankPanel = false;}
        if(newPMType != ProcessorUtil.PM_CARD){bankPanel = true; cardPanel = false;}
        PMmessage='';isChargeSuccess=false;
    }
    public void changeOwner(){
        if(bankPMAccountHolderType == 'business') {bankPMBusinessName = true; bankPMIndividualName = false; PMmessage = '';}
        if(bankPMAccountHolderType == 'individual'){bankPMIndividualName = true; bankPMBusinessName = false; PMmessage = '';}
        bankPMBusinessOwnerName='';
        bankPMIndividualOwnerFirstName='';
        bankPMIndividualOwnerLastName='';
    }
    public void renderPMpage(){
        bankPMRoutingNumber = '';bankPMAccountNumber='';bankPMConfirmAccountNumber='';bankPMAccountHolderName='';bankPMBusinessOwnerName='';bankPMIndividualOwnerFirstName='';bankPMIndividualOwnerLastName='';bankPMCountry = 'US'; bankPMCurrency = 'USD';PMmessage=''; editCustomerErrors='';newPMType='card';unMatchedAccount=false;isChargeSuccess=false;
    }
    public void createPaymentMethod(){
        isPaymentMethodCreated = false;
        try{            
            Map<String,Object> request = new Map<String,Object>();
            Map<String,Object> response = new Map<String,Object>();
            request.put(ProcessorUtil.API_ACTION, (newPMType == ProcessorUtil.PM_CARD ? (config.Payment_Processor_Type__c != ProcessorUtil.PAT_BRAINTREE ? ProcessorUtil.ACT_UPDATE_CUSTOMER : ProcessorUtil.ACT_CREATE_CARD_TOKEN) : ProcessorUtil.ACT_CREATE_BANK_TOKEN));
            request.put(ProcessorUtil.API_VERSION, ProcessorUtil.VER_1);
            request.put(ProcessorUtil.API_PROCESSOR_ID, config.Provider_ID__c);
            RecordCreationExtension.cardInfo cInfo;
            RecordCreationExtension.bankAccountInfo bankInfo;
            if(newPMType == ProcessorUtil.PM_CARD){
                RecordCreationExtension.cardAddress cAddress = new RecordCreationExtension.cardAddress(cardStreetLine1, cardStreetLine2, cardCity, cardState, cardCountry, cardPostalCode);
                cInfo = new RecordCreationExtension.cardInfo(processorCustomerId, cardNumber, cardExpiryMonth, cardExpiryYear, cardCVC, cardHolderName, PMTokenValue, cAddress);
            }
            if(newPMType == ProcessorUtil.PM_BANK){
                List<BWP_Customer__c> customerList = selectorCustomer.selectByProcessorCustomerId(new Set<String>{processorCustomerId}, 1);
                String company = customerList.size()> 0 ? customerList[0].Company__c : '';
                String accountType = config.Payment_Processor_Type__c == ProcessorUtil.PAT_STRIPE ? bankPMAccountHolderType : bankPMBankAccountType;
                bankInfo = new RecordCreationExtension.bankAccountInfo(processorCustomerId, bankPMCountry, bankPMCurrency, bankPMAccountHolderName, accountType, bankPMAccountNumber, bankPMRoutingNumber, bankPMBusinessOwnerName, bankPMIndividualOwnerFirstName, bankPMIndividualOwnerLastName, company);
            }
            if(config.Payment_Processor_Type__c == ProcessorUtil.PAT_STRIPE){
                if(newPMType == ProcessorUtil.PM_CARD){
                    response = RecordCreationExtension.createCard_Stripe(request, cInfo);
                }
                else if(newPMType == ProcessorUtil.PM_BANK){
                    PMmessage = RecordCreationExtension.validateBankAccount(config.Payment_Processor_Type__c, bankPMAccountHolderName, bankPMRoutingNumber, bankPMAccountNumber);
                    if(String.isNotBlank(PMmessage)){
                        return;
                    }
                    if (String.isBlank(bankPMConfirmAccountNumber)){
                        PMmessage = 'Please confirm Bank Account Number.';
                        return;
                    }
                    if(!isBankAuthAccepted){
                        PMmessage = RecordCreationExtension.bankAuthMessage();
                        return;
                    }
                    response = RecordCreationExtension.createBankAccount_Stripe(request, bankInfo);
                }
            }
            else if(config.Payment_Processor_Type__c == ProcessorUtil.PAT_BRAINTREE){
                if(newPMType == ProcessorUtil.PM_CARD && String.isNotBlank(PMTokenValue)){
                    response = RecordCreationExtension.createCard_Braintree(request, cInfo);
                }
                else if(newPMType == ProcessorUtil.PM_BANK){
                    PMmessage = RecordCreationExtension.validateBankAccount(config.Payment_Processor_Type__c, '', bankPMRoutingNumber, bankPMAccountNumber);
                    if(String.isNotBlank(PMmessage)){
                        return;
                    }
                    PMmessage = RecordCreationExtension.validateBraintreeOwner(bankPMAccountHolderType, bankPMBusinessOwnerName, bankPMIndividualOwnerFirstName,  bankPMIndividualOwnerLastName);
                    if(String.isNotBlank(PMmessage)){
                        return;
                    }
                    if(!isBankAuthAccepted){
                        PMmessage = RecordCreationExtension.bankAuthMessage();
                        return;
                    }
                    response = RecordCreationExtension.createBankAccount_Braintree(request, bankInfo);
                }
            }
            else if(config.Payment_Processor_Type__c == ProcessorUtil.PAT_SQUARE){
                if(String.isBlank(squareCardErrors) && String.isBlank(cardPostalCode) && String.isNotBlank(PMTokenValue)){
                    PMmessage = 'Please enter valid Postal Code in More Options section';
                    return;
                }
                if(String.isBlank(squareCardErrors) && String.isNotBlank(PMTokenValue))
                    response = RecordCreationExtension.createCard_Square(request, cInfo);
            }
            isPaymentMethodCreated = ProcessorUtil.isValidResponse(response);
            if(isPaymentMethodCreated){
                List<ProcessorUtil.CustomerWrapper> custMethod = (List<ProcessorUtil.CustomerWrapper>) response.get(ProcessorUtil.CUST_RESP);
                customer.Default_Source__c = custMethod[0].defaultSource;
                if(String.isNotBlank(customer.Default_Source__c)){
                    BWP_Payment_Method__c payMethod = selectorPaymentMethod.selectByProcessorId(customer.Default_Source__c, 1)[0];
                    defaultSourceNumber = (payMethod.Last_4_digits__c != NULL) ? payMethod.Last_4_digits__c : payMethod.Account_Number__c;
                    defaultSourceBrand = string.isNotBlank(payMethod.Card_Brand__c) ? payMethod.Card_Brand__c : 'others';
                    if (defaultSourceBrand != 'others') {
                        String cardBrand = '';
                        cardBrand = (defaultSourceBrand.replaceAll( '\\s+', ''));
                        if(cardBrand.contains('_')){
                            cardBrand = (cardBrand.replaceAll( '_', ''));
                        }
                        if(!logoPath.contains('.png'))
                            logoPath += cardBrand.toLowerCase()+'.png';
                    }
                }
                APICallHandler.userInteractionLogPush(false, 'Payment Method Created', 'Customer Layout', 'A new '+config.Payment_Processor_Type__c+' Payment Method is created from Breadwinner Payments');
            }
            else if(!response.isEmpty()){
                processResponseFailure(response);
            }
        }
        catch(Exception ex){
            PMmessage = ex.getmessage();
            System.debug('Exception occurred while creating customers in '+config.Payment_Processor_Type__c+'.'+ex.getStackTraceString()+'\n'+ex.getmessage());
            APICallHandler.userInteractionLogPush(false, 'Create Payment Method', 'ERROR', 'Exception: '+ex.getMessage());
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, ' '+ex.getmessage()));
        }
    }
    
    public void processResponseFailure(Map<String,Object> response){
        List<ProcessorUtil.Error> apiErrors = (List<ProcessorUtil.Error>) response.get(ProcessorUtil.RESP_API_ERRORS);
        List<ProcessorUtil.Error> processingErrors = (List<ProcessorUtil.Error>) response.get(ProcessorUtil.RESP_PROC_ERRORS);
        String errorMessages = '';
        String createdInstance = (response.get(ProcessorUtil.API_ACTION) == ProcessorUtil.ACT_UPDATE_CUSTOMER ? 'Update Customer' : response.get(ProcessorUtil.API_ACTION) == ProcessorUtil.ACT_CHARGE_PROCESSOR ? 'Create Payment' : 'Create Payment Method');
        System.debug('--createdInstance-'+createdInstance);
        if(apiErrors != null){
            for (ProcessorUtil.Error error : apiErrors){
                errorMessages += error.message;
            }
            APICallHandler.userInteractionLogPush(FALSE, createdInstance, 'ERROR', 'Exception: '+errorMessages);
        }
        else if (processingErrors != null){
            for (ProcessorUtil.Error error : processingErrors){
                errorMessages += error.message;
            }
            if(response.get(ProcessorUtil.API_ACTION) == ProcessorUtil.ACT_CHARGE_PROCESSOR && errorMessages.contains('Read timed out')){
                APICallHandler.userInteractionLogPush(FALSE, createdInstance, 'PEX', 'Exception: '+errorMessages);
                chargeMessage = 'We attempted to process the card but were unable to confirm payment due to the following error: Read timed out';
            }
            APICallHandler.userInteractionLogPush(FALSE, createdInstance, 'ERROR', 'Exception: '+errorMessages);
        }
        if(response.get(ProcessorUtil.API_ACTION) == ProcessorUtil.ACT_UPDATE_CUSTOMER){
            editCustomerErrors = errorMessages;
            System.debug('--editCustomerErrors--'+editCustomerErrors);
        }
        else if(response.get(ProcessorUtil.API_ACTION) == ProcessorUtil.ACT_CHARGE_PROCESSOR){
            chargeMessage = errorMessages.capitalize();
        }
        else{
            PMmessage = errorMessages;
        }
    }
    
    public void confirmnumber(){
        if(String.isNotBlank(bankPMAccountNumber) && String.isNotBlank(bankPMConfirmAccountNumber))
            unMatchedAccount = bankPMAccountNumber == bankPMConfirmAccountNumber? false: true;
    }
    public List<SelectOption> getCurrencies(){
        List<SelectOption> listOfCurrencies = new List<SelectOption>();
        listOfCurrencies = BreadwinnerUtil.getStripeCurrencies();
        return listOfCurrencies;
    }

    public List<SelectOption> getPaymentMethodOptions(){
        return RecordCreationExtension.paymentMethodOptions;
    }
    public Boolean canCreatePaymentMethod(String processorType){
        return Schema.SObjectType.BWP_Payment_Method__c.isCreateable() & ProcessorUtil.processorsThatAllowPaymentMethods.contains(processorType);
    }
    public Boolean canCreateTransaction(String processorType){
        return Schema.SObjectType.BWP_Transaction__c.isCreateable() & ProcessorUtil.processorsThatAllowPayments.contains(processorType);
    }
    public Boolean canUpdateCustomer(String processorType){
        return Schema.SObjectType.BWP_Customer__c.isUpdateable() & ProcessorUtil.processorsThatAllowCustomerUpdate.contains(processorType);
    }
    public class TransactionWrapper {
        public Id RecordId                          {get; set;}
        public String Name                          {get; set;}
        public String PaymentDate                   {get; set;}
        public String PaymentMethodType             {get; set;}
        public String PMCardBrand                   {get; set;}
        public String PMLast4Digits                 {get; set;}
        public String PMBankName                    {get; set;}
        public String PMAccountNumber               {get; set;}
        public String ChargeStatus                  {get; set;}
        public String PaymentStatus                 {get; set;}
        public String Description                   {get; set;}
        public String ChargeCurrency                {get; set;}
        public Decimal Amount                       {get; set;}
        public Boolean showDecimals                 {get; set;}
    }
    public List<TransactionWrapper> getTransactionWrapperRecords(List<BWP_Transaction__c> trxnList){
        if(trxnList == null) return new List<TransactionWrapper>();
        List<String> zeroDecimalCurrenciesList = BreadwinnerUtil.getZeroDecimalStripeCurrencies();
        List<TransactionWrapper> transactionsList = new List<TransactionWrapper>();
        for(BWP_Transaction__c trxn: trxnList){
            TransactionWrapper txn = new TransactionWrapper();
            txn.RecordId = trxn.Id;
            txn.Name = trxn.Name;
            txn.PaymentDate = trxn.Created_Date_in_Processor__c.date().format();
            if(sObjName == appNameSpace+'BWP_Customer__c'){
                txn.PaymentMethodType = trxn.Source__r.Type__c;
                txn.PMCardBrand = trxn.Source__r.Card_Brand__c;
                txn.PMLast4Digits = trxn.Source__r.Last_4_digits__c;
                txn.PMBankName = trxn.Source__r.Bank_Name__c;
                txn.PMAccountNumber = trxn.Source__r.Account_Number__c;
            }
            txn.ChargeStatus = trxn.Charge_Status__c;
            txn.PaymentStatus = trxn.Status__c;
            txn.Description = trxn.Description__c;
            txn.ChargeCurrency = trxn.Currency__c;
            if(zeroDecimalCurrenciesList.contains((trxn.Currency__c).toLowerCase())) txn.showDecimals = false;
            else txn.showDecimals = true;
            txn.Amount = trxn.Amount__c;
            transactionsList.add(txn);
        }
        return transactionsList;
    }
}