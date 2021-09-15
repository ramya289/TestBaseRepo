@IsTest
private class Test_Processor_Authorize_Net {
    @testSetup
    static void setup() {
        String uniqueUserName = 'testuser' + DateTime.now().getTime() + '@testorg.com';
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1 ];
        User user = new User(Alias = 'TestUser', Email = 'testuser@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = prof.Id, TimeZoneSidKey = 'America/Los_Angeles', UserName = uniqueUserName);
        insert user;
        String adminPSName = 'Breadwinner_Payments_Admin_User';
        List<PermissionSet> pset = [SELECT Id FROM PermissionSet WHERE Name = 'Breadwinner_Payments_Admin_User'];
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
            
            bc.saveConnectedAppCredentials();            
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
        }
    }
    
    @IsTest
    static void coverageForConstructor(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BWP_Processor_Config__c apc = UnitTests.createPayConfig(ProcessorUtil.PAT_AUTHORIZE_NET);
            Processor_Authorize_Net ps = new Processor_Authorize_Net(apc.Provider_ID__c);
        }
    }
}