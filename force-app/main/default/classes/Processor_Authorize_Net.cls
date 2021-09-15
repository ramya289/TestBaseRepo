public with sharing class Processor_Authorize_Net extends Processor{
    
    //Authorize.Net Endpoints
    public static String authorizeNetAuthorizationUrl = 'https://account.authorize.net/oauth/authorize';
    public static String authorizeNetTestAuthorizationUrl = 'https://sandbox.authorize.net/oauth/authorize';
    public static String authorizeNetTokenUrl = 'https://access.authorize.net/oauth/v1/token';
    public static String authorizeNetTestTokenUrl  = 'https://accesstest.authorize.net/oauth/v1/token';
    public static String authorizeNetBaseUrl = 'https://api.authorize.net/xml/v1/request.api';
    public static String authorizeNetTestBaseUrl = 'https://apitest.authorize.net/xml/v1/request.api';

    BWP_Processor_Config__c apc;
    BreadwinnerUtil.AppConfig apcWrapper;

    public Processor_Authorize_Net(String authorizeNetAccountId) {
        apc = BreadwinnerUtil.getProcessorConfig(authorizeNetAccountId);
        if (apc == null) {
            throw new ProcessorUtil.InvalidAccountConfigurationException('Invalid Authorize.Net ORG Id provided.');
        }
        apcWrapper = BreadwinnerUtil.getProcessorConfigWrapper(apc);
    }
    
    /**
*  Builds URL to perform authorization with Authorize.Net in live mode. Test credentials will be used.
*
*  @return String
**/
    public static String getAuthUrl(){
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        String sfMode = BreadwinnerUtil.isLightning() ? 'lightning' : 'classic';
        String redirectURL = ProcessorUtil.REDIRECT_URL.removeEnd('/') + '/';
        String clientId = getClientId('live');
        String stateValue = '{SFMode:' + sfMode + ',ProMode:live,ProType:Authorize.Net,Callback:' + sfdcBaseURL + '/apex/' + BreadwinnerUtil.namespaceApi + 'BreadwinnerPayments}';
        return authorizeNetAuthorizationUrl + '?sub=oauth&client_id=' + EncodingUtil.urlEncode((String.isNotBlank(clientId) ? clientId : ''),'UTF-8') + '&state=' + stateValue + '&scope=read,write&redirect_uri=' + redirectURL;
    }
    
    /**
*  Builds URL to perform authorization with Authorize.Net in test mode. Test credentials will be used.
*
*  @return String
**/
    public static String getTestAuthUrl(){
        String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        String sfMode = BreadwinnerUtil.isLightning() ? 'lightning' : 'classic';
        String redirectURL = ProcessorUtil.REDIRECT_URL.removeEnd('/') + '/';
        String clientId = getClientId('test');
        String stateValue = '{SFMode:' + sfMode + ',ProMode:test,ProType:Authorize.Net,Callback:' + sfdcBaseURL + '/apex/' + BreadwinnerUtil.namespaceApi + 'BreadwinnerPayments}';
    	return authorizeNetTestAuthorizationUrl+'?sub=oauth&client_id=' + EncodingUtil.urlEncode((String.isNotBlank(clientId) ? clientId : ''),'UTF-8') + '&state=' + stateValue + '&scope=read,write&redirect_uri=' + redirectURL;
    }

    //This method is used to get the Authorize.Net client Id
    public static String getClientId(String connectionType){
        String returnClientId = '';
        String developerName = (connectionType == 'test' ? 'AuthorizeNet_Test_Credentials' : 'AuthorizeNet_Credentials');
        if(Schema.sObjectType.Breadwinner_Payments_Metadata__mdt.isAccessible()) {
            Breadwinner_Payments_Metadata__mdt authNetCredential = [SELECT Id, Key__c, Secret__c, DeveloperName FROM Breadwinner_Payments_Metadata__mdt WHERE DeveloperName =:developerName LIMIT 1];
            returnClientId = authNetCredential.Key__c;
        }
        return returnClientId;
    }
    
    //This method is used to get the Authorize.Net client Secret
    private static String getClientSecret(String connectionType){
        String returnClientSecret = '';
        String developerName = (connectionType == 'test' ? 'AuthorizeNet_Test_Credentials' : 'AuthorizeNet_Credentials');
        if(Schema.sObjectType.Breadwinner_Payments_Metadata__mdt.isAccessible()) {
            Breadwinner_Payments_Metadata__mdt authNetCredential = [SELECT Id, Key__c, Secret__c, DeveloperName FROM Breadwinner_Payments_Metadata__mdt WHERE DeveloperName =:developerName LIMIT 1];
            returnClientSecret = authNetCredential.Secret__c;
        }
        return returnClientSecret;
    }

    public static void saveAppCredentials(String connectionMode, BWP_Processor_Config__c config) {
        String code = ApexPages.currentPage().getParameters().get('code');
        String accountName = '';
        String accountCurrency = '';
        if(String.isNotBlank(code)){
            code = String.escapeSingleQuotes(code);
        }
        String endPoint = connectionMode == 'test' ? authorizeNetTestTokenUrl : authorizeNetTokenUrl;
        endPoint +=  '?code=' + code + '&grant_type=authorization_code';
        endPoint +=  '&client_id=' +(getClientId(connectionMode));
        endPoint +=  '&client_secret=' +(getClientSecret(connectionMode));
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        
        HttpResponse res = new HttpResponse();
        try {
            res = new HTTP().send(req);
        } catch (Exception ex){
            System.debug('ex: ' + ex.getMessage());
        }
        
        System.debug('=='+res.getBody());
        AuthorizeNetTokenInfo tokenResponse = new AuthorizeNetTokenInfo();
        if (res.getStatusCode() == 200) {

            //deserializing the response
            tokenResponse = (AuthorizeNetTokenInfo)JSON.deserialize(res.getBody(), AuthorizeNetTokenInfo.class);

            String accessToken = tokenResponse.access_token;
            HttpRequest request = new HttpRequest();
            request.setEndpoint(authorizeNetTestBaseUrl);
            request.setMethod('POST');
            String body = '{"getMerchantDetailsRequest": {"merchantAuthentication": {"accessToken": "'+accessToken+'"}}}';
            request.setBody(body);
            HttpResponse resp = new HttpResponse();
            try {
                resp = new Http().send(request);
            }catch (Exception ex) {
                System.debug('ex: ' + ex.getMessage());
            }

            system.debug('response----'+resp.getBody());
            String respBody = resp.getBody().trim().replace('\uFEFF', '');
            AuthNetAccountInfo accInfo = (AuthNetAccountInfo)JSON.deserialize(respBody, AuthNetAccountInfo.class);
            accountName =  accInfo.merchantName;
            accountCurrency = accInfo.currencies[0];

            config = BreadwinnerUtil.getProcessorConfig(accInfo.publicClientKey)!= null ? BreadwinnerUtil.getProcessorConfig(accInfo.publicClientKey) : new BWP_Processor_Config__c();
            System.debug('config--------------'+config);
            config.Account_Name__c = String.isNotBlank(accountName) ? accountName : '';
            config.Default_Currency__c = String.isNotBlank(accountCurrency) ? accountCurrency : '';
            if (tokenResponse.access_token != null) {
                if(tokenResponse.expires_in != null){
                    config.Access_Token_Expiry_Date__c = system.now().addSeconds(Integer.valueOf(tokenResponse.expires_in));
                }
                config.Access_Token__c = tokenResponse.access_token;
                config.Refresh_Token__c = tokenResponse.refresh_token;
                config.Scope__c = tokenResponse.scope;
                config.Live_Mode__c = accInfo.isTestMode;
                config.Name =  accInfo.publicClientKey;
                config.Provider_ID__c = accInfo.publicClientKey;
                config.Need_To_Reconnect__c = false;
                config.Payment_Processor_Type__c = ProcessorUtil.PAT_AUTHORIZE_NET;
                if (config.Customer_Sync_Config__c == null) {
                    config.Customer_Sync_Config__c = 'NONAME_AND_NOEMAIL';
                }
                if (config.Customer_Match_Config__c == null) {
                    config.Customer_Match_Config__c = 'NO_VALID_PAYMENTS';
                }
                config = CryptoUtil.encryptSecrets(config);
                BreadwinnerUtil.upsertAppConfig(config);
                
                //Running Historical Sync
                /* HistoricalSyncBatch historicalSync = new HistoricalSyncBatch('Customer');
Database.executeBatch(historicalSync, 1);
APICallHandler.userInteractionLogPush(false, 'Historical Sync', 'Restarted', 'Historical Sync is restarted automatically after connection/reconnection');
*/            
            }
        } else {
            throw new ProcessorUtil.ConnectionException('Error occurred while connecting with Authorize.Net.');
        }
    }
    
    //Authorize.Net Account info wrapper
    private class AuthorizeNetTokenInfo {
        public String access_token;
        public String refresh_token;
        public String token_type;
        public String scope;
        public Integer expires_in;
        public Integer refresh_token_expires_in;
    }

    public class AuthNetAccountInfo{
        public Boolean isTestMode;
        public String merchantName;
        public String publicClientKey;
        public List<String> paymentMethods;
        public List<String> currencies;
    }
}