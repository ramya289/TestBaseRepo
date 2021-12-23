global with sharing class BreadwinnerPaymentsAPI {

    public static List<ProcessorUtil.Error> apiErrors = new List<ProcessorUtil.Error>();

    private static Set<String> apiVersions = new Set<String>{'1.0'};
    //Exception classes
    virtual class APIException extends Exception {}

    class INVALID_SUBSCRIPTION_Exception extends APIException {}
    class READ_ONLY_MODE_ENABLED_Exception extends APIException {}
    class CONNECTION_NOT_FOUND_Exception extends APIException {}

    class INVALID_REQUEST_Exception extends APIException {}
    class INVALID_REQUEST_JSON_Exception extends APIException {}
    class INVALID_ACTION_Exception extends APIException {}
    class INVALID_VERSION_Exception extends APIException {}
    class INVALID_PROCESSOR_Exception extends APIException {}

    public class RequestObject {
        public Map<String, Object> options = new Map<String, Object>();
        public String requestJSON;
    }

    global static Map<String,Object> call(Map<String,Object> request) {

        Map<String,Object> response = new Map<String,Object>();

        try {
            Map<String, Object> parsedRequest = new Map<String, Object>();
            for (String key : request.keySet()) {
                parsedRequest.put(key.toLowerCase(), request.get(key));
            }

            validateRequest(parsedRequest);

            String processorAccountId = String.valueOf(parsedRequest.get(ProcessorUtil.API_PROCESSOR_ID.toLowerCase()));
            String action = String.valueOf(parsedRequest.get(ProcessorUtil.API_ACTION.toLowerCase()));
            String requestJSON = String.valueOf(parsedRequest.get(ProcessorUtil.API_REQUEST_JSON.toLowerCase()));
            String timeout = String.valueOf(parsedRequest.get(ProcessorUtil.API_TIMEOUT.toLowerCase()));
            String version = String.valueOf(parsedRequest.get(ProcessorUtil.API_VERSION.toLowerCase()));

            Processor pi = getProcessorById(processorAccountId);

            ProcessorUtil.ResponseObject responseObj = new ProcessorUtil.ResponseObject();

            
            validateBreadwinnerConfig(action);
            
            if (action == ProcessorUtil.ACT_CREATE_CUSTOMER) {
                responseObj = pi.createCustomer(requestJSON);
            } else if (action == ProcessorUtil.ACT_CREATE_BANK_TOKEN) {
                responseObj = pi.createBankToken(requestJSON);
            } else if (action == ProcessorUtil.ACT_CREATE_CARD_TOKEN) {
                responseObj = pi.createCardToken(requestJSON);
            } else if (action == ProcessorUtil.ACT_UPDATE_CUSTOMER) {
                responseObj = pi.updateCustomer(requestJSON);
            } else if (action == ProcessorUtil.ACT_CHARGE_PROCESSOR) {
                responseObj = pi.chargeProcessor(requestJSON, timeout);
            } else if (action == ProcessorUtil.ACT_FETCH_CUSTOMERS_ALL) {
                responseObj = pi.fetchCustomers(requestJSON);
            } else if (action == ProcessorUtil.ACT_FETCH_TRANSACTIONS_ALL) {
                responseObj = pi.fetchTransactions(requestJSON);
            } else if (action == ProcessorUtil.ACT_VERIFY_BANKACCOUNT) {
                responseObj = pi.verifyBankAccount(requestJSON);
            } else if (action == ProcessorUtil.ACT_CREATE_CHECKOUT){
                responseObj = pi.createCheckoutURL(requestJSON);
            }
            else {
                throw new INVALID_ACTION_Exception('"' + action + '" is not valid.');
            }

            response.put(ProcessorUtil.API_ACTION, action);
            response.put(ProcessorUtil.API_VERSION, version);
            response.put(ProcessorUtil.RESP_STATUS, responseObj.status);
            response.put(ProcessorUtil.RESP_VAL_REQ, true);
            response.put(ProcessorUtil.RESP_JSON, responseObj.responseJSON);
            // Sending only requested data to the end user.
            if(String.isNotBlank(responseObj.checkoutResponseJSON)) {
                response.put(ProcessorUtil.CHECKOUT_RESP, responseObj.checkoutResponseJSON);
            }
            if(responseObj.customerList != null) {
                response.put(ProcessorUtil.CUST_RESP, responseObj.customerList);
            }
            if(responseObj.paymentMethodList != null) {
                response.put(ProcessorUtil.PAYMETHOD_RESP, responseObj.paymentMethodList);
            }
            if(responseObj.transactionList != null) {
                response.put(ProcessorUtil.PAYMENT_RESP, responseObj.transactionList);
            }
            if (responseObj.errors?.size() > 0) {
                response.put(ProcessorUtil.RESP_PROC_ERRORS, responseObj.errors);
            }

        }   catch(Exception ex){
            apiErrors.add(handleErrors(ex));
            response.put(ProcessorUtil.RESP_API_ERRORS, apiErrors);
            response.put(ProcessorUtil.RESP_VAL_REQ, false);
            APICallHandler.userInteractionLogPush(true, 'Global API', 'ERROR', 'An Exception occurred : ' + ex + '  Stack Trace: '+ex.getStackTraceString());
        }

        response.put('timestamp',System.now().getTime());

        System.debug('response: ' + response);

        return response;
    }

    private static Processor getProcessorById(String processorAccountId){
        BWP_Processor_Config__c appC = BreadwinnerUtil.getProcessorConfig(processorAccountId);
        if (appC == null){
            throw new INVALID_PROCESSOR_Exception('Invalid Processor Account Id.');
        }

        Processor pi;
        if (appC.Payment_Processor_Type__c == ProcessorUtil.PAT_BRAINTREE) {
            pi = new Processor_Braintree(processorAccountId);
        } else if (appC.Payment_Processor_Type__c == ProcessorUtil.PAT_SQUARE){
            pi = new Processor_Square(processorAccountId);
        } else if (appC.Payment_Processor_Type__c == ProcessorUtil.PAT_STRIPE){
            pi = new Processor_Stripe(processorAccountId);
        } else if (appC.Payment_Processor_Type__c == ProcessorUtil.PAT_AUTHORIZE_NET){
            pi = new Processor_Authorize_Net(processorAccountId);
        }/*else if (appC.Payment_Processor_Type__c == ProcessorUtil.PAT_PAYPAL){
          pi = new Processor_PayPal(processorAccountId);
        } */else {
            throw new INVALID_PROCESSOR_Exception('Unsupported payment processor: "' + appC.Payment_Processor_Type__c + '".');
        }
        return pi;

    }


    /**
     * Make sure Breadwinner is configured correctly before proceeding.
     * Throw an exception if configuration is not correct
     */
    @TestVisible
    private static void validateBreadwinnerConfig(String action){

        if (!BreadwinnerUtil.isBreadwinnerActive()) {
            throw new INVALID_SUBSCRIPTION_Exception();
        }
        if (BreadwinnerUtil.isReadOnlyModeEnabled()){
        	if(action != ProcessorUtil.ACT_FETCH_CUSTOMERS_ALL && action != ProcessorUtil.ACT_FETCH_TRANSACTIONS_ALL){
                throw new READ_ONLY_MODE_ENABLED_Exception();
            }
        }
        if (BreadwinnerUtil.processorConfigList.size() == 0){
            throw new CONNECTION_NOT_FOUND_Exception();
        }
    }

    /**
     * Make sure the required request parameters are passed in.
     * Throw an exception if that is not the case
     */
    private static void validateRequest(Map<String,Object> request){
        if (request.isEmpty()){
           throw new INVALID_REQUEST_Exception();
        }

        if(request.get(ProcessorUtil.API_PROCESSOR_ID.toLowerCase()) == null){
            throw new INVALID_PROCESSOR_Exception();
        }

        if(request.get(ProcessorUtil.API_ACTION.toLowerCase()) == null){
            throw new INVALID_ACTION_Exception();
        }

        String requestJSON = String.valueOf(request.get(ProcessorUtil.API_REQUEST_JSON.toLowerCase()));
        if(String.isBlank(requestJSON)) {
            throw new INVALID_REQUEST_JSON_Exception();
        }

        String version = String.valueOf(request.get(ProcessorUtil.API_VERSION.toLowerCase()));
        if (String.isBlank(version)|| !apiVersions.contains(version)) {
            throw new INVALID_VERSION_Exception(version);
        }
    }

    private static ProcessorUtil.Error handleErrors(Exception e){
        ProcessorUtil.Error error = new ProcessorUtil.Error();
        String errorCode = e.getTypeName();
        String msg = e.getMessage();
        System.debug('msg: '+msg);

        List<String> errorCodeSplitList =  errorCode.substringBefore('_Exception').split('\\.');
        errorCode = (!errorCodeSplitList.isEmpty() && errorCodeSplitList.size()>1)? errorCodeSplitList[errorCodeSplitList.size()-1] : errorCode;
        System.debug('errorCode: '+errorCode);
        error.code = errorCode;

        switch on errorCode {

            when 'INVALID_REQUEST' {
                error.message = 'Request is Invalid.';
                error.detail = 'Request is Invalid. Please refer the Breadwinner API Docs.';
            }
            when 'CONNECTION_NOT_FOUND' {
                error.message = 'Breadwinner is not connected.';
                error.detail = 'Please connect Breadwinner to your Payment Processor.';
            }
            when 'READ_ONLY_MODE_ENABLED' {
                error.message = 'Breadwinner Read-Only mode is Enabled.';
                error.detail = 'You can not send a request to Breadwinner Payments when Read-Only mode is enabled. Switch to Active mode.';
            }
            when 'INVALID_SUBSCRIPTION' {
                error.message = 'Invalid Subscription.';
                error.detail = 'You don\'t have valid Subscription to Breadwinner. Please contact Breadwinner Support Team.';
            }
            when 'INVALID_ACTION' {
                error.message = 'Invalid action. Supplied value is: '+ msg+'.';
                error.detail = 'The action, '+ msg +', is not supported by Breadwinner. Please refer Breadwinner API Docs for supported actions.';
            }
            when 'INVALID_VERSION' {
                error.message = 'Invalid version. Supplied value is: '+ msg+'.';
                error.detail = 'The version, '+ msg +', is not supported by Breadwinner. Please refer Breadwinner API Docs for supported versions.';
            }
            when 'INVALID_REQUEST_JSON' {
                error.message = msg.capitalize()+'s requestJSON is NULL or Empty.';
                error.detail = 'Supplied '+ msg.capitalize()+'s requestJSON is NULL or Empty. Please refer the Breadwinner API Docs.';
            }
            when 'JSONException' {
                error.code = 'INVALID_REQUEST_JSON';
                error.message = 'Invalid requestJSON.';
                error.detail = 'Request JSON(requestJSON) is not formatted properly. Please refer the Breadwinner API Docs.';
            }
            when 'INVALID_PROCESSOR' {
                error.message = 'Invalid processor id. ' + msg;
                error.detail = 'ProcessorId is not valid. Please refer the Breadwinner API Docs.';
            }
            when else{
                error.code ='UNEXPECTED';
                error.message = 'Something went wrong in Breadwinner API.';
                error.detail = 'Unexpected error occured in Breadwinner API. Please contact the Breadwinner Support Team. \nThe Actual Error we found is: '+e;
                APICallHandler.userInteractionLogPush(true, 'Global API', APICallHandler.ED_ERROR, 'An Exception occurred : '+e+'  Stack Trace: '+e.getStackTraceString());
            }
        }

        return error;
    }

    public class Error{
        public String Message                       {get; set;}
        public String Detail                        {get; set;}
        public String Code                          {get; set;}
    }
}