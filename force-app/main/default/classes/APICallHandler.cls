/*
* Description - Class to handle all API requests to stripe.
* All callouts are being sent from this class only except disconnection, token generation in completeAuth controller.
*/
@namespaceAccessible
public with sharing class APICallHandler {

    private static Selector_User userSelector = new Selector_User();

    //event detail types for logging messages to POW
    public static final String ED_ERROR = 'ERROR';

    public static HttpResponse getList(BreadwinnerUtil.AppConfig appConfig, String method, String endPoint, String body) { 
        HttpRequest req = new HttpRequest();
        req = authorizeRequest(req, appConfig);
        req.setMethod(method);
        req.setEndpoint(endPoint);

        if (appConfig.PaymentProcessorType == ProcessorUtil.PAT_BRAINTREE){
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Braintree-Version', '2019-01-01');
            req.setBody(body);
        } else if(appConfig.PaymentProcessorType == ProcessorUtil.PAT_SQUARE){
            req.setHeader('Content-Type', 'application/json');
            if(String.isNotBlank(body)) {
                req.setBody(body);
            }
        } else if(appConfig.PaymentProcessorType == ProcessorUtil.PAT_PAYPAL){
            req.setHeader('Content-Type', 'application/json');
        }

        HttpResponse res = new Http().send(req);
        System.debug('response----'+res.getBody());
        return res;
    }
    
    public static HttpResponse post(BreadwinnerUtil.AppConfig appConfig, String method, String endPoint, String bodyUrlEncoded) {
        return post(appConfig, method, endPoint, bodyUrlEncoded, null);
    }

    public static HttpResponse post(BreadwinnerUtil.AppConfig appConfig, String method, String endPoint, String bodyUrlEncoded, String timeout) {

        System.debug('Body is--> '+ bodyUrlEncoded);
        HttpRequest req = new HttpRequest();
        req = authorizeRequest(req, appConfig);
        req.setMethod(method);
        if (appConfig.PaymentProcessorType == ProcessorUtil.PAT_SQUARE) {
            req.setHeader('Content-Type', 'application/json');
        }
        req.setEndpoint(endPoint);
        if(String.isNotBlank(bodyUrlEncoded)) {
            req.setBody(bodyUrlEncoded);
        }

        if (String.isNotBlank(timeout)){
            req.setTimeout(Integer.valueOf(timeout));
        }

        HttpResponse res = new Http().send(req);
        return res;
    }

    // This method is intended to add more parameters to HTTP request.
    public static HttpRequest authorizeRequest(HttpRequest req, BreadwinnerUtil.AppConfig ac) {
        if(!Test.isRunningTest())
        ac = CryptoUtil.decryptSecrets(ac);
        String rawAccessToken = ac.accessToken;
        if (ac.PaymentProcessorType == ProcessorUtil.PAT_STRIPE) {
            req.setHeader('Authorization', 'Bearer ' + rawAccessToken);
        } else if (ac.PaymentProcessorType == ProcessorUtil.PAT_BRAINTREE) {
            req.setHeader('Authorization', 'Basic ' + rawAccessToken);
        } else if (ac.PaymentProcessorType == ProcessorUtil.PAT_SQUARE) {
            req.setHeader('Authorization', 'Bearer ' + rawAccessToken);
        } /*else if (ac.PaymentProcessorType == ProcessorUtil.PAT_PAYPAL){
            req.setHeader('Authorization', 'Bearer '+ rawAccessToken);
        } else if (ac.PaymentProcessorType == ProcessorUtil.PAT_AUTHORIZE_NET){
            req.setHeader('Authorization', 'Bearer '+ rawAccessToken);
        }*/
        return req;
    }


    /* Push logs to POW*/
    @namespaceAccessible
    public static void userInteractionLogPush(Boolean isSynchronous, String eventType, String eventDetail, String additionalDetail){
        if(!Test.isRunningTest()) {
            if(isSynchronous) {
                synchronousLogPush(eventType, eventDetail, additionalDetail);
            } else {
                asynchronousLogPush(eventType, eventDetail, additionalDetail);
            }
        }
    }

    @future(callout = true)
    public static void asynchronousLogPush(String eventType, String eventDetail, String additionalDetail){
        synchronousLogPush(eventType, eventDetail, additionalDetail);
    }

    @TestVisible
    private static void synchronousLogPush(String eventType, String eventDetail, String additionalDetail){
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            String endPointBaseURL = BreadwinnerUtil.getSupportEndpointBaseURL();
            String packageVersion = BreadwinnerUtil.getBW_PackageVersion();//BreadwinnerUtil.getBW_PackageVersion();
            String orgType = isSandbox ? 'sandbox':'production';
            String body = '{"org_id":"' + UserInfo.getOrganizationId() + '",';
            body += '"company_name":"' + UserInfo.getOrganizationName() + '",';
            body += '"event_type":"' + eventType + '",';
            body += '"event_detail":"' + eventDetail + '",';
            body += '"first_name":"' + UserInfo.getFirstName() + '",';
            body += '"last_name":"' + UserInfo.getLastName() + '",';
            body += '"email":"' + UserInfo.getUserEmail() + '",';
            body += '"additional_detail":"' + additionalDetail.replaceAll('"','&quot').replaceAll('\n',' &nl ') + '",';
            body += '"org_type":"' + orgType + '",';
            body += '"package_version":"' + packageVersion + '",';
            body += '"is_human":"' + !(System.isBatch() || System.isScheduled() || System.isFuture()) + '",';
            body += '"sf_user_id" :"' + UserInfo.getUserId() + '",';
            body += '"sf_user_type" :"' + UserInfo.getUserType() + '",';
            body += '"app" : "Payments"}';

            request.setEndpoint(endPointBaseURL+'/api/v2/user_interaction_log');
            //request.setEndpoint('https://support-staging.breadwinnerhq.com/api/v2/user_interaction_log');
            request.setMethod('POST');
            request.setBody(body);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            authorize(request);
            System.debug('Request Body : ' + request.getBody());
            HttpResponse response = http.send(request);
            System.debug('response body '+response);
        }
        catch(exception e){
            System.debug('Exception e : ' + e.getMessage());
        }
    }
    public static void authorize(HttpRequest req){
        Breadwinner_Payments_Metadata__mdt auth = [SELECT MasterLabel, Key__c,DeveloperName FROM Breadwinner_Payments_Metadata__mdt WHERE DeveloperName = 'Breadwinner_Token' LIMIT 1];
        Blob b = EncodingUtil.base64Decode(EncodingUtil.base64Decode(auth.Key__c).toString());
        req.setHeader('Auth-Token', '' + EncodingUtil.convertFromHex(b.toString()).toString());
    }

    // This needs to be it's own private method because this class shouldn't call other classes
    private static Boolean isSandbox{
        get {
            if (isSandbox == null){
                isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            }
            return isSandbox;
        }
        set;
    }

    // Methods for SF Org Creation and Sync
    public static HttpResponse BreadwinnerORGCreation(Boolean isSynchronous) {
        if(!Test.isRunningTest()) {
            Id userId = UserInfo.getUserId();
            if (isSynchronous) {
                return createSFOrg(userId,false);
            } else {
                asyncCreateSFOrg(userId,false);
            }
        }
        return null;
    }

    @future(callout = true)
    public static void asyncCreateSFOrg (Id installingUserId, Boolean is_human_install) {
        createSFOrg(installingUserId, is_human_install);
    }
    
    // description:  send request to create record in sf org
    private static HttpResponse createSFOrg (Id installingUserId, Boolean is_human_install) {
        Http httpObj = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        String supportEndPointBaseURL = BreadwinnerUtil.getSupportEndpointBaseURL();
        
        DateTime date_of_installation = System.now();
        String org_id = UserInfo.getOrganizationId();
        String org_name = UserInfo.getOrganizationName();
        String first_name = '';
        String last_name = '';
        String user_email = '';
        if(installingUserId != NULL) {
            List<User> listUser = userSelector.selectById(new Set<String>{installingUserId});
            if(listUser.size() > 0) {
                first_name = listUser.get(0).FirstName;
                last_name = listUser.get(0).LastName;
                user_email = listUser.get(0).Email;
            }
        }
        if(String.isBlank(user_email)) {
            first_name = UserInfo.getFirstName();
            last_name = UserInfo.getLastName();
            user_email = UserInfo.getUserEmail();
        }
        Organization org = BreadwinnerUtil.orgInfo();
        String org_type = org.IsSandbox ? 'sandbox': 'production';
        String org_edition = org.OrganizationType;
        Boolean is_trial = org.TrialExpirationDate != NULL;
        String sf_org_type = org_type == 'sandbox' ? 'Sandbox' : ((String.isNotBlank(org_edition) && org_edition.containsIgnoreCase('Developer') ) ? 'Developer' : (is_trial ? 'Production-Trial':'Production'));
            
        Integer active_user_count;
        Integer active_platform_user_count;
        Integer active_salesforce_user_count;
        Integer installed_packages_number;
        try {
            active_user_count = userSelector.selectCount(true,4500);
            List<AggregateResult> userCountByLicenseName = [SELECT Profile.UserLicense.Name lName, COUNT(Id) c FROM User WHERE IsActive = TRUE WITH SECURITY_ENFORCED GROUP BY Profile.UserLicense.Name LIMIT 45000];
            for(AggregateResult ar : userCountByLicenseName){
                System.debug(ar.get('lName') +' count is ' + ar.get('c'));
                String lName = String.valueOf(ar.get('lName'));
                Integer count = Integer.valueOf(ar.get('c'));
                if(String.isNotBlank(lName) && lName.toLowerCase() =='salesforce') {
                    active_salesforce_user_count = count;
                }
                else if(String.isNotBlank(lName) && lName.toLowerCase() == 'salesforce platform') {
                    active_platform_user_count = count;
                }
            }
            installed_packages_number = [SELECT NamespacePrefix FROM PackageLicense GROUP BY NamespacePrefix].size() - 1;
        } catch(Exception e) {
            System.debug('BreadwinnerORGCreation ::: Exception: '+e+', Stack Trace: '+e.getStackTraceString());
        }
        
        String body = '';
        body = '{"orgID":"' + org_id + '",';
        body += '"dateOfInstallation":"' + date_of_installation.formatGMT('yyyy-MM-dd HH:mm:ss') + '",';
        body += '"org_type":"' + org_type + '",';
        body += '"first_name":"' + first_name + '",';
        body += '"last_name":"' + last_name + '",';
        body += '"userEmail":"' + user_email + '",';
        body += '"org_name":"' + org_name + '",';
        body += '"sf_org_type":"' + sf_org_type + '",';
        body += '"is_human_install":"' + is_human_install + '",';
        if(String.isNotBlank(org_edition)) body += '"org_edition":"' + org_edition + '",';
        body += '"is_trial":"' + is_trial + '",';
        if(active_user_count != null) body += '"active_total_users":"' + active_user_count + '",';
        if(active_platform_user_count != null) body += '"active_platform_users":"' + active_platform_user_count + '",';
        if(active_salesforce_user_count != null) body += '"active_salesforce_users":"' + active_salesforce_user_count + '",';
        if(active_salesforce_user_count != null) body += '"org_user_count":"' + active_salesforce_user_count + '",';
        if(installed_packages_number != null) body += '"installed_packages_number":"' + installed_packages_number + '",';
        body += '"app":"Payments"}';
        request.setEndpoint(supportEndPointBaseURL+'/api/v2/installed');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        authorize(request);
        request.setBody(body);
        System.debug('createSFOrg Request Body: '+request.getBody());
        if(!Test.isRunningTest()) response = httpObj.send(request);
        System.debug('createSFOrg Response: '+ response);
        return response;
    }

    public static AccountResponse SyncBreadwinnerSetting() {
        AccountResponse accountResponseObj = getSFOrgInfo();
        if(accountResponseObj != NULL) {
            updateBWCustomSettingRecord(accountResponseObj);
        }
        return accountResponseObj;
    }
    
    // description: invoke from scheduled job
    @future (callout=true)
    public static void asyncGetSFOrgInfo() {
        AccountResponse accountResponseObj = SyncBreadwinnerSetting();
        System.debug('AccountResponseObj: '+accountResponseObj);
    }
    
    public static AccountResponse getSFOrgInfo() {
        system.debug('get sf org info');
        AccountResponse accountResponseObj;
        String supportEndPointBaseURL = BreadwinnerUtil.getSupportEndpointBaseURL();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setTimeout(120000);
        authorize(request);
        String requestUrl = supportEndPointBaseURL+'/api/v2/subscriptionstatus/'+ UserInfo.getOrganizationId() + '/Payments';
        System.debug('requestUrl: '+requestUrl);
        request.setEndpoint(requestUrl);
        try {
            HttpResponse response;
           	response = http.send(request);
            if(Test.isRunningTest()) {
                response.setBody('{"version":"v2","result":{"account":{"status":"trial","expiration":"2021-12-11 06:20:19","billing_status":null,"active":"true","days_overdue":null,"free_plan":false,"plan_name":"Starter","plan_code":20,"override_plan_name":"Business","override_plan_code":91,"override_plan_expiration":"2021-12-01 23:59:59"}}}');
                response.setStatusCode(200);
            }
            System.debug('org Response :::------'+response.getBody());
            if(response != NULL && response.getStatusCode() == 200){
                System.debug('response: '+response.getBody());
                accountResponseObj = parseAccountResponse(response.getBody());
                System.debug('accountResponseObj: ' + accountResponseObj);
                return accountResponseObj;
            }
            else if(response != NULL && response.getStatusCode() == 404 && response.getBody() != NULL && response.getBody().containsIgnoreCase(UserInfo.getOrganizationId())) {
                system.debug('status----'+response);
                HttpResponse orgCreateResponse = BreadwinnerORGCreation(TRUE);
                if(orgCreateResponse != NULL && orgCreateResponse.getStatusCode() == 200){
                    accountResponseObj = SyncBreadwinnerSetting();
                }
                else System.debug('orgCreateResponse Response ::: '+orgCreateResponse);
            }
            else System.debug('getOrgValidity Response ::: '+response);
            if(Test.isRunningTest()) { Decimal d = 5/0; }
        }
        catch(Exception e) {
            System.debug('getOrgValidity ::: Exception: '+e+', Stack Trace: '+e.getStackTraceString());
            userInteractionLogPush(TRUE, 'org validity', 'ERROR', 'Exception from getSFOrgInfo: '+e+', Stack Trace: '+e.getStackTraceString());
        }
        return NULL;
    }
    
    public static AccountResponse parseAccountResponse(String responseBody) {
        AccountResponse accountResponseObj = new AccountResponse();
        try{
            JSONParser parser = JSON.createParser(responseBody);
            while(parser.nextToken() != null) {
                if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'account')) {
                    parser.nextToken();
                    if(parser.getCurrentToken() == JSONToken.START_OBJECT ){
                        accountResponseObj = (AccountResponse)parser.readValueAs(AccountResponse.class);
                    }
                }
            }
            if(Test.isRunningTest()) { Decimal d = 5/0; }
        }
        catch(Exception e){
            System.debug('parseAccountResponse ::: Exception: '+e+', Stack Trace: '+e.getStackTraceString());
            userInteractionLogPush(TRUE, 'org validity', 'ERROR', 'Exception while parsing: '+e+', Stack Trace: '+e.getStackTraceString());
        }
        return accountResponseObj;
    }
    
    // Description - Method to update the Breadwinner Custom Setting record
    public static void updateBWCustomSettingRecord(AccountResponse statusResponse) {
        Boolean isActive = statusResponse.active != 'false';
        DateTime expirationDateTime;
        DateTime Override_Plan_Expiration_DateTime;
        
        try {
            expirationDateTime = DateTime.valueOfGmt(statusResponse.expiration);
            if(String.isNotBlank(statusResponse.override_plan_expiration))
                Override_Plan_Expiration_DateTime = DateTime.valueOfGmt(statusResponse.override_plan_expiration);
        }
        catch(Exception e) {System.debug('Exception in parsing date value '+e); }
        
        userInteractionLogPush(TRUE, 'org validity', 'refresh', 'Active :'+isActive +'| '+expirationDateTime+'| '+ statusResponse.status);             
        
        Breadwinner_Settings__c bwSetting = BreadwinnerUtil.getBWSetting();
        try {
            bwSetting.Active__c = isActive;
            bwSetting.Date_of_Expiration__c = expirationDateTime;
            bwSetting.Plan_Name__c = statusResponse.plan_name;
            bwSetting.Plan_Code__c = statusResponse.plan_code;
            bwSetting.Override_Plan_Name__c = statusResponse.override_plan_name;
            bwSetting.Override_Plan_Code__c = statusResponse.override_plan_code;
            bwSetting.Override_Plan_Expiration_Date__c = Override_Plan_Expiration_DateTime;
            bwSetting.Status__c = statusResponse.status;
            if(String.isBlank(bwSetting.Support_URL__c)) bwSetting.Support_URL__c = BreadwinnerUtil.getSupportURL();
            if(String.isBlank(bwSetting.Salesforce_Org_Id__c)) bwSetting.Salesforce_Org_Id__c = UserInfo.getOrganizationId();
            SecurityUtil.dmlUpsert(bwSetting);
            if(Test.isRunningTest()) { Decimal d = 5/0; }
        }
        catch(Exception e){
            System.debug('updateBWCustomSettingRecord ::: Exception: '+e+', Stack Trace: '+e.getStackTraceString());
            userInteractionLogPush(TRUE, 'org validity', 'ERROR', 'Exception while upserting BW Setting: '+e+', Stack Trace: '+e.getStackTraceString());
        }
    }
    
    /*
    * Description :     This method is using to get AccessToken and Processor Account Details.
    *                   Calling this method when Connect/Reconnect clicked in Breadwinner tab.
    */
    public static HTTPResponse getProcessorConnectionInfo(String endPoint, String method, String accessToken, String reqBody) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod(method);
        if(String.isNotBlank(accessToken)){
            request.setHeader('Authorization', 'Bearer ' + accessToken);
        }
        request.setHeader('Content-Type', 'application/json');
        if(String.isNotBlank(reqBody)){
            request.setBody(reqBody);
        }
        HttpResponse response = http.send(request);
        return response;
    }
    // Subscriptions response wrapper
    public class AccountResponse{
        public String active                {get; set;}
        public String status                {get; set;}
        public String expiration            {get; set;}
        public String plan_code             {get; set;}
        public String plan_name             {get; set;}

        public String override_plan_code        {get; set;}
        public String override_plan_name        {get; set;}
        public String override_plan_expiration  {get; set;}

    }

}