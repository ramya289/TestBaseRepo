public class CreateCustomerExtension {

    Selector_Account selectorAccount = new Selector_Account();
    Selector_Contact selectorContact = new Selector_Contact();
    Selector_BWP_Customer selectorCustomer = new Selector_BWP_Customer();
    Selector_BWP_Payment_Method selectorPaymentMethod = new Selector_BWP_Payment_Method();
    Selector_BWP_Payment selectorPayment = new Selector_BWP_Payment();

    // New Customer, Payment and Payment Method Page variables, to help identify next step/redirection
    public static final String CUST_FROM_PAYMENT = 'customerPageFromNewPayment';
    public static final String PAYMETHOD_FROM_PAYMENT = 'paymentMethodPageFromNewPayment';
    public static final String CUST_FROM_PAYMETHOD = 'customerPageFromNewPayMethod';
    public static final String NEW_PAYMETHOD = 'isCreatePayMethodPage';
    
    // Varibales to identify current running page
    public static final String PG_CUSTOMER = 'Customer';
    public static final String PG_PAYMENTMETHOD = 'Payment Method';
    public static final String PG_PAYMENT = 'Payment';
    
    public String PMType                                        {get; set;}
    public Boolean ShowTokenSetion                              {get; set;}
    Public Boolean cardPanel                          		    {get; set;}
    Public Boolean bankPanel                     				{get; set;} 
    public Boolean disableTokenBtn                              {get; set;}
    public String PMTokenValue                                  {get; set;}
    public String PMErrorValue                                  {get; set;}
    public Boolean doNotAddPM                                   {get; set;}
    
    public Boolean CustomerPage                                 {get; set;}
    public Boolean PaymentMethodPage                            {get; set;}
    public Boolean PaymentPage                                  {get; set;}
    public List<BWP_Processor_Config__c> payConfigList          {get; set;}
    public BWP_Customer__c  newCustomer                         {get; set;}
    public BWP_Processor_Config__c payConfig                    {get; set;}
    
    public Id CustomerId;
    public List<SelectOption> listOfPaymentMethods               {get; set;}
    public String PM                                             {get; set;}
    
    
    public String TestingPage                                     {get; set;}
    public Boolean areFieldsInvalid                               {get; set;}
    public String TestingPageException                                         {get; set;}
    public Map<String, String> currentpageParams                               {get; set;}
    public String ParentobjectName                                             {get; set;}
    public String parentobjlabel                                               {get; set;}
    public set<String> ParentObjectFields;
    public sObject sObj                                                        {get; set;}
    Map<String, Schema.SObjectField> SobjectFields                             {get; set;}
    public String child_object                                                 {get; set;}
    public String child_object_API_Name                                        {get; set;}
    Map<String, Schema.SObjectField> SobjectChildFields                        {get; set;}
    public sObject Child_sObj;
    map<String, String> ParentObjUrlParam                                         {get; set;}
    
    public Id parentid                                                            {get; set;}
    public String originating_record                                              {get; set;}
    public String Orgingating_Record_Name                                         {get; private set;}
    public String Parent_Account                                                  {get; set;}
    public String Account_Name                                                    {get; private set;}
    public String Customer_Name                                                   {get; set;}
    public String Customer_Name_Value                                             {get; private set;}
    public String Customer_Email                                                  {get; set;}
    public String Customer_Email_Value                                            {get; set;}
    public String Customer_Phone_Number                                           {get; set;}
    public String Customer_Phone_Number_Value                                     {get; set;}
    public String Customer_Description                                            {get; set;}
    public String Customer_Description_Value                                      {get; set;}
    public String Customer_Address1                                               {get; set;}
    public String Customer_Address1_Value                                         {get; set;}
    public String Customer_Address2                                               {get; set;}    
    public String Customer_Address2_Value                                         {get; set;}
    public String Customer_City                                                   {get; set;}
    public String Customer_City_Value                                             {get; set;}
    public String Customer_State                                                  {get; set;}
    public String Customer_State_Value                                            {get; set;}
    public String Customer_Country                                                {get; set;}    
    public String Customer_Country_Value                                          {get; set;}
    public String Customer_PostalCode                                             {get; set;}
    public String Customer_PostalCode_Value                                       {get; set;}
    
    public String Customer_InvoicePrefix                                          {get; set;}
    public String Customer_InvoicePrefix_Value                                    {get; set;}
    public String Customer_Language                                               {get; set;}
    public String Customer_Language_Value                                         {get; set;}
    public String Customer_TaxStatus                                              {get; set;}
    public String Customer_TaxStatus_Value                                        {get; set;}
    public String Customer_TaxType                                                {get; set;}
    public String Customer_TaxType_Value                                          {get; set;}
    public String Customer_TaxId                                                  {get; set;} 
    public String Customer_TaxId_Value                                            {get; set;}      
    
    public String Card_Number                                                     {get; set;}
    public String Card_Number_Value                                               {get; set;}
    
    public String child_relationship_name                                         {get; set;}
    public String Child_Object_Plural_Label                                       {get; set;}
    public String Payment_Amount                                                  {get; set;}
    public String Payment_Amount_Value                                            {get; set;}
    public String Payment_Currency                                                {get; set;}
    public String Payment_Currency_Value                                          {get; set;}
    public String Payment_Description                                             {get; set;}
    public String Payment_Description_Value                                       {get; set;}
    public String Payment_method                                                  {get; set;}
    public String Payment_method_Value                                            {get; set;}
    public String Stripe_customer                                                 {get; set;}    
    
    
    public String selectedCon                                               {get; set;}
    public Boolean initialized                                                   {get; set;}
    public Boolean activeSubscription                                            {get; set;}
    
    public List<SelectOption> TaxStatus                                             {
        get{
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('none','Taxable'));
            options.add(new SelectOption('exempt','Exempt'));
            options.add(new SelectOption('reverse','Reverse Charge'));
            return options;
        }
        private set;
    }

    public List<SelectOption> getPaymentMethodOptions(){
        return RecordInfoExtension.paymentMethodOptions;
    }

    public String PageException                                                    {get; set;}
    
    public String selectedRecordId                                                 {get; private set;}    //useful to retrieve related Customers of a selected Account/Contact
    public Boolean notInitializedWithAccount                                       {get; set;}
    public Boolean isAdministrator{
        get{
            return BreadwinnerUtil.isAdministrator();
        }
    }
    
    public boolean unMatchedAccount                                                 {get; set;}
    
    // New Payment related Fields
    public BWP_Payment__c newPayment 												{get; set;}
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

    Map<String, BWP_Payment_Method__c> paymentMethodsMap;
    BWP_Processor_Config__c appConfig;
    public Boolean isCreateCustomerPage												{get; set;}
    public Boolean isCreatePayMethodPage                                            {get; set;}
    public Boolean newCustomerPageFromPayment										{get; set;}
    public Boolean newCustomerPageFromPaymentMethod                                 {get; set;}
    public Boolean newPaymentMethodPageFromPayment								    {get; set;}
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
    Boolean createCustomerandPayment;
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
    public String applicationId														{get; set;}
    
    public Breadwinner_Settings__c bwSetting;
    public String selectedProcessorAccountType                                      {get; set;}
    public Map<String, BWP_Processor_Config__c> payConfigMap;
    public List<SelectOption> connectedProcessorsList                               {get; set;} 
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

    public decimal chargeTaxAmount                                                  {get; set;}
    public Boolean chargeIsTaxExempt                                                {get; set;}
    public Boolean isBankAuthAccepted                                               {get; set;}
    public String authorizeBankMessage                                              {get; set;}
    public Boolean isChargeSuccess;
    public String customerMatchType                                                 {get; set;}
    public String selectedObject                                                 	{get; set;}
    public CreateCustomerExtension(ApexPages.StandardController controller) {
        isBreadwinnerAdministrator = BreadwinnerUtil.isBreadwinnerAdministrator();
        payConfigList = BreadwinnerUtil.processorConfigList;
        isCreateCustomerPage = false;
        isCreatePayMethodPage = false;
        PaymentMethodPage  = false;
        PaymentPage = false;
        CustomerPage = true;
        TestingPage = 'false';
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
        String pageName = ApexPages.currentPage().getUrl().split('apex/')[1];
        isCreateCustomerPage = pageName.containsIgnoreCase('CreateCustomer');
        isCreatePayMethodPage = pageName.containsIgnoreCase('CreatePaymentMethod');
        payConfig = payConfigList.size()>0 ? payConfigList[0] : new BWP_Processor_Config__c();
        selectedProcessorName = String.isNotBlank(payConfig.Name) ? payConfig.Name : '';
        selectedProcessorAccountName = String.isNotBlank(payConfig.Account_Name__c) ? payConfig.Account_Name__c : '';
        selectedProcessorAccountType = String.isNotBlank(payConfig.Payment_Processor_Type__c) ? payConfig.Payment_Processor_Type__c : '';
        bwSetting =  BreadwinnerUtil.getBWSetting();
        isBreadwinnerReadOnlyMode = bwSetting.Read_Only_Mode__c;
        hasMultiplePmTypes = RecordInfoExtension.hasMultiplePmTypes(selectedProcessorAccountType);
        system.debug('page name------'+pageName);
        if(isCreateCustomerPage){
            newCustomer = (BWP_Customer__c)controller.getRecord();
            selectedObject = newCustomer.Salesforce_Account__c != null ? ProcessorUtil.CMT_ACCOUNT : newCustomer.Salesforce_Contact__c != null ? ProcessorUtil.CMT_CONTACT : '';
            newCustomerPageFromPayment = pageName.containsIgnoreCase(CUST_FROM_PAYMENT);
            newPaymentMethodPageFromPayment = pageName.containsIgnoreCase(PAYMETHOD_FROM_PAYMENT);
            newCustomerPageFromPaymentMethod = pageName.containsIgnoreCase(CUST_FROM_PAYMETHOD);
            paymentMethodFromNewPaymentMethodPage = pageName.containsIgnoreCase(NEW_PAYMETHOD);
            if(newCustomerPageFromPayment || newCustomerPageFromPaymentMethod){
                CustomerPage = true;
            }
            else if(newPaymentMethodPageFromPayment || paymentMethodFromNewPaymentMethodPage){
                CustomerPage = false;
                PaymentMethodPage = true;
                selectedBWPCustomer = String.isNotBlank(ApexPages.currentPage().getParameters().get('selectedBWPCustomer')) ? (ApexPages.currentPage().getParameters().get('selectedBWPCustomer')) : '';
                selectedProcessorName = String.isNotBlank(ApexPages.currentPage().getParameters().get('processorName')) ? (ApexPages.currentPage().getParameters().get('processorName')) : '';
                payConfig = payConfigList.size()>0 ? BreadwinnerUtil.getProcessorConfig(selectedProcessorName) : new BWP_Processor_Config__c();
                customerInfo = queryCustomerInfo(selectedBWPCustomer);
                hasMultiplePmTypes = RecordInfoExtension.hasMultiplePmTypes(customerInfo.Processor_Type__c);
                authorizeBankMessage = RecordInfoExtension.authorizeBankMessage(customerInfo);
                if(customerInfo.Processor_Type__c ==  ProcessorUtil.PAT_SQUARE)
                    applicationId = Processor_Square.getClientId(payConfig.Live_Mode__c == True ? 'live' : 'test');
            }
        }
        else if(isCreatePayMethodPage){
            newPayMethod = (BWP_Payment_Method__c)controller.getRecord();
            selectedObject = newPayMethod.Account__c != null ? ProcessorUtil.CMT_ACCOUNT : newPayMethod.Contact__c != null ? ProcessorUtil.CMT_CONTACT : '';
            newCustomer = new BWP_Customer__c();
        }
        else{
            newPayment = (BWP_Payment__c)controller.getRecord();
            selectedObject = newPayment.Account__c != null ? ProcessorUtil.CMT_ACCOUNT : newPayment.Contact__c != null ? ProcessorUtil.CMT_CONTACT : '';
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
        createCustomerandPayment = false;
        payConfigMap = new Map<String, BWP_Processor_Config__c>();
        paymentMethodInfo = new BWP_Payment_Method__c();
        if(payConfigList.size() > 0){
            for(BWP_Processor_Config__c payConfig : payConfigList){
                if(String.isNotBlank(payConfig.Customer_Match_Type__c)){
                    customerMatchType = payConfig.Customer_Match_Type__c;
                }
                payConfigMap.put(payConfig.Provider_ID__c, payConfig);
                connectedProcessorsList.add(new SelectOption(payConfig.Provider_ID__c, payConfig.Payment_Processor_Type__c+' - '+(String.isNotBlank(payConfig.Account_Name__c) ? payConfig.Account_Name__c : payConfig.Provider_ID__c)));
            }
        }
        selectedObject = String.isNotBlank(selectedObject) ? selectedObject : String.isNotBlank(customerMatchType) ? customerMatchType : ProcessorUtil.CMT_ACCOUNT;
        customerMatchType = String.isNotBlank(customerMatchType) ? customerMatchType : selectedObject;
        if(isCreateCustomerPage){
            customerMatchTypeError(PG_CUSTOMER, selectedObject, customerMatchType);
            newPayment = new BWP_Payment__c();
            newPayMethod = new BWP_Payment_Method__c();
            ParentObjectFields = new set<String>();
            ParentObjUrlParam = new map<string, string>();
            ShowTokenSetion = true;
            cardPanel = true;
            bankPanel = false;
            PMType = ProcessorUtil.PM_CARD;
            PageException = '';
            unMatchedAccount = false;
            doNotAddPM = false;
            SobjectFields = new Map<string, Schema.SObjectField>();
            Customer_Name_Value = '';
            Customer_Email_Value = '';
            Customer_Phone_Number_Value = '';
            Customer_Description_Value = '';
            Customer_Address1_Value = '';
            Customer_Address2_Value = '';
            Customer_City_Value = '';
            Customer_State_Value = '';
            Customer_Country_Value = '';
            Customer_PostalCode_Value = '';
            Customer_InvoicePrefix_Value = '';
            Customer_Language_Value = '';
            Customer_TaxStatus_Value = '';
            Customer_TaxType_Value = '';
            Customer_TaxId_Value = '';
            Card_Number_Value = '';
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
            /* Commenting the below code as it's not being used. It can be used to Create Customer, Payment Method or Payment from a Custom Url.
            else{       
                system.debug('from Custom URL');
                currentpageParams = ApexPages.currentPage().getParameters();
                TestingPage = currentpageParams.get('testing');
                Parent_Account = currentpageParams.get('Parent_Account');
                Customer_Name = currentpageParams.get('Customer_Name');
                Customer_Email = currentpageParams.get('Customer_Email');
                Customer_Phone_Number = currentpageParams.get('Customer_Phone_Number');
                Customer_Description = currentpageParams.get('Customer_Description');
                Customer_Address1 = currentpageParams.get('Customer_Address1');
                Customer_Address2 = currentpageParams.get('Customer_Address2');
                Customer_City = currentpageParams.get('Customer_City');
                Customer_State = currentpageParams.get('Customer_State');
                Customer_Country = currentpageParams.get('Customer_Country');
                Customer_PostalCode = currentpageParams.get('Customer_PostalCode');
                Customer_InvoicePrefix = currentpageParams.get('Customer_InvoicePrefix');
                Customer_Language = currentpageParams.get('Customer_Language');
                Customer_TaxStatus = currentpageParams.get('Customer_TaxStatus');
                Customer_TaxType = currentpageParams.get('Customer_TaxType');
                Customer_TaxId = currentpageParams.get('Customer_TaxId');
                


                Card_Number = currentpageParams.get('Card_Number');
                
                Payment_Amount = currentpageParams.get('Payment_Amount');
                Payment_Currency = currentpageParams.get('Payment_Currency');
                Payment_Description = currentpageParams.get('Payment_Description');
                Payment_method = currentpageParams.get('Payment_method');
                Stripe_customer = currentpageParams.get('Stripe_customer');
                
                Child_Relationship_Name = currentpageParams.get('Child_Relationship_Name');
                
                if(String.isNotBlank(currentpageParams.get('originating_record')) ){
                    selectedCon = 'createnewstripecontact';
                    parentid = currentpageParams.get('originating_record').replace('/','').trim();
                    
                    Schema.SObjectType sobjectType = parentid.getSObjectType();
                    ParentobjectName = sobjectType.getDescribe().getName();
                    parentobjlabel = sobjectType.getDescribe().getlabel();
                    
                    sObj = sobjectType.newSObject();
                    List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{ParentobjectName});
                    SobjectFields = sobjectType.getdescribe().fields.getMap();
                    
                    if(String.isNotBlank(Parent_Account))
                        ParentObjectFields.add(Parent_Account.ToLowerCase());
                    
                    List<Schema.ChildRelationship> Childrelationship = describeSobjectsResult[0].getChildRelationships();
                    if(String.isNotBlank(Child_Relationship_Name)){            
                        String crn1 = Child_Relationship_Name;
                        String crn2 = '';
                        if(crn1.endsWithIgnoreCase('__r')){
                            crn2 = Child_Relationship_Name.removeEndIgnoreCase('__r');
                        }
                        else{
                            crn2 = crn1 +'__r';
                        }                 
                        
                        for(Schema.ChildRelationship s : Childrelationship){
                            //if(s.getRelationshipName() == child_relationship_name)
                            if(s.getRelationshipName() == crn1 || s.getRelationshipName() == crn2){
                                Child_Relationship_Name = s.getRelationshipName();
                                List<Schema.DescribeSObjectResult> describeSobjectsResult1 = Schema.describeSObjects(new List<String>{string.valueof(s.getChildSObject())});// this can accept list of strings, we describe only one object here
                                
                                child_object = describeSobjectsResult1[0].getLabel();
                                child_object_API_Name = describeSobjectsResult1[0].getName();
                                SobjectChildFields = describeSobjectsResult1[0].fields.getMap();
                                Child_Object_Plural_Label = describeSobjectsResult1[0].getLabelPlural();
                                system.debug('SobjectChildFields '+SobjectChildFields);
                                system.debug('child_object'+child_object);
                            }  
                        } 
                        if(SobjectChildFields == null ){
                            TestingPageException = (String.isNotBlank(TestingPageException)? (TestingPageException+ '\n') : '' )+ ' Invalid Child_Relationship_Name for the object: '+parentobjlabel;
                        }   
                    }
                    for(string param : currentpageParams.keyset()){
                        if((param.trim().ToLowercase()=='parent_account' || param.trim().ToLowercase()=='customer_name' || param.trim().ToLowercase()=='customer_email' ||param.trim().ToLowercase()=='customer_phone_number' ||param.trim().ToLowercase()=='customer_description' ||param.trim().ToLowercase()=='customer_address1' ||param.trim().ToLowercase()=='customer_address2' ||param.trim().ToLowercase()=='customer_city'||param.trim().ToLowercase()=='customer_state'||param.trim().ToLowercase()=='customer_country'||param.trim().ToLowercase()=='customer_postalcode'||param.trim().ToLowercase()=='Customer_Language'||param.trim().ToLowercase()=='Customer_TaxStatus'||param.trim().ToLowercase()=='Customer_TaxType'||param.trim().ToLowercase()=='Customer_TaxId'||param.trim().ToLowercase()=='Customer_InvoicePrefix'))
                        { 
                            ParentObjUrlParam.put(param.tolowercase().trim(), currentpageParams.get(param).trim().ToLowercase());
                            if(String.isNotBlank(ParentObjUrlParam.get(param.tolowercase().trim())))
                                ParentObjectFields.add(ParentObjUrlParam.get(param.tolowercase().trim()));
                        }
                    }
                    
                    if(true){
                        try{
                            schema.describefieldresult ParentAccountresult;
                            if(Parent_Account != null && SobjectFields.containskey(Parent_Account))
                                ParentAccountresult = SobjectFields.get(Parent_Account).getDescribe();
                            system.debug(ParentObjectFields);
                            String q='SELECT Id';//+Parent_Account;//+','+Parent_Account.replace('__c','__r')+'.name';
                            if(SobjectFields.containsKey('name'))
                                q += ', name';
                            ParentObjectFields.remove('id');
                            ParentObjectFields.remove('Id');
                            ParentObjectFields.remove('name');
                            for(string s : ParentObjectFields){ 
                                q += ','+s;
                            }
                            if(ParentAccountresult!=null && ParentAccountresult.getCalculatedFormula()!=null)
                                q += ','+ParentAccountresult.getCalculatedFormula();
                            q += ' FROM '+ParentobjectName+' WHERE '+ 'id =\''+parentid+'\'';
                            system.debug(q);
                            if(Schema.getGlobalDescribe().get(ParentobjectName).getDescribe().isAccessible()){
                                //TODO: migrate to QueryBuilder
                                Sobj = Database.query(q);
                            }
                            
                            newCustomer.Customer_Name__c = String.isNotBlank(Customer_Name) ? String.valueOf(Sobj.get(Customer_Name)) : '';
                            newCustomer.Email__c = String.isNotBlank(Customer_Email) ? String.valueOf(Sobj.get(Customer_Email)):'';
                            newCustomer.Customer_Phone__c = String.isNotBlank(Customer_Phone_Number) ? String.valueOf(Sobj.get(Customer_Phone_Number)) : '';
                            newCustomer.Description__c = String.isNotBlank(Customer_Description) ? String.valueOf(Sobj.get(Customer_Description)) : '';
                            newCustomer.Billing_Street_Address_1__c = String.isNotBlank(Customer_Address1) ? String.valueOf(Sobj.get(Customer_Address1)) : '';
                            newCustomer.Billing_Street_Address_2__c = String.isNotBlank(Customer_Address2) ? String.valueOf(Sobj.get(Customer_Address2)) : '';
                            newCustomer.Billing_City__c = String.isNotBlank(Customer_City) ? String.valueOf(Sobj.get(Customer_City)) : '';
                            newCustomer.Billing_State__c = String.isNotBlank(Customer_State) ? String.valueOf(Sobj.get(Customer_State)):'';
                            newCustomer.Billing_Country__c = String.isNotBlank(Customer_Country) ? String.valueOf(Sobj.get(Customer_Country)) : '';
                            newCustomer.Billing_Postal_Code__c = String.isNotBlank(Customer_PostalCode) ? String.valueOf(Sobj.get(Customer_PostalCode)) : '';
                            try{
                                if(String.isNotBlank(parent_account)){
                                    newCustomer.Salesforce_Account__c = (id)(Sobj.get(parent_account));
                                    selectedRecordId = (id)sObj.get(parent_account);
                                }
                                if(SobjectFields.containsKey('name')){      
                                    Orgingating_Record_Name = String.valueOf(sObj.get('name'));
                                }       
                                if(String.isNotBlank(selectedRecordId)){
                                    Account_Name = selectorAccount.selectById(new Set<String>{selectedRecordId})[0].Name;
                                }       
                                else{       
                                    TestingPageException = (String.isNotBlank(TestingPageException)? (TestingPageException+ '\n\n\n') : '' ) + 'Account is not selected for this '+parentobjlabel+' record. Customer can not be created without an Account.';
                                    TestingPage = 'true';
                                }

                                Customer_Name_Value = (String.isNotBlank(Customer_Name)) ? String.valueOf(Sobj.get(Customer_Name)) : '';
                                Customer_Email_Value = String.isNotBlank(Customer_Email) ? String.valueOf(Sobj.get(Customer_Email)) : '';
                                Customer_Phone_Number_Value = String.isNotBlank(Customer_Phone_Number) ? String.valueOf(Sobj.get(Customer_Phone_Number)) : '';
                                Customer_Description_Value = String.isNotBlank(Customer_Description) ? String.valueOf(Sobj.get(Customer_Description)) : '';
                                Customer_Address1_Value = String.isNotBlank(Customer_Address1) ? String.valueOf(Sobj.get(Customer_Address1)) : '';
                                Customer_Address2_Value = String.isNotBlank(Customer_Address2) ? String.valueOf(Sobj.get(Customer_Address2)) : '';
                                Customer_City_Value = String.isNotBlank(Customer_City) ? String.valueOf(Sobj.get(Customer_City)) : '';
                                Customer_State_Value = String.isNotBlank(Customer_State) ? String.valueOf(Sobj.get(Customer_State)) : '';
                                Customer_Country_Value = String.isNotBlank(Customer_Country) ? String.valueOf(Sobj.get(Customer_Country)) : '';
                                Customer_PostalCode_Value = String.isNotBlank(Customer_PostalCode) ? String.valueOf(Sobj.get(Customer_PostalCode)) : '';
                            }
                            catch(exception e){
                                PageException = 'Please check the Parent Account field you have entered '+e.getmessage();
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' '+PageException));
                            }
                            
                            newCustomer.Invoice_Prefix__c = String.isNotBlank(Customer_InvoicePrefix) ? String.valueOf(Sobj.get(Customer_InvoicePrefix)) : '';
                            newCustomer.Language__c = String.isNotBlank(Customer_Language) ? String.valueOf(Sobj.get(Customer_Language)) : '';
                            newCustomer.Tax_Exempt__c = String.isNotBlank(Customer_TaxStatus) ? String.valueOf(Sobj.get(Customer_TaxStatus)) : '';
                            newCustomer.Tax_Type__c = String.isNotBlank(Customer_TaxType) ? String.valueOf(Sobj.get(Customer_TaxType)) : '';
                            newCustomer.Tax_Id__c = String.isNotBlank(Customer_TaxId) ? String.valueOf(Sobj.get(Customer_TaxId)) : '';
                        }catch(exception e){
                            TestingPageException = e.getMessage();
                            areFieldsInvalid = true;
                            system.debug(e.getStackTraceString());
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' '+e));
                            if(String.isBlank(TestingPage)){        
                                TestingPage = 'true';
                            }
                        } 
                    }
                }
            }
            */
            if(String.isBlank(selectedRecordId)){
                notInitializedWithAccount = true;
            }
        }
        else if(isCreatePayMethodPage){
            isPayMethodFromStandardNewButton = false;
            selectedBWPCustomer = String.isNotBlank(defaultSelection) ? defaultSelection : '';
            paymentMethodsMap = new Map<String, BWP_Payment_Method__c>();
            getSelectedRecordId(newPayMethod.Account__c, newPayMethod.Contact__c, getCurrentPageRecordId());
            querySelectedobject(selectedRecordId);
            if(String.isBlank(selectedRecordId)){
                isPayMethodFromStandardNewButton = true;
            }
            customerMatchTypeError(PG_PAYMENTMETHOD, selectedObject, customerMatchType);
        }
        else{
            isPaymentFromStandardNewButton = false;
            selectedBWPCustomer = String.isNotBlank(defaultSelection) ? defaultSelection : '';
            paymentMethodsMap = new Map<String, BWP_Payment_Method__c>();
            getSelectedRecordId(newPayment.Account__c, newPayment.Contact__c, getCurrentPageRecordId());
            querySelectedobject(selectedRecordId);
            if(String.isBlank(selectedRecordId)){
                isPaymentFromStandardNewButton = true;
            }
            customerMatchTypeError(PG_PAYMENT, selectedObject, customerMatchType);
        }
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
            CustomerPage = false;
            PaymentMethodPage = true;
            isCustomerSelected = true;
            listOfPaymentMethods = getListOfPaymentMethods(selectedBWPCustomer);
            customerInfo = selectorCustomer.selectByProcessorCustomerId_WithPaymentMethods(new Set<String>{selectedBWPCustomer},1,50)[0];
            selectedProcessorName = customerInfo.Processor_Org_Id__c;
            if(String.isNotBlank(customerInfo.Default_Source__c)){
                //TODO: does this query make sense?  You're quering the the processor_id by the defualt_Source
                // shouldn't this just be selectedPaymentMethod = customerInfo.Default_Source__c
                selectedPaymentMethod = [SELECT Id, Processor_Id__c FROM BWP_Payment_Method__c WHERE Processor_Id__c =: customerInfo.Default_Source__c WITH SECURITY_ENFORCED].Processor_Id__c;
            }
            else{
                selectedPaymentMethod = 'createNewBWPPaymentMethod';
            }
            if(String.isNotBlank(selectedPaymentMethod) && paymentMethodsMap.get(selectedPaymentMethod) == null){
                selectedPaymentMethod = 'createNewBWPPaymentMethod';
            }
            if(isCreatePayMethodPage){
                isCustomerSelected = true;
                PageReference pageRef = new PageReference('/apex/CreateCustomer?'+NEW_PAYMETHOD+'=true&testing=false'+(String.isNotBlank(selectedBWPCustomer) ? ('&selectedBWPCustomer='+selectedBWPCustomer) : '')+(String.isNotBlank(selectedProcessorName) ? ('&processorName='+selectedProcessorName) : ''));
                return pageRef;
            }
            system.debug('default source---'+customerInfo.Default_Source__c);
            system.debug('customer related prceossor id-------'+selectedProcessorName);
            //listOfPaymentMethods = getlistOfPaymentMethods(selectedBWPCustomer);
        }
        else if(isCreatePayMethodPage && selectedBWPCustomer == 'createNewBWPCustomer'){
            CustomerPage = true;
            PageReference pageRef = new PageReference('/apex/CreateCustomer?'+CUST_FROM_PAYMETHOD+'=true'+(String.isNotBlank(selectedRecordId) ? ('&recordId='+selectedRecordId) : ''));
            return pageRef; 
        }
        else{
            CustomerPage = true;
            PageReference pageRef = new PageReference('/apex/CreateCustomer?'+CUST_FROM_PAYMENT+'=true'+(String.isNotBlank(selectedRecordId) ? ('&recordId='+selectedRecordId) : ''));
            return pageRef;
        }
        return null;
    } 
    public pagereference redirectToPaymentPage(){
        if(selectedPaymentMethod != 'createNewBWPPaymentMethod'){
            PaymentMethodPage = false;
            PaymentPage = true;
            isPaymentMethodSelected = true;
            listOfPaymentMethods = getListOfPaymentMethods(selectedBWPCustomer);
            system.debug('selectedPaymentMethod------------'+selectedPaymentMethod);
            paymentMethodInfo = selectorPaymentMethod.selectByProcessorId(selectedPaymentMethod,1)[0];
        }
        else{
            selectedProcessorName = selectorCustomer.selectByProcessorCustomerId(new Set<String>{selectedBWPCustomer},1)[0].Processor_Org_Id__c;
            PageReference pageRef = new PageReference('/apex/CreateCustomer?'+PAYMETHOD_FROM_PAYMENT+'=true&testing=false'+(String.isNotBlank(selectedBWPCustomer) ? ('&selectedBWPCustomer='+selectedBWPCustomer) : '')+(String.isNotBlank(selectedProcessorName) ? ('&processorName='+selectedProcessorName) : ''));
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
            BWP_Processor_Config__c appC = payConfigList.size() > 0 ? BreadwinnerUtil.getProcessorConfig(selectedProcessorName) : new BWP_Processor_Config__c();
            Map<String,Object> request = new Map<String,Object>();
            Map<String,Object> response = new Map<String,Object>();
            request.put(ProcessorUtil.API_ACTION, ProcessorUtil.ACT_CHARGE_PROCESSOR);
            request.put(ProcessorUtil.API_VERSION, ProcessorUtil.VER_1);
            request.put(ProcessorUtil.API_PROCESSOR_ID,appC.Provider_ID__c);

            if(newPayment.Amount__c == null || newPayment.Amount__c <= 0){
                errorMessage = ' Amount must be greater than 0.';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));
                return null;
            }
            if(customerInfo.Processor_Type__c == ProcessorUtil.PAT_STRIPE){
                if(String.isNotBlank(newPayment.Description__c) && newPayment.Description__c.length()>=1000){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' Description must be at most 1000 characters'));
                }
                if (ApexPages.hasMessages(ApexPages.Severity.ERROR)){
                    return null;
                }
                response = chargeCustomer_Stripe(request);
            }
            else if(customerInfo.Processor_Type__c == ProcessorUtil.PAT_BRAINTREE){
                response = chargeCustomer_Braintree(request);
            }
            else if(customerInfo.Processor_Type__c == ProcessorUtil.PAT_SQUARE){
                response = chargeCustomer_Square(request);
            }
            if(isChargeSuccess){
                APICallHandler.userInteractionLogPush(FALSE, 'Payment Created', (String.isNotBlank(selectedRecordId) ? customerMatchType : ((String.isNotBlank(ParentobjectName) && String.isNotBlank(parentobjlabel)) ? (parentobjlabel + ' (' + ParentobjectName + ')') : 'BWP Customer')), 'A new '+customerInfo.Processor_Type__c+' Payment is created from Breadwinner Payments');
                List<ProcessorUtil.PaymentWrapper> paymentResp = (List<ProcessorUtil.PaymentWrapper>) response.get(ProcessorUtil.PAYMENT_RESP);
                BWP_Payment__c newPayment = selectorPayment.selectByProcessorId(new Set<String>{paymentResp[0].processorId}, null)[0];
				return new PageReference('/' + newPayment.Id);
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
    private Map<String,Object> chargeCustomer_Stripe(Map<String,Object> request){
        BWP_Payment_Method__c selectedPaymentMethodDetails = String.isNotBlank(selectedPaymentMethod) ? paymentMethodsMap.get(selectedPaymentMethod) : new BWP_Payment_Method__c();
        Charge.StripeCharge ch = new Charge.StripeCharge();
        ch.amount = newPayment.Amount__c > 0 ? newPayment.Amount__c : 0;
        ch.customer = selectedPaymentMethodDetails.Processor_Customer_Id__c;
        ch.stripe_currency = string.isNotBlank(newPayment.Currency__c) ? newPayment.Currency__c : '';
        ch.description = newPayment.Description__c;
        ch.paymentMethod = selectedPaymentMethodDetails.Processor_Id__c;
        ch.paymentMethodType = selectedPaymentMethodDetails.Type__c;
        
        Map<String, List<Charge.StripeCharge>> chargeMap = new Map<String, List<Charge.StripeCharge>>();
        chargeMap.put('charge', new List<Charge.StripeCharge>{ch});
        
        request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(chargeMap));
        System.debug('ChargeCustomer request: ' + request);
        
        Map<String, Object> response =  BreadwinnerPaymentsAPI.call(request);
        System.debug('ChargeCustomer response: ' + response);
        
        isChargeSuccess = ProcessorUtil.isValidResponse(response);
        
        return response;
    }
    private Map<String,Object> chargeCustomer_Braintree(Map<String,Object> request){
        BWP_Payment_Method__c selectedPaymentMethodDetails = String.isNotBlank(selectedPaymentMethod) ? paymentMethodsMap.get(selectedPaymentMethod) : new BWP_Payment_Method__c();
        Charge.BraintreeCharge ch = new Charge.BraintreeCharge();
        Charge.Amount amount = new Charge.Amount();  
        amount.value = String.valueOf(newPayment.Amount__c);
        ch.amount = amount;
        Charge.Customer customer = new Charge.Customer(); 
        customer.id = selectedPaymentMethodDetails.Processor_Customer_Id__c;
        ch.customer = customer;
        Charge.PaymentMethod paymentMethod = new Charge.PaymentMethod(); 
        paymentMethod.id = selectedPaymentMethodDetails.Processor_Id__c;
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
        
        BWP_Payment_Method__c selectedPaymentMethodDetails = String.isNotBlank(selectedPaymentMethod) ? paymentMethodsMap.get(selectedPaymentMethod) : new BWP_Payment_Method__c();
        
        Charge.SquareCharge ch = new Charge.SquareCharge();
        Charge.Money money = new Charge.Money();
        money.amount =  newPayment.Amount__c > 0 ? newPayment.Amount__c*100 : 0;
        money.square_currency = string.isNotBlank(newPayment.Currency__c) ? newPayment.Currency__c.toUppercase() : '';
        ch.amount_money = money;
        ch.customer_id = selectedPaymentMethodDetails.Processor_Customer_Id__c;
        ch.source_id = selectedPaymentMethodDetails.Processor_Id__c;
        ch.idempotency_key = idempotencyKey;
        
        Map<String, List<Charge.SquareCharge>> chargeMap = new Map<String, List<Charge.SquareCharge>>();
        chargeMap.put('charge', new List<Charge.SquareCharge>{ch});
        
        request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(chargeMap));
        System.debug('ChargeCustomer request: ' + request);
        
        Map<String, Object> response =  BreadwinnerPaymentsAPI.call(request);
        System.debug('ChargeCustomer response: ' + response);
        
        isChargeSuccess = ProcessorUtil.isValidResponse(response);
        
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
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Breadwinner doesn\'t support the creation of Customer for the Processor ' + selectedProcessorAccountType));
                return null;
            }

            if(isCustomerCreated){
                List<ProcessorUtil.CustomerWrapper> customerResp = (List<ProcessorUtil.CustomerWrapper>) response.get(ProcessorUtil.CUST_RESP);
                if(customerResp != NULL){
                    PaymentMethodPage = true;
                    CustomerPage = false;
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
                        applicationId = Processor_Square.getClientId(payConfig.Live_Mode__c == True ? 'live' : 'test');
                    }
                    hasMultiplePmTypes = RecordInfoExtension.hasMultiplePmTypes(selectedProcessorAccountType);
                    selectedBWPCustomer = customerInfo.Processor_Customer_Id__c;
                    selectedProcessorName = customerInfo.Processor_Org_Id__c;
                    authorizeBankMessage = RecordInfoExtension.authorizeBankMessage(customerInfo);
                    APICallHandler.userInteractionLogPush(FALSE, 'Customer Created', (String.isNotBlank(selectedRecordId) ? customerMatchType : ((String.isNotBlank(ParentobjectName) && String.isNotBlank(parentobjlabel)) ? (parentobjlabel + ' (' + ParentobjectName + ')') : 'BWP Customer')), 'A new '+selectedProcessorAccountType+' Customer is created from Breadwinner Payments');

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
            BWP_Processor_Config__c payConfig = payConfigList.size() > 0 ? BreadwinnerUtil.getProcessorConfig(selectedProcessorName) : new BWP_Processor_Config__c();

            request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(requestMap));
            System.debug('Stripe CreateCustomer request: ' + request);
            response =  BreadwinnerPaymentsAPI.call(request);
            System.debug('Stripe CreateCustomer response: ' + response);

            isCustomerCreated = ProcessorUtil.isValidResponse(response);
        }
        else{
            CustomerPage = true;PaymentMethodPage  = false; 
        }
        return response;
    }
    private Map<String,Object> createCustomer_Braintree(Map<String,Object> request){
        Customer.BraintreeCustomer braintreeCustomer = new Customer.BraintreeCustomer();
        Map<String, Object> response = new Map<String, Object>();
        BWP_Processor_Config__c payConfig = payConfigList.size() > 0 ? BreadwinnerUtil.getProcessorConfig(selectedProcessorName) : new BWP_Processor_Config__c();
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
            CustomerPage = true;PaymentMethodPage  = false;
        }
        return response;
    }
    private Map<String,Object> createCustomer_Square(Map<String,Object> request){
        Customer.SquareCustomer squareCustomer = new Customer.SquareCustomer();
        Map<String, Object> response = new Map<String, Object>();
        BWP_Processor_Config__c payConfig = payConfigList.size() > 0 ? BreadwinnerUtil.getProcessorConfig(selectedProcessorName) : new BWP_Processor_Config__c();
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
            CustomerPage = true;PaymentMethodPage  = false;
        }
        return response;
    }
    
    public pageReference createPaymentMethod(){
        BWP_Processor_Config__c appC = payConfigList.size() > 0 ? BreadwinnerUtil.getProcessorConfig(selectedProcessorName) : new BWP_Processor_Config__c();
        
        if(PMType == ProcessorUtil.PM_CARD && appC.Payment_Processor_Type__c != ProcessorUtil.PAT_SQUARE){
            errorMessage = RecordInfoExtension.validateCard(cardNumber, cardExpiryMonth, cardExpiryYear);
            if(String.isNotBlank(errorMessage)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' '+ errorMessage));
                return null;
            } 
        }
        else if(PMType == ProcessorUtil.PM_BANK){
            errorMessage = RecordInfoExtension.validateBankAccount(appC.Payment_Processor_Type__c, bankPMAccountHolderName, bankPMRoutingNumber, bankPMAccountNumber);
            if(String.isNotBlank(errorMessage)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' '+ errorMessage));
                return null;
            }
        }
        
        Map<String,Object> request = new Map<String,Object>();
        Map<String, Object> response = new Map<String, Object>();
        request.put(ProcessorUtil.API_ACTION, (PMType == ProcessorUtil.PM_CARD ? ProcessorUtil.ACT_CREATE_CARD_TOKEN : ProcessorUtil.ACT_CREATE_BANK_TOKEN));
        request.put(ProcessorUtil.API_VERSION, ProcessorUtil.VER_1);
        request.put(ProcessorUtil.API_PROCESSOR_ID,appC.Provider_ID__c);
        
        if(appC.Payment_Processor_Type__c == ProcessorUtil.PAT_STRIPE){
            if(PMType == ProcessorUtil.PM_CARD){
                response = createCard_Stripe(request, selectedBWPCustomer);
            }
            else if(PMType == ProcessorUtil.PM_BANK){
                if (String.isBlank(bankPMConfirmAccountNumber)){
                    errorMessage = 'Please confirm Bank Account Number.';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' '+ errorMessage));
                    return null;
                }
                if(!isBankAuthAccepted){
                    errorMessage = RecordInfoExtension.bankAuthMessage();
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' '+ errorMessage));
                    return null;
                }
                response = createBankAccount_Stripe(request, selectedBWPCustomer);
            }
        }
        else if(appC.Payment_Processor_Type__c == ProcessorUtil.PAT_BRAINTREE){
            if(PMType == ProcessorUtil.PM_CARD){
                response = createCard_Braintree(request, selectedBWPCustomer);
            }
            else if(PMType == ProcessorUtil.PM_BANK){
                errorMessage = RecordInfoExtension.validateBraintreeOwner(bankPMAccountHolderType, bankPMBusinessOwnerName, bankPMIndividualOwnerFirstName,  bankPMIndividualOwnerLastName);
                if(String.isNotBlank(errorMessage)){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ' '+ errorMessage));
                    return null;
                }
                if(!isBankAuthAccepted){
                    errorMessage = RecordInfoExtension.bankAuthMessage();
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ' '+ errorMessage));
                    return null;
                }
                response = createBankAccount_Braintree(request, selectedBWPCustomer);
            }
        }
        else if(appC.Payment_Processor_Type__c == ProcessorUtil.PAT_SQUARE){
            if(String.isBlank(squareCardErrors) && String.isBlank(cardPostalCode) && String.isNotBlank(PMTokenValue)){
                errorMessage = 'Please enter valid Postal Code in More Options section';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' '+ errorMessage));
                return null;
            }
            if(String.isBlank(squareCardErrors) && String.isNotBlank(PMTokenValue))
                response = createCard_Square(request, selectedBWPCustomer);
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' Creation of Payment Method via Breadwinner Payments has not been enabled for this Processor Type. Please contact Breadwinner Support for more information.'));
            return null;
        }
        if(isPaymentMethodCreated){
            PaymentMethodPage = false;
            PaymentPage = true;
            if(PMType == ProcessorUtil.PM_BANK){
                PaymentPage = false;
            }
            listOfPaymentMethods = new List<SelectOption>();
            listOfPaymentMethods = getListOfPaymentMethods(selectedBWPCustomer);
         
            List<ProcessorUtil.PaymentMethodWrapper> payMethodList = (List<ProcessorUtil.PaymentMethodWrapper>) response.get(ProcessorUtil.PAYMETHOD_RESP);
            Set<String> createdPayMethodIds = new Set<String>();
            for(ProcessorUtil.PaymentMethodWrapper payMethod : payMethodList){
                createdPayMethodIds.add(payMethod.processorId);                
            }
            APICallHandler.userInteractionLogPush(false, 'Payment Method Created', (String.isNotBlank(selectedRecordId) ? customerMatchType : ((String.isNotBlank(ParentobjectName) && String.isNotBlank(parentobjlabel)) ? (parentobjlabel +' ('+ParentobjectName+')') : 'BWP Customer')), 'A new '+appC.Payment_Processor_Type__c+' Payment Method is created from Breadwinner Payments');
            newPayMethod = selectorPaymentMethod.selectByProcessorId(createdPayMethodIds,1)[0];
            paymentMethodInfo = newPayMethod;
            selectedPaymentMethod = newPayMethod.Processor_Id__c;
            createdPayMethodId = newPayMethod.Processor_Id__c;
            if(newCustomerPageFromPaymentMethod || paymentMethodFromNewPaymentMethodPage){
                return new PageReference('/' + newPayMethod.Id);
            }
        }
        else if(!response.isEmpty()){
            processResponseFailure(response);
        }
        return null;
    }
    public Map<String,Object> createCard_Stripe(Map<String,Object> request, String selectedBWPCustomer){
        Customer.StripeCustomer customer = new Customer.StripeCustomer();
        customer.Id = selectedBWPCustomer;
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
    public Map<String,Object> createCard_Braintree(Map<String,Object> request, String selectedBWPCustomer){
        Customer.BraintreeCustomer customer = new Customer.BraintreeCustomer();
        customer.id = selectedBWPCustomer;
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
    public Map<String,Object> createCard_Square(Map<String,Object> request, String selectedBWPCustomer){
        Customer.SquareCustomer customer = new Customer.SquareCustomer();
        customer.id = selectedBWPCustomer;
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
    
    public Map<String,Object> createBankAccount_Stripe(Map<String,Object> request, String selectedBWPCustomer){
        Customer.StripeCustomer customer = new Customer.StripeCustomer();
        customer.Id = selectedBWPCustomer;
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
        isBankAccountCreated = isPaymentMethodCreated;
        return response;
    }
    public Map<String,Object> createBankAccount_Braintree(Map<String,Object> request, String selectedBWPCustomer){
        Customer.BraintreeCustomer customer = new Customer.BraintreeCustomer();
        customer.id = selectedBWPCustomer;
        List<BWP_Customer__c> customersList = selectorCustomer.selectByProcessorCustomerId(new Set<String>{selectedBWPCustomer}, 1);
        customer.company = customersList.size()>0 ? customersList[0].Company__c : '';
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
		isBankAccountCreated = isPaymentMethodCreated;
        return response;
    }
    
    public pageReference verifyBankAccount(){
        BWP_Processor_Config__c appC = payConfigList.size() > 0 ? BreadwinnerUtil.getProcessorConfig(selectedProcessorName) : new BWP_Processor_Config__c();
        try{
            Customer.verifyBankAccount verify = new Customer.verifyBankAccount();
            verify.customerId = selectedBWPCustomer;
            verify.bankId = createdPayMethodId;
            verify.firstDeposit = firstDeposit;
            verify.secondDeposit = secondDeposit;
            Map<String, List<Customer.verifyBankAccount>> verifyMap = new Map<String, List<Customer.verifyBankAccount>>();
            verifyMap.put('verify', new List<Customer.verifyBankAccount>{verify});

            Map<String,Object> request = new Map<String,Object>();
            request.put(ProcessorUtil.API_ACTION,ProcessorUtil.ACT_VERIFY_BANKACCOUNT);
            request.put(ProcessorUtil.API_VERSION, ProcessorUtil.VER_1);
            request.put(ProcessorUtil.API_PROCESSOR_ID, appC.Provider_ID__c);
            request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(verifyMap));
            System.debug('VerifyBank Account request: ' + request);
            Map<String, Object> response =  BreadwinnerPaymentsAPI.call(request);
            System.debug('VerifyBank Account response: ' + response);
            
            isBankAccountVerified = ProcessorUtil.isValidResponse(response);
            if(isBankAccountVerified){
                String resp = (String) response.get(ProcessorUtil.RESP_JSON);
                JSONParser parser = JSON.createParser(resp);
                BWP_Payment_Method__c PayMethod = selectorPaymentMethod.selectByProcessorId(createdPayMethodId, 1)[0];
                if(appC.Payment_Processor_Type__c == ProcessorUtil.PAT_STRIPE){
                    Customer.Source source = (Customer.Source) parser.readValueAs(Customer.Source.Class);
                    BWP_Payment_Method__c updatePayMethod = new BWP_Payment_Method__c(id = PayMethod.id, Card_Status__c = source.status.capitalize());
                    SecurityUtil.dmlUpdate(updatePayMethod);
                }
                listOfPaymentMethods = getListOfPaymentMethods(selectedBWPCustomer);
                selectedPaymentMethod = PayMethod.Processor_Id__c;
                isBankAccountCreated = false;
                PaymentMethodPage = false;
                PaymentPage = true;
            }
            else{
                processResponseFailure(response);
            }
        }
        catch(Exception ex){
            isBankAccountVerified = false;
            System.debug('Exception occurred while Verifying Bank Account in '+appC.Payment_Processor_Type__c+'.'+ex.getStackTraceString()+'\n'+ex.getmessage());
            APICallHandler.userInteractionLogPush(false, 'Verify Bank Account', 'ERROR', 'Exception: '+ex.getMessage());
        }
        return null;
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
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'We attempted to process the card but were unable to confirm payment due to the following error: Read timed out'));
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
        bankPMCountry = '';
        bankPMCurrency = '';
        bankPMAccountHolderName = '';
        bankPMAccountHolderType = 'business';
        bankPMAccountNumber = '';              
        bankPMRoutingNumber = '';
        bankPMBusinessOwnerName = '';
        bankPMIndividualOwnerFirstName = '';
        bankPMIndividualOwnerLastName = '';
        isBankAuthAccepted = false;
        changeOwner();
    }
    public PageReference redirectToNewCustomerPage(){
        TestingPage='false';
        return Page.CreateCustomer;
    }
    public pagereference createPayment(){
        createCustomerandPayment = true;
        createCustomer();
        if(isCustomerCreated){
            CustomerPage = false;
            PaymentMethodPage  = false;
            PaymentPage = true;
        }
        return null;
    }
    
    public pageReference CustomerFromCustomObj(){
        if(TestingPage != '' && TestingPage == 'true'){
            CustomerPage = false;
            PaymentMethodPage  = false;
            PaymentPage = false;
        }
            
            //return page.TestCustomerCreationPage;
        return null;
    }
    public void cardTokenGeneration(){
        cancel();
        ShowTokenSetion = true;
        PMTokenValue='';
        system.debug('token : '+ShowTokenSetion);//cardPanel = false;
        doNotAddPM = false;
        //return null;
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
    public void disableTokenBtn(){disableTokenBtn = false;}
    
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
        CustomerPage =true;
    }
    
    public void showPaymentMethodPanel(){
        CustomerPage = false;
        PaymentMethodPage = true;
        PaymentPage = false;
        isPaymentMethodSelected = false;
        errorMessage = '';
        newPayment.Amount__c = 0;
        newPayment.Description__c = '';
        chargeTaxAmount = 0;
        chargeIsTaxExempt = false;
        
    }
    public void showCustomerPanel(){
        CustomerPage = true;
        PaymentMethodPage = false;
        PaymentPage = false;
        isCustomerSelected = false;
    }
    public PageReference cancelProcess(){
        if(isCreateCustomerPage){
            if(parentid != NULL)
                return new PageReference('/' + parentid);
            else if(newCustomer.Salesforce_Account__c!= NULL)
                return new PageReference('/' + newCustomer.Salesforce_Account__c);
            else if(newCustomer.Salesforce_Contact__c!= NULL)
                return new PageReference('/' + newCustomer.Salesforce_Contact__c);
            else if(newCustomerPageFromPaymentMethod)
                return new PageReference('/'+BWP_Payment_Method__c.SObjectType.getDescribe().getKeyPrefix()+'/o');
            else if(newCustomerPageFromPayment)
                return new PageReference('/'+BWP_Payment__c.SObjectType.getDescribe().getKeyPrefix()+'/o');
            else if(!newPaymentMethodPageFromPayment && !paymentMethodFromNewPaymentMethodPage)
                return new PageReference('/'+BWP_Customer__c.SObjectType.getDescribe().getKeyPrefix()+'/o');
        }
        else if(isCreatePayMethodPage){
            if(newPayMethod.Account__c!= NULL)
                return new PageReference('/' + newPayMethod.Account__c);
            else if(newPayMethod.Contact__c!= NULL)
                return new PageReference('/' + newPayMethod.Contact__c);
            else{
                Schema.DescribeSObjectResult result = BWP_Payment_Method__c.SObjectType.getDescribe();
                return new PageReference('/'+result.getKeyPrefix()+'/o');
            }
        }
        else{
            if(newPayment.Account__c != NULL){
                return new PageReference('/' + newPayment.Account__c);
            }
            else if(newPayment.Contact__c!= NULL){
                return new PageReference('/' + newPayment.Contact__c);
            }
            else if(newPayment != NULL){
                Schema.DescribeSObjectResult result = BWP_Payment__c.SObjectType.getDescribe();
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
            String errMsg = ' You can only create a ' + (pageName == PG_CUSTOMER ? PG_CUSTOMER : (pageName == PG_PAYMENTMETHOD ? PG_PAYMENTMETHOD : PG_PAYMENT)) + ' from ' + (customerMatchType == ProcessorUtil.CMT_ACCOUNT ? 'an Account' : 'a Contact');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, errMsg));
        }
    }
    public void confirmAccountNumber(){
        if(String.isNotblank(bankPMAccountNumber) && String.isNotblank(bankPMConfirmAccountNumber))
            unMatchedAccount = bankPMAccountNumber == bankPMConfirmAccountNumber ? false : true;
    }
}