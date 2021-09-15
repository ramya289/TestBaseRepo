public with sharing class Processor_Square  extends Processor {

    private static Selector_BWP_Customer selectorCustomer = new Selector_BWP_Customer();
    private static Selector_BWP_Payment selectorPayment = new Selector_BWP_Payment();
    private static Selector_BWP_Payment_Method selectorPaymentMethod = new Selector_BWP_Payment_Method();

    //Square Endpoints
    public static String squareBaseUrlv2 = 'https://connect.squareup.com/v2';
    public static String squareTestBaseUrlv2 = 'https://connect.squareupsandbox.com/v2';
    public static String squareAuthorizationUrl = 'https://connect.squareup.com/oauth2';
    public static String squareTestAuthorizationUrl = 'https://connect.squareupsandbox.com/oauth2';

    BWP_Processor_Config__c apc;
    BreadwinnerUtil.AppConfig apcWrapper;

    public Processor_Square(String stripeAccountId) {
        apc = BreadwinnerUtil.getProcessorConfig(stripeAccountId);
        if (apc == null) {
           throw new ProcessorUtil.InvalidAccountConfigurationException('Invalid Square ORG Id provided.');
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
    public override ProcessorUtil.ResponseObject createCardToken(String requestJSON) {
        return createCardToken(apcWrapper, requestJSON);
    }
    public override ProcessorUtil.ResponseObject chargeProcessor(String requestJSON, String timeout) {
        return chargeProcessor(apcWrapper, requestJSON, timeout);
    }
    public override ProcessorUtil.ResponseObject fetchCustomers(String requestJSON){
        return fetchCustomers(apcWrapper, requestJSON);
    }
    public override ProcessorUtil.ResponseObject fetchPayments(String requestJSON){
        return fetchPayments(apcWrapper, requestJSON);
    }
    
    
    @TestVisible
    private static ProcessorUtil.ResponseObject createCustomer(BreadwinnerUtil.AppConfig apcWrapper, String requestJSON){

        Map<String, Customer.SquareCustomer> squareIdCustomerMapResponse = new Map<String, Customer.SquareCustomer> ();

        ProcessorUtil.ResponseObject response = new ProcessorUtil.ResponseObject();
        response.errors = new List<ProcessorUtil.Error>();

        Map<String, Object> objectMap = (Map<String,Object>) JSON.deserializeUntyped(requestJSON);
        System.debug('objectMap: ' + objectMap);

        List<Object> objectList = (List<Object>) objectMap.get('customer');

        // addToSalesforce by default
        Boolean addToSalesforce = true;
        if (objectMap.get('addToSalesforce') != null){
            addToSalesforce = (Boolean) objectMap.get('addToSalesforce');
        }

        String endPoint = getEndpointBaseUrl(apcWrapper) + '/customers';

        try {
            for (Object obj : objectList){
                try{
                    String jsonObject = JSON.serializePretty(obj);
                    JSONParser objectParser = JSON.createParser(jsonObject);
                    Customer.SquareCustomer customer = (Customer.SquareCustomer) objectParser.readValueAs(Customer.SquareCustomer.class);
                    String reqBody = '';
                    reqBody = JSON.serializePretty(customer);
                                        
                    if (customer != null && customer.accountId != null){
                        BreadwinnerUtil.accountId = customer.accountId;
                    }

                    HttpResponse res = APICallHandler.post(apcWrapper, 'POST', endPoint, reqBody);
                    if (res.getStatusCode() == 200) {
                        JSONParser parser = JSON.createParser(res.getBody());
						SquareCustomers customersResp = (SquareCustomers) parser.readValueAs(SquareCustomers.Class);
                        Customer.SquareCustomer customerData = customersResp.customer;
                        squareIdCustomerMapResponse.put(customerData.id, customerData);

                        apcWrapper.currentRunningClassContext = BreadwinnerUtil.CNTX_BWAPI;

                        Map<String, Object> processorToCustomerMap = new Map<String, Object>{apcWrapper.PaymentProcessorType => squareIdCustomerMapResponse};
                        response = syncCustomers(processorToCustomerMap, apcWrapper,addToSalesforce);
                        response.responseJSON = JSON.serializePretty(squareIdCustomerMapResponse);
                        response.status = String.valueOf(res.getStatusCode());
                    } else {
                        Map<String, Object> responseOfVaultPM = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                        List<Object> errorsListOfVaultPM = (List<Object>)responseOfVaultPM.get('errors');
                        Map<String, Object> error = (Map<String, Object>)errorsListOfVaultPM[0];
                        String errorMessage = error.get('detail').toString();
                        if(errorMessage == 'At least one of `given_name`, `family_name`, `company_name`, `email_address`, or `phone_number` is required for a customer.')
                            errorMessage = 'At least one of First Name, Last Name, Company, Email or Phone is required for a Customer';
                        response.errors.add(new ProcessorUtil.Error(error.get('code').toString(), errorMessage));
                        APICallHandler.userInteractionLogPush(true, 'Create Square Customer', 'ERROR' , 'Response for Square Org Name('+apcWrapper.accountName+'): Status Code: '+res.getStatusCode()+' Response Body: '+res.getBody() );
                    }
                } catch (Exception ex) {
                    // We want to catch any additional errors and let the process continue.
                    response.errors.add(new ProcessorUtil.Error('Exception Occurred', 'An Exception occurred while creating the Customer to Square. ' + ex.getMessage()));
                    System.debug('Exception occurred while creating customers in Square.' + ex.getStackTraceString());
                }
            }

        } catch (Exception ex) {
            response.errors.add(new ProcessorUtil.Error('Exception Occurred', 'An Exception occurred while creating the Customer to Square. ' + ex.getMessage()));
            System.debug('Exception occurred while creating customers in Square.' + ex.getStackTraceString());
        }

        return response;

    }

    @TestVisible
    private static ProcessorUtil.ResponseObject updateCustomer(BreadwinnerUtil.AppConfig apcWrapper, String requestJSON){
        System.debug('request: ' + requestJSON);
        
        Map<String, Customer.SquareCustomer> squareIdCustomerMapResponse = new Map<String, Customer.SquareCustomer> ();
        
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
            for (Object obj : objectList){
                try{
                    String jsonObject = JSON.serializePretty(obj);
                    JSONParser objectParser = JSON.createParser(jsonObject);
                    Customer.SquareCustomer customer = (Customer.SquareCustomer) objectParser.readValueAs(Customer.SquareCustomer.class);
                    String reqBody = '';
                    reqBody = JSON.serializePretty(customer);
                    
                    String endPoint = getEndpointBaseUrl(apcWrapper) + '/customers/'+customer.id;
                    HttpResponse res = APICallHandler.post(apcWrapper, 'PUT', endPoint, reqBody);
                    if (res.getStatusCode() == 200) {
                        JSONParser parser = JSON.createParser(res.getBody());
                        SquareCustomers customersResp = (SquareCustomers) parser.readValueAs(SquareCustomers.Class);
                        Customer.SquareCustomer customerData = customersResp.customer;
                        squareIdCustomerMapResponse.put(customerData.id, customerData);
                        
                        apcWrapper.currentRunningClassContext = BreadwinnerUtil.CNTX_BWAPI;
                        Map<String, Object> processorToCustomerMap = new Map<String, Object>{apcWrapper.PaymentProcessorType => squareIdCustomerMapResponse};
                        response = syncCustomers(processorToCustomerMap, apcWrapper,addToSalesforce);
                        response.responseJSON = JSON.serializePretty(squareIdCustomerMapResponse);
                        response.status = String.valueOf(res.getStatusCode());
                    } else {
                        Map<String, Object> responseOfVaultPM = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                        List<Object> errorsListOfVaultPM = (List<Object>)responseOfVaultPM.get('errors');
                        Map<String, Object> error = (Map<String, Object>)errorsListOfVaultPM[0];
                        String errorMessage = error.get('detail').toString();
                        if(errorMessage == 'At least one of `given_name`, `family_name`, `company_name`, `email_address`, or `phone_number` is required for a customer.')
                            errorMessage = 'At lease one of First Name, Last Name, Company, Email or Phone is required for a Customer';
                        if(errorMessage == 'Provided value for `email_address` is invalid.')
                            errorMessage = 'Provided value for email address is invalid.';
                        response.errors.add(new ProcessorUtil.Error(error.get('code').toString(), errorMessage));
                        APICallHandler.userInteractionLogPush(true, 'Update Square Customer', 'ERROR' , 'Response for Square Org Name('+apcWrapper.accountName+'): Status Code: '+res.getStatusCode()+' Response Body: '+res.getBody() );
                    }
                } catch (Exception ex) {
                    // We want to catch any additional errors and let the process continue.
                    response.errors.add(new ProcessorUtil.Error('Exception Occurred', 'An Exception occurred while updating the Customer to Square. ' + ex.getMessage()));
                    System.debug('Exception occurred while updating customers in Square.' + ex.getStackTraceString());
                }
            }
            
        } catch (Exception ex) {
            response.errors.add(new ProcessorUtil.Error('Exception Occurred', 'An Exception occurred while updating the Customer to Square. ' + ex.getMessage()));
            System.debug('Exception occurred while updating customers in Square.' + ex.getStackTraceString());
        }
        return response;
    }
    
    @TestVisible
    private static ProcessorUtil.ResponseObject createCardToken(BreadwinnerUtil.AppConfig apcWrapper, String requestJSON){

        Map<String, Customer.SquareCustomer> squareIdCustomerMapResponse = new Map<String, Customer.SquareCustomer> ();

        ProcessorUtil.ResponseObject response = new ProcessorUtil.ResponseObject();
        response.errors = new List<ProcessorUtil.Error>();

        Map<String, Object> objectMap = (Map<String,Object>) JSON.deserializeUntyped(requestJSON);
        System.debug('objectMap: ' + objectMap);

        List<Object> objectList = (List<Object>) objectMap.get('customer');

        // addToSalesforce by default
        Boolean addToSalesforce = true;
        if (objectMap.get('addToSalesforce') != null){
            addToSalesforce = (Boolean) objectMap.get('addToSalesforce');
        }

        try {
            for (Object obj : objectList){
                try{
                    String jsonObject = JSON.serializePretty(obj);
                    JSONParser objectParser = JSON.createParser(jsonObject);
                    Customer.SquareCustomer customer = (Customer.SquareCustomer) objectParser.readValueAs(Customer.SquareCustomer.class);
                    String endPoint = getEndpointBaseUrl(apcWrapper) + '/customers/'+customer.id+'/cards';
                    String reqBody = '{"card_nonce":' +'\"'+customer.cards[0].card_nonce+'\"';
                    reqBody += ', "cardholder_name" : '+(String.isNotBlank(customer.cards[0].cardholder_name) ? ('\"' + customer.cards[0].cardholder_name + '\"') : null);
                    String country = '';
                    if(customer.cards[0].billing_address != null){
                        country = customer.cards[0].billing_address.country;
                        reqBody += ', "billing_address" : {';
                        reqBody += ' "address_line_1" : '+(String.isNotBlank(customer.cards[0].billing_address.address_line_1) ? ('\"' + customer.cards[0].billing_address.address_line_1 + '\"') : null);                              
                        reqBody += ', "address_line_2" : '+(String.isNotBlank(customer.cards[0].billing_address.address_line_2) ? ('\"' + customer.cards[0].billing_address.address_line_2 + '\"') : null);                              
                        reqBody += ', "administrative_district_level_1" : '+(String.isNotBlank(customer.cards[0].billing_address.administrative_district_level_1) ? ('\"' + customer.cards[0].billing_address.administrative_district_level_1 + '\"') : null);                              
                        reqBody += ', "locality" : '+(String.isNotBlank(customer.cards[0].billing_address.locality) ? ('\"' + customer.cards[0].billing_address.locality + '\"') : null);                              
                        reqBody += ', "postal_code" : '+(String.isNotBlank(customer.cards[0].billing_address.postal_code) ? ('\"' + customer.cards[0].billing_address.postal_code + '\"') : null);                              
                        reqBody += ', "country" : '+(String.isNotBlank(customer.cards[0].billing_address.country) ? ('\"' + customer.cards[0].billing_address.country + '\"') : null);                              
                        reqBody += '}';
                    }
                    reqBody += '}';
                    if (customer != null && customer.accountId != null){
                        BreadwinnerUtil.accountId = customer.accountId;
                    }
                    HttpResponse res = APICallHandler.post(apcWrapper, 'POST', endPoint, reqBody);
                    if (res.getStatusCode() == 200) {
                        HttpResponse resp = APICallHandler.getList(apcWrapper, 'GET', getEndpointBaseUrl(apcWrapper) + '/customers/'+customer.id, '');
                        JSONParser parser = JSON.createParser(resp.getBody());
                        SquareCustomers customersResp = (SquareCustomers) parser.readValueAs(SquareCustomers.Class);
                        Customer.SquareCustomer customerData = customersResp.customer;
                        squareIdCustomerMapResponse.put(customerData.id, customerData);
                        apcWrapper.currentRunningClassContext = BreadwinnerUtil.CNTX_BWAPI;

                        Map<String, Object> processorToCustomerMap = new Map<String, Object>{apcWrapper.PaymentProcessorType => squareIdCustomerMapResponse};
                        response = syncCustomers(processorToCustomerMap, apcWrapper, addToSalesforce);
                        response.responseJSON = resp.getBody();
                        response.status = String.valueOf(resp.getStatusCode());
                    } else {
                        Map<String, Object> responseOfVaultPM = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                        List<Object> errorsListOfVaultPM = (List<Object>)responseOfVaultPM.get('errors');
                        Map<String, Object> error = (Map<String, Object>)errorsListOfVaultPM[0];
                        String errorMessage = error.get('detail').toString();
                        if(errorMessage.containsIgnoreCase('is not a valid enum value for `billing_address.country`.'))
                            errorMessage = country+ ' is not a valid Enum, please update it correctly';
                        response.errors.add(new ProcessorUtil.Error(error.get('code').toString(), errorMessage));
                        APICallHandler.userInteractionLogPush(true, 'Create Square Card', 'ERROR' , 'Response for Square Org Name('+apcWrapper.accountName+'): Status Code: '+res.getStatusCode()+' Response Body: '+res.getBody() );
                    }
                } catch (Exception ex) {
                    // We want to catch any additional errors and let the process continue.
                    response.errors.add(new ProcessorUtil.Error('Exception Occurred', 'An Exception occurred while creating the Customer to Square. ' + ex.getMessage()));
                    System.debug('Exception occurred while creating card in Square.' + ex.getStackTraceString());
                }
            }

        } catch (Exception ex) {
            response.errors.add(new ProcessorUtil.Error('Exception Occurred', 'An Exception occurred while creating the Customer to Square. ' + ex.getMessage()));
            System.debug('Exception occurred while creating customers in Square.' + ex.getStackTraceString());
        }

        return response;

    }

    @TestVisible
    private static ProcessorUtil.ResponseObject chargeProcessor(BreadwinnerUtil.AppConfig apcWrapper, String requestJSON, String timeout){

        Customer.SquareCustomer squareCustomer = new Customer.SquareCustomer();

        ProcessorUtil.ResponseObject response = new ProcessorUtil.ResponseObject();
        response.errors = new List<ProcessorUtil.Error>();

        Map<String, Object> objectMap = (Map<String,Object>) JSON.deserializeUntyped(requestJSON);
        System.debug('objectMap: ' + objectMap);

        List<Object> objectList = (List<Object>) objectMap.get('charge');
        if (objectList.size() > 1){
            response.errors.add(new ProcessorUtil.Error('', 'You can only make one charge at a time.'));
            return response;
        }
        Charge.SquareCharge charge;
        try{
            String jsonObject = JSON.serializePretty(objectList[0]);
            JSONParser objectParser = JSON.createParser(jsonObject);
            charge = (Charge.SquareCharge) objectParser.readValueAs(Charge.SquareCharge.class);
			String endPoint = getEndpointBaseUrl(apcWrapper) + '/payments';
            if (charge.customer_id == null) {
                response.errors.add(new ProcessorUtil.Error('Required field missing.','Square customer Id is required.'));
                return response;
            }

            if (String.isBlank(charge.amount_money.square_currency)) {
                response.errors.add(new ProcessorUtil.Error('Required field missing.','currency is required.'));
                return response;
            }

            if (charge.amount_money.amount == null || charge.amount_money.amount <= 0) {
                response.errors.add(new ProcessorUtil.Error('Required field missing.','"amount" is required and must be greater than zero.'));
                return response;
            }

            String reqBody = '{"idempotency_key":' +'\"'+charge.idempotency_key+'\"';
            reqBody += ', "amount_money" : {';
            reqBody += ' "amount" : ' +charge.amount_money.amount;
            reqBody += ', "currency" : ' +'\"'+charge.amount_money.square_currency+'\"}';
            reqBody += ', "source_id" : ' +'\"' +charge.source_id+'\"';
            reqBody += ', "customer_id" : ' +'\"' +charge.customer_id+'\"';
            reqBody += '}'; 
            System.debug('--reqBody--'+reqBody);
            HttpResponse res = APICallHandler.post(apcWrapper, 'POST', endPoint, reqBody, timeout);
            System.debug('--res---'+res.getBody());
              if (res.getStatusCode() == 200) {
                  String  responseStr = res.getBody().replaceAll('"currency"', '"square_currency"');
                  JSONParser parser = JSON.createParser(responseStr);
                  Map<String, Charge.SquareCharge > squareIdChargeMapResponse = new Map<String, Charge.SquareCharge> ();
                  SquarePayments payments = (SquarePayments) parser.readValueAs(SquarePayments.class);
                  Charge.SquareCharge payment = payments.payment;
                  squareIdChargeMapResponse.put(payment.id, payment);
                  Map<String, Object> processorToPaymentMap = new Map<String, Object>();
                  processorToPaymentMap.put(ProcessorUtil.PAT_SQUARE, squareIdChargeMapResponse);
                  apcWrapper.currentRunningClassContext = BreadwinnerUtil.CNTX_BWAPI;
                  response.paymentList = syncPayments(processorToPaymentMap, apcWrapper);
                  response.responseJSON = JSON.serializePretty(squareIdChargeMapResponse);
                  response.status = String.valueOf(res.getStatusCode());
              }
            else {
                Map<String, Object> responseOfVaultPM = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                List<Object> errorsListOfVaultPM = (List<Object>)responseOfVaultPM.get('errors');
                Map<String, Object> error = (Map<String, Object>)errorsListOfVaultPM[0];
                response.errors.add(new ProcessorUtil.Error(error.get('code').toString(), error.get('detail').toString()));
                APICallHandler.userInteractionLogPush(true, 'Create Charge', 'ERROR' , 'Response for Square Org Name('+apcWrapper.accountName+'): Status Code: '+res.getStatusCode()+' Response Body: '+res.getBody() );
            }
        }
        catch (Exception ex) {
            response.errors.add(new ProcessorUtil.Error('Exception Occurred','An Exception occurred while charging. ' + ex.getMessage()));
            System.debug('Exception occurred while charging' + ex.getStackTraceString());
            APICallHandler.userInteractionLogPush(FALSE, 'Create Square Payment', 'ERROR', 'Exception: '+ex.getMessage());
        }
        return response;
    }
    
    
    @TestVisible
    private static ProcessorUtil.ResponseObject fetchCustomers(BreadwinnerUtil.AppConfig apcWrapper, String requestJSON) {
        ProcessorUtil.ResponseObject response = new ProcessorUtil.ResponseObject();
        response.errors = new List<ProcessorUtil.Error>();
        FetchRequest filters = (FetchRequest)System.JSON.deserialize(requestJSON, FetchRequest.class);
        String endPoint = getEndpointBaseUrl(apcWrapper) + '/customers/search';
        String reqBody = '';
        reqBody = (String.isNotBlank(filters.square_limit)) ? '{"limit":'+filters.square_limit : '{"limit":10';
        reqBody += String.isNotBlank(filters.cursor) ? ',"cursor":"'+filters.cursor+'"' : '';

        if(String.isNotBlank(filters.begin_time)){
            system.debug('single');
            reqBody += ',"query": {"filter":{"updated_at":{"start_at":'+filters.begin_time+'}}}}';
        }
        else{
            reqBody += '}'; 
        }
        HttpResponse res = APICallHandler.getList(apcWrapper, 'GET', endPoint, reqBody);

        response.status = String.valueOf(res.getStatusCode());

        if (res.getStatusCode() == 200) {
            FetchResponse fetchResponse = new FetchResponse();
            fetchResponse = parseCustomers(res.getBody());
            response.responseJSON = JSON.serializePretty(fetchResponse);

        } else {
            //apcWrapper.needToReconnect = true;
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
        FetchRequest filters = (FetchRequest)System.JSON.deserialize(requestJSON, FetchRequest.class);
        String endPoint = getEndpointBaseUrl(apcWrapper) + '/payments';
        endPoint += String.isNotBlank(filters.cursor) ? '?cursor=' + filters.cursor : '';
        if(String.isNotBlank(filters.begin_time)) {
            endPoint += (endPoint.contains('?') ? '&' : '?') + 'begin_time=' + filters.begin_time + '&end_time=' + filters.end_time;
        }

        HttpResponse res = APICallHandler.getList(apcWrapper, 'GET', endPoint, '');
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
        List<Customer.SquareCustomer> customersList = new List<Customer.SquareCustomer>();	
        Map<String, Customer.SquareCustomer> squareIdCustomerMap = new Map<String, Customer.SquareCustomer>();
        FetchResponse response = new FetchResponse();
        try{	
            JSONParser parser = JSON.createParser(responseBody);
            SquareCustomers customersResp = (SquareCustomers) parser.readValueAs(SquareCustomers.Class);
            if(customersResp.customers != NULL){
                for(Customer.SquareCustomer squareCustomer : customersResp.customers){
                    squareIdCustomerMap.put(squareCustomer.Id,squareCustomer);
                    System.debug('--squareIdToCustomerMap---'+squareIdCustomerMap);
                }
            }
            if(customersResp.cursor != NULL){
                response.cursor = customersResp.cursor;
                response.requireNextRun = TRUE;
            }
            if(customersResp.cursor == NULL){
                response.cursor = '';
                response.requireNextRun = FALSE;
            }
            if(customersResp.customer != NULL && customersResp.customers == NULL ){
                Customer.Squarecustomer customer = customersResp.customer;
                squareIdCustomerMap.put(customer.Id,customer);
            }
            response.customerMapById = squareIdCustomerMap;
        } catch(Exception ex) {	
            System.debug('Customer Sync failed for while parsing. \n' +ex.getStackTraceString());	
            APICallHandler.userInteractionLogPush(TRUE, 'Customer Sync', 'ERROR' , 'Customer Sync failed for while parsing. \n' +ex.getStackTraceString());	
        }	
        return response;	
    }
    public static FetchResponse parsePayments(String responseBody) {	
        Map<String, Charge.SquareCharge> squareIdToPaymentMap = new Map<String, Charge.SquareCharge>();
        FetchResponse response = new FetchResponse();
        try{
            String  responseStr = responseBody.replaceAll('"currency"', '"square_currency"');
            JSONParser parser = JSON.createParser(responseStr);
            SquarePayments payments = (SquarePayments) parser.readValueAs(SquarePayments.class);
            if(payments.payment != null && payments.payments == null){
                Charge.SquareCharge payment = payments.payment;
                squareIdToPaymentMap.put(payment.id,payment);
                response.requireNextRun = FALSE;
            }
            else if(payments.payments != NULL){
                for(Charge.SquareCharge payment : payments.payments){
                    squareIdToPaymentMap.put(payment.id, payment);
                }
            }
            if(payments.cursor != NULL){
                response.cursor = payments.cursor;
                response.requireNextRun = TRUE;
            }
            else if(payments.cursor == NULL){
                response.cursor = '';
                response.requireNextRun = FALSE;
            }	
            response.paymentMapById = squareIdToPaymentMap;
        } catch(Exception ex) {
            System.debug('Payments Sync failed for while parsing. \n' +ex.getStackTraceString());
            APICallHandler.userInteractionLogPush(true, 'Payment Sync', 'ERROR' , 'Payments Sync failed for  while parsing. \n' +ex.getMessage());
        }
        return response;	
    }
    //*** Saving the Square customers and related payment methods to SF. Orphan records will not be saved.
    public static ProcessorUtil.ResponseObject syncCustomers(Map<String, Object> processorToCustomerMap, BreadwinnerUtil.AppConfig appConfig, Boolean addToSalesforce) {

        ProcessorUtil.ResponseObject responseObj = new ProcessorUtil.ResponseObject();
        List<ProcessorUtil.CustomerWrapper> customerList = new List<ProcessorUtil.CustomerWrapper>();
        List<ProcessorUtil.PaymentMethodWrapper> payMethodList = new List<ProcessorUtil.PaymentMethodWrapper>();
        try {
            if(String.isBlank(appConfig.customerSyncConfig) || ((String.isNotBlank(appConfig.customerSyncConfig) && (appConfig.customerSyncConfig != 'NONE')))  && appConfig.currentRunningClassContext != BreadwinnerUtil.CNTX_BWAPI)
                processorToCustomerMap = excludeCustomers(processorToCustomerMap, appConfig);
            //if(String.isNotBlank(appConfig.customerSyncConfig) && (appConfig.customerSyncConfig != 'NONE') && appConfig.currentRunningClassContext != 'BWAPI')
            system.debug('processorToCustomerMap'+processorToCustomerMap);
            Breadwinner_Settings__c bwSetting = BreadwinnerUtil.getBWSetting();
            Map<String, Customer.SquareCustomer> backupsquareIdCustomerMap = new Map<String, Customer.SquareCustomer>();
            Map<String, Customer.SquareCustomer> squareIdCustomerMap = (Map<String, Customer.SquareCustomer>) processorToCustomerMap.get(ProcessorUtil.PAT_SQUARE);
            backupsquareIdCustomerMap.putAll(squareIdCustomerMap);

            List<BWP_Customer__c> customerUpsertList = new List<BWP_Customer__c> ();
            Map<String, BWP_Customer__c> customerUpsertMap = new Map<String, BWP_Customer__c>();
            Map<String, BWP_Payment_Method__c> sourcesMap = new Map<String, BWP_Payment_Method__c> ();
            Map<String,BWP_Customer__c> existingSFCustomersMap = new Map<String,BWP_Customer__c>();
            Map<String,BWP_Payment_Method__c> existingSFPaymentMethodsMap = new Map<String,BWP_Payment_Method__c>();
            Set<String> receivedPaymentMethodIdSet = new Set<String>();

            //Holding existing customer records in Salesforce
            List<BWP_Customer__c> custList = selectorCustomer.selectByProcessorCustomerId(squareIdCustomerMap.keySet(), 45000);
            for (BWP_Customer__c cus : custList) {
                existingSFCustomersMap.put(cus.Processor_Customer_Id__c, cus);
            }
            //Collecting Square id of all received payment methods
            for(Customer.SquareCustomer cus : squareIdCustomerMap.values()) {
                if(cus.cards != null){
                    for(Customer.SquareCard src : cus.cards) {
                        receivedPaymentMethodIdSet.add(src.id);
                    }
                }
            }
            //Holding existing Payment method records in Salesforce
            for(BWP_Payment_Method__c pm : selectorPaymentMethod.selectByProcessorId(receivedPaymentMethodIdSet,45000)) {
                BWP_Payment_Method__c payMethod = new BWP_Payment_Method__c(id = pm.id);
                existingSFPaymentMethodsMap.put(payMethod.Processor_Id__c, payMethod);
            }

            Boolean areRecordTypesEnabled = ProcessorUtil.areRecordTypesEnabled();
            Boolean isDefaultRecordTypeMaster = ProcessorUtil.isDefaultRecordTypeIsMaster();
            //-- Map to store Processor Account Id and new SF Account to be inserted
            Map<String, Account> mapCustomerIdAndNewSFAccount = new Map<String, Account>();

            Map<String, Contact> mapCustomerIdAndNewSFContact = new Map<String, Contact>();
            Set<String> customerNameSet = new Set<String>();
            Set<String> customerEmailSet = new Set<String>();

            for(String ContactId : squareIdCustomerMap.keySet()){
                if(!existingSFCustomersMap.containsKey(ContactId) || (existingSFCustomersMap.containsKey(ContactId) && existingSFCustomersMap.get(ContactId).Salesforce_Account__c == NULL && !existingSFCustomersMap.get(ContactId).No_Associated_SF_Account__c )){
                    Customer.SquareCustomer sc = squareIdCustomerMap.get(ContactId);
                    String customerName = (String.isNotBlank(sc.given_name) ? (sc.given_name + (String.isNotBlank(sc.family_name) ? (' '+sc.family_name) : '')) : (String.isNotBlank(sc.family_name) ? sc.family_name : ''));
                    if(String.isNotBlank(customerName)){
                        String ContactName = customerName.toLowerCase().replace('\\', '%');
                        Set<String> relatedNameSet = BreadwinnerUtil.getSimilarAccountNameSet(ContactName);
                        customerNameSet.addAll(relatedNameSet);
                    }
                    else if(String.isNotBlank(sc.email_address)){
                        String ContactEmail = sc.email_address.toLowerCase().replace('\\', '%');
                        Set<String> relatedNameSet = BreadwinnerUtil.getSimilarAccountNameSet(ContactEmail);
                        customerNameSet.addAll(relatedNameSet);
                    }
                    if(ProcessorUtil.arePersonAccountsEnabled() && String.isNotBlank(sc.email_address)){
                        String email = sc.email_address.toLowerCase().replace('\\', '%');
                        customerEmailSet.add(email);
                    }
                }
            }
            
            system.debug('appConfig.isCustomerMatchComplete'+appConfig.isCustomerMatchComplete);
            system.debug('appConfig.currentRunningClassContext'+appConfig.currentRunningClassContext);
            if(appConfig.isCustomerMatchComplete && appConfig.customerMatchType == ProcessorUtil.CMT_ACCOUNT && appConfig.currentRunningClassContext != BreadwinnerUtil.CNTX_BWAPI){
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
                system.debug('account match is already completed');
                for(String refId : squareIdCustomerMap.keySet()){
                    Customer.SquareCustomer cust = squareIdCustomerMap.get(refId);
                    String cName = (String.isNotBlank(cust.given_name) ? (cust.given_name + (String.isNotBlank(cust.family_name) ? (' '+cust.family_name) : '')) : (String.isNotBlank(cust.family_name) ? cust.family_name : ''));
                    ID accID;
                    if(!existingSFCustomersMap.containsKey(refId) || (existingSFCustomersMap.containsKey(refId) && existingSFCustomersMap.get(refId).Salesforce_Account__c == NULL && !existingSFCustomersMap.get(refId).No_Associated_SF_Account__c )){
                        String customerNameLowerCase = (String.isNotBlank(cName)) ? (cName).toLowerCase().replace('\\', '%') : (String.isNotBlank(cust.email_address) ? (cust.email_address.toLowerCase().replace('\\', '%')) : '');
                        // first check with person account email then with company name if person accounts are enabled

                        String personEmail = String.isNotBlank(cust.email_address) ? (cust.email_address.toLowerCase().replace('\\', '%')) : '';

                        //first check with Person accounts enabled
                        if((ProcessorUtil.arePersonAccountsEnabled() && personAccountEmailToAccountMap.containsKey(personEmail)) || nameToAccountMap.containsKey(customerNameLowerCase)){
                            System.debug('existed accounts');
                            if(ProcessorUtil.arePersonAccountsEnabled() && personAccountEmailToAccountMap.containsKey(personEmail)){
                                accID = personAccountEmailToAccountMap.get(personEmail).Id;
                            }
                            else if(nameToAccountMap.containsKey(customerNameLowerCase) ){
                                accID = nameToAccountMap.get(customerNameLowerCase).Id;
                            }
                        }
                    }

                    if(String.isNotBlank(cust.id)) {
                        // Querying existing Square Customer if any or creating new one
                        BWP_Customer__c customerSf = existingSFCustomersMap.get(cust.id) != null ? existingSFCustomersMap.get(cust.id) : new BWP_Customer__c();
                        customerSf = constructSquareCustomer(customerSf, cust, appConfig);

                        if(!existingSFCustomersMap.containsKey(refId) || (existingSFCustomersMap.containsKey(refId) && existingSFCustomersMap.get(refId).Salesforce_Account__c == NULL && !existingSFCustomersMap.get(refId).No_Associated_SF_Account__c )) {
                            customerSf.Salesforce_Account__c = customerSf.Salesforce_Account__c != null ? customerSf.Salesforce_Account__c : accID;
                        }
                        customerUpsertList.add(customerSf);
                        customerUpsertMap.put(refId, customerSf);
                        squareIdCustomerMap.remove(refId);
                        if(cust.cards != null){
                            for (Customer.SquareCard src : cust.cards) {
                                // Querying existing Square Payment Method if any or creating new one
                                BWP_Payment_Method__c srcSf =  existingSFPaymentMethodsMap.get(src.id) != null ? existingSFPaymentMethodsMap.get(src.id) : new BWP_Payment_Method__c();
                                srcSf.Customer__r = new BWP_Customer__c(Processor_Customer_Id__c = cust.id);
                                srcSf.Processor_Customer_Id__c = cust.id;
                                srcSf.Account__c = String.isNotBlank(customerSf.Salesforce_Account__c) ? customerSf.Salesforce_Account__c : accID;
                                srcSf = constructSquarePaymentMethod(srcSf, src, appConfig);
                                sourcesMap.put(src.id, srcSf);
                            }
                        }
                    }

                    if(accID == NULL && (!existingSFCustomersMap.containsKey(refId) || (existingSFCustomersMap.containsKey(refId) && existingSFCustomersMap.get(refId).Salesforce_Account__c == NULL && !existingSFCustomersMap.get(refId).No_Associated_SF_Account__c ))){
                        // Create New accounts
                        system.debug('new accounts');
                        String customerName = (String.isNotBlank(cName) ? cName : (String.isNotBlank(cust.email_address) ? cust.email_address : ''));
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

                        acctRef.Phone = cust.phone_number;
                        if(cust.address != NULL){
                            acctRef.BillingStreet = cust.address.address_line_1.replaceAll('%%', '\r\n');
                            acctRef.BillingCity = cust.address.locality;
                            acctRef.BillingState = cust.address.administrative_district_level_1;
                            acctRef.BillingCountry = cust.address.country;
                            acctRef.BillingPostalCode = cust.address.postal_code;
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
                for(String refId : squareIdCustomerMap.keySet()){
                    Customer.SquareCustomer cw = squareIdCustomerMap.get(refId);
                    ID conID;
                    if(!existingSFCustomersMap.containsKey(refId) || (existingSFCustomersMap.containsKey(refId) && existingSFCustomersMap.get(refId).Salesforce_Contact__c == NULL && !existingSFCustomersMap.get(refId).No_Associated_SF_Contact__c )){
                        String customerName = formatCustomerName(cw);
                        string customerNameLowerCase = String.isNotBlank(customerName) ? (customerName.toLowerCase().replace('\\', '%')) : (String.isNotBlank(cw.email_address) ? (cw.email_address.toLowerCase().replace('\\', '%')) : '');
                            String email = String.isNotBlank(cw.email_address) ? (cw.email_address.toLowerCase().replace('\\', '%')) : '';
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
                    
                    if(String.isNotBlank(cw.id)) {
                        // Querying existing Stripe Customer if any or creating new one
                        BWP_Customer__c customerSf = existingSFCustomersMap.get(cw.id) != null ? existingSFCustomersMap.get(cw.id) : new BWP_Customer__c();
                        customerSf = constructSquareCustomer(customerSf, cw, appConfig);
                        if(!existingSFCustomersMap.containsKey(refId) || (existingSFCustomersMap.containsKey(refId) && existingSFCustomersMap.get(refId).Salesforce_Contact__c == NULL && !existingSFCustomersMap.get(refId).No_Associated_SF_Contact__c )) customerSf.Salesforce_Contact__c = customerSf.Salesforce_Contact__c != null ? customerSf.Salesforce_Contact__c : conID;
                        customerUpsertList.add(customerSf);
                        customerUpsertMap.put(refId, customerSf);
                        squareIdCustomerMap.remove(refId);
                        if(cw.cards != null){
                            for (Customer.SquareCard src : cw.cards) {
                                // Querying existing Square Payment Method if any or creating new one
                                BWP_Payment_Method__c srcSf =  existingSFPaymentMethodsMap.get(src.id) != null ? existingSFPaymentMethodsMap.get(src.id) : new BWP_Payment_Method__c();
                                srcSf.Customer__r = new BWP_Customer__c(Processor_Customer_Id__c = cw.id);
                                srcSf.Processor_Customer_Id__c = cw.id;
                                srcSf.Contact__c = String.isNotBlank(customerSf.Salesforce_Contact__c) ? customerSf.Salesforce_Contact__c : conID;
                                srcSf = constructSquarePaymentMethod(srcSf, src, appConfig);
                                sourcesMap.put(src.id, srcSf);
                            }
                        }
                    }
                    
                    if(conID == NULL && (!existingSFCustomersMap.containsKey(refId) || (existingSFCustomersMap.containsKey(refId) && existingSFCustomersMap.get(refId).Salesforce_Contact__c == NULL && !existingSFCustomersMap.get(refId).No_Associated_SF_Contact__c ))){
                        // Create New accounts
                        system.debug('new Contacts');
                        Contact conRef = new Contact();
                        conRef.FirstName = (String.isNotBlank(cw.given_name) ? cw.given_name : '');
                        conRef.LastName = (String.isNotBlank(cw.family_name) ? cw.family_name : '');
                        conRef.Email = (String.isNotBlank(cw.email_address) ? cw.email_address : '');
                        conRef.Phone = cw.phone_number;
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
                for(String refId : squareIdCustomerMap.keySet()){
                    Customer.SquareCustomer customer = squareIdCustomerMap.get(refId);
                    if(String.isNotBlank(customer.id)) {
                        // Querying existing Square Customer if any or creating new one
                        BWP_Customer__c customerSf = existingSFCustomersMap.get(customer.id) != null ? existingSFCustomersMap.get(customer.id) : new BWP_Customer__c();
                        customerSf = constructSquareCustomer(customerSf, customer, appConfig);
                        if(BreadwinnerUtil.accountId != null)
                            customerSf.Salesforce_Account__c = BreadwinnerUtil.accountId;
                        if(customer.cards != null){
                            for (Customer.SquareCard src : customer.cards) {
                                // Querying existing Square Payment Method if any or creating new one
                                BWP_Payment_Method__c srcSf =  existingSFPaymentMethodsMap.get(src.id) != null ? existingSFPaymentMethodsMap.get(src.id) : new BWP_Payment_Method__c();
                                srcSf.Customer__r = new BWP_Customer__c(Processor_Customer_Id__c = customer.id);
                                srcSf.Processor_Customer_Id__c = customer.id;
                                if(String.isNotBlank(customerSf.Salesforce_Account__c))
                                    srcSf.Account__c = customerSf.Salesforce_Account__c;
                                if(String.isNotBlank(customerSf.Salesforce_Contact__c))
                                    srcSf.Contact__c = customerSf.Salesforce_Contact__c;
                                srcSf = constructSquarePaymentMethod(srcSf, src, appConfig);
                                sourcesMap.put(src.id, srcSf);
                            }
                        }
                        customerUpsertMap.put(refId, customerSF);
                        customerUpsertList.add(customerSf);
                    }
                }

            }
            
            Set<Id> updatedCustomerIdSet = new Set<Id>();
            
            if (!customerUpsertMap.isEmpty()) {
                responseObj.customerList = ProcessorUtil.upsertAndReturnCustomerList(customerUpsertMap.values(), updatedCustomerIdSet, addToSalesforce);
            }
            
            if (!sourcesMap.isEmpty()) {
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
        Set<String> successfulPaymentsCustomerIdSet = new Set<String>();

        Map<String, Charge.SquareCharge> squareIdPaymentMap = (Map<String, Charge.SquareCharge>) processorIdToPaymentMap.get(ProcessorUtil.PAT_SQUARE);
        if(squareIdPaymentMap == null) {
            return rtnList;
        }
        
        Map<String, BWP_Payment__c> upsertMapByRefId = new Map<String, BWP_Payment__c>();

        Map<String,BWP_Payment__c> existingSFPaymentsMap = new Map<String,BWP_Payment__c>();

        List<BWP_Payment__c> existingList = selectorPayment.selectByProcessorId(squareIdPaymentMap.keySet(), new List<String>{'Source__r.Id'});
        for(BWP_Payment__c payment : existingList) {
            BWP_Payment__c pmnt = new BWP_Payment__c(id = payment.id);
            existingSFPaymentsMap.put(pmnt.Processor_Id__c, pmnt);
        }

        try {
            // Boolean to check the syncing of failed Payments
            Boolean doNotImportCustomerAndFailedPayments = (String.isBlank(appConfig.customerMatchConfig) || (String.isNotBlank(appConfig.customerMatchConfig) && (appConfig.customerMatchConfig.contains('NO_VALID_PAYMENTS')))) ? TRUE : FALSE;

            // Fetch Employee details
            Map<String, String> employeeIdToNameMap = getSquareEmployeeDetails(appConfig);
            Map<String, String> paymentIdToCustomerIdMap = getSquareCustomerDetails(appConfig, squareIdPaymentMap);
            Map<String, Map<String, String>> paymentIdToSFIdsMap = getSquarePaymentMethodIds(squareIdPaymentMap, paymentIdToCustomerIdMap);

            for(Charge.SquareCharge pw : squareIdPaymentMap.values()){
                BWP_Payment__c paymentSf = existingSFPaymentsMap.get(pw.id) != null ? existingSFPaymentsMap.get(pw.id) : new BWP_Payment__c();
                Map<String, String> salesforceIdMap = paymentIdToSFIdsMap.get(pw.id);
                if (salesforceIdMap != null) {
                    try {
                        paymentSf.Customer__c = String.isNotBlank(salesforceIdMap.get('CustomerSFId')) ? salesforceIdMap.get('CustomerSFId') : null;
                        paymentSf.Account__c = String.isNotBlank(salesforceIdMap.get('CustomerSalesforceAccountId')) ? salesforceIdMap.get('CustomerSalesforceAccountId') : null;
                        paymentSf.Contact__c = String.isNotBlank(salesforceIdMap.get('customerSalesforceContactId')) ? salesforceIdMap.get('customerSalesforceContactId') : null;
                        paymentSf.Source__c = String.isNotBlank(salesforceIdMap.get('PaymentMethodSFId')) ? salesforceIdMap.get('PaymentMethodSFId') : null;
                    } catch (Exception ex){
                        System.debug('ex: ' + ex.getMessage());
                    }
                }

                paymentSf.Staff_Name__c = String.isNotBlank(pw.employee_id) ? (employeeIdToNameMap.get(pw.employee_id) != null ? employeeIdToNameMap.get(pw.employee_id) : '') : '';
                paymentSf.Processor_Customer_Id__c = String.isNotBlank(pw.customer_id) ? pw.customer_id : (paymentIdToCustomerIdMap.get(pw.id) != null ? paymentIdToCustomerIdMap.get(pw.id) : '');
                paymentSf = constructSquarePayment(paymentSf, pw, appConfig);
                if (doNotImportCustomerAndFailedPayments && paymentSf.Payment_Status__c == ProcessorUtil.CHARGE_SUCCEEDED) {
                    if(String.isNotBlank(paymentSf.Customer__c)){
                        successfulPaymentsCustomerIdSet.add(paymentSf.Customer__c);
                    }
                }
                if (String.isNotBlank(paymentSf.Customer__c) && (doNotImportCustomerAndFailedPayments ? (paymentSf.Payment_Status__c == 'SUCCEEDED' ? TRUE : FALSE) : TRUE)){
                    //if(doNotImportCustomerAndFailedPayments ? (paymentSf.Payment_Status__c == 'COMPLETED' ? TRUE : FALSE) : TRUE){
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
            System.debug('Payments Sync failed for '+appConfig.Name +' while syncing. \n' +ex.getStackTraceString());
            APICallHandler.userInteractionLogPush(TRUE, 'Customer Sync', 'ERROR' , 'Payments Sync failed for '+appConfig.Name +' while syncing. \n' +ex.getStackTraceString());
        }

        return rtnList;
    }

    // This method is used to convert the Square Customer wrapper to Square Customer record.
    @TestVisible
    private static BWP_Customer__c constructSquareCustomer(BWP_Customer__c customerSf, Customer.SquareCustomer cw, BreadwinnerUtil.AppConfig appConfig){
        if(customerSf.Id == null){
            customerSf.Created_Via__c = BreadwinnerUtil.getCreatedViaValue(appConfig.currentRunningClassContext);
        }
        customerSf.Customer_ID__c = cw.id+'-'+appConfig.PaymentProcessorType+'-'+appConfig.accountId;
        customerSf.Processor_Type__c = appConfig.PaymentProcessorType;
        customerSf.Processor_Org_Id__c = appConfig.accountId;
        customerSf.Processor_Org_Name__c = appConfig.accountName;
        customerSf.Livemode__c = appConfig.liveMode == TRUE ? TRUE : FALSE;
        customerSf.Customer_Name__c = (String.isNotBlank(cw.given_name) ? (cw.given_name + (String.isNotBlank(cw.family_name) ? (' '+cw.family_name) : '')) : (String.isNotBlank(cw.family_name) ? cw.family_name : ''));
        customerSf.Name = (String.isNotBlank(customerSf.Customer_Name__c) ? customerSf.Customer_Name__c : ((String.isNotBlank(cw.email_address) ? cw.email_address : (String.isNotBlank(cw.id) ? cw.id : ''))));
        customerSf.First_Name__c = cw.given_name;
        customerSf.Last_Name__c = cw.family_name;
        customerSf.Email__c = cw.email_address;
        customerSf.Processor_Customer_Id__c = cw.id;
        customerSf.Company__c = cw.company_name;
        //Billing Address
        if (cw.address != null) {
            customerSf.Billing_City__c = cw.address.locality;
            customerSf.Billing_Country__c = cw.address.country;
            customerSf.Billing_Street_Address_1__c = cw.address.address_line_1;
            customerSf.Billing_Street_Address_2__c = cw.address.address_line_2;
            customerSf.Billing_Postal_Code__c = cw.address.postal_code;
            customerSf.Billing_State__c = cw.address.administrative_district_level_1;
        }
        Datetime createdDateTime = (Datetime) JSON.deserialize('"' + cw.created_at + '"', Datetime.class);
        customerSf.Created_Date_in_Processor__c = createdDateTime;
        customerSf.Customer_Phone__c = String.isNotBlank(cw.phone_number) ? cw.phone_number : '';
        customerSf.Description__c = cw.note;

        return customerSf;
    }
    // This method is used to convert the Square Payment Method wrapper to Square Payment Method record.
    @TestVisible
    private static BWP_Payment_Method__c constructSquarePaymentMethod(BWP_Payment_Method__c srcSf, Customer.SquareCard src, BreadwinnerUtil.AppConfig appConfig){
        if(srcSf.Id == null){
            srcSf.Created_Via__c = BreadwinnerUtil.getCreatedViaValue(appConfig.currentRunningClassContext);
        }
        srcSf.Processor_Id__c = src.id;
        srcSf.Processor_Type__c = appConfig.PaymentProcessorType;
        srcSf.Processor_Org_Id__c = appConfig.accountId;
        srcSf.Livemode__c = appConfig.liveMode == TRUE ? TRUE : FALSE;

        
        if(src.billing_address != null){
            srcSf.City__c = src.billing_address.locality;
            srcSf.Address_Country__c = src.billing_address.country;
            srcSf.Address_Line1__c = src.billing_address.address_line_1;
            srcSf.Address_Line2__c = src.billing_address.address_line_2;
            srcSf.State__c = src.billing_address.administrative_district_level_1;
            srcSf.Zip_Code__c = src.billing_address.postal_code;
        }

        srcSf.Card_Brand__c = src.card_brand;
        srcSf.Expiry_Month__c = String.Valueof(src.exp_month);
        srcSf.Expiry_Year__c = String.Valueof(src.exp_year);
        srcSf.Fingerprint__c = src.fingerprint;
        srcSf.Last_4_digits__c = src.last_4;
        srcSf.Name_On_Card__c = src.cardholder_name;
        srcSf.Type__c = ProcessorUtil.PM_CARD;

        return srcSf;
    }
    // This method is used to convert the Square Payment wrapper to Square Payment record.
    @TestVisible
    private static BWP_Payment__c constructSquarePayment(BWP_Payment__c paymentSf, Charge.SquareCharge pw, BreadwinnerUtil.AppConfig appConfig){
        if(paymentSf.Id == null){
            paymentSf.Created_Via__c = BreadwinnerUtil.getCreatedViaValue(appConfig.currentRunningClassContext);
        }
        paymentSf.Processor_Id__c = pw.id;
        paymentSf.Location_Id__c = pw.location_id;
        paymentSf.Processor_Type__c = appConfig.PaymentProcessorType;
        paymentSf.Processor_Org_Id__c = appConfig.accountId;
        paymentSf.Is_Live_Payment__c = appConfig.liveMode == TRUE ? TRUE : FALSE;
        paymentSf.Amount__c = (pw.amount_money.amount)/100;
        paymentSf.Currency__c = String.isNotBlank(pw.amount_money.square_currency) ? (pw.amount_money.square_currency).toUpperCase() : '';

        if (pw.app_fee_money != null) {
            paymentSf.Application_Fee__c = (pw.app_fee_money.amount)/100;
        }
        if (pw.processing_fee != null)
            paymentSf.Processing_Fee__c = (pw.processing_fee[0].amount_money.amount)/100;
        Datetime createdDateTime = (Datetime) JSON.deserialize('"' + pw.created_at + '"', Datetime.class);
        paymentSf.Created_Date_in_Processor__c = createdDateTime;
        paymentSf.Description__c = pw.note;
        paymentSf.Receipt_URL__c = pw.receipt_url;
        paymentSf.Receipt_Number__c = pw.receipt_number;
        if (pw.refunded_money != null) {
            paymentSf.Amount_Refunded__c = (pw.refunded_money.amount) / 100;
        }
        paymentSf.Payment_Status__c = (pw.status == 'COMPLETED' ? ProcessorUtil.CHARGE_SUCCEEDED : (pw.status == 'APPROVED' ? ProcessorUtil.CHARGE_APPROVED : (pw.status == 'CANCELED' ? ProcessorUtil.CHARGE_CANCELED : (pw.status == 'CANCELED' ? ProcessorUtil.CHARGE_CANCELED : ''))));

        if(pw.billing_address != null) {
            paymentSf.Billing_Street_Address_1__c = pw.billing_address.address_line_1;
            paymentSf.Billing_Street_Address_2__c = pw.billing_address.address_line_2;
            paymentSf.Billing_City__c = pw.billing_address.locality;
            paymentSf.Billing_State__c = pw.billing_address.administrative_district_level_1;
            paymentSf.Billing_Country__c = pw.billing_address.country;
            paymentSf.Billing_Postal_Code__c = pw.billing_address.postal_code;
        }
        return paymentSf;
    }

    private static Map<String, Object> excludeCustomers(Map<String, Object> processorToCustomerMap, BreadwinnerUtil.AppConfig appConfig){

        Map<String, Object> returnProcessorToCustomerMap = new Map<String, Object>();
        String customerSyncConfigValue = '';
        customerSyncConfigValue = String.isNotBlank(appConfig.customerSyncConfig) ? appConfig.customerSyncConfig : 'NONAME_AND_NOEMAIL';
        Map<String, Customer.SquareCustomer> squareIdCustomerMap = (Map<String, Customer.SquareCustomer>) processorToCustomerMap.get(ProcessorUtil.PAT_SQUARE);

        // Excluding Square Customers based on configuration values from Breadwinner Payments page
        if(!squareIdCustomerMap.isEmpty()){
            for(String contactId : squareIdCustomerMap.keySet()){
                Customer.SquareCustomer sc = squareIdCustomerMap.get(contactId);
                Boolean excludeCustomer = false;
                String cName = (String.isNotBlank(sc.given_name) ? (sc.given_name + (String.isNotBlank(sc.family_name) ? (' '+sc.family_name) : '')) : (String.isNotBlank(sc.family_name) ? sc.family_name : ''));
                if(customerSyncConfigValue.contains('NONAME_AND_NOEMAIL') && String.isBlank(cName) && String.isBlank(sc.email_address)){
                    excludeCustomer = true;
                }
                else if(customerSyncConfigValue.contains('NO_NAME') && (String.isBlank(cName))){
                    excludeCustomer = true;
                }
                else if(customerSyncConfigValue.contains('NO_EMAIL') && String.isBlank(sc.email_address)){
                    excludeCustomer = true;
                }
                if(excludeCustomer){
                    squareIdCustomerMap.remove(contactId);
                }
            }
        }
        if(!squareIdCustomerMap.isEmpty()){
            returnprocessorToCustomerMap.put(ProcessorUtil.PAT_SQUARE, squareIdCustomerMap);
        }
        return returnprocessorToCustomerMap;
    }

    public static Map<String, String> getSquareEmployeeDetails(BreadwinnerUtil.AppConfig appConfig){
        Map<String, String> employeeIdToNameMap = new Map<String, String>();
        try{
            String endPoint = getEndpointBaseUrl(appConfig) + '/team-members/search';
            HttpResponse res = new HttpResponse();
            res = APICallHandler.getList(appConfig, 'POST', endPoint, '');
            if(res.getStatusCode() == 200){
                JSONParser parser = JSON.createParser(res.getBody());
                TeamMembers responseData = (TeamMembers) parser.readValueAs(TeamMembers.Class);
                system.debug('response---'+responseData);
                if(responseData.team_members != NULL){
                    for(SquareTeamMemberWrapper teamMember : responseData.team_members){
                        String teamMemberName = (String.isNotBlank(teamMember.given_name) ? (teamMember.given_name + (String.isNotBlank(teamMember.family_name) ? (' '+teamMember.family_name) : '')) : (String.isNotBlank(teamMember.family_name) ? teamMember.family_name : ''));
                        employeeIdToNameMap.put(teamMember.id, teamMemberName);
                    }
                }
            }
        }
        catch(Exception ex){
            System.debug('Team Members fetch is failed for:: '+appConfig.Name +' \n' +ex.getStackTraceString());
            APICallHandler.userInteractionLogPush(TRUE, 'Payment Sync', 'ERROR' , 'Team Members fetch failed for '+appConfig.Name +' \n' +ex.getStackTraceString());
        }
        return employeeIdToNameMap;
    }

    public static Map<String, String> getSquareCustomerDetails(BreadwinnerUtil.AppConfig appConfig, Map<String, Charge.SquareCharge> squarePaymentMap){
        Map<String, String> paymentIdToCustomerIdMap = new Map<String, String>();
        Map<String, String> orderIdToCustomerIdMap = new Map<String, String>();
        Map<String, String> paymentIdToOrderIdMap = new Map<String, String>();
        try{
            String endPoint = getEndpointBaseUrl(appConfig) + '/orders/batch-retrieve';
            String reqBody = '{"order_ids":[';
            integer i = 0;
            for(Charge.SquareCharge pw: squarePaymentMap.values()){
                if(pw.order_id != null && i == 0){
                    reqBody += '"'+pw.order_id+'"';
                }
                else{
                    reqBody += ',"'+pw.order_id+'"';
                }
                i++;
                paymentIdToOrderIdMap.put(pw.id, pw.order_id);
            }
            reqBody += ']}';
            system.debug('reqest body----'+reqBody);
            //String reqBody = '{"location_ids":["05RTMS5E56H06"]}';
            HttpResponse res = new HttpResponse();
            res = APICallHandler.getList(appConfig, 'POST', endPoint, reqBody);
            if(res.getStatusCode() == 200){
                JSONParser parser = JSON.createParser(res.getBody());
                Orders responseData = (Orders) parser.readValueAs(Orders.Class);
                system.debug('response---'+responseData);
                if(responseData.orders != NULL){
                    for(SquareOrderWrapper order : responseData.orders){
                        orderIdToCustomerIdMap.put(order.id, order.customer_id);
                    }
                }
            }
            if(paymentIdToOrderIdMap != null){
                for(String paymentId : paymentIdToOrderIdMap.keyset()){
                    String orderId = paymentIdToOrderIdMap.get(paymentId) != null ? paymentIdToOrderIdMap.get(paymentId) : '';
                    String customerId = orderIdToCustomerIdMap.get(orderId) != null ? orderIdToCustomerIdMap.get(orderId) : '';
                    paymentIdToCustomerIdMap.put(paymentId, customerId);
                }
            }
            system.debug('payment id to customer id map-----'+paymentIdToCustomerIdMap);
        }
        catch(Exception ex){
            System.debug('Square Orders fetch is failed for:: '+appConfig.Name +' \n' +ex.getStackTraceString());
            APICallHandler.userInteractionLogPush(TRUE, 'Payment Sync', 'ERROR' , 'Orders fetch failed for '+appConfig.Name +' \n' +ex.getStackTraceString());
        }

        return paymentIdToCustomerIdMap;
    }
    /**
     * Takes the passed in Square Charges (payments).  Queries the Customers & Source objects
     * @param squarePaymentMap Map of Charge.SquareCharge
     * @param squarePaymentIdToCustomerId Map of CustomerId keyed by Charge.SquareCharge.Id
     *
     * @return returns a map of various Salesforce record Ids keyed by Charge.SquareCharge.Id
     */
    private static Map<String, Map<String, String>> getSquarePaymentMethodIds(Map<String, Charge.SquareCharge> squarePaymentMap, Map<String, String> squarePaymentIdToCustomerId){
        Map<String, Map<String, String>> paymentIdToSFIdsMap = new Map<String, Map<String, String>>();
        try{
            for(Charge.SquareCharge pw: squarePaymentMap.values()){
                String customerId = String.isNotBlank(pw.customer_id) ? pw.customer_id : (squarePaymentIdToCustomerId.get(pw.id) != null ? squarePaymentIdToCustomerId.get(pw.id) : '');

                if(String.isNotBlank(customerId)){
                    List<BWP_Customer__c> customerPMList = selectorCustomer.selectByProcessorCustomerId_WithPaymentMethods(new Set<String>{customerId},1,50);
                    String PMSalesforceId = '';
                    String customerSFId = '';
                    String customerSalesforceAccountId = '';
                    String customerSalesforceContactId = '';
                    if(customerPMList != NULL && !customerPMList.isEmpty()){
                        customerSFId = customerPMList[0].id;
                        customerSalesforceAccountId = customerPMList[0].Salesforce_Account__c;
                        customerSalesforceContactId = customerPMList[0].Salesforce_Contact__c;
                        if(customerPMList[0].Source__r != null){
                            for(BWP_Payment_Method__c pm : customerPMList[0].Source__r){
                                if(pm.Card_Brand__c == (String.isNotBlank(pw.card_details.card.card_brand) ? pw.card_details.card.card_brand : '') && pm.Last_4_digits__c == pw.card_details.card.last_4 && pm.Expiry_Month__c == String.valueOf(pw.card_details.card.exp_month) && pm.Expiry_Year__c == String.valueOf(pw.card_details.card.exp_year)){
                                    PMSalesforceId = pm.Id;
                                }
                            }
                        }

                        Map<String, String> idsMap = new Map<String, String>();
                        //paymentIdToPaymentMethodIdMap.put(pw.Id, PMSalesforceId+';'+customerSFId+';'+(String.isNotBlank(customerSalesforceAccountId) ? customerSalesforceAccountId :''));
                        idsMap.put('PaymentMethodSFId', PMSalesforceId);
                        idsMap.put('CustomerSFId', customerSFId);
                        idsMap.put('CustomerSalesforceAccountId', customerSalesforceAccountId);
                        idsMap.put('customerSalesforceContactId', customerSalesforceContactId);
                        paymentIdToSFIdsMap.put(pw.Id, idsMap);
                    }
                }
                system.debug('paymentIdToPaymentMethodIdMap::::::::'+paymentIdToSFIdsMap);
            }
        }
        catch(Exception ex){
            System.debug('Square Customers fetch is failed \n' +ex.getStackTraceString());
            APICallHandler.userInteractionLogPush(TRUE, 'Payment Sync', 'ERROR' , 'Existing Customers fetch failed \n' +ex.getStackTraceString());
        }
        return paymentIdToSFIdsMap;
    }

    /**
     *  Builds URL to perform authorization with Square in live mode. Live credentials will be used.
     *
     *  @return String
     */
    public static String getAuthUrl(){
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        System.debug('Base URL: ' + sfdcBaseURL );
        String sfMode = BreadwinnerUtil.isLightning() ? 'lightning' : 'classic';
        String clientId = getClientId('live');
        String stateValue = '{"SFMode":"'+sfMode+'","ProMode":"live","ProType":"Square","Callback":"'+sfdcBaseURL+'/apex/'+BreadwinnerUtil.namespaceApi+'BreadwinnerPayments"}';
        return squareAuthorizationUrl + '/authorize' + '?client_id=' + EncodingUtil.urlEncode((String.isNotBlank(clientId) ? clientId : ''),'UTF-8')+'&scope=MERCHANT_PROFILE_READ+CUSTOMERS_READ+CUSTOMERS_WRITE+PAYMENTS_READ+PAYMENTS_WRITE+EMPLOYEES_READ+ORDERS_READ&session=false&state='+stateValue;
    }

    /**
     *  Builds URL to perform authorization with Square in test mode. Test credentials will be used.
     *
     *  @return String
     */
    public static String  getTestAuthUrl(){
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        String sfMode = BreadwinnerUtil.isLightning() ? 'lightning' : 'classic';
        String clientId = getClientId('test');
        String stateValue = '{"SFMode":"'+sfMode+'","ProMode":"test","ProType":"Square","Callback":"'+sfdcBaseURL+'/apex/'+BreadwinnerUtil.namespaceApi+'BreadwinnerPayments"}';
        return squareTestAuthorizationUrl + '/authorize' + '?client_id=' + EncodingUtil.urlEncode((String.isNotBlank(clientId) ? clientId : ''),'UTF-8')+'&scope=MERCHANT_PROFILE_READ+CUSTOMERS_READ+CUSTOMERS_WRITE+PAYMENTS_READ+PAYMENTS_WRITE+EMPLOYEES_READ+ORDERS_READ&state='+stateValue;
    }

    public static void saveAppCredentials(String connectionMode, BWP_Processor_Config__c config) {
        SquareTokenInfo tokenResponse = new SquareTokenInfo();
        String code = ApexPages.currentPage().getParameters().get('code');
        if(String.isNotBlank(code)){
            code = String.escapeSingleQuotes(code);
        }
        String endPoint = '';
        String reqBody = '';
        endPoint = (connectionMode == 'live' ? squareAuthorizationUrl : squareTestAuthorizationUrl);
        endPoint = endPoint + '/token';
        reqBody = '{"client_id":"'+ getClientId(connectionMode)+'",';
        reqBody = reqBody + '"client_secret":"' + getClientSecret(connectionMode)+'",';
        reqBody = reqBody + '"grant_type":"authorization_code","code":"'+code+'"}';
        HttpResponse response = new HttpResponse();
        // Get AccessToken
        response = APICallHandler.getProcessorConnectionInfo(endPoint, 'POST', '', reqBody);
        system.debug('response----------------------'+response.getBody());
        if (response.getStatusCode() == 200) {
            // Deserializing the response
            tokenResponse = (SquareTokenInfo)JSON.deserialize(response.getBody(), SquareTokenInfo.class);
            String accountName = '';
            String accountCurrency = '';
            // Getting Square Account info
            if (tokenResponse.access_token != null) {
                system.debug('request to merchant');
                String endPointMerchantDetails = '';
                endPointMerchantDetails = (connectionMode == 'live' ? squareBaseUrlv2 : squareTestBaseUrlv2);
                endPointMerchantDetails = endPointMerchantDetails + '/merchants';
                HttpResponse accRes = new HttpResponse();
                // Request to get Square Account Details
                accRes = APICallHandler.getProcessorConnectionInfo(endPointMerchantDetails, 'GET', tokenResponse.access_token, '');
                system.debug('accresp---------'+accRes);
                if(accRes.getStatusCode() == 200){
                    Merchant accInfo = (Merchant)JSON.deserialize(accRes.getBody(), Merchant.class);
                    for(SquareAccountInfo squareaccInfo : accInfo.merchant){
                        if(tokenResponse.merchant_id == squareaccInfo.id){
                            accountName = squareaccInfo.business_name;
                            accountCurrency = squareaccInfo.default_currency;
                        }
                    }
                }
            }
            config = BreadwinnerUtil.getProcessorConfig(tokenResponse.merchant_id) != null ? BreadwinnerUtil.getProcessorConfig(tokenResponse.merchant_id) : new BWP_Processor_Config__c();
            config.Account_Name__c = String.isNotBlank(accountName) ? accountName : '';
            config.Default_Currency__c = String.isNotBlank(accountCurrency) ? accountCurrency : '';
            if (tokenResponse.access_token != null) {
                config.Access_Token__c = tokenResponse.access_token;
                config.Access_Token_Expiry_Date__c = (DateTime) JSON.deserialize('"' + tokenResponse.expires_at + '"', DateTime.class);
                config.Live_Mode__c = (connectionMode == 'live' ? TRUE : FALSE);
                config.Refresh_Token__c = tokenResponse.refresh_token;
                config.Provider_ID__c = tokenResponse.merchant_id;
                config.Name = tokenResponse.merchant_id;
                config.Need_To_Reconnect__c = false;
                config.Payment_Processor_Type__c = ProcessorUtil.PAT_SQUARE;
                if (config.Customer_Sync_Config__c == null) {
                    config.Customer_Sync_Config__c = 'NONAME_AND_NOEMAIL';
                }
                if (config.Customer_Match_Config__c == null) {
                    config.Customer_Match_Config__c = 'NO_VALID_PAYMENTS';
                }
                config = CryptoUtil.encryptSecrets(config);
                BreadwinnerUtil.upsertAppConfig(config);
            }
        } else {
            throw new ProcessorUtil.ConnectionException('Error occurred while connecting with Square.');
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
            endPoint = ac.livemode ? squareAuthorizationUrl : squareTestAuthorizationUrl;
            endPoint = endPoint + '/token';

            reqBody = '{"client_id":"' + getClientId(connectionType)+'",';
            reqBody = reqBody + '"client_secret":"' + getClientSecret(connectionType)+'",';
            reqBody = reqBody + '"grant_type":"refresh_token","refresh_token":"'+ac.refreshToken+'"}';
            system.debug('req body-------------'+reqBody);
            response = APICallHandler.post(ac, 'POST', endPoint, reqBody);
            system.debug('response--'+response);
            SquareTokenInfo tokenResponse = new SquareTokenInfo();
            if(response.getStatusCode() == 200){
                APICallHandler.userInteractionLogPush(TRUE, 'Refresh Access Token', 'Success' , 'Successfully Refreshed Access Token for the Square Account '+appConfig.Account_Name__c);
                tokenResponse = (SquareTokenInfo)JSON.deserialize(response.getbody(), SquareTokenInfo.class);
                if(tokenResponse.access_token != null) {
                    appConfig.Access_token__c = tokenResponse.access_token;
                    appConfig.Access_Token_Expiry_Date__c = (DateTime) JSON.deserialize('"' + tokenResponse.expires_at + '"', DateTime.class);
                    appConfig = CryptoUtil.encryptSecrets(appConfig);
                    BreadwinnerUtil.isBreadwinnerTransaction = true;
                    SecurityUtil.dmlUpsert(appConfig);
                }
            }
            else{
                APICallHandler.userInteractionLogPush(TRUE, 'Refresh Access Token', 'ERROR' , 'Failed to Refresh Access Token for the Square Account '+appConfig.Account_Name__c+'. Error'+response.getBody());
            }

        }catch(Exception e){
            System.debug('Error occured while refreshing the Access Token from Square.'+e.getStackTraceString());
            APICallHandler.userInteractionLogPush(TRUE, 'Refresh Access Token', 'ERROR' , e.getmessage());
        }
    }

    //This method is used to get the Square client Id
    public static String getClientId(String connectionType){
        String returnClientId = '';
        String developerName = (connectionType == 'test' ? 'Square_Test_Credentials' : 'Square_Credentials');
        if(Schema.sObjectType.Breadwinner_Payments_Metadata__mdt.isAccessible()) {
            Breadwinner_Payments_Metadata__mdt squareCredential = [SELECT Id, Key__c, Secret__c, DeveloperName FROM Breadwinner_Payments_Metadata__mdt WHERE DeveloperName =:developerName LIMIT 1];
            returnClientId = squareCredential.Key__c;
        }
        return returnClientId;
    }
    //This method is used to get the Square client Secret
    private static String getClientSecret(String connectionType){
        String returnClientSecret = '';
        String developerName = (connectionType == 'test' ? 'Square_Test_Credentials' : 'Square_Credentials');
        if(Schema.sObjectType.Breadwinner_Payments_Metadata__mdt.isAccessible()) {
            Breadwinner_Payments_Metadata__mdt squareCredential = [SELECT Id, Key__c, Secret__c, DeveloperName FROM Breadwinner_Payments_Metadata__mdt WHERE DeveloperName =:developerName LIMIT 1];
            returnClientSecret = squareCredential.Secret__c;
        }
        return returnClientSecret;
    }

    public static String getEndpointBaseUrl(BreadwinnerUtil.AppConfig appConfig){
        return appConfig.livemode ? squareBaseUrlv2 : squareTestBaseUrlv2;
    }

    private static String formatCustomerName(Customer.SquareCustomer cust){
        String customerName = (String.isNotBlank(cust.given_name) ? (cust.given_name + (String.isNotBlank(cust.family_name) ? (' '+cust.family_name) : '')) : (String.isNotBlank(cust.family_name) ? cust.family_name : ''));
        return customerName;
    }
    public class SquareCustomers {
        public Customer.SquareCustomer customer;
        public List<Customer.SquareCustomer> customers;
        public String cursor;
    }

    private class SquarePayments {
        public List<Charge.SquareCharge> payments;
        public Charge.SquareCharge payment;
        public String cursor;
    }

    private class SquareTeamMemberWrapper{
        public String id;
        public String given_name;
        public String family_name;
        public String status;
    }
    private class TeamMembers{
        public List<SquareTeamMemberWrapper> team_members;
    }
    private class Orders{
        public List<squareOrderWrapper> orders;
    }
    private class squareOrderWrapper{
        public String id;
        public String customer_id;
    }
    // Filter options when fetching square data
    public class FetchRequest {
        public String customerId;
        public String start_at;
        public String square_limit;
        public String cursor;
        public String begin_time;
        public String end_time;
    }

    public class FetchResponse {
        public String cursor;
        public Boolean requireNextRun;
        public Map<String, Customer.SquareCustomer> customerMapById;
        public Map<String, Charge.SquareCharge> paymentMapById;
    }

    private class Merchant{
        private List<SquareAccountInfo> merchant;
    }
    //Square Account Info wrapper
    private class SquareAccountInfo {
        private String id;
        private String business_name;
        private String country;
        private String default_currency;
        private String status;
    }

    //Square Token Info Wrapper
    public class SquareTokenInfo {
        public String access_token;
        public String token_type;
        public String expires_at;
        public String merchant_id;
        public String refresh_token;
    }

}