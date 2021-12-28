@IsTest
private class Test_Processor_Authorize_Net {
    @testSetup
    static void setup() {
        String uniqueUserName = 'testuser' + DateTime.now().getTime() + '@testorg.com';
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1 ];
        User user = new User(Alias = 'TestUser', Email = 'testuser@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = prof.Id, TimeZoneSidKey = 'America/Los_Angeles', UserName = uniqueUserName);
        insert user;
        String adminPSName = BreadwinnerUtil.ADMIN_PS_NAME;
        List<PermissionSet> pset = [SELECT Id FROM PermissionSet WHERE Name = :BreadwinnerUtil.ADMIN_PS_NAME];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = pset[0].Id);
    }
    @IsTest
    static void authorization_Success(){
        Test.startTest();
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            PageReference Breadwinner = Page.BreadwinnerPayments;
            Breadwinner.getParameters().put('Code', '3D01p0o000008fdcfsgfg01p0o000008RJfx');
            Breadwinner.getParameters().put('state', '{"SFMode":"classic","ProMode":"test","ProType":"Authorize.Net","Callback":"https://c.ap16.visual.force.com/apex/BreadwinnerPayments"}');
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"access_token":"eyJraWQiOiI4MGI2ZDJjM","token_type":"bearer","refresh_token":"eyJraWQiOiI4MGI2ZDJjM","expires_in":28798,"scope":"read write","refresh_token_expires_in":28799,"client_status":"active"}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            BreadwinnerController bc = new BreadwinnerController();
            
            bc.saveAuthorizeNetCredentials();
        }
        Test.stopTest();
    }
    
    @IsTest
    static void authorization_Failure(){
        Test.startTest();
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            PageReference Breadwinner = Page.BreadwinnerPayments;
            Breadwinner.getParameters().put('Code', '3D01p0o000008fdcfsgfg01p0o000008RJfx');
            Breadwinner.getParameters().put('state', '{"SFMode":"classic","ProMode":"test","ProType":"Authorize.Net","Callback":"https://c.ap16.visual.force.com/apex/BreadwinnerPayments"}');
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"status":401,"reason":"ACCESS_TOKEN_EXPIRED","message":"The provided access token has expired","correlationId":"a14f7c31-a0dc-4dd7-a2a6-8ddba2c84059"}';
            httpMock.statusCode = 401;
            Test.setMock(HttpCalloutMock.class, httpMock);
            BreadwinnerController bc = new BreadwinnerController();
            
            bc.saveAuthorizeNetCredentials();
        }
        Test.stopTest();
    }
    
    @IsTest
    static void coverageForAuthorizationMethods(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BWP_Processor_Config__c apc = UnitTests.createPayConfig(ProcessorUtil.PAT_AUTHORIZE_NET);
            BreadwinnerController bc = new BreadwinnerController();
            bc.config = apc;
            bc.getAuthorizeNetAuthUrl();
            bc.getAuthorizeNetTestAuthUrl();
            
            Test.startTest();
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"access_token":"eyJraWQiOiI4MGI2ZDJjM","token_type":"bearer","refresh_token":"eyJraWQiOiI4MGI2ZDJjM","expires_in":28798,"scope":"read write","refresh_token_expires_in":28799,"client_status":"active"}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            Processor_Authorize_Net.refreshAccessToken(apc);
            Test.stopTest();
        }
    }
    
    @IsTest
    static void coverageForOverrideMethods() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            try{
                Processor_Authorize_Net ps = new Processor_Authorize_Net('12345');
            } catch (Exception ex){}
            BWP_Processor_Config__c apc = UnitTests.createPayConfig(ProcessorUtil.PAT_AUTHORIZE_NET);
            Processor_Authorize_Net ps = new Processor_Authorize_Net(apc.Provider_Id__c);
            try{
                ps.fetchCustomers('');
            } catch (Exception ex){}
            try{
                ps.fetchTransactions('');
            } catch (Exception ex){}
        }
    }
    
    @IsTest
    static void fetchCustomers_When_Success() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_AUTHORIZE_NET);
            apcWrapper.isAlreadyDecrypted = true;
            System.debug('--apcWrapper---'+apcWrapper);
            Test.startTest();
                        
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            
            httpMock.response = '{"ids":["47988","47997","48458","48468","189118","190178"],"messages":{"resultCode":"Ok","message":[{"code":"I00001","text":"Successful."}]}}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Authorize_Net.fetchCustomers(apcWrapper, '');
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void fetchCustomers_When_Failure() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_AUTHORIZE_NET);
            apcWrapper.isAlreadyDecrypted = true;
            Test.startTest();
                        
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"messages":{"resultCode":"Error","message":[{"code":"E00007","text":"User authentication failed due to invalid authentication values."}]}}';
            httpMock.statusCode = 400;
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Authorize_Net.fetchCustomers(apcWrapper, '');
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void fetchTransactions_When_Success() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_AUTHORIZE_NET);
            apcWrapper.isAlreadyDecrypted = true;
            Test.startTest();

            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"batchList":[{"batchId":"11856714","settlementTimeUTC":"2021-07-02T04:14:18Z","settlementTimeLocal":"2021-07-01T21:14:18","settlementState":"settledSuccessfully","paymentMethod":"creditCard","marketType":"eCommerce","product":"Card Not Present"},{"batchId":"11870986","settlementTimeUTC":"2021-07-07T02:46:47Z","settlementTimeLocal":"2021-07-06T19:46:47","settlementState":"settledSuccessfully","paymentMethod":"creditCard","marketType":"eCommerce","product":"Card Not Present"}],"messages":{"resultCode":"Ok","message":[{"code":"I00001","text":"Successful."}]}}';   
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Authorize_Net.fetchTransactions(apcWrapper, '');
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void fetchTransactions_When_Failure() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_AUTHORIZE_NET);
            apcWrapper.isAlreadyDecrypted = true;
            Test.startTest();
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"messages":{"resultCode":"Error","message":[{"code":"E00007","text":"User authentication failed due to invalid authentication values."}]}}';   
            httpMock.statusCode = 400;
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Authorize_Net.fetchTransactions(apcWrapper, '');
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }
    
    /*@IsTest
    static void processorBatchCustomerSync_When_Success() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            Test.startTest();
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"profile":{"paymentProfiles":[{"customerPaymentProfileId":"87","payment":{"creditCard":{"cardNumber":"XXXX1111","expirationDate":"XXXX","cardType":"Visa","issuerNumber":"411111"}},"originalNetworkTransId":"0TN1VE648DFCJSHQ81GZH9F","originalAuthAmount":0,"billTo":{"phoneNumber":"000-000-0000","firstName":"John","lastName":"Doe","address":"123 Main St.","city":"Bellevue","state":"WA","zip":"98004","country":"US"}},{"customerPaymentProfileId":"86","payment":{"creditCard":{"cardNumber":"XXXX1111","expirationDate":"XXXX","cardType":"Visa","issuerNumber":"411111"}},"originalNetworkTransId":"0STSMT7WLO5D80U0KJR4Z9A","originalAuthAmount":0,"customerType":"individual","billTo":{"phoneNumber":"123-123-1235","firstName":"Customer FirstName","lastName":"Customer LastName","address":"123 Main St.","city":"Bellevue","state":"WA","zip":"98004","country":"US"}}],"profileType":"regular","customerProfileId":"527262","merchantCustomerId":"MerchantCustID","description":"Profile description here","email":"customer-profile-email@here.com"},"messages":{"resultCode":"Ok","message":[{"code":"I00001","text":"Successful."}]}}';
            Test.setMock(HttpCalloutMock.class, httpMock);
            List<String> authNetIds = new List<String>{'1', '2', '3'};
            Processor_Batch processorBatch = new Processor_Batch(authNetIds, UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_AUTHORIZE_NET), 'Customer');
            processorBatch.runThisSyncOnly = true;
            Database.executeBatch(processorBatch, 40);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void processorBatchPaymentsSync_When_Success() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            Test.startTest();
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"transactions":[{"transId":"60170195482","submitTimeUTC":"2021-07-01T11:22:38Z","submitTimeLocal":"2021-07-01T04:22:38","transactionStatus":"voided","invoiceNumber":"none","firstName":"Afreen","lastName":"Waheed","accountType":"Visa","accountNumber":"XXXX1111","settleAmount":0,"marketType":"eCommerce","product":"Card Not Present"},{"transId":"60170195479","submitTimeUTC":"2021-07-01T11:22:37Z","submitTimeLocal":"2021-07-01T04:22:37","transactionStatus":"voided","invoiceNumber":"none","firstName":"Afreen","lastName":"Waheed","accountType":"Visa","accountNumber":"XXXX1111","settleAmount":0,"marketType":"eCommerce","product":"Card Not Present"}],"totalNumInResultSet":20,"messages":{"resultCode":"Ok","message":[{"code":"I00001","text":"Successful."}]}}';
            Test.setMock(HttpCalloutMock.class, httpMock);
            List<String> authNetIds = new List<String>{'01', '02', '03'};
            Processor_Batch processorBatch = new Processor_Batch(authNetIds, UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_AUTHORIZE_NET), 'Payment');
            processorBatch.runThisSyncOnly = true;
            Database.executeBatch(processorBatch);
            
            Test.stopTest();
        }
    }*/
    
    
    @IsTest
    static void coverageForConstructor(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BWP_Processor_Config__c apc = UnitTests.createPayConfig(ProcessorUtil.PAT_AUTHORIZE_NET);
            Processor_Authorize_Net ps = new Processor_Authorize_Net(apc.Provider_ID__c);
        }
    }
}