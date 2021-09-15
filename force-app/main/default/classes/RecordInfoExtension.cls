public with sharing class RecordInfoExtension{

    private static Selector_BWP_Customer selectorCustomer = new Selector_BWP_Customer();
    private static Selector_BWP_Payment_Method selectorPaymentMethod = new Selector_BWP_Payment_Method();
    private static Selector_BWP_Payment selectorPayment = new Selector_BWP_Payment();

    public BWP_Processor_Config__c config                               {get; set;}
    public ID recordId                                                 {get; set;}
    public Sobject sObj                                                {get; set;}
    public String logoPath                                             {get; set;}
    public Boolean showBWLayout                                        {get; set;}    
    
    public BWP_Customer__c customer                              {get; set;}
    public BWP_Payment_Method__c paymethod                       {get; set;}
    public BWP_Payment__c payment                                {get; set;}    
    public Decimal firstDeposit                                  {get; set;}
    public Decimal secondDeposit                                 {get; set;}
    public String defaultSourceBrand                             {get; set;}
    public String defaultSourceNumber                            {get; set;}
    public List<BWP_Payment_Method__c> paymentsCardList          {get; set;}
    public List<BWP_Payment_Method__c> paymentsBankList          {get; set;}
    public List<BWP_Payment_Method__c> paymentsOtherList         {get; set;}
    
    
    public List<BWP_Payment__c> paymentsList                     {get; set;} 
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
    
    public BWP_Payment__c createdPaymentInfo                        {get; set;}
    
    
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
    public Boolean canCreatePayment                                                  {get; set;}
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
    public String applicationId														 {get; set;}

    public Boolean isBankAuthAccepted                                                {get; set;}
    public String authorizeBankMessage                                               {get; set;}
    public String customermatchType                                                  {get; set;}
    public Boolean showShippingAddress                                               {get;set;}
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
            paymentsList=new List<BWP_Payment__c>();
            createdPaymentInfo = new BWP_Payment__c();
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
            canCreatePayment = false;
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
                else if( sObjName ==appNameSpace+'BWP_Payment__c'){customFields = ',Customer__r.Name,Customer__r.Customer_Name__c,Customer__r.Email__c,Source__r.Card_Brand__c,Source__r.Last_4_digits__c,Source__r.Type__c,Source__r.Bank_Account_Holder_Name__c,Source__r.Bank_Name__c,Source__r.Account_Number__c FROM BWP_Payment__c WHERE Id=:recordId LIMIT 1';}

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
                    canCreatePayment = canCreatePayment(customer.Processor_Type__c);
                    hasMultiplePmTypes = hasMultiplePmTypes(customer.Processor_Type__c);
                    canUpdateCustomer = canUpdateCustomer(customer.Processor_Type__c);
                    showShippingAddress = (String.isNotBlank(customer.Shipping_Street_Address_1__c) || String.isNotBlank(customer.Shipping_Street_Address_2__c) || String.isNotBlank(customer.Shipping_State__c) || String.isNotBlank(customer.Shipping_City__c) || String.isNotBlank(customer.Shipping_Country__c) || String.isNotBlank(customer.Shipping_Postal_Code__c)) ? True : False;
                    fetchCustomerRelatedPaymentMethods();
                    updateSelectedPaymentMethodDetails();
                    authorizeBankMessage = authorizeBankMessage(customer);
                    if (schema.SobjectType.BWP_Payment__c.isAccessible()) {

                        List<String> relatedList = new List<String>{
                            'Source__r.Name',
                            'Source__r.Type__c',
                            'Source__r.Account_Number__c',
                            'Source__r.Bank_Name__c',
                            'Source__r.Card_Brand__c',
                            'Source__r.Last_4_digits__c'
                        };
                        List<BWP_Payment__c> payList = selectorPayment.selectByCustomerId(new Set<String>{recordId},relatedList,1000);
                        for (BWP_Payment__c pay: payList) {
                            paymentsList.add(pay);
                        }
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

                }
                if(sObjName == appNameSpace+'BWP_Payment_Method__c'){
                    paymethod = (BWP_Payment_Method__c) sobj;
                    canCreatePayment = canCreatePayment(paymethod.Processor_Type__c);
                    if(string.isNotBlank(paymethod.Card_Brand__c)){
                        String cardBrand = '';
                        cardBrand = (paymethod.Card_Brand__c.replaceAll( '\\s+', ''));
                        if(cardBrand.contains('_')){
                            cardBrand = (cardBrand.replaceAll( '_', ''));
                        }
                        logoPath += cardBrand.toLowerCase()+'.png';
                    } 
                    APICallHandler.userInteractionLogPush(true, 'page visit', 'Payment Method Page' , 'Visited Payment Method view page');  
                    if(!isCustomerRelatedOrgConnected)
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ' Please connect to a related '+paymethod.Processor_Type__c+' Account from the Setup section of Breadwinner Payments Tab.'));
                }
                if(sObjName == appNameSpace+'BWP_Payment__c'){
                    payment = (BWP_Payment__c)sobj;
                    if(string.isNotBlank(payment.Source__r.Card_Brand__c)){
                        String cardBrand = '';
                        cardBrand = (payment.Source__r.Card_Brand__c.replaceAll( '\\s+', ''));
                        if(cardBrand.contains('_')){
                            cardBrand = (cardBrand.replaceAll( '_', ''));
                        }
                        logoPath += cardBrand.toLowerCase()+'.png';
                    }
                    datetime paymenttime = payment.createdDate;
                    datetime addMinToPaymentTime = paymenttime.addMinutes(1);
                    system.debug('paymenttime-----'+paymenttime);
                    system.debug('addMinToPaymentTime-----'+addMinToPaymentTime);
                    system.debug('system.now()----'+system.now());
                    if(String.isNotBlank(payment.Currency__c)){
                        for(String zerodecimalcurreny: zeroDecimalCurrenciesList){
                            if(zerodecimalcurreny == (payment.Currency__c).toLowerCase()){
                                isZeroDecimalCurrency = true;
                            }
                        }
                    }
                    if(System.Now() < addMinToPaymentTime && payment.Created_Via__c == BreadwinnerUtil.CNTX_BW){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,' The charge was successfully applied.'));
                    }
                    APICallHandler.userInteractionLogPush(true, 'page visit', 'Payment Page' , 'Visited Payment view page');
                    //if(!isCustomerRelatedOrgConnected)
                    // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ' Please connect to a related '+payment.Processor_Type__c+' Account from the Setup section of Breadwinner Payments Tab.'));
                }
                
                for(BWP_Payment__c pay : selectorPayment.selectBySourceId(new Set<String>{recordId}, 1000)){
                    paymentsList.add(pay);
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
            system.debug('payment----'+pay.Processor_Id__c);
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
                        system.debug('selectedPaymentMethod----'+selectedPaymentMethod);
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
            if(chargeAmount <= 0){
                chargeMessage = 'Amount must be greater than 0';   
            }
            else{
                if(config.Payment_Processor_Type__c == ProcessorUtil.PAT_STRIPE){
                    if(chargingDescription.length()<=1000 ){
                        chargeMessage = chargingDescription.length()>1000? ' Invalid string: Description must be at most 1000 characters': ' Please provide valid Amount';
                    }
                    response = chargeCustomer_Stripe(request);
                }
                else if(config.Payment_Processor_Type__c == ProcessorUtil.PAT_BRAINTREE){
                    response = chargeCustomer_Braintree(request);
                }
                else if(config.Payment_Processor_Type__c == ProcessorUtil.PAT_SQUARE){
                    response = chargeCustomer_Square(request);
                }
            }

            if(isChargeSuccess){
                List<ProcessorUtil.PaymentWrapper> paymentResp = (List<ProcessorUtil.PaymentWrapper>) response.get(ProcessorUtil.PAYMENT_RESP);
                createdPaymentInfo = selectorPayment.selectByProcessorId(new Set<String>{paymentResp[0].processorId}, null)[0];
                APICallHandler.userInteractionLogPush(false, 'Payment Created', 'Customer Layout', 'A new '+config.Payment_Processor_Type__c+' Payment is created from Breadwinner Payments');
                chargeMessage = '';
            }
            else{
                processResponseFailure(response);
            }
        }catch(Exception ex){
            chargeMessage = ex.getmessage();
            System.debug('Exception occurred while creating Payment in '+config.Payment_Processor_Type__c+'.'+ex.getStackTraceString()+'\n'+ex.getmessage());
            APICallHandler.userInteractionLogPush(false, 'Create Payment', 'ERROR', 'Exception: '+ex.getMessage());
        }
    }
    private Map<String,Object> chargeCustomer_Stripe(Map<String,Object> request){
        BWP_Payment_Method__c paymethod = sObjName == appNameSpace+'BWP_Customer__c' && selectedPaymentMethod!=null ? paymentMethodsMap.get(selectedPaymentMethod) :paymethod;
        Charge.StripeCharge ch = new Charge.StripeCharge();
        ch.amount = chargeAmount > 0 ? chargeAmount : 0;
        ch.customer = paymethod.Processor_Customer_Id__c;
        ch.stripe_currency = String.isNotBlank(selectedCurrency) ? selectedCurrency : '';//'usd';
        ch.description = chargingDescription;
        ch.paymentMethod = paymethod.Processor_Id__c;
        ch.paymentMethodType = String.isNotBlank(paymethod.Type__c) ? (paymethod.Type__c == ProcessorUtil.PM_CARD ? ProcessorUtil.PM_CARD : (paymethod.Type__c != ProcessorUtil.PM_BANK ? ProcessorUtil.PM_ACH_CREDIT : ProcessorUtil.PM_BANK)) : '';
        system.debug('ch.stripe_currency'+ch.stripe_currency);

        Map<String, List<Charge.StripeCharge>> chargeMap = new Map<String, List<Charge.StripeCharge>>();
        chargeMap.put('charge', new List<Charge.StripeCharge>{ch});

        request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(chargeMap));

        request.put(ProcessorUtil.API_TIMEOUT, '20000');
        System.debug('ChargeCustomer request: ' + request);
        Map<String, Object> response =  BreadwinnerPaymentsAPI.call(request);
        System.debug('ChargeCustomer response: ' + response);
        
        isChargeSuccess = ProcessorUtil.isValidResponse(response);
        
        return response;
    }
    private Map<String,Object> chargeCustomer_Braintree(Map<String,Object> request){
        BWP_Payment_Method__c paymethod = sObjName == appNameSpace+'BWP_Customer__c' && selectedPaymentMethod!=null ? paymentMethodsMap.get(selectedPaymentMethod) :paymethod;
        Charge.BraintreeCharge ch = new Charge.BraintreeCharge();
        Charge.Amount amount = new Charge.Amount();
        amount.value = String.valueOf(chargeAmount);
        ch.amount = amount;
        Charge.Customer customer = new Charge.Customer();
        customer.id = paymethod.Processor_Customer_Id__c;
        ch.customer = customer;
        Charge.PaymentMethod paymentMethod = new Charge.PaymentMethod();
        paymentMethod.id = paymethod.Processor_Id__c;
        ch.paymentMethod = paymentMethod;
        Charge.TransactionTaxInput transactionTaxInput = new Charge.TransactionTaxInput();
        Charge.Amount taxAmount = new Charge.Amount();
        taxAmount.value = String.valueOf(chargeTaxAmount);
        transactionTaxInput.taxAmount =  taxAmount;
        transactionTaxInput.taxExempt = chargeIsTaxExempt;
        ch.transactionTaxInput = transactionTaxInput;
        Map<String, List<Charge.BraintreeCharge>> chargeMap = new Map<String, List<Charge.BraintreeCharge>>();
        chargeMap.put('charge', new List<Charge.BraintreeCharge>{ch});


        request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(chargeMap));

        System.debug('ChargeCustomer request: ' + request);
        Map<String, Object> response =  BreadwinnerPaymentsAPI.call(request);
        System.debug('ChargeCustomer response: ' + response);
        
        isChargeSuccess = ProcessorUtil.isValidResponse(response);
        
        return response;
    }
    private Map<String,Object> chargeCustomer_Square(Map<String,Object> request){
        BWP_Payment_Method__c paymethod = sObjName == appNameSpace+'BWP_Customer__c' && selectedPaymentMethod!=null ? paymentMethodsMap.get(selectedPaymentMethod) :paymethod;
        Charge.SquareCharge ch = new Charge.SquareCharge();
        Charge.Money money = new Charge.Money();
        money.amount =  chargeAmount > 0 ? chargeAmount*100 : 0;
        money.square_currency = String.isNotBlank(selectedCurrency) ? selectedCurrency.toUppercase() : '';
        ch.amount_money = money;
        ch.customer_id = paymethod.Processor_Customer_Id__c;
        ch.source_id = paymethod.Processor_Id__c;
        ch.idempotency_key = idempotencyKey;
        Map<String, List<Charge.SquareCharge>> chargeMap = new Map<String, List<Charge.SquareCharge>>();
        chargeMap.put('charge', new List<Charge.SquareCharge>{ch});

        request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(chargeMap));

        request.put(ProcessorUtil.API_TIMEOUT, '20000');
        System.debug('ChargeCustomer request: ' + request);
        Map<String, Object> response =  BreadwinnerPaymentsAPI.call(request);
        System.debug('ChargeCustomer response: ' + response);
        
        isChargeSuccess = ProcessorUtil.isValidResponse(response);
        
        return response;
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
            Customer.verifyBankAccount verify = new Customer.verifyBankAccount();
            verify.customerId = paymethod.Processor_Customer_Id__c;
            verify.bankId = paymethod.Processor_Id__c;
            verify.firstDeposit = firstDeposit;
            verify.secondDeposit = secondDeposit;
            Map<String, List<Customer.verifyBankAccount>> verifyMap = new Map<String, List<Customer.verifyBankAccount>>();
            verifyMap.put('verify', new List<Customer.verifyBankAccount>{verify});

            Map<String,Object> request = new Map<String,Object>();
            request.put(ProcessorUtil.API_ACTION,ProcessorUtil.ACT_VERIFY_BANKACCOUNT);
            request.put(ProcessorUtil.API_VERSION, ProcessorUtil.VER_1);
            request.put(ProcessorUtil.API_PROCESSOR_ID, config.Provider_ID__c);
            request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(verifyMap));
            System.debug('Stripe VerifyBank Account request: ' + request);
            Map<String, Object> response =  BreadwinnerPaymentsAPI.call(request);
            System.debug('Stripe VerifyBank Account response: ' + response);

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
                paymentsList = new List<BWP_Payment__c>();
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
                    List<BWP_Payment__c> payList = selectorPayment.selectByCustomerId(new Set<String>{recordId}, relatedFields, 1000);

                    for (BWP_Payment__c pay : payList) {
                        paymentsList.add(pay);
                    }

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
                    for (BWP_Payment__c pay : selectorPayment.selectBySourceId(new Set<String>{recordId}, 1000)) {
                        paymentsList.add(pay);
                    }
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
        if(config.Payment_Processor_Type__c ==  ProcessorUtil.PAT_SQUARE){
            applicationId = Processor_Square.getClientId(config.Live_Mode__c == True ? 'live' : 'test');
        }
        bankPMRoutingNumber = '';bankPMAccountNumber='';bankPMConfirmAccountNumber='';bankPMAccountHolderName='';bankPMBusinessOwnerName='';bankPMIndividualOwnerFirstName='';bankPMIndividualOwnerLastName='';bankPMCountry = 'US'; bankPMCurrency = 'USD';PMmessage=''; newPMType='card';unMatchedAccount=false;isChargeSuccess=false;
    }
    public void createPaymentMethod(){
        isPaymentMethodCreated = false;
        try{            
            Map<String,Object> request = new Map<String,Object>();
            Map<String,Object> response = new Map<String,Object>();
            request.put(ProcessorUtil.API_ACTION, (newPMType == ProcessorUtil.PM_CARD ? ProcessorUtil.ACT_CREATE_CARD_TOKEN : ProcessorUtil.ACT_CREATE_BANK_TOKEN));
            request.put(ProcessorUtil.API_VERSION, ProcessorUtil.VER_1);
            request.put(ProcessorUtil.API_PROCESSOR_ID, config.Provider_ID__c);
            if(config.Payment_Processor_Type__c == ProcessorUtil.PAT_STRIPE){
                if(newPMType == ProcessorUtil.PM_CARD){
                    PMmessage = validateCard(cardNumber, cardExpiryMonth, cardExpiryYear);
                    if(String.isNotBlank(PMmessage)){
                        return;
                    }
                    response = createCard_Stripe(request, processorCustomerId);
                }
                else if(newPMType == ProcessorUtil.PM_BANK){
                    PMmessage = validateBankAccount(config.Payment_Processor_Type__c, bankPMAccountHolderName, bankPMRoutingNumber, bankPMAccountNumber);
                    if(String.isNotBlank(PMmessage)){
                        return;
                    }
                    if (String.isBlank(bankPMConfirmAccountNumber)){
                        PMmessage = 'Please confirm Bank Account Number.';
                        return;
                    }
                    if(!isBankAuthAccepted){
                        PMmessage = bankAuthMessage();
                        return;
                    }
                    response = createBankAccount_Stripe(request, processorCustomerId);
                }
            }
            else if(config.Payment_Processor_Type__c == ProcessorUtil.PAT_BRAINTREE){
                if(newPMType == ProcessorUtil.PM_CARD){
                    PMmessage = validateCard(cardNumber, cardExpiryMonth, cardExpiryYear);
                    if(String.isNotBlank(PMmessage)){
                        return;
                    }
                    response = createCard_Braintree(request, processorCustomerId);
                }
                else if(newPMType == ProcessorUtil.PM_BANK){
                    PMmessage = validateBankAccount(config.Payment_Processor_Type__c, '', bankPMRoutingNumber, bankPMAccountNumber);
                    if(String.isNotBlank(PMmessage)){
                        return;
                    }
                    PMmessage = validateBraintreeOwner(bankPMAccountHolderType, bankPMBusinessOwnerName, bankPMIndividualOwnerFirstName,  bankPMIndividualOwnerLastName);
                    if(String.isNotBlank(PMmessage)){
                        return;
                    }
                    if(!isBankAuthAccepted){
                        PMmessage = bankAuthMessage();
                        return;
                    }
                    response = createBankAccount_Braintree(request, processorCustomerId);
                }
            }
            else if(config.Payment_Processor_Type__c == ProcessorUtil.PAT_SQUARE){
                if(String.isBlank(squareCardErrors) && String.isBlank(cardPostalCode) && String.isNotBlank(PMTokenValue)){
                    PMmessage = 'Please enter valid Postal Code in More Options section';
                    return;
                }
                if(String.isBlank(squareCardErrors) && String.isNotBlank(PMTokenValue))
                    response = createCard_Square(request, processorCustomerId);
            }
            if(isPaymentMethodCreated){
                List<ProcessorUtil.CustomerWrapper> custMethod = (List<ProcessorUtil.CustomerWrapper>) response.get(ProcessorUtil.CUST_RESP);
                customer.Default_Source__c = custMethod[0].defaultSource;
                List<ProcessorUtil.PaymentMethodWrapper> payMethod = (List<ProcessorUtil.PaymentMethodWrapper>) response.get(ProcessorUtil.PAYMETHOD_RESP);
                defaultSourceNumber = (payMethod[0].last4digits != NULL) ? payMethod[0].last4digits : payMethod[0].accountNumber;
                defaultSourceBrand = string.isNotBlank(payMethod[0].cardBrand) ? payMethod[0].cardBrand : 'others';
                if (defaultSourceBrand != 'others') {
                    String cardBrand = '';
                    cardBrand = (defaultSourceBrand.replaceAll( '\\s+', ''));
                    if(cardBrand.contains('_')){
                        cardBrand = (cardBrand.replaceAll( '_', ''));
                    }
                    if(!logoPath.contains('.png'))
                        logoPath += cardBrand.toLowerCase()+'.png';
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
    public Map<String,Object> createCard_Stripe(Map<String,Object> request, String processorCustomerId){
        Customer.StripeCustomer customer = new Customer.StripeCustomer();
        customer.id = processorCustomerId;
        List<Customer.Source> datalist = new list<Customer.Source>();
        Customer.Source data = new Customer.Source();
        data.cardNumber = cardNumber;
        data.exp_month = cardExpiryMonth;
        data.exp_year = cardExpiryYear;
        data.cvc = cardCVC;
        data.name = cardHolderName;
        data.address_line1 = cardStreetLine1;
        data.address_line2 = cardStreetLine2;
        data.address_city = cardCity;
        data.address_state = cardState;
        data.address_zip = cardPostalCode;
        data.address_country = cardCountry;
        datalist.add(data);
        Customer.Sources data2 = new  Customer.Sources();
        data2.data = datalist;
        customer.Sources = data2;

        Map<String, List<Customer.StripeCustomer>> customerMap = new Map<String, List<Customer.StripeCustomer>>();
        customerMap.put('customer', new List<Customer.StripeCustomer>{customer});

        request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(customerMap));

        Map<String, Object> response =  BreadwinnerPaymentsAPI.call(request);
        System.debug('Payment Method response: ' + response);
        
        isPaymentMethodCreated = ProcessorUtil.isValidResponse(response);
        
        return response;
    }
    public Map<String,Object> createCard_Braintree(Map<String,Object> request, String processorCustomerId){
        Customer.BraintreeCustomer customer = new Customer.BraintreeCustomer();
        customer.id = processorCustomerId;
        List<Customer.PaymentMethodDetails> datalist = new  list<Customer.PaymentMethodDetails>();
        Customer.PaymentMethodDetails cardDetails = new Customer.PaymentMethodDetails();
        cardDetails.cardNumber = cardNumber;
        cardDetails.expirationMonth = String.valueOf(Integer.valueOf(cardExpiryMonth));
        cardDetails.expirationYear = cardExpiryYear;
        cardDetails.cardholderName = cardHolderName;
        datalist.add(cardDetails);
        customer.paymentMethodDetails = datalist;
        Map<String, List<Customer.BraintreeCustomer>> customerMap = new Map<String, List<Customer.BraintreeCustomer>>();
        customerMap.put('customer', new List<Customer.BraintreeCustomer>{customer});

        request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(customerMap));

        Map<String, Object> response =  BreadwinnerPaymentsAPI.call(request);
        System.debug('Payment Method response: ' + response);
        
        isPaymentMethodCreated = ProcessorUtil.isValidResponse(response);
        
        return response;
    }
    public Map<String,Object> createCard_Square(Map<String,Object> request, String processorCustomerId){
        Customer.SquareCustomer customer = new Customer.SquareCustomer();
        customer.id = processorCustomerId;
        List<Customer.SquareCard> cards = new List<Customer.SquareCard>();
        Customer.SquareCard card = new Customer.SquareCard();
        card.card_nonce = PMTokenValue;
        card.cardholder_name = cardHolderName;

        Customer.SquareAddress address = new Customer.SquareAddress();
        address.address_line_1 = cardStreetLine1;
        address.address_line_2 = cardStreetLine2;
        address.locality = cardCity;
        address.administrative_district_level_1 = cardState;
        address.postal_code = cardPostalCode;
        address.country = cardCountry;
        card.billing_address = address;

        cards.add(card);
        customer.cards = cards;
        Map<String, Object> requestMap = new Map<String, Object>();

        requestMap.put('customer', new List<Customer.SquareCustomer>{customer});
        request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(requestMap));
        request.put(ProcessorUtil.API_ACTION, ProcessorUtil.ACT_CREATE_CARD_TOKEN);
        Map<String, Object> response =  BreadwinnerPaymentsAPI.call(request);
        System.debug('Payment Method response: ' + response);
        
        isPaymentMethodCreated = ProcessorUtil.isValidResponse(response);
        
        return response;
    }

    
    public Map<String,Object> createBankAccount_Stripe(Map<String,Object> request, String processorCustomerId){
        Customer.StripeCustomer customer = new Customer.StripeCustomer();
        customer.id = processorCustomerId;
        List<Customer.Source> datalist = new  list<Customer.Source>();
        Customer.Source data = new Customer.Source();
        data.country = bankPMCountry;
        data.stripe_currency = bankPMCurrency;
        data.account_holder_name = bankPMAccountHolderName ;
        data.account_holder_type = bankPMAccountHolderType ;
        data.account_number = bankPMAccountNumber;
        data.routing_number = bankPMRoutingNumber;
        datalist.add(data);
        Customer.Sources data2= new  Customer.Sources();
        data2.data = datalist;
        customer.Sources = data2;
        Map<String, List<Customer.StripeCustomer>> customerMap = new Map<String, List<Customer.StripeCustomer>>();
        customerMap.put('customer', new List<Customer.StripeCustomer>{customer});

        request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(customerMap));

        Map<String, Object> response =  BreadwinnerPaymentsAPI.call(request);
        System.debug('Payment Method response: ' + response);
        
        isPaymentMethodCreated = ProcessorUtil.isValidResponse(response);
        
        return response;
    }
    public Map<String,Object> createBankAccount_Braintree(Map<String,Object> request, String processorCustomerId){
        Customer.BraintreeCustomer customer = new Customer.BraintreeCustomer();
        customer.id = processorCustomerId;
        List<BWP_Customer__c> customerList = selectorCustomer.selectByProcessorCustomerId(new Set<String>{processorCustomerId}, 1);
        String company = customerList.size()> 0 ? customerList[0].Company__c : '';
        customer.company = company;
        List<Customer.PaymentMethodDetails> datalist = new  list<Customer.PaymentMethodDetails>();
        Customer.PaymentMethodDetails cardDetails = new Customer.PaymentMethodDetails();
        cardDetails.accountNumber = bankPMAccountNumber.replaceAll('(\\s+)', '');
        cardDetails.routingNumber = bankPMRoutingNumber.replaceAll('(\\s+)', '');
        cardDetails.accountType = bankPMBankAccountType.toUppercase();
        if(String.isNotBlank(bankPMBusinessOwnerName)){
            Customer.BusinessOwner businessOwnerName = new Customer.BusinessOwner();
            businessOwnerName.businessName = bankPMBusinessOwnerName;
            cardDetails.businessOwner = businessOwnerName;
        }
        if(String.isNotBlank(bankPMIndividualOwnerFirstName) && String.isNotBlank(bankPMIndividualOwnerLastName)){
            Customer.IndividualOwner individualOwnerName = new Customer.IndividualOwner();
            individualOwnerName.firstName = bankPMIndividualOwnerFirstName;
            individualOwnerName.lastName = bankPMIndividualOwnerLastName;
            cardDetails.individualOwner = individualOwnerName;
        }
        datalist.add(cardDetails);
        customer.paymentMethodDetails = datalist;
        Map<String, List<Customer.BraintreeCustomer>> customerMap = new Map<String, List<Customer.BraintreeCustomer>>();
        customerMap.put('customer', new List<Customer.BraintreeCustomer>{customer});
        
        request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(customerMap));

        Map<String, Object> response =  BreadwinnerPaymentsAPI.call(request);
        System.debug('Payment Method response: ' + response);
        
        isPaymentMethodCreated = ProcessorUtil.isValidResponse(response);
        
        return response;
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

    public static List<SelectOption> PaymentMethodOptions                                           {
        get{
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption(ProcessorUtil.PM_Card,'Card'));
            options.add(new SelectOption(ProcessorUtil.PM_Bank,'Bank Account'));
            return options;
        }
        private set;
    }
    public Boolean canCreatePaymentMethod(String processorType){
        return Schema.SObjectType.BWP_Payment_Method__c.isCreateable() & ProcessorUtil.processorsThatAllowPaymentMethods.contains(processorType);
    }
    public Boolean canCreatePayment(String processorType){
        return Schema.SObjectType.BWP_Payment__c.isCreateable() & ProcessorUtil.processorsThatAllowPayments.contains(processorType);
    }
    public static Boolean hasMultiplePmTypes(String processorType){
        return Schema.SObjectType.BWP_Payment__c.isCreateable() & ProcessorUtil.processorsWithMultiplePmTypes.contains(processorType);
    }
    public Boolean canUpdateCustomer(String processorType){
        return Schema.SObjectType.BWP_Customer__c.isUpdateable() & ProcessorUtil.processorsThatAllowCustomerUpdate.contains(processorType);
    }
    public static String bankAuthMessage(){
        return 'Please click the \" I accept \" checkbox as proof of authorization';
    }
    public static String authorizeBankMessage(BWP_Customer__c customer){
        String message;
        if(customer.Processor_Type__c == 'Stripe'){
            message = 'By clicking "Add Bank Account", I authorize "'+customer.Processor_Type__c+'", on behalf of "'+UserInfo.getOrganizationName()+'" (i) to verify my bank account information using bank information and consumer reports and (ii) to debit my bank account.';
        }
        if(customer.Processor_Type__c == 'Braintree'){
            message = 'By clicking "Add Bank Account", I authorize "'+customer.Processor_Type__c+'", on behalf of "'+((String.isNotBlank(customer.Company__c) || customer.Company__c != null ) ? customer.Company__c : UserInfo.getOrganizationName())+'" (i) to verify my bank account information using bank information and consumer reports and (ii) to debit my bank account.';
        }
        return message;
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
    
}