@namespaceAccessible
public with sharing class Processor_Stripe extends Processor {

    private static Selector_BWP_Customer selectorCustomer = new Selector_BWP_Customer();
    private static Selector_BWP_Payment_Method selectorPaymentMethod = new Selector_BWP_Payment_Method();
    private static Selector_BWP_Transaction selectorTransaction = new Selector_BWP_Transaction();

    //Stripe End points
    @namespaceAccessible public static String stripeAuthorizationUrl = 'https://connect.stripe.com/oauth/authorize';
    @namespaceAccessible public static String stripeTokenUrl = 'https://connect.stripe.com/oauth/token';
    @namespaceAccessible public static String stripeBaseUrlv1 = 'https://api.stripe.com/v1';
    
    BWP_Processor_Config__c apc;
    BreadwinnerUtil.AppConfig apcWrapper;

    @namespaceAccessible
    public Processor_Stripe(String stripeAccountId) {
        apc = BreadwinnerUtil.getProcessorConfig(stripeAccountId);
        if (apc == null) {
           throw new ProcessorUtil.InvalidAccountConfigurationException('Invalid Stripe ORG Id provided.');
        }
        apcWrapper = BreadwinnerUtil.getProcessorConfigWrapper(apc);
    }
    //This method is used to get the Stripe client Id
    private static String getClientId(String connectionType){
        String returnClientId = '';
        String developerName = (connectionType == 'test' ? 'Stripe_Test_Credentials' : 'Stripe_Credentials');
        if(Schema.sObjectType.Breadwinner_Payments_Metadata__mdt.isAccessible()) {
            Breadwinner_Payments_Metadata__mdt stripeCredential = [SELECT Id, Key__c, Secret__c, DeveloperName FROM Breadwinner_Payments_Metadata__mdt WHERE DeveloperName =:developerName LIMIT 1];
            returnClientId = stripeCredential.Key__c;
        }
        return returnClientId;
    }
    //This method is used to get the Stripe client Secret
    private static String getClientSecret(String connectionType){
        String returnClientSecret = '';
        String developerName = (connectionType == 'test' ? 'Stripe_Test_Credentials' : 'Stripe_Credentials');
        if(Schema.sObjectType.Breadwinner_Payments_Metadata__mdt.isAccessible()) {
            Breadwinner_Payments_Metadata__mdt stripeCredential = [SELECT Id, Key__c, Secret__c, DeveloperName FROM Breadwinner_Payments_Metadata__mdt WHERE DeveloperName =:developerName LIMIT 1];
            returnClientSecret = stripeCredential.Secret__c;
        }
        return returnClientSecret;
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
    public override ProcessorUtil.ResponseObject createBankToken(String requestJSON) {
        return createBankToken(apcWrapper, requestJSON);
    }
    public override ProcessorUtil.ResponseObject chargeProcessor(String requestJSON, String timeout) {
        return chargeProcessor(apcWrapper, requestJSON, timeout);
    }
    public override ProcessorUtil.ResponseObject fetchCustomers(String requestJSON) {
        return fetchCustomers(apcWrapper, requestJSON);
    }
    public override ProcessorUtil.ResponseObject fetchTransactions(String requestJSON) {
        return fetchTransactions(apcWrapper, requestJSON);
    }
    public override ProcessorUtil.ResponseObject verifyBankAccount(String requestJSON) {
        return verifyBankAccount(apcWrapper, requestJSON);
    }
    
    @TestVisible
    private static ProcessorUtil.ResponseObject createCustomer(BreadwinnerUtil.AppConfig apcWrapper, String requestJSON){
        Map<String, Customer.StripeCustomer> stripeIdCustomerMapResponse = new Map<String, Customer.StripeCustomer> ();

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

        String endPoint = stripeBaseUrlv1 + '/customers';

        try {
            for (Object obj : objectList){
                try{
                    String jsonObject = JSON.serializePretty(obj);
                    JSONParser objectParser = JSON.createParser(jsonObject);
                    Customer.StripeCustomer customer = (Customer.StripeCustomer) objectParser.readValueAs(Customer.StripeCustomer.class);

                    String reqBody = 'name=' + getURLEncodeData(customer.name);
                    reqBody += getUrlBody(customer, false);

                    if (customer != null && customer.accountId != null){
                        BreadwinnerUtil.accountId = customer.accountId;
                    }

                    HttpResponse res = APICallHandler.post(apcWrapper, 'POST', endPoint, reqBody);

                    if (res.getStatusCode() == 200) {
                        String responseStr = replaceStripeWords(res.getBody());
                        JSONParser parser = JSON.createParser(responseStr);

                        Customer.StripeCustomer customerData = (Customer.StripeCustomer) parser.readValueAs(Customer.StripeCustomer.class);
                        stripeIdCustomerMapResponse.put(customerData.id, customerData);
                        apcWrapper.currentRunningClassContext = BreadwinnerUtil.CNTX_BWAPI;

                        Map<String, Object> processorToCustomerMap = new Map<String, Object>{apcWrapper.PaymentProcessorType => stripeIdCustomerMapResponse};
                        response = syncCustomers(processorToCustomerMap, apcWrapper, addToSalesforce);
                        response.responseJSON = JSON.serializePretty(stripeIdCustomerMapResponse);
                        response.status = String.valueOf(res.getStatusCode());
                    } else {
                        Map<String, Object> responseFromStripe = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                        Map<String, Object> error = (Map<String, Object>)responseFromStripe.get('error');
                        response.errors.add(formatError(error, String.valueOf(res.getStatusCode())));
                        APICallHandler.userInteractionLogPush(true, 'Create Stripe Customer', 'ERROR' , 'Response for Stripe Org Name('+apcWrapper.accountName+'): Status Code: '+res.getStatusCode()+' Response Body: '+res.getBody() );
                    }
                } catch (Exception ex) {
                    // We want to catch any additional errors and let the process continue.
                    response.errors.add(new ProcessorUtil.Error('Exception Occurred', 'An Exception occurred while creating the Customer to Stripe. ' + ex.getMessage()));
                    System.debug('Exception occurred while creating customers in Stripe.' + ex.getStackTraceString());
                }
            }

        } catch (Exception ex) {
            response.errors.add(new ProcessorUtil.Error('Exception Occurred', 'An Exception occurred while creating the Customer to Stripe. ' + ex.getMessage()));
            System.debug('Exception occurred while creating customers in Stripe.' + ex.getStackTraceString());
        }

        return response;

    }

    @TestVisible
    private static ProcessorUtil.ResponseObject updateCustomer(BreadwinnerUtil.AppConfig apcWrapper, String requestJSON){
        System.debug('request: ' + requestJSON);
        Map<String, Customer.StripeCustomer> stripeIdCustomerMapResponse = new Map<String, Customer.StripeCustomer> ();

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
                try {
                    String jsonObject = JSON.serializePretty(obj);
                    JSONParser objectParser = JSON.createParser(jsonObject);
                    Customer.StripeCustomer customer = (Customer.StripeCustomer) objectParser.readValueAs(Customer.StripeCustomer.class);

                    System.debug('customer: ' + customer);

                    if (customer == null) {
                        response.errors.add(new ProcessorUtil.Error('', 'Invalid customer format'));
                        return response;
                    }

                    if (customer.id == null) {
                        response.errors.add(new ProcessorUtil.Error('', 'Please enter Stripe customer id'));
                        return response;
                    }

                    if (customer.accountId != null) {
                        BreadwinnerUtil.accountId = customer.accountId;
                    }

                    String endPoint = stripeBaseUrlv1 + '/customers/' + customer.id;
                    
                    if (customer.sources != null || customer.source != null) {
                        endPoint += '/sources';
                    }
                    String reqBody = getUrlBody(customer, true);

                    HttpResponse res = APICallHandler.post(apcWrapper, 'POST', endPoint, reqBody);
                    if (res.getStatusCode() == 200) {
                        HttpResponse resp = APICallHandler.getList(apcWrapper, 'GET', stripeBaseUrlv1 + '/customers/' + customer.id, '');
                        String responseStr = replaceStripeWords(resp.getBody());
                        JSONParser parser = JSON.createParser(responseStr);
                        Customer.StripeCustomer customerData = (Customer.StripeCustomer) parser.readValueAs(Customer.StripeCustomer.class);
                        stripeIdCustomerMapResponse.put(customerData.id, customerData);
                        Map<String, Object> processorToCustomerMap = new Map<String, Object>();
                        apcWrapper.currentRunningClassContext = BreadwinnerUtil.CNTX_BWAPI;
                        processorToCustomerMap.put(apcWrapper.PaymentProcessorType, stripeIdCustomerMapResponse);
                        response = syncCustomers(processorToCustomerMap, apcWrapper,addToSalesforce);
                        response.responseJSON = JSON.serializePretty(stripeIdCustomerMapResponse);
                        response.status = String.valueOf(res.getStatusCode());
                    } else {
                        Map<String, Object> responseFromStripe = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                        Map<String, Object> error = (Map<String, Object>)responseFromStripe.get('error');
                        response.errors.add(formatError(error, String.valueOf(res.getStatusCode())));
                        APICallHandler.userInteractionLogPush(TRUE, 'Updating Stripe Customer', 'ERROR', 'Response for Stripe Org Name(' + apcWrapper.accountName + '): Status Code: ' + res.getStatusCode() + ' Response Body: ' + res.getBody());
                    }
                } catch (Exception ex) {
                    // We want to catch any additional errors and let the process continue.
                    response.errors.add(new ProcessorUtil.Error('Exception Occurred', 'An Exception occurred while updating the Customer to Stripe. ' + ex.getMessage()));
                    System.debug('Exception occurred while updating customers in Stripe.' + ex.getStackTraceString());
                }
            }
        } catch (Exception ex) {
            response.errors.add(new ProcessorUtil.Error('Exception Occurred','An Exception occurred while updating the Customer to Stripe. ' + ex.getMessage()));
            System.debug('Exception occurred while updating the customer in Stripe.' + ex.getStackTraceString());
        }

        return response;

    }

    @TestVisible
    private static ProcessorUtil.ResponseObject createCardToken(BreadwinnerUtil.AppConfig apcWrapper, String requestJSON){
        ProcessorUtil.ResponseObject response = new ProcessorUtil.ResponseObject();
        response.errors = new List<ProcessorUtil.Error>();

        Map<String, Object> objectMap = (Map<String,Object>) JSON.deserializeUntyped(requestJSON);
        System.debug('objectMap: ' + objectMap);

        List<Object> objectList = (List<Object>) objectMap.get('customer');

        try {
            for (Object obj : objectList) {
                try {
                    String jsonObject = JSON.serializePretty(obj);
                    JSONParser objectParser = JSON.createParser(jsonObject);
                    Customer.StripeCustomer customer = (Customer.StripeCustomer) objectParser.readValueAs(Customer.StripeCustomer.class);
                    System.debug('createCardToken customer: ' + customer);

                    Customer.Sources sources = customer.sources;

                    String bodyUrlEncoded = 'card[number]=' + sources.data[0].cardNumber +
                            '&card[exp_month]=' + sources.data[0].exp_month +
                            '&card[exp_year]=' + sources.data[0].exp_year +
                            '&card[cvc]=' + sources.data[0].cvc +
                            '&card[name]=' + sources.data[0].name +
                            '&card[address_line1]=' + sources.data[0].address_line1 +
                            '&card[address_line2]=' + sources.data[0].address_line2 +
                            '&card[address_city]=' + sources.data[0].address_city +
                            '&card[address_state]=' + sources.data[0].address_state +
                            '&card[address_zip]=' + sources.data[0].address_zip +
                            '&card[address_country]=' + sources.data[0].address_country;
                    HttpResponse res = APICallHandler.post(apcWrapper, 'POST', stripeBaseUrlv1 + '/tokens', bodyUrlEncoded);
                    if (res.getStatusCode() == 200) {
                        response.status = String.valueOf(res.getStatusCode());
                        String responseStr = replaceStripeWords(res.getBody());
                        JSONParser parser = JSON.createParser(responseStr);

                        Customer.Source sourceData = (Customer.Source) parser.readValueAs(Customer.Source.class);
                        System.debug('sourceData: ' + sourceData);
                        response.responseJSON = JSON.serializePretty(sourceData);
                        customer.source = sourceData.id;
                        // update Stripe customer (and Salesforce) with new Card Token
                        if(customer.id != NULL){
                            Map<String, List<Customer.StripeCustomer>> customerMap = new Map<String, List<Customer.StripeCustomer>>();
                            customerMap.put('customer', new List<Customer.StripeCustomer>{customer});

                            ProcessorUtil.ResponseObject updateCustomerResponse = updateCustomer(apcWrapper, JSON.serializePretty(customerMap));
                            if (updateCustomerResponse.errors != null) {
                                response.errors = updateCustomerResponse.errors;
                            }
                            response = updateCustomerResponse;
                        }
                    } else {
                        Map<String, Object> responseFromStripe = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                        Map<String, Object> error = (Map<String, Object>)responseFromStripe.get('error');
                        response.errors.add(formatError(error, String.valueOf(res.getStatusCode())));
                        APICallHandler.userInteractionLogPush(true, 'Create Stripe Payment Method', 'ERROR', 'Response for Stripe Org Name(' + apcWrapper.accountName + '): Status Code: ' + res.getStatusCode() + ' Response Body: ' + res.getBody());
                    }
                } catch (Exception ex) {
                    // We want to catch any additional errors and let the process continue.
                    response.errors.add(new ProcessorUtil.Error('Exception Occurred', 'An Exception occurred while creating card token. ' + ex.getMessage()));
                    System.debug('Exception occurred while creating card token.' + ex.getStackTraceString());
                }
            }
        } catch (Exception ex) {
            response.errors.add(new ProcessorUtil.Error('Exception Occurred', 'An Exception occurred while creating the card token in Stripe. ' + ex.getMessage()));
            System.debug('Exception occurred while creating card token in Stripe.' + ex.getStackTraceString());
        }

        return response;
    }

    @TestVisible
    private static ProcessorUtil.ResponseObject createBankToken(BreadwinnerUtil.AppConfig apcWrapper, String requestJSON){
        Customer.StripeCustomer stripeCustomer = new Customer.StripeCustomer();
        Customer.Sources paymentMethod = new Customer.Sources();

        String reqBody = '';//'bank_account[country]=us&bank_account[currency]=USD&bank_account[account_holder_name]=Jenny Rosen&bank_account[account_holder_type]=individual&bank_account[account_number]=000123456789&bank_account[routing_number]=110000000';

        ProcessorUtil.ResponseObject response = new ProcessorUtil.ResponseObject();
        response.errors = new List<ProcessorUtil.Error>();

        Map<String, Object> objectMap = (Map<String,Object>) JSON.deserializeUntyped(requestJSON);
        System.debug('objectMap: ' + objectMap);

        List<Object> objectList = (List<Object>) objectMap.get('customer');

        try {
            for (Object obj : objectList) {
                try {
                    String jsonObject = JSON.serializePretty(obj);
                    JSONParser objectParser = JSON.createParser(jsonObject);
                    Customer.StripeCustomer customer = (Customer.StripeCustomer) objectParser.readValueAs(Customer.StripeCustomer.class);

                    System.debug('customer: ' + customer);

                    Customer.Source source = customer.sources.data[0];
                    if (String.isNotBlank(source.account_holder_name)) reqBody += 'bank_account[account_holder_name]=' + source.account_holder_name;
                    if (String.isNotBlank(source.country)) reqBody += '&bank_account[country]=' + source.country;
                    if (String.isNotBlank(source.stripe_currency)) reqBody += '&bank_account[currency]=' + source.stripe_currency;
                    if (String.isNotBlank(source.account_holder_type)) reqBody += '&bank_account[account_holder_type]=' + source.account_holder_type;
                    if (String.isNotBlank(source.account_number)) reqBody += '&bank_account[account_number]=' + source.account_number;
                    if (source.routing_number != null) reqBody += '&bank_account[routing_number]=' + source.routing_number;

                    System.debug('reqBody: ' + reqBody);

                    HttpResponse res = APICallHandler.post(apcWrapper, 'POST', stripeBaseUrlv1 + '/tokens', reqBody);

                    if (res.getStatusCode() == 200) {
                        response.status = String.valueOf(res.getStatusCode());
                        String responseStr = replaceStripeWords(res.getBody());
                        JSONParser parser = JSON.createParser(responseStr);

                        Customer.Source sourceData = (Customer.Source) parser.readValueAs(Customer.Source.class);
                        System.debug('sourceData: ' + sourceData);
                        response.responseJSON = JSON.serializePretty(sourceData);
                        customer.source = sourceData.id;
                        // update Stripe customer (and Salesforce) with new Bank Token
                        if(customer.id != NULL){
                            Map<String, List<Customer.StripeCustomer>> customerMap = new Map<String, List<Customer.StripeCustomer>>();
                            customerMap.put('customer', new List<Customer.StripeCustomer>{customer});
                            ProcessorUtil.ResponseObject updateCustomerResponse = updateCustomer(apcWrapper, JSON.serializePretty(customerMap));
                            if (updateCustomerResponse.errors != null) {
                                response.errors = updateCustomerResponse.errors;
                            }
                            response = updateCustomerResponse;
                        }

                    } else {
                        Map<String, Object> responseFromStripe = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                        Map<String, Object> error = (Map<String, Object>)responseFromStripe.get('error');
                        response.errors.add(formatError(error, String.valueOf(res.getStatusCode())));
                        APICallHandler.userInteractionLogPush(TRUE, 'Create Stripe Payment Method', 'ERROR', 'Response for Stripe Org Name(' + apcWrapper.accountName + '): Status Code: ' + res.getStatusCode() + ' Response Body: ' + res.getBody());
                    }
                } catch (Exception ex) {
                    // We want to catch any additional errors and let the process continue.
                    response.errors.add(new ProcessorUtil.Error('Exception Occurred', 'An Exception occurred while creating bank token. ' + ex.getMessage()));
                    System.debug('Exception occurred while creating bank token.' + ex.getStackTraceString());
                }
            }
        } catch (Exception ex) {
            response.errors.add(new ProcessorUtil.Error('Exception Occurred', 'An Exception occurred while creating bank token. ' + ex.getMessage()));
            System.debug('Exception occurred while creating bank token.' + ex.getStackTraceString());
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
        try {
            for (Object obj : objectList){
                try {
                    String jsonObject = JSON.serializePretty(obj);
                    JSONParser objectParser = JSON.createParser(jsonObject);
                    Customer.verifyBankAccount verify = (Customer.verifyBankAccount) objectParser.readValueAs(Customer.verifyBankAccount.class);
                    
                    System.debug('verify: ' + verify);
                    
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
                    
                    String endPoint = stripeBaseUrlv1 + '/customers/'+verify.customerId+'/sources/'+verify.bankId+'/verify';
                    
                    String reqBody = 'amounts[0]='+Integer.ValueOf(verify.firstDeposit*100);
                    reqBody += '&amounts[1]='+Integer.ValueOf(verify.secondDeposit*100);
                    
                    HttpResponse res = APICallHandler.post(apcWrapper, 'POST', endPoint, reqBody);
                    if (res.getStatusCode() == 200) {
                        response.status = String.valueOf(res.getStatusCode());
                        response.responseJSON = res.getBody();
                     } else {
                        Map<String, Object> body = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                        Map<String, Object>  error=(Map<String, Object>)body.get('error');
                        response.errors.add(formatError(error, String.valueOf(res.getStatusCode())));
                        APICallHandler.userInteractionLogPush(TRUE, 'Verifying Bank Account', 'ERROR', 'Response for Stripe Org Name(' + apcWrapper.accountName + '): Status Code: ' + res.getStatusCode() + ' Response Body: ' + res.getBody());
                    }
                    
                } catch (Exception ex) {
                    response.errors.add(new ProcessorUtil.Error('Exception Occurred', 'An Exception occurred while Verifying Bank Account to Stripe. ' + ex.getMessage()));
                    System.debug('Exception occurred while Verifying Bank Account in Stripe.' + ex.getStackTraceString());
                }
            }
        } catch (Exception ex) {
            response.errors.add(new ProcessorUtil.Error('Exception Occurred','An Exception occurred while Verifying Bank Account to Stripe. ' + ex.getMessage()));
            System.debug('Exception occurred while Verifying Bank Account in Stripe.' + ex.getStackTraceString());
        }
        return response;
    }

    @TestVisible
    private static ProcessorUtil.ResponseObject chargeProcessor(BreadwinnerUtil.AppConfig apcWrapper, String requestJSON, String timeout){
        Customer.StripeCustomer stripeCustomer = new Customer.StripeCustomer();
        Customer.Sources paymentMethod = new Customer.Sources();

        ProcessorUtil.ResponseObject response = new ProcessorUtil.ResponseObject();
        response.errors = new List<ProcessorUtil.Error>();

        Map<String, Object> objectMap = (Map<String,Object>) JSON.deserializeUntyped(requestJSON);
        System.debug('objectMap: ' + objectMap);

        List<Object> objectList = (List<Object>) objectMap.get('charge');
        if (objectList.size() > 1){
            response.errors.add(new ProcessorUtil.Error('', 'You can only make one charge at a time.'));
            return response;
        }
        Charge.StripeCharge charge;
        try {
            String jsonObject = JSON.serializePretty(objectList[0]);
            JSONParser objectParser = JSON.createParser(jsonObject);
            charge = (Charge.StripeCharge) objectParser.readValueAs(Charge.StripeCharge.class);

            System.debug('charge: ' + charge);

            Boolean isBankAccountPM = charge.paymentMethodType == 'BankAccount';

            String endPoint = stripeBaseUrlv1;
            endPoint += isBankAccountPM ?'/charges' : '/payment_intents';

            //Validate required fields
            if (charge.customer == null) {
                response.errors.add(new ProcessorUtil.Error('Required field missing.','Stripe customer Id is required.'));
                return response;
            }

            if (String.isBlank(charge.stripe_currency)) {
                response.errors.add(new ProcessorUtil.Error('Required field missing.','currency is required.'));
                return response;
            }

            if (charge.amount == null || charge.amount <= 0) {
                response.errors.add(new ProcessorUtil.Error('Required field missing.','"amount" is required and must be greater than zero.'));
                return response;
            }

            //Check and build UrlBody
            String reqBody =  'customer=' + getURLEncodeData(charge.customer);
            reqBody += '&currency=' + getURLEncodeData(charge.stripe_currency);
            if (String.isNotBlank(charge.description)) {
                reqBody += '&description=' + getURLEncodeData(charge.description);
            }

            List<String> zeroDecimalCurrenciesList = new List<String>();
            zeroDecimalCurrenciesList = BreadwinnerUtil.getZeroDecimalStripeCurrencies();
            Boolean isZeroDecimalCurrency = false;
            for(String cur : zeroDecimalCurrenciesList){
                if(cur == charge.stripe_currency){
                    isZeroDecimalCurrency = true;
                }
            }
            if(isZeroDecimalCurrency){
                reqBody += '&amount=' + getURLEncodeData(String.valueOf(Integer.Valueof(charge.amount)));
            } else{
                reqBody += '&amount=' + getURLEncodeData(String.valueOf(Integer.Valueof(charge.amount * 100)));
            }

            if (isBankAccountPM) {
                //Bank Account parameters
                if (charge.paymentMethod != null) {
                    reqBody += '&source=' + getURLEncodeData(charge.paymentMethod);
                }
                if (charge.capture != null) {
                    reqBody += '&capture=' + getURLEncodeData(String.valueOf(charge.capture));
                }
            } else {
                // Card parameters
                if (charge.paymentMethod != null) {
                    if (charge.paymentMethodType == ProcessorUtil.PM_ACH_CREDIT) {
                        reqBody += '&source=' + getURLEncodeData(charge.paymentMethod);
                        reqBody += '&payment_method_types[0]=ach_credit_transfer';
                    } else {
                        reqBody += '&payment_method=' + getURLEncodeData(charge.paymentMethod);
                        //reqBody += '&source=' + getURLEncodeData(charge.paymentMethod);
                    }
                }
                reqBody += '&confirm=' + getURLEncodeData(String.valueOf('true'));
                reqBody += '&confirmation_method=' + getURLEncodeData(String.valueOf('automatic'));
            }

            HttpResponse res = APICallHandler.post(apcWrapper, 'POST', endPoint, reqBody, timeout);

            if (res.getStatusCode() == 200) {
                response.status = String.valueOf(res.getStatusCode());
                String responseStr = replaceStripeWords(res.getBody());
                JSONParser parser = JSON.createParser(responseStr);

                Map<String, Charge.StripeCharge > stripeIdChargeMapResponse = new Map<String, Charge.StripeCharge> ();

                if (isBankAccountPM) {
                    Charge.StripeCharge responseData = (Charge.StripeCharge) parser.readValueAs(Charge.StripeCharge.class);
                    stripeIdChargeMapResponse.put(responseData.id, responseData);
                    System.debug('Created Stripe BankAcount Charges ' + stripeIdChargeMapResponse.keySet());
                } else {
                    PaymentIntent responseData = (PaymentIntent) parser.readValueAs(PaymentIntent.class);
                    Charge.StripeCharge chargeReceived = responseData.charges.data[0];
                    stripeIdChargeMapResponse.put(chargeReceived.id, chargeReceived);
                    System.debug('Created Stripe Card Charges ' + stripeIdChargeMapResponse.keySet());
                }

                Map<String, Object> processorToPaymentMap = new Map<String, Object>();
                processorToPaymentMap.put(ProcessorUtil.PAT_STRIPE, stripeIdChargeMapResponse);
                apcWrapper.currentRunningClassContext = BreadwinnerUtil.CNTX_BWAPI;
                response.transactionList = syncTransactions(processorToPaymentMap, apcWrapper);

                response.responseJSON = JSON.serializePretty(stripeIdChargeMapResponse);

            } else {
                Map<String, Object> responseFromStripe = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                Map<String, Object> error = (Map<String, Object>)responseFromStripe.get('error');
                response.errors.add(formatError(error, String.valueOf(res.getStatusCode())));
                APICallHandler.userInteractionLogPush(true, 'Create Stripe Payment', 'ERROR' , 'Response for Stripe Org Name('+apcWrapper.accountName+'): Status Code: '+res.getStatusCode()+' Response Body: '+res.getBody() );
            }
        } 
        catch(System.CalloutException ex){
            response.errors.add(new ProcessorUtil.Error('Exception Occurred','An Exception occurred while charging. ' + ex.getMessage()));
            if(ex.getMessage().contains('Read timed out')){ 
                createPEXPayments(charge, apcWrapper);
                APICallHandler.userInteractionLogPush(FALSE, 'Create Stripe Payment', 'PEX', 'Exception: '+ex.getMessage());
            }
            else{
                APICallHandler.userInteractionLogPush(FALSE, 'Create Stripe Payment', 'ERROR', 'Exception: '+ex.getMessage());
            }
        }
        catch (Exception ex) {
            response.errors.add(new ProcessorUtil.Error('Exception Occurred','An Exception occurred while charging. ' + ex.getMessage()));
            System.debug('Exception occurred while charging' + ex.getStackTraceString());
            APICallHandler.userInteractionLogPush(FALSE, 'Create Stripe Payment', 'ERROR', 'Exception: '+ex.getMessage());
        }

        return response;
    }

    @TestVisible
    private static void createPEXPayments(Charge.StripeCharge charge, BreadwinnerUtil.AppConfig apcWrapper){
        BWP_Transaction__c newCharge = new BWP_Transaction__c();
        newCharge = constructStripeTransaction(newCharge, charge, apcWrapper);
        newCharge.Created_Date_in_Processor__c = System.now();
        newCharge.Amount__c = charge.amount;
        newCharge.Charge_Status__c = ProcessorUtil.CHARGE_EXCEPTION;
        List<BWP_Customer__c> customerList = selectorCustomer.selectByProcessorCustomerId(new Set<String>{charge.customer},null);

        newCharge.customer__c = customerList[0].Id;
        newCharge.Salesforce_Account__c = customerList[0].Salesforce_Account__c;

        List<BWP_Payment_Method__c> paymentMethodList = selectorPaymentMethod.selectByProcessorId(charge.paymentMethod,1);

        newCharge.Source__c = paymentMethodList[0].id;
        List<BWP_Transaction__c> transactionsList = new List<BWP_Transaction__c>();
        transactionsList.add(newCharge);
        SecurityUtil.dmlInsert(transactionsList);
    }
    @TestVisible
    private static ProcessorUtil.ResponseObject fetchCustomers(BreadwinnerUtil.AppConfig apcWrapper, String requestJSON) {
        ProcessorUtil.ResponseObject response = new ProcessorUtil.ResponseObject();
        response.errors = new List<ProcessorUtil.Error>();
        FetchRequest filters = (FetchRequest)System.JSON.deserialize(requestJSON, FetchRequest.class);

        String endPoint = stripeBaseUrlv1 + '/customers';

        //Generate endpoint as per user inputs
        if (String.isNotBlank(filters.customerId)) {
            //if user supplies id, no other filter will be built.
            endPoint += '/' + filters.customerId;
        } else {
            if (String.isNotBlank(filters.stripe_limit)) {
                String encodedLimit = getURLEncodeData(filters.stripe_limit);
                //make max limit to 50 to reduce head size and DML rows issues.
                endPoint += '?limit=' + (Integer.valueOf(encodedLimit) >= 50 ? 50 : Integer.valueOf(encodedLimit));
            } else {
                //if no limit is supplied, 10 will be applied by default.
                endPoint += '?limit=10';
            }

            if (String.isNotBlank(filters.starting_after)) {
                endPoint += '&starting_after=' + filters.starting_after;
            }
            if (String.isNotBlank(filters.email)) {
                endPoint += '&email=' + getURLEncodeData(filters.email);
            }
            if (String.isNotBlank(filters.ending_before)) {
                endPoint += '&ending_before=' + getURLEncodeData(String.valueOf(filters.ending_before));
            }

            //Add date time filters
            if (String.isNotBlank(filters.createdGreaterThan)) {
                endPoint += '&created[gt]=' + (DateTime.valueOf(filters.createdGreaterThan).getTime()) / 1000;
            }
            if (String.isNotBlank(filters.createdGreaterThanOrEqual)) {
                endPoint += '&created[gte]=' + (DateTime.valueOf(filters.createdGreaterThanOrEqual).getTime()) / 1000;
            }
            if (String.isNotBlank(filters.createdLessThan)) {
                endPoint += '&created[lt]=' + (DateTime.valueOf(filters.createdLessThan).getTime()) / 1000;
            }
            if (String.isNotBlank(filters.createdLessThanOrEqual)) {
                endPoint += '&created[lte]=' + (DateTime.valueOf(filters.createdLessThanOrEqual).getTime()) / 1000;
            }
        }
        System.debug('EndPoint: ' + endPoint);

        HttpResponse res = APICallHandler.getList(apcWrapper, 'GET', endPoint, '');
        response.status = String.valueOf(res.getStatusCode());
        if (res.getStatusCode() == 200) {
            FetchResponse fetchResponse = new FetchResponse();
            fetchResponse = parseCustomers(res.getBody());
            response.responseJSON = JSON.serializePretty(fetchResponse);
        } else {
            String Action_Type = ProcessorUtil.getLogAction(apcWrapper.currentRunningClassContext, 'Fetching Customers');
            APICallHandler.userInteractionLogPush(true, Action_Type, 'ERROR' , 'Response for Processor Org Name('+apcWrapper.accountName+'): Status Code: '+res.getStatusCode()+' Response Body: '+res.getBody() );
            Map<String, Object> responseFromStripe = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            Map<String, Object> error = (Map<String, Object>)responseFromStripe.get('error');
            if(error != NULL)
                response.errors.add(formatError(error, String.valueOf(res.getStatusCode())));
        }
        return response;
    }
    @TestVisible
    private static ProcessorUtil.ResponseObject fetchTransactions(BreadwinnerUtil.AppConfig apcWrapper, String requestJSON) {
        ProcessorUtil.ResponseObject response = new ProcessorUtil.ResponseObject();
        response.errors = new List<ProcessorUtil.Error>();
        FetchRequest filters = (FetchRequest)System.JSON.deserialize(requestJSON, FetchRequest.class);
        String endPoint = stripeBaseUrlv1 + '/charges';
        if (String.isNotBlank(filters.stripe_limit)) {
            String encodedLimit = getURLEncodeData(filters.stripe_limit);
            //make max limit to 50 to reduce head size and DML rows issues.
            endPoint += '?limit=' + (Integer.valueOf(encodedLimit) >= 50 ? 50 : Integer.valueOf(encodedLimit));
        } else {
            //if no limit is supplied, 10 will be applied by default.
            endPoint += '?limit=10';
        }
        if (String.isNotBlank(filters.starting_after)) {
            endPoint += '&starting_after=' + filters.starting_after;
        }
        if (String.isNotBlank(filters.createdGreaterThanOrEqual)) {
            endPoint += '&created[gte]=' + (DateTime.valueOf(filters.createdGreaterThanOrEqual).getTime()) / 1000;
        }
        HttpResponse res = APICallHandler.getList(apcWrapper, 'GET', endPoint, '');
        response.status = String.valueOf(res.getStatusCode());

        if (res.getStatusCode() == 200) {
            system.debug('response---------'+res.getBody());
            FetchResponse fetchResponse = new FetchResponse();
            fetchResponse = parsePayments(res.getBody());
            response.responseJSON = JSON.serializePretty(fetchResponse);

        } else {
            apcWrapper.needToReconnect = true;
            apcWrapper.requireNextPaymentSyncRun = false;
            String Action_Type = ProcessorUtil.getLogAction(apcWrapper.currentRunningClassContext, 'Fetching Transactions');
            APICallHandler.userInteractionLogPush(true, Action_Type, 'ERROR' , 'Response for Processor Org Name('+apcWrapper.accountName+'): Status Code: '+res.getStatusCode()+' Response Body: '+res.getBody() );

            Map<String, Object> responseFromStripe = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            Map<String, Object> error = (Map<String, Object>)responseFromStripe.get('error');
            if(error != NULL)
                response.errors.add(formatError(error, String.valueOf(res.getStatusCode())));
        }

        return response;

    }

    public static FetchResponse parseCustomers(String responseBody) {	
        Map<String, Customer.StripeCustomer> stripeIdCustomerMap = new Map<String, Customer.StripeCustomer>();
        FetchResponse response = new FetchResponse();
        try{	
            String responseStr = replaceStripeWords(responseBody);	
            JSONParser parser = JSON.createParser(responseStr);	
            CustomerResponse responseData = (CustomerResponse) parser.readValueAs(CustomerResponse.Class);	
            system.debug('Data---'+responseData.data+'respone data parsed---'+responseData);	
            if(responseData.data != null){	
                Boolean hasMoreRecords = responseData.has_more;	
                String lastCustId = '';	
                for (Customer.StripeCustomer customer : responseData.data)	
                {	
                    stripeIdCustomerMap.put(customer.id, customer);
                    lastCustId = customer.id;	
                }	
                if(hasMoreRecords){	
                    response.requireNextRun = TRUE;
                    response.last_record_id = lastCustId;
                }
                else{
                    response.requireNextRun = FALSE;
                    response.last_record_id = '';
                }	
            }
            else if(responseData.data == null){
                Customer.StripeCustomer customer = (Customer.StripeCustomer) JSON.deserialize(responseStr, Customer.StripeCustomer.Class);
                stripeIdCustomerMap.put(customer.id,customer);
            }	
            response.customerMapById = stripeIdCustomerMap;
            //response.objectMapById = stripeIdCustomerMap;
        } catch(Exception ex) {	
            System.debug('Customer Sync failed for while parsing. \n' +ex.getStackTraceString());
            APICallHandler.userInteractionLogPush(TRUE, 'Customer Sync', 'ERROR' , 'Customer Sync failed for while parsing. \n' +ex.getStackTraceString());
        }	
        return response;	
    }	
    public static FetchResponse parsePayments(String responseBody) {	
        Map<String,Charge.StripeCharge> stripeIdPaymentMap = new Map<String,Charge.StripeCharge>();
        FetchResponse response = new FetchResponse();
        try{	
            String responseStr = replaceStripeWords(responseBody);	
            JSONParser parser = JSON.createParser(responseStr);	
            ChargesResponse responseData = (ChargesResponse) parser.readValueAs(ChargesResponse.class);
            if(responseData.data != NULL){	
                Boolean hasMoreRecords = responseData.has_more;	
                String lastPaymentId = '';
                for (Charge.StripeCharge ch : responseData.data) {
                    stripeIdPaymentMap.put(ch.Id,ch);
                    lastPaymentId = ch.id;
                }
                if(hasMoreRecords){	
                    system.debug('hasmore records');
                    response.requireNextRun = TRUE;
                    response.last_record_id = lastPaymentId;
                }
                else{
                    response.requireNextRun = FALSE;
                    response.last_record_id = '';
                }	
            }
            else if(responseData.data == NULL){
                system.debug('single payment');
                Charge.StripeCharge charge = (Charge.StripeCharge) JSON.deserialize(responseStr, Charge.StripeCharge.Class);
                stripeIdPaymentMap.put(charge.id, charge);
            }	
            response.paymentMapById = stripeIdPaymentMap;
        } catch(Exception ex) {
            System.debug('Payments Sync failed for while parsing. \n' +ex.getStackTraceString());
            APICallHandler.userInteractionLogPush(true, 'Payment Sync', 'ERROR' , 'Payments Sync failed for  while parsing. \n' +ex.getMessage());
        }
        return response;	
    }
    
    //*** Saving the Stripe customers and related payment methods to SF. Orphan records will not be saved.
    public static ProcessorUtil.ResponseObject syncCustomers(Map<String, Object> processorToCustomerMap, BreadwinnerUtil.AppConfig appConfig, Boolean addToSalesforce) {

        ProcessorUtil.ResponseObject responseObj = new ProcessorUtil.ResponseObject();
        List<ProcessorUtil.CustomerWrapper> customerList = new List<ProcessorUtil.CustomerWrapper>();
        List<ProcessorUtil.PaymentMethodWrapper> payMethodList = new List<ProcessorUtil.PaymentMethodWrapper>();
        try {
            if(String.isBlank(appConfig.customerSyncConfig) || ((String.isNotBlank(appConfig.customerSyncConfig) && (appConfig.customerSyncConfig != 'NONE')))  && appConfig.currentRunningClassContext != BreadwinnerUtil.CNTX_BWAPI)
                processorToCustomerMap = excludeCustomers(processorToCustomerMap, appConfig);
            String paymentProcessorType = '';
            Breadwinner_Settings__c bwSetting = BreadwinnerUtil.getBWSetting();
            Map<String, Customer.StripeCustomer> stripeIdCustomerMap =  new Map<String, Customer.StripeCustomer>();
            stripeIdCustomerMap = (Map<String, Customer.StripeCustomer>) processorToCustomerMap.get(ProcessorUtil.PAT_STRIPE);
            paymentProcessorType = ProcessorUtil.PAT_STRIPE;

            List<BWP_Customer__c> customerUpsertList = new List<BWP_Customer__c> ();
            Map<String, BWP_Customer__c> customerUpsertMap = new Map<String, BWP_Customer__c>();
            Map<String, BWP_Payment_Method__c> sourcesMap = new Map<String, BWP_Payment_Method__c>();
            Map<String,BWP_Customer__c> existingSFCustomersMap = new Map<String,BWP_Customer__c>();
            Map<String,BWP_Payment_Method__c> existingSFPaymentMethodsMap = new Map<String,BWP_Payment_Method__c>();
            Set<String> receivedPaymentMethodsIdSet = new Set<String>();
            //Stripe related info
            if(stripeIdCustomerMap != null){
                //Holding existing customer records in Salesforce
                for(BWP_Customer__c cus : selectorCustomer.selectByProcessorCustomerId(stripeIdCustomerMap.keySet(), 45000))
                    existingSFCustomersMap.put(cus.Processor_Customer_Id__c,cus);

                //Collecting Stripe id of all received payment methods
                for(Customer.StripeCustomer cus : stripeIdCustomerMap.values()) {
                    for(Customer.Source src : cus.sources.data) {
                        receivedPaymentMethodsIdSet.add(src.id);
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

            for(String ContactId : stripeIdCustomerMap.keySet()){
                if(!existingSFCustomersMap.containsKey(ContactId) || (existingSFCustomersMap.containsKey(ContactId) && existingSFCustomersMap.get(ContactId).Salesforce_Account__c == NULL && !existingSFCustomersMap.get(ContactId).No_Associated_SF_Account__c )){
                    Customer.StripeCustomer sc = stripeIdCustomerMap.get(ContactId);
                    ProcessorUtil.getExistingRecordsSet(sc.name, sc.email, customerNameSet, customerEmailSet);
                }
            }
            //Stripe Customers
            system.debug('appConfig.isCustomerMatchComplete'+appConfig.isCustomerMatchComplete);
            system.debug('appConfig.currentRunningClassContext'+appConfig.currentRunningClassContext);
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
                for(String refId : stripeIdCustomerMap.keySet()){
                    Customer.StripeCustomer cw = stripeIdCustomerMap.get(refId);
                    ID accID;
                    if(!existingSFCustomersMap.containsKey(refId) || (existingSFCustomersMap.containsKey(refId) && existingSFCustomersMap.get(refId).Salesforce_Account__c == NULL && !existingSFCustomersMap.get(refId).No_Associated_SF_Account__c )){
                        string customerNameLowerCase = String.isNotBlank(cw.name) ? (cw.name.toLowerCase().replace('\\', '%')) : (String.isNotBlank(cw.email) ? (cw.email.toLowerCase().replace('\\', '%')) : '');
                        // first check with person account email then with company name if person accounts are enabled
                        String personEmail = String.isNotBlank(cw.email) ? (cw.email.toLowerCase().replace('\\', '%')) : '';
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

                    if(String.isNotBlank(cw.id)) {
                        // Querying existing Stripe Customer if any or creating new one
                        BWP_Customer__c customerSf = existingSFCustomersMap.get(cw.id) != null ? existingSFCustomersMap.get(cw.id) : new BWP_Customer__c();
                        customerSf = constructStripeCustomer(customerSf, cw, appConfig);
                        if(!existingSFCustomersMap.containsKey(refId) || (existingSFCustomersMap.containsKey(refId) && existingSFCustomersMap.get(refId).Salesforce_Account__c == NULL && !existingSFCustomersMap.get(refId).No_Associated_SF_Account__c )) customerSf.Salesforce_Account__c = customerSf.Salesforce_Account__c != null ? customerSf.Salesforce_Account__c : accID;
                        customerUpsertList.add(customerSf);
                        customerUpsertMap.put(refId, customerSf);
                        stripeIdCustomerMap.remove(refId);
                        for (Customer.Source src : cw.sources.data) {
                            // Querying existing Stripe Payment Method if any or creating new one
                            BWP_Payment_Method__c srcSf =  existingSFPaymentMethodsMap.get(src.id) != null ? existingSFPaymentMethodsMap.get(src.id) : new BWP_Payment_Method__c();
                            srcSf.Customer__r = new BWP_Customer__c(Processor_Customer_Id__c = cw.id);
                            srcSf.Processor_Customer_Id__c = cw.id;
                            srcSf.Salesforce_Account__c = String.isNotBlank(customerSf.Salesforce_Account__c) ? customerSf.Salesforce_Account__c : accID;
                            srcSf = constructStripePaymentMethod(srcSf, src, appConfig);
                            sourcesMap.put(src.id, srcSf);
                        }
                    }

                    if(accID == NULL && (!existingSFCustomersMap.containsKey(refId) || (existingSFCustomersMap.containsKey(refId) && existingSFCustomersMap.get(refId).Salesforce_Account__c == NULL && !existingSFCustomersMap.get(refId).No_Associated_SF_Account__c ))){
                        // Create New accounts
                        system.debug('new accounts');
                        String customerName = (String.isNotBlank(cw.name) ? cw.name : (String.isNotBlank(cw.email) ? cw.email : ''));
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

                        acctRef.Phone = cw.Phone;
                        if(cw.address != NULL){
                            acctRef.BillingStreet = cw.address.line1.replaceAll('%%', '\r\n');
                            acctRef.BillingCity = cw.address.city;
                            acctRef.BillingState = cw.address.state;
                            acctRef.BillingCountry = cw.address.country;
                            acctRef.BillingPostalCode = cw.address.postal_code;
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
                for(String refId : stripeIdCustomerMap.keySet()){
                    Customer.StripeCustomer cw = stripeIdCustomerMap.get(refId);
                    ID conID;
                    if(!existingSFCustomersMap.containsKey(refId) || (existingSFCustomersMap.containsKey(refId) && existingSFCustomersMap.get(refId).Salesforce_Contact__c == NULL && !existingSFCustomersMap.get(refId).No_Associated_SF_Contact__c )){
                        string customerNameLowerCase = String.isNotBlank(cw.name) ? (cw.name.toLowerCase().replace('\\', '%')) : (String.isNotBlank(cw.email) ? (cw.email.toLowerCase().replace('\\', '%')) : '');
                            String email = String.isNotBlank(cw.email) ? (cw.email.toLowerCase().replace('\\', '%')) : '';
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
                        customerSf = constructStripeCustomer(customerSf, cw, appConfig);
                        if(!existingSFCustomersMap.containsKey(refId) || (existingSFCustomersMap.containsKey(refId) && existingSFCustomersMap.get(refId).Salesforce_Contact__c == NULL && !existingSFCustomersMap.get(refId).No_Associated_SF_Contact__c )) customerSf.Salesforce_Contact__c = customerSf.Salesforce_Contact__c != null ? customerSf.Salesforce_Contact__c : conID;
                        customerUpsertList.add(customerSf);
                        customerUpsertMap.put(refId, customerSf);
                        stripeIdCustomerMap.remove(refId);
                        for (Customer.Source src : cw.sources.data) {
                            // Querying existing Stripe Payment Method if any or creating new one
                            BWP_Payment_Method__c srcSf =  existingSFPaymentMethodsMap.get(src.id) != null ? existingSFPaymentMethodsMap.get(src.id) : new BWP_Payment_Method__c();
                            srcSf.Customer__r = new BWP_Customer__c(Processor_Customer_Id__c = cw.id);
                            srcSf.Processor_Customer_Id__c = cw.id;
                            srcSf.Salesforce_Contact__c = String.isNotBlank(customerSf.Salesforce_Contact__c) ? customerSf.Salesforce_Contact__c : conID;
                            srcSf = constructStripePaymentMethod(srcSf, src, appConfig);
                            sourcesMap.put(src.id, srcSf);
                        }
                    }
                    
                    if(conID == NULL && (!existingSFCustomersMap.containsKey(refId) || (existingSFCustomersMap.containsKey(refId) && existingSFCustomersMap.get(refId).Salesforce_Contact__c == NULL && !existingSFCustomersMap.get(refId).No_Associated_SF_Contact__c ))){
                        // Create New accounts
                        system.debug('new Contacts');
                        String customerName = (String.isNotBlank(cw.name) ? cw.name : (String.isNotBlank(cw.email) ? cw.email : ''));
                        Contact conRef = new Contact();
                        conRef.LastName = customerName;
                        conRef.Email = (String.isNotBlank(cw.email) ? cw.email : '');
                        conRef.Phone = cw.Phone;
                        if(cw.address != NULL){
                            conRef.MailingStreet = cw.address.line1.replaceAll('%%', '\r\n');
                            conRef.MailingCity = cw.address.city;
                            conRef.MailingState = cw.address.state;
                            conRef.MailingCountry = cw.address.country;
                            conRef.MailingPostalCode = cw.address.postal_code;
                        }
                        
                        conRef.Description = 'This Salesforce Contact was created by Breadwinner.';
                        //Do field Truncation
                        if(string.isNotBlank(conRef.MailingStreet) && conRef.MailingStreet.length() > 255) conRef.MailingStreet = conRef.MailingStreet.left(255);
                        if(string.isNotBlank(conRef.MailingCity) && conRef.MailingCity.length() > 40) conRef.MailingCity = conRef.MailingCity.left(40);
                        if(string.isNotBlank(conRef.MailingState) && conRef.MailingState.length() > 20) conRef.MailingState = conRef.MailingState.left(20);
                        if(string.isNotBlank(conRef.MailingPostalCode) && conRef.MailingPostalCode.length() > 20) conRef.MailingPostalCode = conRef.MailingPostalCode.left(20);
                        if(string.isNotBlank(conRef.MailingCountry) && conRef.MailingCountry.length() > 40) conRef.MailingCountry = conRef.MailingCountry.left(40);
                        
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
                for(String refId : stripeIdCustomerMap.keySet()){
                    Customer.StripeCustomer customer = stripeIdCustomerMap.get(refId);
                    if(String.isNotBlank(customer.id)) {
                        // Querying existing Stripe Customer if any or creating new one
                        BWP_Customer__c customerSf = existingSFCustomersMap.get(customer.id) != null ? existingSFCustomersMap.get(customer.id) : new BWP_Customer__c();
                        customerSf = constructStripeCustomer(customerSf, customer, appConfig);
                        //system.debug('accountId------'+accountId);
                        if(BreadwinnerUtil.accountId != null)
                            customerSf.Salesforce_Account__c = BreadwinnerUtil.accountId;
                        for (Customer.Source src : customer.sources.data) {
                            // Querying existing Stripe Payment Method if any or creating new one
                            BWP_Payment_Method__c srcSf =  existingSFPaymentMethodsMap.get(src.id) != null ? existingSFPaymentMethodsMap.get(src.id) : new BWP_Payment_Method__c();
                            srcSf.Customer__r = new BWP_Customer__c(Processor_Customer_Id__c = customer.id);
                            srcSf.Processor_Customer_Id__c = customer.id;
                            if(String.isNotBlank(customerSf.Salesforce_Account__c))
                                srcSf.Salesforce_Account__c = customerSf.Salesforce_Account__c;
                            if(String.isNotBlank(customerSf.Salesforce_Contact__c))
                                srcSf.Salesforce_Contact__c = customerSf.Salesforce_Contact__c;
                            srcSf = constructStripePaymentMethod(srcSf, src, appConfig);
                            sourcesMap.put(src.id, srcSf);
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

        }catch(Exception ex) {
            System.debug('Customer Sync failed for '+appConfig.Name +' while syncing. \n' +ex.getStackTraceString()+'\n'+ex.getMessage());
            APICallHandler.userInteractionLogPush(TRUE, 'Customer Sync', 'ERROR' , 'Customer Sync failed for '+appConfig.Name +' while syncing. \n' +ex.getStackTraceString()+'\n'+ex.getMessage());
        }
        return responseObj;
    }

 
    //Saving the payments to SF. Orphan records will not be saved.
    public static List<ProcessorUtil.TransactionWrapper> syncTransactions(Map<String, Object> processorIdToPaymentMap, BreadwinnerUtil.AppConfig appConfig) {
        List<ProcessorUtil.TransactionWrapper> rtnList = new List<ProcessorUtil.TransactionWrapper>();
        Map<String, Object> returnMap = new Map<String, Object>();
        // Map tp store the Payment Id and related Customer Id
        Set<String> successfulPaymentsCustomerIdSet = new Set<String>();
        Map<String, Charge.StripeCharge> stripeIdPaymentMap = (Map<String, Charge.StripeCharge>) processorIdToPaymentMap.get(ProcessorUtil.PAT_STRIPE);
        if(stripeIdPaymentMap == null) {
            return rtnList;
        }

        Map<String, BWP_Transaction__c> upsertMapByRefId = new Map<String, BWP_Transaction__c>();
        Map<String,BWP_Transaction__c> existingSFPaymentsMap = new Map<String,BWP_Transaction__c>();
        for(BWP_Transaction__c trxn : selectorTransaction.selectByProcessorId(stripeIdPaymentMap.keySet(), new List<String>{'Source__r.Id'})) {
            BWP_Transaction__c txn = new BWP_Transaction__c(id = trxn.id, Processor_Id__c = trxn.Processor_Id__c);
            existingSFPaymentsMap.put(txn.Processor_Id__c, txn);
        }
        try {
            // Boolean to check the syncing of failed Payments
            Boolean doNotImportCustomerAndFailedPayments = (String.isBlank(appConfig.customerMatchConfig) || (String.isNotBlank(appConfig.customerMatchConfig) && (appConfig.customerMatchConfig.contains('NO_VALID_PAYMENTS')))) ? TRUE : FALSE;

            Set<String> customerIdSet = new Set<String>();
            Set<String> paymentMethodIdSet = new Set<String>();
            // Create a customerIdSet & paymentIdSet to be used in a query later
            for (Charge.StripeCharge pw : stripeIdPaymentMap.values()) {
                String payment_Method_Id = String.isNotBlank(pw.payment_method) ? pw.payment_method : (String.isNotBlank(pw.source.id) ? pw.source.id : null);
                customerIdSet.add(pw.customer);
                paymentMethodIdSet.add(payment_Method_Id);
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

            // Loop though the payments and create a BWP_Transaction__c list
           for (Charge.StripeCharge pw : stripeIdPaymentMap.values()) {
                String payment_Method_Id = String.isNotBlank(pw.payment_method) ? pw.payment_method : (String.isNotBlank(pw.source.id) ? pw.source.id : NULL);

                BWP_Customer__c customer = customerMapByProcessorCustomerId.get(pw.customer);
                BWP_Payment_Method__c paymentMethod = paymentMethodMapByProcessorId.get(payment_Method_Id);

                BWP_Transaction__c transactionSf = existingSFPaymentsMap.get(pw.id) != null ? existingSFPaymentsMap.get(pw.id) : new BWP_Transaction__c();
                
                if (customer != NULL) {
                    transactionSf.Customer__c = customer.Id;
                    transactionSf.Salesforce_Account__c = String.isNotBlank(customer.Salesforce_Account__c) ? customer.Salesforce_Account__c : NULL;
                    transactionSf.Salesforce_Contact__c = String.isNotBlank(customer.Salesforce_Contact__c) ? customer.Salesforce_Contact__c : NULL;
                }
                
                if(paymentMethod != NULL && String.isNotBlank(paymentMethod.Id))
                    transactionSf.Source__c = paymentMethod.Id;
                transactionSf = constructStripeTransaction(transactionSf, pw, appConfig);
                if (doNotImportCustomerAndFailedPayments && transactionSf.Status__c == ProcessorUtil.CHARGE_SUCCEEDED) {
                    if(String.isNotBlank(transactionSf.Customer__c)){
                        successfulPaymentsCustomerIdSet.add(transactionSf.Customer__c);
                    }
                }

                if (String.isNotBlank(transactionSf.customer__c) && (doNotImportCustomerAndFailedPayments ? (transactionSf.Status__c == 'Succeeded' ? TRUE : FALSE) : TRUE)){
                    upsertMapByRefId.put(transactionSf.Processor_Id__c, transactionSf);
                }
                system.debug('successfulPaymentsCustomerIdSet----------'+successfulPaymentsCustomerIdSet);
            }
            
            if(!upsertMapByRefId.isEmpty()){
                rtnList = ProcessorUtil.upsertAndReturnPaymentList(upsertMapByRefId.values());
            }
            
            if(doNotImportCustomerAndFailedPayments && !successfulPaymentsCustomerIdSet.isEmpty()){
                ProcessorUtil.updateSuccessfulPaymentsCustomers(doNotImportCustomerAndFailedPayments, successfulPaymentsCustomerIdSet);
            }
            
        }catch(Exception Ex) {
            System.debug('Payments Sync failed for '+appConfig.Name +' while syncing. \n' +ex.getStackTraceString());
            APICallHandler.userInteractionLogPush(TRUE, 'Payment Sync', 'ERROR' , 'Payments Sync failed for '+appConfig.Name +' while syncing. \n' +ex.getStackTraceString());
        }

        return rtnList;

    }

    // This method is used to convert the Stripe Customer wrapper to Stripe Customer record.
    private static BWP_Customer__c constructStripeCustomer(BWP_Customer__c customerSf, Customer.StripeCustomer cw, BreadwinnerUtil.AppConfig appConfig){
        if(customerSf.Id == null){
            customerSf.Created_Via__c = BreadwinnerUtil.getCreatedViaValue(appConfig.currentRunningClassContext);
        }
        customerSf.Customer_ID__c = cw.id+'-'+appConfig.PaymentProcessorType+'-'+appConfig.accountId;
        customerSf.Customer_Account_Balance__c = cw.balance != null ? (BreadwinnerUtil.zeroDecimalCurrencies.contains((cw.stripe_currency != null ? cw.stripe_currency : appConfig.defaultCurrency).toUpperCase()) ? Decimal.valueOf(cw.balance) : Decimal.valueOf(cw.balance) * 0.01):0;
        customerSf.Processor_Type__c = appConfig.PaymentProcessorType;
        customerSf.Processor_Org_Id__c = appConfig.accountId;
        customerSf.Processor_Org_Name__c = appConfig.accountName;
        customerSf.Name = (String.isNotBlank(cw.name) ? cw.name : ((String.isNotBlank(cw.email) ? cw.email : (String.isNotBlank(cw.id) ? cw.id : ''))));
        customerSf.Customer_Name__c = cw.name;
        customerSf.Email__c = cw.email;
        customerSf.Processor_Customer_Id__c = cw.id;
        customerSf.Tax_Exempt__c = cw.tax_exempt; // customer.sources.total_count;

        if (cw.stripe_currency != null) {
            customerSf.Currency__c = (cw.stripe_currency).toUpperCase();
        }
        if(cw.created != null)
            customerSf.Created_Date_in_Processor__c = DateTime.newInstance((long)(cw.created) * 1000);
        customerSf.Default_Source__c= cw.default_source != null ? cw.default_source: '';
        customerSf.Delinquent__c = cw.delinquent != null ? cw.delinquent : false;
        customerSf.Description__c = cw.description;
        customerSf.Invoice_Prefix__c = cw.invoice_prefix;
        customerSf.Livemode__c = cw.livemode != null ? cw.livemode : false;

        if (cw.preferred_locales != null && cw.preferred_locales.size()>0) {
            customerSf.Language__c = formatLanguage(cw.preferred_locales!=null? cw.preferred_locales[0]:'');
        }
        if (cw.tax_info != null) {
            customerSf.Tax_Id__c = cw.tax_info != null ? cw.tax_info.tax_id : '';
        } else { // Assigning more tax ids
            customerSf.Tax_Id__c ='';
            if (cw.tax_ids!=null){
                for(Customer.Tax_info   tax :  cw.tax_ids.data) {
                    tax.stripe_type =  (tax.stripe_type).toUpperCase().replace('EU',tax.country).replace('_',' ');
                    customerSf.Tax_Id__c =  String.isNotBlank(customerSf.Tax_Id__c) ? customerSf.Tax_Id__c + tax.stripe_type + ' → ' + tax.value + '\n' : tax.stripe_type+' → '+tax.value+'\n' ;
                }
            }
        }
        //Billing Address
        if (cw.address != null) {
            customerSf.Billing_City__c = cw.address.city;
            customerSf.Billing_Country__c = cw.address.country;
            customerSf.Billing_Street_Address_1__c = cw.address.line1;
            customerSf.Billing_Street_Address_2__c = cw.address.line2;
            customerSf.Billing_Postal_Code__c = cw.address.postal_code;
            customerSf.Billing_State__c = cw.address.state;
        }
        customerSf.Customer_Phone__c = String.isNotBlank(cw.phone) ? cw.phone : '';

        //Shipping Address
        if (cw.shipping != null) {
            customerSf.Shipping_City__c = cw.shipping.address.city;
            customerSf.Shipping_Country__c = cw.shipping.address.country;
            customerSf.Shipping_Street_Address_1__c = cw.shipping.address.line1;
            customerSf.Shipping_Street_Address_2__c = cw.shipping.address.line2;
            customerSf.Shipping_Postal_Code__c = cw.shipping.address.postal_code;
            customerSf.Shipping_Addressee__c = cw.shipping.name;
            customerSf.Shipping_Phone__c = cw.shipping.phone;
            customerSf.Shipping_State__c = cw.shipping.address.state;
        }
        return customerSf;
    }
    // This method is used to convert the Stripe Payment Method wrapper to Stripe Payment Method record.
    @TestVisible
    private static BWP_Payment_Method__c constructStripePaymentMethod(BWP_Payment_Method__c srcSf, Customer.Source src, BreadwinnerUtil.AppConfig appConfig){
        if(srcSf.Id == null){
            srcSf.Created_Via__c = BreadwinnerUtil.getCreatedViaValue(appConfig.currentRunningClassContext);
        }

        srcSf.Processor_Id__c = src.id;
        srcSf.Processor_Type__c = appConfig.PaymentProcessorType;
        srcSf.Processor_Org_Id__c = appConfig.accountId;

        if (src.stripe_object == 'card') {
                srcSf.City__c = src.address_city;
                srcSf.Address_Country__c = src.address_country;
                srcSf.Address_Line1__c = src.address_line1;
                srcSf.Address_Line2__c = src.address_line2;
                srcSf.State__c = src.address_state;
                srcSf.Zip_Code__c = src.address_zip;
                srcSf.Card_Brand__c = src.brand;
                srcSf.Country__c = src.country;
                srcSf.Expiry_Month__c = String.Valueof(src.exp_month);
                srcSf.Expiry_Year__c = String.Valueof(src.exp_year);
                srcSf.Fingerprint__c = src.fingerprint;
                srcSf.Last_4_digits__c = src.last4;
                srcSf.Name_On_Card__c = src.name;
                srcSf.Type__c = ProcessorUtil.PM_CARD;
        } else if (src.stripe_object == 'source' && src.stripe_type == 'card') {
            if (src.amount != null) {
                srcSf.Amount__c = BreadwinnerUtil.zeroDecimalCurrencies.contains((src.stripe_currency).toUpperCase()) ? Decimal.valueOf(src.amount) : Decimal.valueOf(src.amount) * 0.01;
            }
            srcSf.Card_Brand__c = src.card.brand;
            srcSf.Country__c = src.card.country;
            srcSf.Expiry_Month__c = String.valueOf(src.card.exp_month);
            srcSf.Expiry_Year__c = String.valueOf(src.card.exp_year);
            srcSf.Fingerprint__c = src.card.fingerprint;
            srcSf.Last_4_digits__c = String.valueOf(src.card.last4);
            srcSf.Name_On_Card__c = src.card.name;
            srcSf.Client_Secret__c = src.client_secret;
            srcSf.Currency__c = src.stripe_currency;
            srcSf.Livemode__c = src.livemode;

            if (src.status != null) {
                srcSf.Card_Status__c = src.status.capitalize();
            }
            srcSf.Type__c = ProcessorUtil.PM_CARD;

        } else if (src.stripe_object == 'source' && src.stripe_type == 'ach_credit_transfer') {

            srcSf.Account_Number__c = src.ach_credit_transfer.account_number;
            srcSf.Bank_Name__c = src.ach_credit_transfer.bank_name;
            srcSf.Fingerprint__c = src.ach_credit_transfer.fingerprint;
            srcSf.SWIFT_Code__c = src.ach_credit_transfer.swift_code;
            srcSf.Routing_Number__c = src.ach_credit_transfer.routing_number;

            if (src.amount != null) {
                srcSf.Amount__c = BreadwinnerUtil.zeroDecimalCurrencies.contains((src.stripe_currency).toUpperCase()) ? Decimal.valueOf(src.amount) : Decimal.valueOf(src.amount) * 0.01;
            }
            srcSf.Client_Secret__c = src.client_secret;
            srcSf.Currency__c = src.stripe_currency;
            srcSf.Livemode__c = src.livemode;

            if (src.status != null) {
                srcSf.Card_Status__c = src.status.capitalize();
            }
            srcSf.Type__c = ProcessorUtil.PM_ACH_CREDIT;

        } else if (src.stripe_object == 'bank_account') {

            srcSf.Bank_Account_Holder_Name__c = src.account_holder_name;
            srcSf.Bank_Name__c = src.bank_name;
            srcSf.Country__c = src.country;
            srcSf.Currency__c = src.stripe_currency;
            srcSf.Fingerprint__c = src.fingerprint;
            srcSf.Last_4_digits__c = src.last4;
            srcSf.Routing_Number__c = src.routing_number;
            if (src.status != null) {
                srcSf.Card_Status__c = src.status.capitalize();
            }
            srcSf.Type__c = ProcessorUtil.PM_BANK;
        }
        return srcSf;
    }

    // This method is used to convert the Stripe Payment wrapper to Stripe Payment record.
    private static BWP_Transaction__c constructStripeTransaction(BWP_Transaction__c transactionSf, Charge.StripeCharge pw, BreadwinnerUtil.AppConfig appConfig){
        if(transactionSf.Id == null){
            transactionSf.Created_Via__c = BreadwinnerUtil.getCreatedViaValue(appConfig.currentRunningClassContext);
        }

        transactionSf.Processor_Id__c = pw.id;
        transactionSf.Amount__c = BreadwinnerUtil.zeroDecimalCurrencies.contains(pw.stripe_currency.toUpperCase()) ? pw.amount : (pw.amount)/100;
        if (pw.application_fee_amount != null) {
            transactionSf.Application_Fee__c = BreadwinnerUtil.zeroDecimalCurrencies.contains(pw.stripe_currency.toUpperCase()) ? (pw.application_fee_amount) : (pw.application_fee_amount)/100;
        }
        if(pw.created != null)
            transactionSf.Created_Date_in_Processor__c = DateTime.newInstance((long)(pw.created) * 1000);
        if(pw.amount_refunded != null)
            transactionSf.Amount_Refunded__c = BreadwinnerUtil.zeroDecimalCurrencies.contains(pw.stripe_currency.toUpperCase()) ? (pw.amount_refunded) : (pw.amount_refunded)/100;
        transactionSf.Currency__c = (pw.stripe_currency).toUpperCase();
        transactionSf.Description__c = pw.description;
        transactionSf.Receipt_URL__c = pw.receipt_url;
        transactionSf.Receipt_Number__c = pw.receipt_number;
        if(pw.captured != null)
            transactionSf.Captured__c = pw.captured;
        if (String.isNotBlank(pw.status)) {
            transactionSf.Status__c = (pw.status == 'succeeded' ? ProcessorUtil.CHARGE_SUCCEEDED : (pw.status == 'failed' ? ProcessorUtil.CHARGE_FAILED : ProcessorUtil.CHARGE_PENDING));
        }
        transactionSf.Receipt_Email__c = pw.receipt_email;

        if(pw.billing_details != null && pw.billing_details.address != null) {
            transactionSf.Billing_Street_Address_1__c = pw.billing_details.address.line1;
            transactionSf.Billing_Street_Address_2__c = pw.billing_details.address.line2;
            transactionSf.Billing_City__c = pw.billing_details.address.city;
            transactionSf.Billing_State__c = pw.billing_details.address.state;
            transactionSf.Billing_Country__c = pw.billing_details.address.country;
            transactionSf.Billing_Postal_Code__c = pw.billing_details.address.postal_code;
        }
        transactionSf.Processor_Customer_Id__c = pw.customer;
        transactionSf.Processor_Type__c = appConfig.PaymentProcessorType;
        transactionSf.Processor_Org_Id__c = appConfig.accountId;

        return transactionSf;
    }

    private static Map<String, Object> excludeCustomers(Map<String, Object> processorToCustomerMap, BreadwinnerUtil.AppConfig appConfig){
        Map<String, Object> returnProcessorToCustomerMap = new Map<String, Object>();
        String customerSyncConfigValue = '';
        customerSyncConfigValue = String.isNotBlank(appConfig.customerSyncConfig) ? appConfig.customerSyncConfig : 'NONAME_AND_NOEMAIL';

        Map<String, Customer.StripeCustomer> stripeIdCustomerMap = (Map<String, Customer.StripeCustomer>) processorToCustomerMap.get(ProcessorUtil.PAT_STRIPE);
        // Excluding Stripe Customers based on configuration values from Breadwinner Payments page
        if(!stripeIdCustomerMap.isEmpty()){
            for(String contactId : stripeIdCustomerMap.keySet()){
                Customer.StripeCustomer sc = stripeIdCustomerMap.get(contactId);
                Boolean excludeCustomer = false;
                if(customerSyncConfigValue.contains('NONAME_AND_NOEMAIL') && String.isBlank(sc.name) && String.isBlank(sc.email)){
                    excludeCustomer = true;
                }
                else if(customerSyncConfigValue.contains('NO_NAME') && String.isBlank(sc.name)){
                    excludeCustomer = true;
                }
                else if(customerSyncConfigValue.contains('NO_EMAIL') && String.isBlank(sc.email)){
                    excludeCustomer = true;
                }
                if(excludeCustomer){
                    stripeIdCustomerMap.remove(contactId);
                }
            }
        }
        if(!stripeIdCustomerMap.isEmpty()){
            returnprocessorToCustomerMap.put(ProcessorUtil.PAT_STRIPE, stripeIdCustomerMap);
        }
        return returnprocessorToCustomerMap;
    }

    private static String getUrlBody(Customer.StripeCustomer stripeCustomer, Boolean updatingCustomer) {
        String reqBody = '';
		if (stripeCustomer.name != null) {
            reqBody += '&name=' + getURLEncodeData(stripeCustomer.name); 
        }
        if (stripeCustomer.balance != null) {
            reqBody += '&balance=' + getURLEncodeData(String.valueOf(stripeCustomer.balance)); //An integer amount in cents that represents the customer’s current balance, which affect the customer’s future invoices. A negative amount represents a credit that decreases the amount due on an invoice; a positive amount increases the amount due on an invoice.
        }
        if (stripeCustomer.description != null) {
            reqBody += '&description=' + getURLEncodeData(stripeCustomer.description); //An arbitrary string that you can attach to a customer object. It is displayed alongside the customer in the dashboard. This will be unset if you POST an empty value.
        }
        if (stripeCustomer.email != null) {
            reqBody += '&email=' + getURLEncodeData(stripeCustomer.email); //Customer’s email address. It’s displayed alongside the customer in your dashboard and can be useful for searching and tracking. This may be up to 512 characters. This will be unset if you POST an empty value.
        }
        if (stripeCustomer.invoice_prefix != null) {
            reqBody += '&invoice_prefix=' + getURLEncodeData(stripeCustomer.invoice_prefix); //The prefix for the customer used to generate unique invoice numbers. Must be 3–12 uppercase letters or numbers.
        }
        if (stripeCustomer.phone != null) {
            reqBody += '&phone=' + getURLEncodeData(stripeCustomer.phone); //The customer’s phone number. This will be unset if you POST an empty value.
        }

        //preferred_locales
        if (stripeCustomer.preferred_locales != null) {
            reqBody += '&preferred_locales[0]=' + getURLEncodeData(stripeCustomer.preferred_locales[0]);
        }
        //Billing Address - The customer’s address.
        if (stripeCustomer.address != null) {
            if (stripeCustomer.address.line1 != null) {
                reqBody += '&address[line1]=' + getURLEncodeData(stripeCustomer.address.line1); //REQUIRED
            }
            if (stripeCustomer.address.line2 != null) {
                reqBody += '&address[line2]=' + getURLEncodeData(stripeCustomer.address.line2);
            }
            if (stripeCustomer.address.city != null) {
                reqBody += '&address[city]=' + getURLEncodeData(stripeCustomer.address.city);
            }
            if (stripeCustomer.address.state != null) {
                reqBody += '&address[state]=' + getURLEncodeData(stripeCustomer.address.state);
            }
            if (stripeCustomer.address.country != null) {
                reqBody += '&address[country]=' + getURLEncodeData(stripeCustomer.address.country);
            }
            if (stripeCustomer.address.postal_code != null) {
                reqBody += '&address[postal_code]=' + getURLEncodeData(stripeCustomer.address.postal_code);
            }
        }

        //Shipping Address. The customer’s shipping information. Appears on invoices emailed to this customer.
        if (stripeCustomer.shipping != null) {
            if (stripeCustomer.shipping.name != null) {
                reqBody += '&shipping[name]=' + getURLEncodeData(stripeCustomer.shipping.name); //REQUIRED
            }
            if (stripeCustomer.shipping.phone != null) {
                reqBody += '&shipping[phone]=' + getURLEncodeData(stripeCustomer.shipping.phone);
            }
            if (stripeCustomer.shipping.address != null) { //REQUIRED
                if (stripeCustomer.shipping.address.line1 != null) {
                    reqBody += '&shipping[address[line1]]=' + getURLEncodeData(stripeCustomer.shipping.address.line1); //REQUIRED
                }
                if (stripeCustomer.shipping.address.line2 != null) {
                    reqBody += '&shipping[address[line2]]=' + getURLEncodeData(stripeCustomer.shipping.address.line2);
                }
                if (stripeCustomer.shipping.address.city != null) {
                    reqBody += '&shipping[address[city]]=' + getURLEncodeData(stripeCustomer.shipping.address.city);
                }
                if (stripeCustomer.shipping.address.state != null) {
                    reqBody += '&shipping[address[state]]=' + getURLEncodeData(stripeCustomer.shipping.address.state);
                }
                if (stripeCustomer.shipping.address.country != null) {
                    reqBody += '&shipping[address[country]]=' + getURLEncodeData(stripeCustomer.shipping.address.country);
                }
                if (stripeCustomer.shipping.address.postal_code != null) {
                    reqBody += '&shipping[address[postal_code]]=' + getURLEncodeData(stripeCustomer.shipping.address.postal_code);
                }
            }
        }

        //Tax data. The customer’s tax IDs.
        if (stripeCustomer.tax_info != null && !updatingCustomer) {
            if (stripeCustomer.tax_info.stripe_type != null) {
                reqBody += '&tax_id_data[0][type]=' + getURLEncodeData(stripeCustomer.tax_info.stripe_type); //REQUIRED. Type of the tax ID, one of au_abn, eu_vat, in_gst, no_vat, or nz_gst
            }
            if (stripeCustomer.tax_info.value != null) {
                reqBody += '&tax_id_data[0][value]=' + getURLEncodeData(stripeCustomer.tax_info.value) + ']'; //REQUIRED.
            }
        }

        if (stripeCustomer.tax_exempt != null) {
            reqBody += '&tax_exempt=' + getURLEncodeData(stripeCustomer.tax_exempt); //The customer’s tax exemption. One of 'none', 'exempt', or 'reverse'.
        }

        if (stripeCustomer.source != null) {
            reqBody += '&source=' + getURLEncodeData(stripeCustomer.source);
        }

        return reqBody;
    }

    private static String getURLEncodeData(String data) {
        return EncodingUtil.urlEncode(data, 'UTF-8');
    }

    // Replacing Stripe words in JSON response
    public static String replaceStripeWords(String str) {
        return str.replaceAll('"object"', '"stripe_object"').
            replaceAll('"currency"', '"stripe_currency"').
            replaceAll('"type"', '"stripe_type"').
            replaceAll('"limit"', '"stripe_limit"');
    }


    public static String formatLanguage(String language){
       
        Map<String, String> abbreviationMap = new Map<String,String>{ 'en' => 'English', 'english' => 'English',
             														  'ar' => 'Arabic', 'arabic' => 'Arabic', 
                                                                      'da' => 'Danish', 'danish' => 'Danish', 
                                                                      'nl' => 'Dutch', 'dutch' => 'Dutch', 
                                                                      'fi' => 'Finnish', 'finnish' => 'Finnish', 
                                                                      'fr' => 'French', 'french' => 'French',
                                                                      'ge' => 'German', 'german' => 'German', 
                                                                      'he' => 'Hebrew', 'hebrew' => 'Hebrew', 
                                                                      'it' => 'Italian', 'italian' => 'Italian', 
                                                                      'ja' => 'Japanese', 'japanese' => 'Japanese',
                                                                      'no' => 'Norwegian', 'norwegian' => 'Norwegian', 
                                                                      'es' => 'Spanish', 'spanish' => 'Spanish', 
                                                                      'sv' => 'Swedish', 'swedish' => 'Swedish' };
                    
       String formattedLanguage = abbreviationMap.get(language.toLowerCase());
       return formattedLanguage == null ? '' : formattedLanguage;
    }
    /**
     *  Builds URL to perform authorization with Stripe in live mode. Live credentials will be used.
     *
     *  @return String
     */
    @namespaceAccessible
    public static String getAuthUrl(){
        String sfMode = BreadwinnerUtil.isLightning() ? 'lightning' : 'classic';
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        String stateValue = '{"SFMode":"' + sfMode +'","ProMode":"live","ProType":"Stripe","Callback":"' + sfdcBaseURL + '/apex/' + BreadwinnerUtil.namespaceApi + 'BreadwinnerPayments"}';
        String redirectURL = ProcessorUtil.REDIRECT_URL;
        String clientId = getClientId('live');
        return stripeAuthorizationUrl + '?response_type=code&client_id=' + EncodingUtil.urlEncode((String.isNotBlank(clientId) ? clientId : ''),'UTF-8') + '&always_prompt=true&scope=read_write&state='+stateValue+'&redirect_uri='+redirectURL;
    }

    /**
     *  Builds URL to perform authorization with Stripe in test mode. Test credentials will be used.
     *
     *  @return String
     */
    @namespaceAccessible
    public static String  getTestAuthUrl(){
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        String redirectURL = ProcessorUtil.REDIRECT_URL;
        String sfMode = BreadwinnerUtil.isLightning() ? 'lightning' : 'classic';//scope=read_only
        String stateValue = '{"SFMode":"' + sfMode + '","ProMode":"test","ProType":"Stripe","Callback":"' + sfdcBaseURL + '/apex/' + BreadwinnerUtil.namespaceApi + 'BreadwinnerPayments"}';
        String clientId = getClientId('test');
        return stripeAuthorizationUrl + '?response_type=code&client_id=' + EncodingUtil.urlEncode((String.isNotBlank(clientId) ? clientId : ''),'UTF-8') + '&always_prompt=true&scope=read_write&state='+stateValue+'&redirect_uri='+redirectURL;
    }

    //To save Connected app info(works in both cases connect and reconnect)
    @namespaceAccessible
    public static BWP_Processor_Config__c saveAppCredentials(String connectionMode, BWP_Processor_Config__c config) {
        String code = ApexPages.currentPage().getParameters().get('code');
        String accountName = '';
        String accountCurrency = '';
        if(String.isNotBlank(code)){
            code = String.escapeSingleQuotes(code);
        }

        String endPoint = stripeTokenUrl;
        endPoint +=  '?code=' + code + '&grant_type=authorization_code';

        endPoint = endPoint + '&client_secret=' +(getClientSecret(connectionMode));
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod('POST');

        HttpResponse res = new HttpResponse();
        res = new HTTP().send(req);

        StripeTokenInfo tokenResponse = new StripeTokenInfo();
        System.debug('=='+res.getBody());
        if (res.getStatusCode() == 200) {

            //deserializing the response
            tokenResponse = (StripeTokenInfo)JSON.deserialize(res.getBody(), StripeTokenInfo.class);

            //getting customer info
            if (tokenResponse.stripe_user_id != null) {
                Http accountCall = new Http();

                String endPointAccountDetails = stripeBaseUrlv1 + '/accounts/' + tokenResponse.stripe_user_id;
                HttpRequest accReq = new HttpRequest();
                accReq.setEndpoint(endPointAccountDetails);
                accReq.setHeader('Authorization', 'Bearer ' + tokenResponse.access_token);
                accReq.setMethod('GET');

                HttpResponse accRes = new HttpResponse();
                accRes = accountCall.send(accReq);
                
                StripeAccountInfo accInfo = (StripeAccountInfo) JSON.deserialize(accRes.getbody(), StripeAccountInfo.class);
                accountName =  accInfo.settings.dashboard.display_name;
                accountCurrency = accInfo.default_currency;
            }
            config = BreadwinnerUtil.getProcessorConfig(tokenResponse.stripe_user_id);
            System.debug('config--------------'+config);
            config.Account_Name__c = String.isNotBlank(accountName) ? accountName : '';
            config.Default_Currency__c = String.isNotBlank(accountCurrency) ? accountCurrency : '';
            if (tokenResponse.access_token != null) {
                config.Access_Token__c = tokenResponse.access_token;
                config.Live_Mode__c = tokenResponse.livemode;
                config.Refresh_Token__c = tokenResponse.refresh_token;
                config.Provider_ID__c = tokenResponse.stripe_user_id;
                config.Card_Creation_Key__c = tokenResponse.stripe_publishable_key; // used for card creation
                config.Scope__c = tokenResponse.scope;
                config.Name = tokenResponse.stripe_user_id;
                config.Need_To_Reconnect__c = false;
                config.Payment_Processor_Type__c = ProcessorUtil.PAT_STRIPE;
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
            throw new ProcessorUtil.ConnectionException('Error occurred while connecting with Stripe.');
        }
        return config;
    }

    private static ProcessorUtil.Error formatError(Map<String, Object> error, String statusCode){
        String errCode = error.get('code') != null ? error.get('code').toString() : statusCode;
        String errMess = error.get('message') != null ? error.get('message').toString() : '';
        return new ProcessorUtil.Error(errCode,errMess);
    }

    private class PaymentIntent {
        public String id;
        public String stripe_object;
        public ChargesList charges;
    }

    private class ChargesList {
        public List<Charge.StripeCharge> data;
    }

    // Filter options when fetching stripe customers
    public class FetchRequest {
        public String customerId;
        public String createdGreaterThan;
        public String createdGreaterThanOrEqual;
        public String createdLessThan;
        public String createdLessThanOrEqual;
        public String ending_before;
        public String email;
        public String stripe_limit;
        public String starting_after;
    }

    public class FetchResponse {
        public String last_record_id;
        public boolean requireNextRun;
        public Map<String, Customer.StripeCustomer> customerMapById;
        public Map<String, Charge.StripeCharge> paymentMapById;
    }

    private class CustomerResponse {
        public Boolean has_more;
        public List<Customer.StripeCustomer> data;
    }

    private class ChargesResponse {
        public Boolean has_more;
        public List <Charge.StripeCharge> data;
    }

    //Stripe Account info wrapper
    private class StripeTokenInfo {
        public String access_token;
        public Boolean livemode;
        public String refresh_token;
        public String token_type;
        public String stripe_publishable_key;
        public String stripe_user_id;
        public String scope;
    }

    private class StripeAccountInfo {
        private String id;
        private String business_name;
        private String display_name;
        private String default_currency;
        private AccountSettings settings;
    }
    private class AccountSettings {
        private Dashboard dashboard;
    }

    private class Dashboard {
        private String display_name;
    }

}