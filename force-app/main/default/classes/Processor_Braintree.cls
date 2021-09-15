public with sharing class Processor_Braintree extends Processor {

    private static Selector_BWP_Customer selectorCustomer = new Selector_BWP_Customer();
    private static Selector_BWP_Payment selectorPayment = new Selector_BWP_Payment();
    private static Selector_BWP_Payment_Method selectorPaymentMethod = new Selector_BWP_Payment_Method();

    //Braintree Endpoints
    public static String braintreeSandBoxUrl = 'https://payments.sandbox.braintree-api.com/graphql';
    public static String braintreeProductionUrl = 'https://payments.braintree-api.com/graphql';

    BWP_Processor_Config__c apc;
    BreadwinnerUtil.AppConfig apcWrapper;

    //This version is used for unit tests only and only assumes one processor
    public Processor_Braintree() {
        if (!System.Test.isRunningTest()){
            throw new ProcessorUtil.InvalidAccountConfigurationException('Invalid Braintree Id provided.');
        }
       // apc = Processor_Config__c.getInstance();
        apcWrapper = BreadwinnerUtil.getProcessorConfigWrapper(apc);
    }

    public Processor_Braintree(String braintreeAccountId) {
        apc = BreadwinnerUtil.getProcessorConfig(braintreeAccountId);
        if (apc == null) {
            throw new ProcessorUtil.InvalidAccountConfigurationException('Invalid Braintree Id provided.');
        }
        apcWrapper = BreadwinnerUtil.getProcessorConfigWrapper(apc);
    }

    /* Override Methods */
    public override ProcessorUtil.ResponseObject createCustomer(String requestJSON){
        return createCustomer(apcWrapper, requestJSON);
    }
    public override ProcessorUtil.ResponseObject updateCustomer(String requestJSON) {
        return updateCustomer(apcWrapper, requestJSON);
    }
    public override ProcessorUtil.ResponseObject fetchCustomers(String requestJSON) {
        return fetchCustomers(apcWrapper, requestJSON);
    }
    public override ProcessorUtil.ResponseObject fetchPayments(String requestJSON) {
        return fetchPayments(apcWrapper, requestJSON);
    }
    public override ProcessorUtil.ResponseObject chargeProcessor(String requestJSON, String timeout) {
        return chargeProcessor(apcWrapper, requestJSON, timeout);
    }
    public override ProcessorUtil.ResponseObject createCardToken(String requestJSON) {
        return createCardToken(apcWrapper, requestJSON);
    }
    public override ProcessorUtil.ResponseObject createBankToken(String requestJSON) {
        return createBankToken(apcWrapper, requestJSON);
    }
    public override ProcessorUtil.ResponseObject verifyBankAccount(String requestJSON) {
        return verifyBankAccount(apcWrapper, requestJSON);
    }

    @TestVisible
    private static ProcessorUtil.ResponseObject createCustomer(BreadwinnerUtil.AppConfig apcWrapper, String requestJSON){

        Map<String, Customer.BraintreeCustomer> braintreeIdCustomerMapResponse = new Map<String, Customer.BraintreeCustomer> ();
        ProcessorUtil.ResponseObject response = new ProcessorUtil.ResponseObject();
        response.errors = new List<ProcessorUtil.Error>();

        Map<String, Object> objectMap = (Map<String,Object>) JSON.deserializeUntyped(requestJSON);
        System.debug('objectMap: ' + objectMap);

        // addToSalesforce by default
        Boolean addToSalesforce = true;
        if (objectMap.get('addToSalesforce') != null){
            addToSalesforce = (Boolean) objectMap.get('addToSalesforce');
        }

        List<Object> objectList = (List<Object>) objectMap.get('customer');
        try {
            for (Object obj : objectList) {
                try {
                    String jsonObject = JSON.serializePretty(obj);
                    JSONParser objectParser = JSON.createParser(jsonObject);

                    Customer.BraintreeCustomer btCustomer = (Customer.BraintreeCustomer) objectParser.readValueAs(Customer.BraintreeCustomer.class);
                    if (btCustomer != null) {
                        if (btCustomer.accountId != null) {
                            BreadwinnerUtil.accountId = btCustomer.accountId;
                        }
                    }

                    System.debug('customer: ' + btCustomer);

                    String query;
                    query = '{ "query": " mutation CreateCustomer($input: CreateCustomerInput!) { createCustomer(input: $input) { customer{ id firstName lastName company email phoneNumber} } }",';
                    query += ' "variables": { "input": { "clientMutationId": "fake-valid-nonce", "customer": {';
                    query += '"firstName": ' + (String.isNotBlank(btCustomer.firstName) ? ('\"' + btCustomer.firstName + '\"') : null) + ',';
                    query += '"lastName": ' + (String.isNotBlank(btCustomer.lastName) ? ('\"' + btCustomer.lastName + '\"') : null) + ',';
                    query += '"email": ' + (String.isNotBlank(btCustomer.email) ? ('\"' + btCustomer.email + '\"') : null) + ',';
                    query += '"company": ' + (String.isNotBlank(btCustomer.company) ? ('\"' + btCustomer.company + '\"') : null) + ',';
                    query += '"phoneNumber": ' + (String.isNotBlank(btCustomer.phoneNumber) ? ('\"' + btCustomer.phoneNumber + '\"') : null);
                    query += '} } } }';
                    HttpResponse res = APICallHandler.getList(apcWrapper, 'POST', getEndpointBaseUrl(apcWrapper), query);
                    response.status = String.valueOf(res.getStatusCode());
                    if (res.getStatusCode() == 200) {
                        FetchResponse resp = new FetchResponse();
                        resp = parseCustomerOnCreate(res, apcWrapper);
                        braintreeIdCustomerMapResponse = resp.CustomerMapById;
                        apcWrapper.currentRunningClassContext = BreadwinnerUtil.CNTX_BWAPI;

                        Map<String, Object> processorTypeToRecordsMap = new Map<String, Object>{apcWrapper.PaymentProcessorType => braintreeIdCustomerMapResponse};
                        response = syncCustomers(processorTypeToRecordsMap, apcWrapper, addToSalesforce);
                        response.responseJSON = JSON.serializePretty(braintreeIdCustomerMapResponse);
                    } else {
                        JSONParser parser = JSON.createParser(res.getBody());
                        ProcessorUtil.Error error = (ProcessorUtil.Error) parser.readValueAs(ProcessorUtil.Error.class);
                        response.errors.add(error);
                        APICallHandler.userInteractionLogPush(TRUE, 'Creating Braintree Customer', 'ERROR', 'Response for Braintree Org Name(' + apcWrapper.accountName + '): Status Code: ' + res.getStatusCode() + ' Response Body: ' + res.getBody());
                    }
                } catch (Exception ex) {
                    // We want to catch any additional errors and let the process continue.
                    response.errors.add(new ProcessorUtil.Error('Exception Occurred', 'An Exception occurred while creating the Customer to Braintree. ' + ex.getMessage()));
                    System.debug('Exception occurred while creating customers in Braintree.' + ex.getStackTraceString());
                }
            }
        } catch (Exception ex) {
            response.errors.add(new ProcessorUtil.Error('Exception Occurred','An Exception occurred while creating the Braintree Customer. ' + ex.getMessage()));
            System.debug('Exception occurred while creating customers in Braintree.' + ex.getStackTraceString());
        }
        return response;

    }

     @TestVisible
    private static ProcessorUtil.ResponseObject updateCustomer(BreadwinnerUtil.AppConfig apcWrapper, String requestJSON){
        System.debug('request: ' + requestJSON);
        
        Map<String, Customer.BraintreeCustomer> braintreeIdCustomerMapResponse = new Map<String, Customer.BraintreeCustomer> ();
        
        ProcessorUtil.ResponseObject response = new ProcessorUtil.ResponseObject();
        response.errors = new List<ProcessorUtil.Error>();
        
        Map<String, Object> objectMap = (Map<String,Object>) JSON.deserializeUntyped(requestJSON);
        System.debug('objectMap: ' + objectMap);
        List<Object> objectList = new List<Object>();
        if(objectMap.get('customer') != NULL) {
            objectList = (List<Object>) objectMap.get('customer');
        }
        
        // addToSalesforce by default
        Boolean addToSalesforce = true;
        if (objectMap.get('addToSalesforce') != null){
            addToSalesforce = (Boolean) objectMap.get('addToSalesforce');
        }
        try {
            for (Object obj : objectList) {
                try {
                    String jsonObject = JSON.serializePretty(obj);
                    JSONParser objectParser = JSON.createParser(jsonObject);

                    Customer.BraintreeCustomer btCustomer = (Customer.BraintreeCustomer) objectParser.readValueAs(Customer.BraintreeCustomer.class);

                    System.debug('customer: ' + btCustomer);

                    String query;
                    query = '{ "query": " mutation updateCustomer($input: UpdateCustomerInput!) { updateCustomer(input: $input) { customer{ id firstName lastName company email phoneNumber} } }",';
                    query += ' "variables": { "input": { "clientMutationId": "fake-valid-nonce", "customerId": '+(String.isNotBlank(btCustomer.id) ? ('\"' + btCustomer.id + '\"') : null)+', "customer": {';
                    query += '"firstName": ' + (String.isNotBlank(btCustomer.firstName) ? ('\"' + btCustomer.firstName + '\"') : null) + ',';
                    query += '"lastName": ' + (String.isNotBlank(btCustomer.lastName) ? ('\"' + btCustomer.lastName + '\"') : null) + ',';
                    query += '"email": ' + (String.isNotBlank(btCustomer.email) ? ('\"' + btCustomer.email + '\"') : null) + ',';
                    query += '"company": ' + (String.isNotBlank(btCustomer.company) ? ('\"' + btCustomer.company + '\"') : null) + ',';
                    query += '"phoneNumber": ' + (String.isNotBlank(btCustomer.phoneNumber) ? ('\"' + btCustomer.phoneNumber + '\"') : null);
                    query += '} } } }';
                    
                    HttpResponse res = APICallHandler.getList(apcWrapper, 'POST', getEndpointBaseUrl(apcWrapper), query);
                    
                    Map<String, Object> responseFromBraintree = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    Map<String, Object> data = (Map<String, Object>)responseFromBraintree.get('data');
                    List<Object> errorsList = (List<Object>)responseFromBraintree.get('errors');
                    
                    response.status = String.valueOf(res.getStatusCode());
                    if (res.getStatusCode() == 200) {
                        if(errorsList == null && data.containsKey('updateCustomer')){
                            FetchResponse resp = new FetchResponse();
                            resp = parseCustomerOnCreate(res, apcWrapper);
                            braintreeIdCustomerMapResponse = resp.CustomerMapById;
                            apcWrapper.currentRunningClassContext = BreadwinnerUtil.CNTX_BWAPI;
                            Map<String, Object> processorTypeToRecordsMap = new Map<String, Object>{apcWrapper.PaymentProcessorType => braintreeIdCustomerMapResponse};
                            response = syncCustomers(processorTypeToRecordsMap, apcWrapper,addToSalesforce);
                            response.responseJSON = JSON.serializePretty(braintreeIdCustomerMapResponse);
                        }
                        if(errorsList != NULL){
                            Map<String, Object> error = (Map<String, Object>)errorsList[0];
                            Map<String, Object> errorClass = (Map<String, Object>)error.get('extensions');
                            response.errors.add(new ProcessorUtil.Error(response.status, error.get('message').toString()));
                        }
                    } 
                } catch (Exception ex) {
                    response.errors.add(new ProcessorUtil.Error('Exception Occurred', 'An Exception occurred while updating the Customer to Braintree. ' + ex.getMessage()));
                    System.debug('Exception occurred while updating customers in Braintree.' + ex.getStackTraceString());
                }
            }
        } catch (Exception ex) {
            response.errors.add(new ProcessorUtil.Error('Exception Occurred','An Exception occurred while updating the Braintree Customer. ' + ex.getMessage()));
            System.debug('Exception occurred while updating customers in Braintree.' + ex.getStackTraceString());
        }
        return response;
    }
    @TestVisible
    private static ProcessorUtil.ResponseObject chargeProcessor(BreadwinnerUtil.AppConfig apcWrapper, String requestJSON, String timeout){
        Map<String, Charge.BraintreeCharge> braintreeIdPaymentMapResponse = new Map<String, Charge.BraintreeCharge> ();
        ProcessorUtil.ResponseObject response = new ProcessorUtil.ResponseObject();
        response.errors = new List<ProcessorUtil.Error>();

        Map<String, Object> objectMap = (Map<String,Object>) JSON.deserializeUntyped(requestJSON);
        System.debug('objectMap: ' + objectMap);

        List<Object> objectList = (List<Object>) objectMap.get('charge');
        try {
            for (Object obj : objectList) {
                try {
                    String jsonObject = JSON.serializePretty(obj);
                    JSONParser objectParser = JSON.createParser(jsonObject);

                    Charge.BraintreeCharge btCharge = (Charge.BraintreeCharge) objectParser.readValueAs(Charge.BraintreeCharge.class);
                    
                    String query;
                    query = '{ "query": " mutation ChargeCustomer($input: ChargePaymentMethodInput!) { chargePaymentMethod(input: $input) { transaction { id amount {value currencyIsoCode} status createdAt customer {id} paymentMethod {id} } } }",';
                    query += ' "variables": { "input": { "paymentMethodId": '+ (String.isNotBlank(btCharge.paymentMethod.id) ? ('\"' + btCharge.paymentMethod.id + '\"') : null) + ',';
                    query += '"transaction": { "amount" : ' + (String.isNotBlank(btCharge.Amount.value) ? ('\"' + btCharge.Amount.value + '\"') : null);
                    if(btCharge.transactionTaxInput != null) 
                        query += ', "tax": { "taxAmount" : ' + (String.isNotBlank(btCharge.transactionTaxInput.taxAmount.value) ? ('\"' + btCharge.transactionTaxInput.taxAmount.value + '\"') : null) + ',"taxExempt" : '+btCharge.transactionTaxInput.taxExempt;
                    query += '} } } } }';

                    HttpResponse res = APICallHandler.getList(apcWrapper, 'POST', getEndpointBaseUrl(apcWrapper), query);

                    response.status = String.valueOf(res.getStatusCode());
                    Map<String, Object> responseFromBraintree = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    Map<String, Object> data = (Map<String, Object>)responseFromBraintree.get('data');
                    List<Object> errorsList = (List<Object>)responseFromBraintree.get('errors');
                    if (res.getStatusCode() == 200) {
                        system.debug('data-----'+data);
                        if(data != NULL){
                            FetchResponse resp = new FetchResponse();
                            resp = parsePaymentOnCreate(res, apcWrapper);
                            braintreeIdPaymentMapResponse = resp.PaymentMapById;
                            apcWrapper.currentRunningClassContext = BreadwinnerUtil.CNTX_BWAPI;
                            Map<String, Object> processorTypeToRecordsMap = new Map<String, Object>();
                            processorTypeToRecordsMap.put(apcWrapper.PaymentProcessorType, braintreeIdPaymentMapResponse);
                            response.paymentList = syncPayments(processorTypeToRecordsMap, apcWrapper);
                            response.responseJSON = JSON.serializePretty(braintreeIdPaymentMapResponse);
                        }
                        if(errorsList != NULL){
                            Map<String, Object> error = (Map<String, Object>)errorsList[0];
                            Map<String, Object> errorClass = (Map<String, Object>)error.get('extensions');
                            response.errors.add(new ProcessorUtil.Error(String.valueOf(res.getStatusCode()), error.get('message').toString()));
                            system.debug('data1----------'+error.get('message'));
                        }
                    } else {
                        Map<String, Object> error = (Map<String, Object>)errorsList[0];
                        Map<String, Object> errorClass = (Map<String, Object>)error.get('extensions');
                        response.errors.add(new ProcessorUtil.Error(String.valueOf(res.getStatusCode()), error.get('message').toString()));
                        APICallHandler.userInteractionLogPush(TRUE, 'Create Braintree Charge', 'ERROR', 'Response for Braintree Org Name(' + apcWrapper.accountName + '): Status Code: ' + res.getStatusCode() + ' Response Body: ' + res.getBody());
                    }
                } catch (Exception ex) {
                    // We want to catch any additional errors and let the process continue.
                    response.errors.add(new ProcessorUtil.Error('Exception Occurred', 'An Exception occurred while creating the Customer to Braintree. ' + ex.getMessage()));
                    System.debug('Exception occurred while creating customers in Braintree.' + ex.getStackTraceString());
                }
            }
        } catch (Exception ex) {
            response.errors.add(new ProcessorUtil.Error('Exception Occurred','An Exception occurred while creating the Braintree Customer. ' + ex.getMessage()));
            System.debug('Exception occurred while creating customers in Braintree.' + ex.getStackTraceString());
        }
        return response;

    }

    @TestVisible
    private static ProcessorUtil.ResponseObject createCardToken(BreadwinnerUtil.AppConfig apcWrapper, String requestJSON){
        ProcessorUtil.ResponseObject response = new ProcessorUtil.ResponseObject();
        response.errors = new List<ProcessorUtil.Error>();

        Map<String, Object> objectMap = (Map<String,Object>) JSON.deserializeUntyped(requestJSON);
        System.debug('objectMap: ' + objectMap);

        // addToSalesforce by default
        Boolean addToSalesforce = true;
        if (objectMap.get('addToSalesforce') != null){
            addToSalesforce = (Boolean) objectMap.get('addToSalesforce');
        }

        List<Object> objectList = (List<Object>) objectMap.get('customer');
        for (Object obj : objectList) {
            try {
                String jsonObject = JSON.serializePretty(obj);
                JSONParser objectParser = JSON.createParser(jsonObject);
                Customer.BraintreeCustomer customer = (Customer.BraintreeCustomer) objectParser.readValueAs(Customer.BraintreeCustomer.class);
                System.debug('createCardToken customer: ' + customer);

                List<Customer.PaymentMethodDetails> sources = customer.paymentMethodDetails;
                String query;
                    query = '{ "query": " mutation CreditCard($input: TokenizeCreditCardInput!) { tokenizeCreditCard(input: $input){ paymentMethod { id } } }",';
                    query += ' "variables": { "input": { ';
                    query += '"creditCard": { "cardholderName" : ' + (String.isNotBlank(sources[0].cardholderName) ? ('\"' + sources[0].cardholderName + '\"') : null);
                    query += ', "expirationYear" : '+(String.isNotBlank(sources[0].expirationYear) ? (sources[0].expirationYear) : null);
                    query += ', "expirationMonth" : '+(String.isNotBlank(sources[0].expirationMonth) ? (sources[0].expirationMonth) : null);
                    query += ', "number" : '+(String.isNotBlank(sources[0].cardNumber) ? ('\"' + sources[0].cardNumber + '\"') : null);
                    query += '} } } }';

                    HttpResponse res = APICallHandler.getList(apcWrapper, 'POST', getEndpointBaseUrl(apcWrapper), query);
                    Map<String, Object> responseFromBraintree = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    Map<String, Object> data = (Map<String, Object>)responseFromBraintree.get('data');
                    List<Object> errorsList = (List<Object>)responseFromBraintree.get('errors');
                    Map<String, Object> paymentMethodDetails = new Map<String, Object>();
                    if(data.containsKey('tokenizeCreditCard'))
                         paymentMethodDetails = (Map<String, Object>)data.get('tokenizeCreditCard');
                    if (res.getStatusCode() == 200) {
                        if(data != NULL && paymentMethodDetails != NULL){
                            Map<String, Object> paymentMethod = (Map<String, Object>)paymentMethodDetails.get('paymentMethod');
                            String token = paymentMethod.get('id').toString();
                            if(String.isNotBlank(token) && String.isNotBlank(customer.Id)){
                                String updateCustomerQuery = '';
                                updateCustomerQuery = '{ "query": " mutation vaultCreditCard($input: VaultPaymentMethodInput!) { vaultPaymentMethod(input: $input){ paymentMethod { id customer { id } } } }",';
                                updateCustomerQuery += ' "variables": { "input": { "paymentMethodId" :' + ( + '\"' + token + '\"');
                                updateCustomerQuery += ', "customerId" : '+(String.isNotBlank(customer.Id) ? ('\"' + customer.Id + '\"') : null);
                                updateCustomerQuery += '} } }';

                                HttpResponse respe = APICallHandler.getList(apcWrapper, 'POST', getEndpointBaseUrl(apcWrapper), updateCustomerQuery);

                                if(addToSalesforce){

                                    Map<String, Object> responseOfVaultPM = (Map<String, Object>) JSON.deserializeUntyped(respe.getBody());
                                    List<Object> errorsListOfVaultPM = (List<Object>)responseOfVaultPM.get('errors');
                                    if(errorsListOfVaultPM == NULL){
                                        String reqJSON = Processor_Braintree.getRequestBody('fetchRecentCustomers', NULL);
                                        String reqBodyWithFilters = '"variables": { "input": { "id": {  "is": '+ ('\"' + customer.Id + '\"') + '} } } }';
                                        reqJSON += reqBodyWithFilters;
                                        ProcessorUtil.ResponseObject fetchCustomerResponse = fetchCustomers(apcWrapper, reqJSON);
                                        JSONParser parser = JSON.createParser(fetchCustomerResponse.responseJSON);
                                        FetchResponse responseData = (FetchResponse) parser.readValueAs(FetchResponse.class);
                                        Map<String, Customer.BraintreeCustomer> braintreeCustomerMapById = new Map<String, Customer.BraintreeCustomer>();
                                        braintreeCustomerMapById = responseData.customerMapById;
                                        Map<String, Object> processorToCustomerMap = new Map<String, Object>();
                                        processorToCustomerMap.put(apcWrapper.PaymentProcessorType, braintreeCustomerMapById);
                                        apcWrapper.currentRunningClassContext = BreadwinnerUtil.CNTX_BWAPI;
                                        response = syncCustomers(processorToCustomerMap, apcWrapper, true);
                                        response.responseJSON = fetchCustomerResponse.responseJSON;
                                    }
                                    else{
                                        Map<String, Object> error = (Map<String, Object>)errorsListOfVaultPM[0];
                                        Map<String, Object> errorClass = (Map<String, Object>)error.get('extensions');
                                        response.errors.add(new ProcessorUtil.Error(String.ValueOf(respe.getStatusCode()), error.get('message').toString()));
                                    }
                                }
                                system.debug('response---------'+respe.getBody());
                            }
                            else {
                                response.responseJSON = JSON.serializePretty(paymentMethod);
                            }
                        }
                        if(errorsList != NULL){
                            Map<String, Object> error = (Map<String, Object>)errorsList[0];
                            Map<String, Object> errorClass = (Map<String, Object>)error.get('extensions');
                            response.errors.add(new ProcessorUtil.Error(String.valueOf(res.getStatusCode()), error.get('message').toString()));
                            system.debug('data1----------'+error.get('message'));
                        }
                    }
            }
            catch (Exception ex) {
                // We want to catch any additional errors and let the process continue.
                response.errors.add(new ProcessorUtil.Error('Exception Occurred', 'An Exception occurred while creating card token. ' + ex.getMessage()));
                System.debug('Exception occurred while creating card token.' + ex.getStackTraceString());
            }
        }
        return response;
    }
    @TestVisible
    private static ProcessorUtil.ResponseObject createBankToken(BreadwinnerUtil.AppConfig apcWrapper, String requestJSON){
        ProcessorUtil.ResponseObject response = new ProcessorUtil.ResponseObject();
        response.errors = new List<ProcessorUtil.Error>();
        
        Map<String, Object> objectMap = (Map<String,Object>) JSON.deserializeUntyped(requestJSON);
        System.debug('objectMap: ' + objectMap);
        
        // addToSalesforce by default
        Boolean addToSalesforce = true;
        if (objectMap.get('addToSalesforce') != null){
            addToSalesforce = (Boolean) objectMap.get('addToSalesforce');
        }
        
        List<Object> objectList = (List<Object>) objectMap.get('customer');
        for (Object obj : objectList) {
            try {
                String jsonObject = JSON.serializePretty(obj);
                JSONParser objectParser = JSON.createParser(jsonObject);
                Customer.BraintreeCustomer customer = (Customer.BraintreeCustomer) objectParser.readValueAs(Customer.BraintreeCustomer.class);
                System.debug('createCardToken customer: ' + customer);
                
                List<Customer.PaymentMethodDetails> sources = customer.paymentMethodDetails;
                system.debug('sources-----------------'+sources);
                String query;
                query = '{ "query": " mutation USBankAccount($input: TokenizeUsBankAccountInput!) { tokenizeUsBankAccount(input: $input){ paymentMethod { id } } }",';
                query += ' "variables": { "input": { ';
                query += '"usBankAccount": { "accountNumber" : ' + (String.isNotBlank(sources[0].accountNumber) ? ('\"' + sources[0].accountNumber + '\"') : null);
                query += ', "routingNumber" : '+(String.isNotBlank(sources[0].routingNumber) ? ('\"' + sources[0].routingNumber + '\"' ) : null);
                query += ', "accountType" : '+(String.isNotBlank(sources[0].accountType) ? ('\"' + sources[0].accountType + '\"') : null);
                query += ', "achMandate" : "I authorize Braintree, a service of PayPal, on behalf of '+((String.isNotBlank(customer.company) || customer.company != null ) ? customer.company  : UserInfo.getOrganizationName())+' (i) to verify my bank account information using bank information and consumer reports and (ii) to debit my bank account."';
                
                if(sources[0].BusinessOwner != null && String.isNotBlank(sources[0].BusinessOwner.businessName)){
                    query += ', "businessOwner" : { "businessName": '+('\"' + sources[0].BusinessOwner.businessName + '\"}');
                } 
                else if(sources[0].individualOwner != null && String.isNotBlank(sources[0].individualOwner.firstName) && (String.isNotBlank(sources[0].individualOwner.lastName))){
                    query += ', "individualOwner" : { ';
                    query += '"firstName" : '+(String.isNotBlank(sources[0].individualOwner.firstName) ? ('\"' + sources[0].individualOwner.firstName + '\"') : null);
                    query += ', "lastName" : '+(String.isNotBlank(sources[0].individualOwner.lastName) ? ('\"' + sources[0].individualOwner.lastName + '\"}') : null);
                }
                query += '} } } }';
                System.debug('--query----'+query);
                
                HttpResponse res = APICallHandler.getList(apcWrapper, 'POST', getEndpointBaseUrl(apcWrapper), query);
                system.debug('response-----'+res.getBody());
                Map<String, Object> responseFromBraintree = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                Map<String, Object> data = (Map<String, Object>)responseFromBraintree.get('data');
                List<Object> errorsList = (List<Object>)responseFromBraintree.get('errors');
                Map<String, Object> paymentMethodDetails = new Map<String, Object>();
                if(data != NULL && data.containsKey('tokenizeUsBankAccount'))
                    paymentMethodDetails = (Map<String, Object>)data.get('tokenizeUsBankAccount');
                if (res.getStatusCode() == 200) {
                    system.debug('data-----'+data);
                    if(data != NULL && paymentMethodDetails != NULL){
                        Map<String, Object> paymentMethod = (Map<String, Object>)paymentMethodDetails.get('paymentMethod');
                        String token = paymentMethod.get('id').toString();
                        if(String.isNotBlank(token) && String.isNotBlank(customer.Id)){
                            String updateCustomerQuery = '';
                            updateCustomerQuery = '{ "query": " mutation vaultUSBankAccount($input: VaultPaymentMethodInput!) { vaultPaymentMethod(input: $input){ paymentMethod { id customer { id } } } }",';
                            updateCustomerQuery += ' "variables": { "input": { "paymentMethodId" :' + ( + '\"' + token + '\"');
                            updateCustomerQuery += ', "customerId" : '+(String.isNotBlank(Customer.Id) ? ('\"' + Customer.Id + '\"') : null);
                            updateCustomerQuery += '} } }';
                            HttpResponse respe = APICallHandler.getList(apcWrapper, 'POST', getEndpointBaseUrl(apcWrapper), updateCustomerQuery);
                            
                            if(addToSalesforce){
                                
                                Map<String, Object> responseOfVaultPM = (Map<String, Object>) JSON.deserializeUntyped(respe.getBody());
                                List<Object> errorsListOfVaultPM = (List<Object>)responseOfVaultPM.get('errors');
                                if(errorsListOfVaultPM == NULL){
                                    String reqJSON = Processor_Braintree.getRequestBody('fetchRecentCustomers', NULL);
                                    String reqBodyWithFilters = '"variables": { "input": { "id": {  "is": '+ ('\"' + customer.Id + '\"') + '} } } }';
                                    reqJSON += reqBodyWithFilters;
                                    ProcessorUtil.ResponseObject fetchCustomerResponse = fetchCustomers(apcWrapper, reqJSON);
                                    JSONParser parser = JSON.createParser(fetchCustomerResponse.responseJSON);
                                    FetchResponse responseData = (FetchResponse) parser.readValueAs(FetchResponse.class);
                                    Map<String, Customer.BraintreeCustomer> braintreeCustomerMapById = new Map<String, Customer.BraintreeCustomer>();
                                    braintreeCustomerMapById = responseData.customerMapById;
                                    Map<String, Object> processorToCustomerMap = new Map<String, Object>();
                                    processorToCustomerMap.put(apcWrapper.PaymentProcessorType, braintreeCustomerMapById);
                                    apcWrapper.currentRunningClassContext = BreadwinnerUtil.CNTX_BWAPI;
                                    response = syncCustomers(processorToCustomerMap, apcWrapper, true);
                                    response.responseJSON = fetchCustomerResponse.responseJSON;
                                }
                                else{
                                    Map<String, Object> error = (Map<String, Object>)errorsListOfVaultPM[0];
                                    Map<String, Object> errorClass = (Map<String, Object>)error.get('extensions');
                                    response.errors.add(new ProcessorUtil.Error(String.valueOf(respe.getStatusCode()), error.get('message').toString()));
                                }
                            }
                            system.debug('response---------'+respe.getBody());
                        }
                        else {
                            response.responseJSON = JSON.serializePretty(paymentMethod);
                        }
                    }
                    if(errorsList != NULL){
                        Map<String, Object> error = (Map<String, Object>)errorsList[0];
                        Map<String, Object> errorClass = (Map<String, Object>)error.get('extensions');
                        response.errors.add(new ProcessorUtil.Error(String.valueOf(res.getStatusCode()), error.get('message').toString()));
                        system.debug('data1----------'+error.get('message'));
                    }
                }
            }
            catch (Exception ex) {
                // We want to catch any additional errors and let the process continue.
                response.errors.add(new ProcessorUtil.Error('Exception Occurred', 'An Exception occurred while creating bank token. ' + ex.getMessage()));
                System.debug('Exception occurred while creating bank token.' + ex.getStackTraceString());
            }
        }
        return response;
    }
     @TestVisible
    private static ProcessorUtil.ResponseObject verifyBankAccount(BreadwinnerUtil.AppConfig apcWrapper, String requestJSON){
        System.debug('request: ' + requestJSON);
        
        ProcessorUtil.ResponseObject response = new ProcessorUtil.ResponseObject();
        response.errors = new List<ProcessorUtil.Error>();
        
        Map<String, Object> objectMap = (Map<String,Object>) JSON.deserializeUntyped(requestJSON);
        List<Object> objectList = new List<Object>();
        if(objectMap.get('verify') != NULL)
            objectList = (List<Object>) objectMap.get('verify');
        
        Boolean addToSalesforce = true;
        if (objectMap.get('addToSalesforce') != null){
            addToSalesforce = (Boolean) objectMap.get('addToSalesforce');
        }
        try {
            for (Object obj : objectList){
                try {
                    String jsonObject = JSON.serializePretty(obj);
                    JSONParser objectParser = JSON.createParser(jsonObject);
                    Customer.verifyBankAccount verify = (Customer.verifyBankAccount) objectParser.readValueAs(Customer.verifyBankAccount.class);
                    
                    if (verify == null) {
                        response.errors.add(new ProcessorUtil.Error('', 'Invalid format'));
                        return response;
                    }
                    if (verify.customerId == null) {
                        response.errors.add(new ProcessorUtil.Error('', 'Please enter String customer id'));
                        return response;
                    }
                    if (verify.bankId == null) {
                        response.errors.add(new ProcessorUtil.Error('', 'Please enter String bank id'));
                        return response;
                    }
                    String query;
                    query = '{ "query": " mutation verifyUsBankAccount($input: VerifyUsBankAccountInput!) { verifyUsBankAccount(input: $input){ verification { id } } }",';
                    query += ' "variables": { "input": { ';
                    query += ' "paymentMethodId" : ' + (String.isNotBlank(verify.bankId) ? ('\"' + verify.bankId + '\"') : null);
                    query += ', "verificationMethod" : '+'"MICRO_TRANSFERS" ';
                    query += ' } } }';
                    
                    HttpResponse res = APICallHandler.getList(apcWrapper, 'POST', getEndpointBaseUrl(apcWrapper), query);
                    Map<String, Object> responseFromBraintree = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    System.debug('---responseFromBraintree---'+responseFromBraintree);
                    Map<String, Object> data = (Map<String, Object>)responseFromBraintree.get('data');
                    List<Object> errorsList = (List<Object>)responseFromBraintree.get('errors');
                    Map<String, Object> paymentMethodDetails = new Map<String, Object>();
                    if(data != NULL && data.containsKey('verifyUsBankAccount'))
                        paymentMethodDetails = (Map<String, Object>)data.get('verifyUsBankAccount');
                    if (res.getStatusCode() == 200) {
                        if(data != NULL && paymentMethodDetails != NULL){
                            Map<String, Object> paymentMethod = (Map<String, Object>)paymentMethodDetails.get('verification');
                            String verifyToken = paymentMethod.get('id').toString();
                            if(String.isNotBlank(verifyToken)){
                                String updateCustomerQuery = '';
                                updateCustomerQuery = '{ "query": " mutation ConfirmMicroTransfer($input: ConfirmMicroTransferAmountsInput!) { confirmMicroTransferAmounts(input: $input){ status verification { status } } }",';
                                updateCustomerQuery += ' "variables": { "input": { "verificationId" :' + ( + '\"' + verifyToken + '\"');
                                updateCustomerQuery += ', "amountsInCents" : '+ '[' +verify.firstDeposit+ ',' +verify.secondDeposit+ ']';
                                updateCustomerQuery += '} } }';
                                HttpResponse resp = APICallHandler.getList(apcWrapper, 'POST', getEndpointBaseUrl(apcWrapper), updateCustomerQuery);
                                Map<String, Object> responseOfConfirmAmounts = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
                                Map<String, Object> StatusResp = (Map<String, Object>) responseOfConfirmAmounts.get('data');
                                Map<String, Object> Status = (Map<String, Object>) StatusResp.get('confirmMicroTransferAmounts');
                                List<Object> errorsListOfConfirmAmounts = (List<Object>)responseOfConfirmAmounts.get('errors');
                                if(errorsListOfConfirmAmounts == NULL && Status.get('status') == 'CONFIRMED'){
                                    String reqJSON = Processor_Braintree.getRequestBody('fetchRecentCustomers', NULL);
                                    String reqBodyWithFilters = '"variables": { "input": { "id": {  "is": '+ ('\"' + verify.customerId + '\"') + '} } } }';
                                    reqJSON += reqBodyWithFilters;
                                    ProcessorUtil.ResponseObject fetchCustomerResponse = fetchCustomers(apcWrapper, reqJSON);
                                    JSONParser parser = JSON.createParser(fetchCustomerResponse.responseJSON);
                                    FetchResponse responseData = (FetchResponse) parser.readValueAs(FetchResponse.class);
                                    Map<String, Customer.BraintreeCustomer> braintreeCustomerMapById = new Map<String, Customer.BraintreeCustomer>();
                                    braintreeCustomerMapById = responseData.customerMapById;
                                    Map<String, Object> processorToCustomerMap = new Map<String, Object>();
                                    processorToCustomerMap.put(apcWrapper.PaymentProcessorType, braintreeCustomerMapById);
                                    apcWrapper.currentRunningClassContext = BreadwinnerUtil.CNTX_BWAPI;
                                    response = syncCustomers(processorToCustomerMap, apcWrapper, true);
                                    response.responseJSON = JSON.serializePretty(braintreeCustomerMapById.get(verify.customerId));
                                    response.status = String.valueOf(resp.getStatusCode());
                                }
                                else if(errorsListOfConfirmAmounts == NULL && Status.get('status') != 'CONFIRMED'){
                                    // possible status values are: AMOUNTS_DO_NOT_MATCH, CONFIRMED, TOO_MANY_ATTEMPTS
                                    if(Status.get('status') == 'AMOUNTS_DO_NOT_MATCH'){
                                        response.errors.add(new ProcessorUtil.Error('', 'The amounts provided do not match the amounts that were sent to the bank account.'));
                                    }
                                    else{
                                        response.errors.add(new ProcessorUtil.Error('', 'You have reached the maximum allowed attempts to verify.'));
                                    }
                                }
                                else{
                                    Map<String, Object> error = (Map<String, Object>)errorsListOfConfirmAmounts[0];
                                    Map<String, Object> errorClass = (Map<String, Object>)error.get('extensions');
                                    response.errors.add(new ProcessorUtil.Error(String.valueOf(resp.getStatusCode()), error.get('message').toString()));
                                }
                            }
                        }
                    }
                    if(errorsList != NULL){
                        Map<String, Object> error = (Map<String, Object>)errorsList[0];
                        response.errors.add(new ProcessorUtil.Error(String.valueOf(res.getStatusCode()), error.get('message').toString()));
                    }
                } catch (Exception ex) {
                    response.errors.add(new ProcessorUtil.Error('Exception Occurred', 'An Exception occurred while Verifying Bank Account to Braintree. ' + ex.getMessage()));
                    System.debug('Exception occurred while Verifying Bank Account in Braintree.' + ex.getStackTraceString());
                }
            }
        } catch (Exception ex) {
            response.errors.add(new ProcessorUtil.Error('Exception Occurred','An Exception occurred while Verifying Bank Account to Braintree. ' + ex.getMessage()));
            System.debug('Exception occurred while Verifying Bank Account in Braintree.' + ex.getStackTraceString());
        }
        return response;
    }
    
    @TestVisible
    private static ProcessorUtil.ResponseObject fetchCustomers(BreadwinnerUtil.AppConfig apcWrapper, String requestJSON) {
        ProcessorUtil.ResponseObject response = new ProcessorUtil.ResponseObject();
        response.errors = new List<ProcessorUtil.Error>();
        HttpResponse res = APICallHandler.getList(apcWrapper, 'POST', getEndpointBaseUrl(apcWrapper), requestJSON);

        response.status = String.valueOf(res.getStatusCode());

        if (res.getStatusCode() == 200) {
            FetchResponse fetchResponse = new FetchResponse();
            fetchResponse = parseCustomers(res.getBody());
            response.responseJSON = JSON.serializePretty(fetchResponse);

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
    private static ProcessorUtil.ResponseObject fetchPayments(BreadwinnerUtil.AppConfig apcWrapper, String requestJSON) {
        ProcessorUtil.ResponseObject response = new ProcessorUtil.ResponseObject();
        response.errors = new List<ProcessorUtil.Error>();
        HttpResponse res = APICallHandler.getList(apcWrapper, 'POST', getEndpointBaseUrl(apcWrapper), requestJSON);

        response.status = String.valueOf(res.getStatusCode());

        if (res.getStatusCode() == 200) {
            FetchResponse fetchResponse = new FetchResponse();
            fetchResponse = parsePayments(res.getBody());
            response.responseJSON = JSON.serializePretty(fetchResponse);
        } else {
            apcWrapper.needToReconnect = true;
            apcWrapper.requireNextPaymentSyncRun = false;
            String Action_Type = ProcessorUtil.getLogAction(apcWrapper.currentRunningClassContext, 'Fetching Payments');
            APICallHandler.userInteractionLogPush(true, Action_Type, 'ERROR' , 'Response for Processor Org Name('+apcWrapper.accountName+'): Status Code: '+res.getStatusCode()+' Response Body: '+res.getBody() );

            JSONParser parser = JSON.createParser(res.getBody());
            ProcessorUtil.Error error = (ProcessorUtil.Error) parser.readValueAs(ProcessorUtil.Error.class);
            response.errors.add(error);
        }

        return response;

    }

    public static FetchResponse parseCustomers(String responseBody) {
        Map<String, Customer.BraintreeCustomer> braintreeIdCustomerMap = new Map<String, Customer.BraintreeCustomer>();
        FetchResponse response = new FetchResponse();
        try{
            String responseStr = responseBody.replaceAll('"__typename"', '"typename"');
            JSONParser parser = JSON.createParser(responseStr);
            Customers responseData;
            while (parser.nextToken() != NULL){
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'customers')){
                    parser.nextToken();
                    if(parser.getCurrentToken() == JSONToken.START_OBJECT ){
                        responseData = (Customers)parser.readValueAs(Customers.class);
                    }
                }
            }
            System.debug('response-----'+responseData);
            Boolean hasMoreRecords = false;
            String lastCustId = '';
            if(responseData != NULL && responseData.pageInfo != NULL){
                hasMoreRecords = responseData.pageInfo.hasNextPage;
                lastCustId = responseData.pageInfo.endCursor;
            }
            if(responseData != NULL){
                for(CustomerNode customerInfo : responseData.edges){
                    braintreeIdCustomerMap.put(customerInfo.node.Id,customerInfo.node);
                }
            }
            if(hasMoreRecords) {
                response.cursor = lastCustId;
                response.requireNextRun = TRUE;
            } else if(!hasMoreRecords) {
                response.cursor = '';
                response.requireNextRun = FALSE;
            }
            response.customerMapById = braintreeIdCustomerMap;
        } catch(Exception ex) {
            System.debug('Customer Sync failed for while parsing. \n' +ex.getStackTraceString());
            APICallHandler.userInteractionLogPush(TRUE, 'Customer Sync', 'ERROR' , 'Customer Sync failed for while parsing. \n' +ex.getStackTraceString());
        }
        return response;
    }
    public static FetchResponse parsePayments(String responseBody) {
        Map<String, Charge.BraintreeCharge> braintreeIdPaymentMap = new Map<String, Charge.BraintreeCharge>();
        FetchResponse response = new FetchResponse();
        try{
            JSONParser parser = JSON.createParser(responseBody);
            Payments responseData;
            while (parser.nextToken() != null){
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'transactions')){
                    parser.nextToken();
                    if(parser.getCurrentToken() == JSONToken.START_OBJECT ){
                        responseData = (Payments)parser.readValueAs(Payments.class);
                    }
                }
            }
            System.debug('response for transactions-------'+responseData);
            Boolean hasMoreRecords = false;
            String lastPaymentId = '';
            if (responseData != null && responseData.pageInfo != null){
                hasMoreRecords = responseData.pageInfo.hasNextPage;
                lastPaymentId = responseData.pageInfo.endCursor;
            }
            System.debug('hasMoreRecords----'+hasMoreRecords);
            System.debug('lastCustId----'+lastPaymentId);
            if(responseData != null){
                for(PaymentNode paymentInfo : responseData.edges){
                    braintreeIdPaymentMap.put(paymentInfo.node.id,paymentInfo.node);
                }
            }
            if(hasMoreRecords) {
                response.cursor = lastPaymentId;
                response.requireNextRun = TRUE;
            } else if(!hasMoreRecords) {
                response.cursor = '';
                response.requireNextRun = FALSE;
            }
            response.paymentMapById = braintreeIdPaymentMap;
        } catch(Exception ex) {
            System.debug('Payments Sync failed for while parsing. \n' +ex.getStackTraceString());
            APICallHandler.userInteractionLogPush(true, 'Payment Sync', 'ERROR' , 'Payments Sync failed for  while parsing. \n' +ex.getMessage());
        }
        return response;
    }
    private static FetchResponse parseCustomerOnCreate(HttpResponse res, BreadwinnerUtil.AppConfig appConfig){
        FetchResponse response = new FetchResponse();
        Map<String, Customer.BraintreeCustomer> braintreeIdCustomerMap = new Map<String, Customer.BraintreeCustomer>();
        JSONParser parser = JSON.createParser(res.getBody());
        system.debug('resbody----'+res.getBody());
        Customer.BraintreeCustomer responseData;
        ErrorFromBraintree responseError;
        while (parser.nextToken() != null){
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'customer')){
                parser.nextToken();
                if(parser.getCurrentToken() == JSONToken.START_OBJECT ){
                    responseData = (Customer.BraintreeCustomer)parser.readValueAs(Customer.BraintreeCustomer.class);
                }
            }
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'errors')){
                parser.nextToken();
                parser.nextToken();
                if(parser.getCurrentToken() == JSONToken.START_OBJECT ){
                    responseError = (ErrorFromBraintree)parser.readValueAs(ErrorFromBraintree.class);
                }
            }
        }

        if(responseData != null){
            braintreeIdCustomerMap.put(responseData.id,responseData);
        }
        response.CustomerMapById = braintreeIdCustomerMap;

        return response;
    }

    private static FetchResponse parsePaymentOnCreate(HttpResponse res, BreadwinnerUtil.AppConfig appConfig){
        FetchResponse response = new FetchResponse();
        Map<String, Charge.BraintreeCharge> braintreeIdPaymentMap = new Map<String, Charge.BraintreeCharge>();
        JSONParser parser = JSON.createParser(res.getBody());
        system.debug('resbody----'+res.getBody());
        Charge.BraintreeCharge responseData;
        ErrorFromBraintree responseError;
        while (parser.nextToken() != null){
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'transaction')){
                parser.nextToken();
                if(parser.getCurrentToken() == JSONToken.START_OBJECT ){
                    responseData = (Charge.BraintreeCharge)parser.readValueAs(Charge.BraintreeCharge.class);
                }
            }
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'errors')){
                parser.nextToken();
                parser.nextToken();
                if(parser.getCurrentToken() == JSONToken.START_OBJECT ){
                    responseError = (ErrorFromBraintree)parser.readValueAs(ErrorFromBraintree.class);
                }
            }
        }

        if(responseData != null){
            braintreeIdPaymentMap.put(responseData.id, responseData);
        }
        response.PaymentMapById = braintreeIdPaymentMap;

        return response;
    }
    public static ProcessorUtil.ResponseObject syncCustomers(Map<String, Object> processorToCustomerMap, BreadwinnerUtil.AppConfig appConfig, Boolean addToSalesforce) {

        ProcessorUtil.ResponseObject responseObj = new ProcessorUtil.ResponseObject();
        List<ProcessorUtil.CustomerWrapper> customerList = new List<ProcessorUtil.CustomerWrapper>();
        List<ProcessorUtil.PaymentMethodWrapper> payMethodList = new List<ProcessorUtil.PaymentMethodWrapper>();
        try {
            if(String.isBlank(appConfig.customerSyncConfig) || ((String.isNotBlank(appConfig.customerSyncConfig) && (appConfig.customerSyncConfig != 'NONE')))  && appConfig.currentRunningClassContext != BreadwinnerUtil.CNTX_BWAPI) {
                processorToCustomerMap = excludeCustomers(processorToCustomerMap, appConfig);
            }
            System.debug('processorToCustomerMap'+processorToCustomerMap);

            Map<String, Customer.BraintreeCustomer> braintreeIdCustomerMap = (Map<String, Customer.BraintreeCustomer>) processorToCustomerMap.get(ProcessorUtil.PAT_BRAINTREE);
            Map<String, Customer.BraintreeCustomer> backupBraintreeIdCustomerMap = new Map<String, Customer.BraintreeCustomer>();
            backupBraintreeIdCustomerMap.putAll(braintreeIdCustomerMap);

            List<BWP_Customer__c> customerUpsertList = new List<BWP_Customer__c> ();
            Map<String, BWP_Customer__c> customerUpsertMap = new Map<String, BWP_Customer__c>();
            Map<String, BWP_Payment_Method__c> sourcesMap = new Map<String, BWP_Payment_Method__c> ();
            Map<String,BWP_Customer__c> existingSFCustomersMap = new Map<String,BWP_Customer__c>();
            Map<String,BWP_Payment_Method__c> existingSFPaymentMethodsMap = new Map<String,BWP_Payment_Method__c>();
            Set<String> receivedPaymentMethodIdSet = new Set<String>();

            if(braintreeIdCustomerMap != null) {
                //Holding existing customer records in Salesforce
                List<BWP_Customer__c> custList = selectorCustomer.selectByProcessorCustomerId(braintreeIdCustomerMap.keySet(), 45000);
                for (BWP_Customer__c cus : custList) {
                    existingSFCustomersMap.put(cus.Processor_Customer_Id__c, cus);
                }
                //Collecting Braintree id of all received payment methods
                for (Customer.BraintreeCustomer cus : braintreeIdCustomerMap.values()) {
                    if (cus.paymentMethods != NULL) {
                        for (Customer.paymentMethodEdges src : cus.paymentMethods.edges) {
                            receivedPaymentMethodIdSet.add(src.node.id);
                        }
                    }
                }
                //Holding existing Payment method records in Salesforce
                if (receivedPaymentMethodIdSet.size() > 0) {
                    List<BWP_Payment_Method__c> pmList = selectorPaymentMethod.selectByProcessorId(receivedPaymentMethodIdSet,45000);
                    for(BWP_Payment_Method__c pm : pmList){
                        BWP_Payment_Method__c payMethod = new BWP_Payment_Method__c(id = pm.id);
                        existingSFPaymentMethodsMap.put(payMethod.Processor_Id__c, payMethod);
                    }
                }
            }

            Boolean areRecordTypesEnabled = ProcessorUtil.areRecordTypesEnabled();
            Boolean isDefaultRecordTypeMaster = ProcessorUtil.isDefaultRecordTypeIsMaster();
            //-- Map to store Processor Account Id and new SF Account to be inserted
            Map<String, Account> mapCustomerIdAndNewSFAccount = new Map<String, Account>();

            Map<String, Contact> mapCustomerIdAndNewSFContact = new Map<String, Contact>();
            Set<String> customerNameSet = new Set<String>();
            Set<String> customerEmailSet = new Set<String>();

            for(String ContactId : braintreeIdCustomerMap.keySet()){
                if(!existingSFCustomersMap.containsKey(ContactId) || (existingSFCustomersMap.containsKey(ContactId) && existingSFCustomersMap.get(ContactId).Salesforce_Account__c == NULL && !existingSFCustomersMap.get(ContactId).No_Associated_SF_Account__c )){
                    Customer.BraintreeCustomer bc = braintreeIdCustomerMap.get(ContactId);
                    String customerName = formatCustomerName(bc);
                    if(String.isNotBlank(customerName)){
                        String ContactName = customerName.toLowerCase().replace('\\', '%');
                        Set<String> relatedNameSet = BreadwinnerUtil.getSimilarAccountNameSet(ContactName);
                        customerNameSet.addAll(relatedNameSet);
                    }
                    else if(String.isNotBlank(bc.email)){
                        String ContactEmail = bc.email.toLowerCase().replace('\\', '%');
                        Set<String> relatedNameSet = BreadwinnerUtil.getSimilarAccountNameSet(ContactEmail);
                        customerNameSet.addAll(relatedNameSet);
                    }
                    if(ProcessorUtil.arePersonAccountsEnabled() && String.isNotBlank(bc.email)){
                        String email = bc.email.toLowerCase().replace('\\', '%');
                        customerEmailSet.add(email);
                    }
                }
            }
            
            
            //Braintree Customers
            System.debug('appConfig.isCustomerMatchComplete'+appConfig.isCustomerMatchComplete);
            System.debug('appConfig.currentRunningClassContext'+appConfig.currentRunningClassContext);
            if(appConfig.isCustomerMatchComplete && appConfig.customerMatchType == ProcessorUtil.CMT_ACCOUNT && appConfig.currentRunningClassContext != BreadwinnerUtil.CNTX_BWAPI){
                System.debug('account match is already completed');

                ///account fetch
                Map<String,Account> nameToAccountMap = new Map<String,Account>();
                Map<String,Account> personAccountEmailToAccountMap= new Map<String,Account>();
                List<String> referenceIdListForCreateNew = new List<String>();
                
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
                for(String refId : backupbraintreeIdCustomerMap.keySet()){
                    BWP_Customer__c existingCustomer = existingSFCustomersMap.get(refId);

                    Customer.BraintreeCustomer bc = backupbraintreeIdCustomerMap.get(refId);
                    String cName = formatCustomerName(bc);
                    Id accID;
                    if(existingCustomer == null || (existingCustomer.Salesforce_Account__c == NULL && !existingCustomer.No_Associated_SF_Account__c )){
                        String customerNameLowerCase = (String.isNotBlank(cName)) ? (cName).toLowerCase().replace('\\', '%') : (String.isNotBlank(bc.email) ? (bc.email.toLowerCase().replace('\\', '%')) : '');
                        // first check with person account email then with company name if person accounts are enabled
                        String personEmail = String.isNotBlank(bc.email) ? (bc.email.toLowerCase().replace('\\', '%')) : '';
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
                    if(String.isNotBlank(bc.id)){
                        BWP_Customer__c customerSf = existingSFCustomersMap.get(bc.id) != null ? existingSFCustomersMap.get(bc.id) : new BWP_Customer__c();
                        customerSf = constructBraintreeCustomer(customerSf, bc, appConfig);
                        if(existingCustomer == null || (existingCustomer.Salesforce_Account__c == NULL && !existingCustomer.No_Associated_SF_Account__c )){
                            customerSf.Salesforce_Account__c = customerSf.Salesforce_Account__c != null ? customerSf.Salesforce_Account__c : accID;
                        }
                        customerUpsertList.add(customerSf);
                        customerUpsertMap.put(refId, customerSf);
                        backupbraintreeIdCustomerMap.remove(refId);
                        if(bc.paymentMethods != NULL){

                            for(Customer.paymentMethodEdges src : bc.paymentMethods.edges){
                                BWP_Payment_Method__c srcSf =  existingSFPaymentMethodsMap.get(src.node.id) != null ? existingSFPaymentMethodsMap.get(src.node.id) : new BWP_Payment_Method__c();
                                //TODO: Customer__c instead of Customer__r??
                                srcSf.Customer__r = new BWP_Customer__c(Processor_Customer_Id__c = bc.id);
                                system.debug('srcSf.Customer__r'+srcSf.Customer__r);
                                srcSf.Processor_Customer_Id__c = bc.id;
                                srcSf.Account__c = String.isNotBlank(customerSf.Salesforce_Account__c) ? customerSf.Salesforce_Account__c : NULL;
                                constructBraintreePaymentMethod(srcSf, src, appConfig);
                                sourcesMap.put(src.node.id, srcSf);
                            }
                        }
                    }
                    if(accID == NULL && (!existingSFCustomersMap.containsKey(refId) || (existingSFCustomersMap.containsKey(refId) && existingSFCustomersMap.get(refId).Salesforce_Account__c == NULL && !existingSFCustomersMap.get(refId).No_Associated_SF_Account__c ))){
                        // Create New accounts
                        system.debug('new accounts');
                        String customerName = (String.isNotBlank(cName) ? cName : (String.isNotBlank(bc.email) ? bc.email : ''));
                        Account acctRef = new Account();

                        if( areRecordTypesEnabled && !isDefaultRecordTypeMaster ){
                            String accDefaultRecordType = ProcessorUtil.getDefaultAccountRecordType();
                            ID chosenRecordTypeId = String.isNotBlank(accDefaultRecordType) ? (ID)accDefaultRecordType : '';

                            system.debug('chosenRecordTypeId: '+chosenRecordTypeId);

                            if(String.isNotBlank(chosenRecordTypeId)) acctRef.put('RecordTypeId', ''+chosenRecordTypeId);
                            if(ProcessorUtil.getIsPersonRecordType(chosenRecordTypeId)){
                                acctRef.put('LastName',customerName);
                            } else{
                                acctRef.Name = customerName;
                            }
                        } else{
                            acctRef.Name = customerName;
                        }
                        acctRef.Phone = bc.phoneNumber;
                        acctRef.Description = 'This Salesforce Account was created by Breadwinner.';

                        mapCustomerIdAndNewSFAccount.put(refId,acctRef);
                        referenceIdListForCreateNew.addAll(mapCustomerIdAndNewSFAccount.keySet());
                    }
                }

                Set<String> otherExceptionsSet = new Set<String>();
                Map<String,Account> mapCustomerIdAndFailedAccounts = new Map<String,Account>();
                String duplicateAccounts = '';

                //Handle Exceptions and State&Country picklists
                Database.UpsertResult[] ur1List = SecurityUtil.databaseUpsert(mapCustomerIdAndNewSFAccount.values());
                //Handle exceptions
                for(Integer i = 0; i< ur1List.size(); i++){
                    if(!ur1List[i].isSuccess()){
                        Database.Error[] errors = ur1List[i].getErrors();
                        Database.Error firstError = errors.get(0);
                        if(String.valueOf(firstError.getStatusCode())== 'FIELD_INTEGRITY_EXCEPTION' && ProcessorUtil.areStateAndCountryPicklistsEnabled()){
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
                                for(Database.Error er : errors) {
                                    otherExceptionsSet.add(er.getStatusCode() + ': ' + er.getMessage());
                                }
                            }
                        }
                    }
                }
                System.debug(mapCustomerIdAndFailedAccounts);
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

                for(String refIdOfNewInsert : mapCustomerIdAndFailedAccounts.keySet()){
                    mapCustomerIdAndNewSFAccount.put(refIdOfNewInsert, mapCustomerIdAndFailedAccounts.get(refIdOfNewInsert));
                }

                for(String refId : mapCustomerIdAndNewSFAccount.keySet()){
                    if(customerUpsertMap.containsKey(refId)){
                        BWP_Customer__c customerSF = customerUpsertMap.get(refId);
                        customerSF.Salesforce_Account__c = mapCustomerIdAndNewSFAccount.get(refId).Id;
                        customerUpsertMap.put(refId, customerSF);
                        customerUpsertList.add(customerSF);
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
                for(String refId : backupbraintreeIdCustomerMap.keySet()){
                    Customer.BraintreeCustomer cw = backupbraintreeIdCustomerMap.get(refId);
                    ID conID;
                    if(!existingSFCustomersMap.containsKey(refId) || (existingSFCustomersMap.containsKey(refId) && existingSFCustomersMap.get(refId).Salesforce_Contact__c == NULL && !existingSFCustomersMap.get(refId).No_Associated_SF_Contact__c )){
                        String customerName = formatCustomerName(cw);
                        string customerNameLowerCase = String.isNotBlank(customerName) ? (customerName.toLowerCase().replace('\\', '%')) : (String.isNotBlank(cw.email) ? (cw.email.toLowerCase().replace('\\', '%')) : '');
                            String email = String.isNotBlank(cw.email) ? (cw.email.toLowerCase().replace('\\', '%')) : '';
                        if(emailToContactMap.containsKey(email) || nameToContactMap.containsKey(customerNameLowerCase)){
                            if(emailToContactMap.containsKey(email)){
                                conID = emailToContactMap.get(email).Id;
                            }
                            else if(nameToContactMap.containsKey(customerNameLowerCase) ){
                                conID = nameToContactMap.get(customerNameLowerCase).Id;
                            }
                        }
                    }
                    
                    if(String.isNotBlank(cw.id)) {
                        // Querying existing Stripe Customer if any or creating new one
                        BWP_Customer__c customerSf = existingSFCustomersMap.get(cw.id) != null ? existingSFCustomersMap.get(cw.id) : new BWP_Customer__c();
                        customerSf = constructBraintreeCustomer(customerSf, cw, appConfig);
                        if(!existingSFCustomersMap.containsKey(refId) || (existingSFCustomersMap.containsKey(refId) && existingSFCustomersMap.get(refId).Salesforce_Contact__c == NULL && !existingSFCustomersMap.get(refId).No_Associated_SF_Contact__c )) customerSf.Salesforce_Contact__c = customerSf.Salesforce_Contact__c != null ? customerSf.Salesforce_Contact__c : conID;
                        customerUpsertList.add(customerSf);
                        customerUpsertMap.put(refId, customerSf);
                        backupbraintreeIdCustomerMap.remove(refId);
                        for (Customer.paymentMethodEdges src : cw.paymentMethods.edges) {
                            // Querying existing Braintree Payment Method if any or creating new one
                            BWP_Payment_Method__c srcSf =  existingSFPaymentMethodsMap.get(src.node.id) != null ? existingSFPaymentMethodsMap.get(src.node.id) : new BWP_Payment_Method__c();
                            srcSf.Customer__r = new BWP_Customer__c(Processor_Customer_Id__c = cw.id);
                            srcSf.Processor_Customer_Id__c = cw.id;
                            srcSf.Contact__c = String.isNotBlank(customerSf.Salesforce_Contact__c) ? customerSf.Salesforce_Contact__c : conID;
                            srcSf = constructBraintreePaymentMethod(srcSf, src, appConfig);
                            sourcesMap.put(src.node.id, srcSf);
                        }
                    }
                    
                    if(conID == NULL && (!existingSFCustomersMap.containsKey(refId) || (existingSFCustomersMap.containsKey(refId) && existingSFCustomersMap.get(refId).Salesforce_Contact__c == NULL && !existingSFCustomersMap.get(refId).No_Associated_SF_Contact__c ))){
                        // Create New accounts
                        Contact conRef = new Contact();
                        conRef.FirstName = (String.isNotBlank(cw.firstName) ? cw.firstName : '');
                        conRef.LastName = (String.isNotBlank(cw.lastName) ? cw.lastName : '');
                        conRef.Email = (String.isNotBlank(cw.email) ? cw.email : '');
                        conRef.Phone = cw.phoneNumber;
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
                // If Account Match is not completed, sync the customers without accounts
                System.debug('account match not done');
                for(String refId : braintreeIdCustomerMap.keySet()){
                    Customer.BraintreeCustomer customer = braintreeIdCustomerMap.get(refId);
                    if(String.isNotBlank(customer.company) ||  String.isNotBlank(customer.email) || String.isNotBlank(customer.id)){
                        BWP_Customer__c customerSf = existingSFCustomersMap.get(customer.id) != null ? existingSFCustomersMap.get(customer.id) : new BWP_Customer__c();
                        customerSf = constructBraintreeCustomer(customerSf, Customer, appConfig);
                        if(BreadwinnerUtil.accountId != null) {
                            customerSf.Salesforce_Account__c = BreadwinnerUtil.accountId;
                        }
                        customerUpsertMap.put(refId, customerSF);
                        customerUpsertList.add(customerSf);
                        if(customer.paymentMethods != NULL){
                            for(Customer.paymentMethodEdges src : customer.paymentMethods.edges){
                                BWP_Payment_Method__c srcSf =  existingSFPaymentMethodsMap.get(src.node.id) != null ? existingSFPaymentMethodsMap.get(src.node.id) : new BWP_Payment_Method__c();
                                srcSf.Customer__r = new BWP_Customer__c(Processor_Customer_Id__c = customer.id);
                                srcSf.Processor_Customer_Id__c = customer.id;
                                if(String.isNotBlank(customerSf.Salesforce_Account__c))
                                    srcSf.Account__c = customerSf.Salesforce_Account__c;
                                if(String.isNotBlank(customerSf.Salesforce_Contact__c))
                                    srcSf.Contact__c = customerSf.Salesforce_Contact__c;
                                constructBraintreePaymentMethod(srcSf, src, appConfig);
                                sourcesMap.put(src.node.id, srcSf);
                            }
                        }
                    }
                }
            }
            system.debug('customers----'+customerUpsertMap);
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

        }catch(Exception ex) {
            System.debug('Customer Sync failed for '+appConfig.Name +' while syncing. \n' +ex.getStackTraceString()+'\n'+ex.getMessage());
            APICallHandler.userInteractionLogPush(TRUE, 'Customer Sync', 'ERROR' , 'Customer Sync failed for '+appConfig.Name +' while syncing. \n' +ex.getStackTraceString()+'\n'+ex.getMessage());
        }
        return responseObj;
    }

    //Saving the payments to SF. Orphan records will not be saved.
    public static List<ProcessorUtil.PaymentWrapper> syncPayments(Map<String, Object> processorIdToPaymentMap, BreadwinnerUtil.AppConfig appConfig) {
        List<ProcessorUtil.PaymentWrapper> rtnList = new List<ProcessorUtil.PaymentWrapper>();
        Map<String, Object> returnMap = new Map<String, Object>();

        // Map tp store the Payment Id and related Customer Id
        Set <String> successfulPaymentsCustomerIdSet = new Set<String>();

        Map<String, Charge.BraintreeCharge> braintreeIdPaymentMap = (Map<String, Charge.BraintreeCharge>) processorIdToPaymentMap.get(ProcessorUtil.PAT_BRAINTREE);
        if (braintreeIdPaymentMap == null){
            return rtnList;
        }

        Map<String, BWP_Payment__c> upsertMapByRefId = new Map<String, BWP_Payment__c>();
        List<BWP_Payment__c> existingList = selectorPayment.selectByProcessorId(braintreeIdPaymentMap.keySet(), new List<String>{'Source__r.Id'});

        Map<String,BWP_Payment__c> existingSFPaymentsMap = new Map<String,BWP_Payment__c>();
        for(BWP_Payment__c payment : existingList) {
            BWP_Payment__c pmnt = new BWP_Payment__c(id = payment.id);
            existingSFPaymentsMap.put(pmnt.Processor_Id__c, pmnt);
        }

        try {
            // Boolean to check the syncing of failed Payments
            Boolean doNotImportCustomerAndFailedPayments = String.isBlank(appConfig.customerMatchConfig) || appConfig.customerMatchConfig.contains('NO_VALID_PAYMENTS');

            Set<String> customerIdSet = new Set<String>();
            Set<String> paymentMethodIdSet = new Set<String>();
            for (Charge.BraintreeCharge pw : braintreeIdPaymentMap.values()) {
                if (pw.customer != null && String.isNotBlank(pw.customer.id)){
                    customerIdSet.add(pw.customer.id);
                    if (pw.paymentMethod != null && String.isNotBlank(pw.paymentMethod.id)){
                        paymentMethodIdSet.add(pw.paymentMethod.id);
                    }
                }
            }

            Map<String, BWP_Customer__c> customerMapByProcessorCustomerId = new Map<String, BWP_Customer__c>();
            List<BWP_Customer__c> customerList = selectorCustomer.selectByProcessorCustomerId(customerIdSet,null);
            for (BWP_Customer__c customer : customerList) {
                customerMapByProcessorCustomerId.put(customer.Processor_Customer_Id__c, customer);
            }

            Map<String, BWP_Payment_Method__c> paymentMethodMapByProcessorId = new Map<String, BWP_Payment_Method__c>();
            List<String> pmIdList = new List<String>();
            pmIdList.addAll(paymentMethodIdSet);
            String pmIdString = String.join(pmIdList,'\',\'');
            List<BWP_Payment_Method__c> pmList = selectorPaymentMethod.selectWhere('Processor_Id__c IN (\'' + pmIdString + '\')');

            for (BWP_Payment_Method__c pm : pmList) {
                paymentMethodMapByProcessorId.put(pm.Processor_Id__c, pm);
            }

            for(Charge.BraintreeCharge pw : braintreeIdPaymentMap.values()){
                BWP_Customer__c customer = new BWP_Customer__c();
                if(pw.customer != null && customerMapByProcessorCustomerId.get(pw.customer.id) != null) {
                    customer = customerMapByProcessorCustomerId.get(pw.customer.id);
                }
                BWP_Payment_Method__c paymentMethod = new BWP_Payment_Method__c();
                if(pw.paymentMethod != null && paymentMethodMapByProcessorId.get(pw.paymentMethod.id) != null) {
                    paymentMethod = paymentMethodMapByProcessorId.get(pw.paymentMethod.id);
                }
                BWP_Payment__c paymentSf = existingSFPaymentsMap.get(pw.id) != null ? existingSFPaymentsMap.get(pw.id) : new BWP_Payment__c();

                if (customer != null) {
                    paymentSf.Customer__c = customer.Id;
                    paymentSf.Account__c = customer.Salesforce_Account__c != null ? customer.Salesforce_Account__c : null;
                    paymentSf.Contact__c = customer.Salesforce_Contact__c != null ? customer.Salesforce_Contact__c : null;
                }
                if (paymentMethod != null) {
                    paymentSf.Source__c = paymentMethod.Id;
                }
                paymentSf = constructBraintreePayment(paymentSf, pw, appConfig);
                if (doNotImportCustomerAndFailedPayments && paymentSf.Payment_Status__c == ProcessorUtil.CHARGE_SUCCEEDED) {
                    if(String.isNotBlank(paymentSf.Customer__c)){
                        successfulPaymentsCustomerIdSet.add(paymentSf.Customer__c);
                    }
                }
                if (String.isNotBlank(paymentSf.Customer__c) && (doNotImportCustomerAndFailedPayments ? (paymentSf.Payment_Status__c == ProcessorUtil.CHARGE_SUCCEEDED ? TRUE : (appConfig.currentRunningClassContext == BreadwinnerUtil.CNTX_BWAPI ? TRUE : FALSE)) : TRUE)){
                    upsertMapByRefId.put(paymentSf.Processor_Id__c, paymentSf);
                }
            }
        
            if(!upsertMapByRefId.isEmpty()){
                rtnList = ProcessorUtil.upsertAndReturnPaymentList(upsertMapByRefId.values());
            }
            
            if(doNotImportCustomerAndFailedPayments && !successfulPaymentsCustomerIdSet.isEmpty()){
                ProcessorUtil.updateSuccessfulPaymentsCustomers(doNotImportCustomerAndFailedPayments, successfulPaymentsCustomerIdSet);
            }
            
        }catch(Exception Ex) {
            System.debug('Payments Sync failed for '+appConfig.name +' while syncing. \n' + ex.getStackTraceString());
            APICallHandler.userInteractionLogPush(true, 'Customer Sync', 'ERROR' , 'Payments Sync failed for '+appConfig.name +' while syncing. \n' + ex.getStackTraceString());
        }
        return rtnList;
    }

    // This method is used to convert the Braintree Customer wrapper to Braintree Customer record.
    private static BWP_Customer__c constructBraintreeCustomer(BWP_Customer__c customerSf, Customer.BraintreeCustomer customer, BreadwinnerUtil.AppConfig appConfig){
        if(customerSf.Id == null){
            customerSf.Created_Via__c = BreadwinnerUtil.getCreatedViaValue(appConfig.currentRunningClassContext);
        }

        customerSf.Customer_ID__c = customer.legacyId+'-'+appConfig.PaymentProcessorType+'-'+appConfig.accountId;
        customerSf.Processor_Type__c = appConfig.PaymentProcessorType;
        customerSf.Processor_Org_Id__c = appConfig.accountId;
        customerSf.Processor_Org_Name__c = appConfig.accountName;
        customerSf.Livemode__c = appConfig.livemode;
        customerSf.Customer_Name__c = formatCustomerName(customer);
        customerSf.Name = (String.isNotBlank(customerSf.Customer_Name__c) ? customerSf.Customer_Name__c : ((String.isNotBlank(customer.email) ? customer.email : (String.isNotBlank(customer.id) ? customer.id : ''))));
        customerSf.Company__c = customer.company;
        customerSf.Processor_Customer_Id__c = customer.id;
        customerSf.First_Name__c = customer.firstName;
        customerSf.Last_Name__c = customer.lastName;
        customerSf.Email__c = customer.email;
        customerSf.Customer_Phone__c = customer.phoneNumber;
        customerSf.Created_Date_in_Processor__c = customerSf.Created_Date_in_Processor__c != null ? customerSf.Created_Date_in_Processor__c : customer.createdAt;
        if (customer.defaultPaymentMethod != null) {
            customerSf.Default_Source__c = customer.defaultPaymentMethod.id;
        }

        return customerSf;
    }
    // This method is used to convert the Braintree Payment Method wrapper to Braintree Payment Method record.
    @TestVisible
    private static BWP_Payment_Method__c constructBraintreePaymentMethod(BWP_Payment_Method__c srcSf, Customer.PaymentMethodEdges src, BreadwinnerUtil.AppConfig appConfig){
        if(srcSf.Id == null){
            srcSf.Created_Via__c = BreadwinnerUtil.getCreatedViaValue(appConfig.currentRunningClassContext);
        }
        srcSf.Processor_Type__c = appConfig.PaymentProcessorType;
        srcSf.Processor_Org_Id__c = appConfig.accountId;
        srcSf.Livemode__c = appConfig.livemode;
        srcSf.Processor_Id__c = src.node.id;
        if(src.node.details.typename == 'CreditCardDetails'){
            Map<String, String> cardTypeName = ProcessorUtil.getCardTypeName();
            String cardType = cardTypeName.get(String.ValueOf(src.node.details.brandCode));
            srcSf.Card_Brand__c = cardType;
            srcSf.Last_4_digits__c = String.ValueOf(src.node.details.last4);
            srcSf.Expiry_Month__c = src.node.details.expirationMonth;
            srcSf.Expiry_Year__c = src.node.details.expirationYear;
            srcSf.Name_On_Card__c = src.node.details.cardholderName;
            srcSf.Type__c = ProcessorUtil.PM_CARD;
        }
        else if(src.node.details.typename == 'UsBankAccountDetails'){
            srcSf.Bank_Account_Holder_Name__c = src.node.details.accountholderName;
            srcSf.Bank_Name__c = src.node.details.bankName;
            srcSf.Last_4_digits__c = src.node.details.last4;
            srcSf.Routing_Number__c = src.node.details.routingNumber;
            if(src.node.details.verified == 'true'){
                srcSf.Card_Status__c = 'Verified';
            }
            else{
                srcSf.Card_Status__c = 'Pending'; 
            }
            srcSf.Type__c = ProcessorUtil.PM_BANK; 
        }
        return srcSf;
    }

    // This method is used to convert the Braintree Payment wrapper to Braintree Payment record.
    private static BWP_Payment__c constructBraintreePayment(BWP_Payment__c paymentSf, Charge.BraintreeCharge pw, BreadwinnerUtil.AppConfig appConfig){

        paymentSf.Processor_Id__c = pw.id;
        paymentSf.Created_Date_in_Processor__c = pw.createdAt;
        paymentSf.Is_Live_Payment__c = appConfig.livemode;
        paymentSf.Processor_Type__c = appConfig.PaymentProcessorType;
        paymentSf.Processor_Org_Id__c = appConfig.accountId;

        Map<String, String> brantreePaymentStatus = getBraintreePaymentStatus();
        if (String.isNotBlank(pw.status)) {
            //String status = brantreePaymentStatus.get(pw.status);
            String status = '';
            if(pw.status == 'SETTLED'){
                status = ProcessorUtil.CHARGE_SUCCEEDED;
            }
            else if(pw.status == 'SETTLING' || pw.status == 'SUBMITTED_FOR_SETTLEMENT' || pw.status == 'SETTLEMENT_PENDING'|| pw.status == 'AUTHORIZING' || pw.status == 'AUTHORIZED'){
                status = ProcessorUtil.CHARGE_PENDING;
            }
            else if(pw.status == 'PROCESSOR_DECLINED' || pw.status == 'SETTLEMENT_DECLINED' || pw.status == 'AUTHORIZATION_EXPIRED'){
                status = ProcessorUtil.CHARGE_DECLINED;
            }
            else if(pw.status == 'GATEWAY_REJECTED'){
                status = ProcessorUtil.CHARGE_REJECTED;
            }
            else if(pw.status == 'VOIDED'){
                status = ProcessorUtil.CHARGE_VOIDED;
            }
            else if(pw.status == 'FAILED'){
                status = ProcessorUtil.CHARGE_FAILED;
            }
            paymentSf.Payment_Status__c = status;
        }
        if (String.isNotBlank(pw.amount.value)) {
            paymentSf.Amount__c = Decimal.valueOf(pw.amount.value);
        }
        if (String.isNotBlank(pw.amount.currencyISOCode)) {
            paymentSf.Currency__c = (pw.amount.currencyISOCode).toUpperCase();
        }
        if(paymentSf.Id == null){
            //new payment
            paymentSf.Created_Via__c = BreadwinnerUtil.getCreatedViaValue(appConfig.currentRunningClassContext);
        }

        if (pw.customer != null && String.isNotBlank(pw.customer.id)) {
            paymentSf.Processor_Customer_Id__c = pw.customer.id;
        }
        return paymentSf;
    }

    private static Map<String, String> getBraintreePaymentStatus(){
        Map<String, String> mapOfBraintreePaymentStatus = new Map<String, String>();
        mapOfBraintreePaymentStatus.put('AUTHORIZATION_EXPIRED', 'Authorization Expired');
        mapOfBraintreePaymentStatus.put('AUTHORIZED', 'Authorized');
        mapOfBraintreePaymentStatus.put('AUTHORIZING', 'Authorizing');
        mapOfBraintreePaymentStatus.put('FAILED', 'Failed');
        mapOfBraintreePaymentStatus.put('GATEWAY_REJECTED', 'Gateway Rejected');
        mapOfBraintreePaymentStatus.put('PROCESSOR_DECLINED', 'Processor Declined');
        mapOfBraintreePaymentStatus.put('SETTLED', 'Settled');
        mapOfBraintreePaymentStatus.put('SETTLEMENT_DECLINED', 'Settlement Declined');
        mapOfBraintreePaymentStatus.put('SETTLEMENT_PENDING', 'Settlement Pending');
        mapOfBraintreePaymentStatus.put('SETTLING', 'Settling');
        mapOfBraintreePaymentStatus.put('SUBMITTED_FOR_SETTLEMENT', 'Submitted For Settlement');
        mapOfBraintreePaymentStatus.put('VOIDED', 'Voided');
        return mapOfBraintreePaymentStatus;
    }

    private static Map<String, Object> excludeCustomers(Map<String, Object> processorToCustomerMap, BreadwinnerUtil.AppConfig appConfig){
        Map<String, Customer.BraintreeCustomer> braintreeIdCustomerMap =  new Map<String, Customer.BraintreeCustomer>();
        Map<String, Object> returnProcessorToCustomerMap = new Map<String, Object>();
        String customerSyncConfigValue = '';
        customerSyncConfigValue = String.isNotBlank(appConfig.customerSyncConfig) ? appConfig.customerSyncConfig : 'NONAME_AND_NOEMAIL';

        braintreeIdCustomerMap = (Map<String, Customer.BraintreeCustomer>) processorToCustomerMap.get(ProcessorUtil.PAT_BRAINTREE);

        // Excluding Braintree Customers based on configuration values from Breadwinner Payments page
        if(!braintreeIdCustomerMap.isEmpty()){
            for(String contactId : braintreeIdCustomerMap.keySet()){
                Customer.BraintreeCustomer bc = braintreeIdCustomerMap.get(contactId);
                Boolean excludeCustomer = false;
                String cName = formatCustomerName(bc);
                if(customerSyncConfigValue.contains('NONAME_AND_NOEMAIL') && String.isBlank(cName) && String.isBlank(bc.email)){
                    excludeCustomer = true;
                }
                else if(customerSyncConfigValue.contains('NO_NAME') && (String.isBlank(cName))){
                    excludeCustomer = true;
                }
                else if(customerSyncConfigValue.contains('NO_EMAIL') && String.isBlank(bc.email)){
                    excludeCustomer = true;
                }
                if(excludeCustomer){
                    braintreeIdCustomerMap.remove(contactId);
                }
            }
        }
        if(!braintreeIdCustomerMap.isEmpty()){
            returnProcessorToCustomerMap.put(ProcessorUtil.PAT_BRAINTREE, braintreeIdCustomerMap);
        }

        return returnProcessorToCustomerMap;
    }

    private static String formatCustomerName(Customer.BraintreeCustomer bc){
        String customerName = (String.isNotBlank(bc.firstName) ? (bc.firstName + (String.isNotBlank(bc.lastName) ? (' '+bc.lastName) : '')) : (String.isNotBlank(bc.lastName) ? bc.lastName : ''));
        return customerName;
    }

    public static String getEndpointBaseUrl(BreadwinnerUtil.AppConfig appConfig){
        return appConfig.livemode ? braintreeProductionUrl : braintreeSandBoxUrl;
    }

    // This method will return the Graphql query string to make a request to Braintree
    public static String getRequestBody (String typeOfAction, String Id) {
        String requestBody;
        if (typeOfAction == 'fetchAllCustomers') {
            requestBody = '{ "query": "query { search { customers (input: {}, first: 50, after: '+(String.isNotBlank(Id) ? ('\\"'+Id+'\\"') : null);
            requestBody += ') { pageInfo { hasNextPage startCursor endCursor } edges { node { id legacyId company firstName lastName phoneNumber email createdAt defaultPaymentMethod { id }';
            requestBody += 'paymentMethods (first: 50) { edges { node { id legacyId usage details { __typename ... on CreditCardDetails { brandCode last4 expirationMonth expirationYear cardholderName uniqueNumberIdentifier } ... on UsBankAccountDetails { accountholderName accountType bankName last4 routingNumber verified } } } } }';
            requestBody +=   '} } } } }"}';
        } else if (typeOfAction == 'fetchAllPayments') {
            requestBody = '{ "query": "query { search { transactions (input: {}, first: 50, after: '+(String.isNotBlank(Id) ? ('\\"'+Id+'\\"') : null);
            requestBody += ') { pageInfo{ hasNextPage startCursor endCursor }';
            requestBody += 'edges { node { id legacyId createdAt status amount { value currencyIsoCode } customer { id } paymentMethod { id } } }';
            requestBody += '} } }"}';
        } else if (typeOfAction == 'fetchRecentCustomers') {
            requestBody = '{"query": "query Search($input: CustomerSearchInput!) { search { customers(input: $input, first: 50, after: '+(String.isNotBlank(Id) ? ('\\"'+Id+'\\"') : null);
            requestBody += ' ) { pageInfo { hasNextPage  startCursor endCursor },';
            requestBody += ' edges { node { id legacyId company firstName lastName phoneNumber email createdAt defaultPaymentMethod { id }';
            requestBody += ' paymentMethods (first: 50) { edges { node { id legacyId usage details { __typename ... on CreditCardDetails {';
            requestBody += ' brandCode last4 expirationMonth expirationYear cardholderName uniqueNumberIdentifier }';
            requestBody += ' ... on UsBankAccountDetails { accountholderName accountType bankName last4 routingNumber verified } } } } } } } } } }",';
        } else if (typeOfAction == 'fetchRecentPayments') {
            requestBody = '{"query": "query Search($input: TransactionSearchInput!) { search { transactions(input: $input, first: 50, after: '+(String.isNotBlank(Id) ? ('\\"'+Id+'\\"') : null);
            requestBody += ' ) { pageInfo { hasNextPage  startCursor endCursor }, edges { node { id legacyId createdAt status amount { value currencyIsoCode } customer { id } paymentMethod { id } } } } } }",';
        }
        return requestBody;
    }

    public static void saveAppCredentials(BWP_Processor_Config__c config, String braintreePublicKey, String braintreePrivateKey, Boolean isBraintreeProduction) {
        String braintreeId = '';
        String braintreeAccountName = '';
        HTTPResponse res = authorizeAccount(braintreePublicKey, braintreePrivateKey, isBraintreeProduction);
        Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        Map<String, Object>  data = (Map<String, Object>)response.get('data');
        Map<String, Object> viewer = new Map<String, Object>();
        Map<String, Object> barintreeObj = new Map<String, Object>();
        List<Map<String, Object>> errorsList = new List<Map<String, Object>>();	
        Map<String, Object> errorsMap = new Map<String, Object>();
        if(data != null){
            viewer = (Map<String, Object>)data.get('viewer');
            barintreeObj = (Map<String, Object>)viewer.get('merchant');
            if(barintreeObj != null){
                if(barintreeObj.get('id') != null){
                    braintreeId = barintreeObj.get('id').toString();
                    braintreeAccountName = barintreeObj.get('companyName').toString();
                }
            }
        }
        if(response.get('errors') != null){	
            for (Object errors : (List<Object>)response.get('errors')){	
                errorsList.add((Map<String, Object>)errors); 	
            }	
            for(object error : errorsList){	
                errorsMap = (Map<String, Object>)error;	
            }	
            BreadwinnerController.braintreeAuthErrors = (errorsMap.get('message') != null) ? (errorsMap.get('message')).toString() : '';	
            return;
        }
        if(String.isNotBlank(braintreeId)){
            Blob headerValue = Blob.valueOf(braintreePublicKey + ':' + braintreePrivateKey);
            config = BreadwinnerUtil.getProcessorConfig(braintreeId) != null ? BreadwinnerUtil.getProcessorConfig(braintreeId) : new BWP_Processor_Config__c();
            config.Payment_Processor_Type__c = ProcessorUtil.PAT_BRAINTREE;
            config.Access_Token__c = EncodingUtil.base64Encode(headerValue);
            config.Name = braintreeId;
            config.Account_Name__c = braintreeAccountName;
            config.Provider_ID__c = braintreeId;
            config.Live_Mode__c = isBraintreeProduction ? true : false;
            if(config.Customer_Sync_Config__c == NULL) {
                config.Customer_Sync_Config__c = 'NONAME_AND_NOEMAIL';
            }
            if(config.Customer_Match_Config__c == NULL) {
                config.Customer_Match_Config__c = 'NO_VALID_PAYMENTS';
            }
            config = CryptoUtil.encryptSecrets(config);
            BreadwinnerUtil.upsertAppConfig(config);
        }
        else {
            throw new ProcessorUtil.ConnectionException('Error occurred while connecting with Braintree.');
        }
    }

    /* This method is used to Authorize the Braintree Account */
    public static HttpResponse authorizeAccount(String braintreePublicKey, String braintreePrivateKey, Boolean isProduction){
        String endPoint = (isProduction) ? 'https://payments.braintree-api.com/graphql' : 'https://payments.sandbox.braintree-api.com/graphql';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        Blob headerValue = Blob.valueOf(braintreePublicKey + ':' + braintreePrivateKey);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Braintree-Version', '2019-01-01');
        req.setBody('{ "query": "query {  viewer {  merchant { id companyName } } }" }');
        Http http = new Http();
        HttpResponse res = http.send(req);
        return res;
    }

    public class FetchResponse {
        public String cursor;
        public Boolean requireNextRun;
        public Map<String, Customer.BraintreeCustomer> customerMapById;
        public Map<String, Charge.BraintreeCharge> paymentMapById;
    }

    public class Amount {
        public String value;
        public String currencyISOCode;
    }
    public class PaymentMethod {
        public String id;
    }
    public class Payments {
        public pageInfo pageInfo;
        public list<PaymentNode> edges;
    }
    public class PaymentNode{
        public Charge.BraintreeCharge node;
    }
    public class Customers{
        public pageInfo pageInfo;
        public list<CustomerNode> edges;
    }
    public class CustomerNode{
        public Customer.BraintreeCustomer node;
    }
    public class PageInfo{
        public Boolean hasNextPage;
        public String startCursor;
        public String endCursor;
    }

    private class ErrorFromBraintree {
        public String message;
        public extensionType extensions;
    }
    private class extensionType {
        public String errorType;
        public String errorClass;
    }
}