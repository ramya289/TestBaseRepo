@IsTest
private class Test_Processor_PayPal {
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
            Breadwinner.getParameters().put('state', '{"SFMode":"classic","ProMode":"test","ProType":"PayPal","Callback":"https://c.ap16.visual.force.com/apex/BreadwinnerPayments"}');
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"scope":"{scope}","access_token":"{access_token}","token_type":"Bearer","expires_in":28800,"refresh_token":"{refresh_token}","nonce":"{nonce}","state":"{state}"}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            BreadwinnerController bc = new BreadwinnerController();
            
            bc.savePayPalCredentials();
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
            Breadwinner.getParameters().put('state', '{"SFMode":"classic","ProMode":"test","ProType":"PayPal","Callback":"https://c.ap16.visual.force.com/apex/BreadwinnerPayments"}');
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"scope":"{scope}","access_token":"{access_token}","token_type":"Bearer","expires_in":28800,"refresh_token":"{refresh_token}","nonce":"{nonce}","state":"{state}"}';
            httpMock.statusCode = 400;
            Test.setMock(HttpCalloutMock.class, httpMock);
            BreadwinnerController bc = new BreadwinnerController();
            
            bc.savePayPalCredentials();
        }
        Test.stopTest();
    }
    
    @IsTest
    static void coverageForAuthorizationMethods(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BWP_Processor_Config__c apc = UnitTests.createPayConfig(ProcessorUtil.PAT_PAYPAL);
            BreadwinnerController bc = new BreadwinnerController();
            bc.getPayPalAuthUrl();
            bc.getPayPalTestAuthUrl();
            Processor_PayPal.refreshAccessToken(apc);
        }
    }
    
    @IsTest
    static void coverageForConstructor(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BWP_Processor_Config__c apc = UnitTests.createPayConfig(ProcessorUtil.PAT_PAYPAL);
            Processor_PayPal pp = new Processor_PayPal(apc.Provider_ID__c);
        }
    }
    
  /* Removing until we actually need this for code coverage
    @IsTest
    static void coverageForOverrideMethods() {
        try{
            Processor_PayPal ps = new Processor_PayPal('12345');
        } catch (Exception ex){}
        List<Payment_Config__mdt> apcs = UnitTests.createAppConfig(1, ProcessorUtil.PAT_PAYPAL);
        Processor_PayPal ps = new Processor_PayPal(apcs[0].Provider_Id__c);
        try{
            ps.fetchCustomers('');
        } catch (Exception ex){}
        try{
            ps.fetchPayments('');
        } catch (Exception ex){}
        
    }
    @IsTest
    static void fetchPayments_When_Success() {
        Payment_Config__mdt apc = UnitTests.createAppConfig(1, ProcessorUtil.PAT_PAYPAL)[0];
        BreadwinnerUtil.AppConfig apcWrapper = BreadwinnerUtil.getAppConfigWrapper(apc);
        Test.startTest();
        Processor_PayPal.FetchRequest fetchRequest = new Processor_PayPal.FetchRequest();
        fetchRequest.fields = 'transaction_info,payer_info,shipping_info';
        fetchRequest.page_size = 2;
        fetchRequest.page = 1;
        fetchRequest.start_date = json.serialize(System.now().addDays(-30)).remove('"');
        fetchRequest.end_date = json.serialize(System.now()).remove('"');
        
        UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
        
        httpMock.response = '{"transaction_details":[{"transaction_info":{"paypal_account_id":"D42UKH3SM7GLW","transaction_id":"60U965010N787725U","transaction_event_code":"T0001","transaction_initiation_date":"2020-10-15T09:20:14+0000","transaction_updated_date":"2020-10-15T09:20:14+0000","transaction_amount":{"currency_code":"USD","value":"1.87"},"transaction_status":"S","transaction_subject":"You have a payout!","transaction_note":"You have received a payout! Thanks for using our service!","ending_balance":{"currency_code":"USD","value":"5939.90"},"available_balance":{"currency_code":"USD","value":"5939.90"},"custom_field":"201403140001","protection_eligibility":"02"},"payer_info":{"account_id":"D42UKH3SM7GLW","email_address":"sb-mrlyn3212482@business.example.com","address_status":"N","payer_status":"Y","payer_name":{"alternate_full_name":"John Doe Test Store"},"country_code":"US"},"shipping_info":{"name":"John, Doe"}},{"transaction_info":{"paypal_account_id":"D42UKH3SM7GLW","transaction_id":"5FL977279A849764V","transaction_event_code":"T0001","transaction_initiation_date":"2020-10-15T12:04:15+0000","transaction_updated_date":"2020-10-15T12:04:15+0000","transaction_amount":{"currency_code":"USD","value":"1.87"},"transaction_status":"S","transaction_subject":"You have a payout!","transaction_note":"You have received a payout! Thanks for using our service!","ending_balance":{"currency_code":"USD","value":"5960.47"},"available_balance":{"currency_code":"USD","value":"5960.47"},"custom_field":"201403140001","protection_eligibility":"02"},"payer_info":{"account_id":"D42UKH3SM7GLW","email_address":"sb-mrlyn3212482@business.example.com","address_status":"N","payer_status":"Y","payer_name":{"alternate_full_name":"John Does Test Store"},"country_code":"US"},"shipping_info":{"name":"John, Doe"}}],"account_number":"XPYWY78WX7HNG","start_date":"2020-10-11T11:15:04+0000","end_date":"2020-11-10T11:15:04+0000","last_refreshed_datetime":"2020-12-10T09:59:59+0000","page":1,"total_items":2,"total_pages":1}';
        
        Test.setMock(HttpCalloutMock.class, httpMock);
        
        ProcessorUtil.ResponseObject response =  Processor_PayPal.fetchPayments(apcWrapper, JSON.serializePretty(fetchRequest));
        System.debug('response: ' + response);
        
        Test.stopTest();
    }
    
    @IsTest
    static void fetchPayments_When_Failure() {
        Payment_Config__mdt apc = UnitTests.createAppConfig(1, ProcessorUtil.PAT_PAYPAL)[0];
        BreadwinnerUtil.AppConfig apcWrapper = BreadwinnerUtil.getAppConfigWrapper(apc);
        
        Test.startTest();
        Processor_PayPal.FetchRequest fetchRequest = new Processor_PayPal.FetchRequest();
        fetchRequest.start_date = json.serialize(System.now().addDays(-35)).remove('"');
        fetchRequest.end_date = json.serialize(System.now()).remove('"');
        
        UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
        httpMock.response = '{"name":"INVALID_REQUEST","message":"Invalid request - see details.","debug_id":"633f738a5da84","details":[{"field":"end_date","value":"2020-10-06T09:38:07.410Z","location":"query","issue":"Date range is greater than 31 days"}],"links":[]}';
        httpMock.statusCode = 400;
        Test.setMock(HttpCalloutMock.class, httpMock);
        
        ProcessorUtil.ResponseObject response =  Processor_PayPal.fetchPayments(apcWrapper, JSON.serializePretty(fetchRequest));
        System.debug('response: ' + response);
        
        Test.stopTest();
    }
    
    @IsTest
    static void historicalSync_When_Success() {
        List<Payment_Config__mdt> apcs = UnitTests.createAppConfig(1, ProcessorUtil.PAT_PAYPAL);
        Test.startTest();
        
        UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
        httpMock.response = '{"transaction_details":[{"transaction_info":{"paypal_account_id":"D42UKH3SM7GLW","transaction_id":"60U965010N787725U","transaction_event_code":"T0001","transaction_initiation_date":"2020-10-15T09:20:14+0000","transaction_updated_date":"2020-10-15T09:20:14+0000","transaction_amount":{"currency_code":"USD","value":"1.87"},"transaction_status":"S","transaction_subject":"You have a payout!","transaction_note":"You have received a payout! Thanks for using our service!","ending_balance":{"currency_code":"USD","value":"5939.90"},"available_balance":{"currency_code":"USD","value":"5939.90"},"custom_field":"201403140001","protection_eligibility":"02"},"payer_info":{"account_id":"D42UKH3SM7GLW","email_address":"sb-mrlyn3212482@business.example.com","address_status":"N","payer_status":"Y","payer_name":{"alternate_full_name":"John Doe Test Store"},"country_code":"US"},"shipping_info":{"name":"John, Doe"}},{"transaction_info":{"paypal_account_id":"D42UKH3SM7GLW","transaction_id":"5FL977279A849764V","transaction_event_code":"T0001","transaction_initiation_date":"2020-10-15T12:04:15+0000","transaction_updated_date":"2020-10-15T12:04:15+0000","transaction_amount":{"currency_code":"USD","value":"1.87"},"transaction_status":"S","transaction_subject":"You have a payout!","transaction_note":"You have received a payout! Thanks for using our service!","ending_balance":{"currency_code":"USD","value":"5960.47"},"available_balance":{"currency_code":"USD","value":"5960.47"},"custom_field":"201403140001","protection_eligibility":"02"},"payer_info":{"account_id":"D42UKH3SM7GLW","email_address":"sb-mrlyn3212482@business.example.com","address_status":"N","payer_status":"Y","payer_name":{"alternate_full_name":"John Does Test Store"},"country_code":"US"},"shipping_info":{"name":"John, Doe"}}],"account_number":"XPYWY78WX7HNG","start_date":"2020-10-11T11:15:04+0000","end_date":"2020-11-10T11:15:04+0000","last_refreshed_datetime":"2020-12-10T09:59:59+0000","page":1,"total_items":2,"total_pages":1}';
        Test.setMock(HttpCalloutMock.class, httpMock);
        HistoricalSyncBatch historicalSync = new HistoricalSyncBatch('Payment');
        
        Database.executeBatch(historicalSync, 1);
        
        Test.stopTest();
    }
    
    @IsTest
    static void historicalSync_When_Failure() {
        List<Payment_Config__mdt> apcs = UnitTests.createAppConfig(1, ProcessorUtil.PAT_PAYPAL);
        
        Test.startTest();
        
        UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
        httpMock.response = '{"name":"INVALID_REQUEST","message":"Invalid request - see details.","debug_id":"633f738a5da84","details":[{"field":"end_date","value":"2020-10-06T09:38:07.410Z","location":"query","issue":"Date range is greater than 31 days"}],"links":[]}';
        httpMock.statusCode = 400;
        Test.setMock(HttpCalloutMock.class, httpMock);
        
        HistoricalSyncBatch historicalSync = new HistoricalSyncBatch('Payment');
        Database.executeBatch(historicalSync, 1);
        
        Test.stopTest();
    }
    
    @IsTest
    static void hourlySync_When_Success() {
        List<Payment_Config__mdt> apcs = UnitTests.createAppConfig(1, ProcessorUtil.PAT_PAYPAL);
        
        Test.startTest();
        
        UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
        httpMock.response = '{"transaction_details":[{"transaction_info":{"paypal_account_id":"D42UKH3SM7GLW","transaction_id":"60U965010N787725U","transaction_event_code":"T0001","transaction_initiation_date":"2020-10-15T09:20:14+0000","transaction_updated_date":"2020-10-15T09:20:14+0000","transaction_amount":{"currency_code":"USD","value":"1.87"},"transaction_status":"S","transaction_subject":"You have a payout!","transaction_note":"You have received a payout! Thanks for using our service!","ending_balance":{"currency_code":"USD","value":"5939.90"},"available_balance":{"currency_code":"USD","value":"5939.90"},"custom_field":"201403140001","protection_eligibility":"02"},"payer_info":{"account_id":"D42UKH3SM7GLW","email_address":"sb-mrlyn3212482@business.example.com","address_status":"N","payer_status":"Y","payer_name":{"alternate_full_name":"John Doe Test Store"},"country_code":"US"},"shipping_info":{"name":"John, Doe"}},{"transaction_info":{"paypal_account_id":"D42UKH3SM7GLW","transaction_id":"5FL977279A849764V","transaction_event_code":"T0001","transaction_initiation_date":"2020-10-15T12:04:15+0000","transaction_updated_date":"2020-10-15T12:04:15+0000","transaction_amount":{"currency_code":"USD","value":"1.87"},"transaction_status":"S","transaction_subject":"You have a payout!","transaction_note":"You have received a payout! Thanks for using our service!","ending_balance":{"currency_code":"USD","value":"5960.47"},"available_balance":{"currency_code":"USD","value":"5960.47"},"custom_field":"201403140001","protection_eligibility":"02"},"payer_info":{"account_id":"D42UKH3SM7GLW","email_address":"sb-mrlyn3212482@business.example.com","address_status":"N","payer_status":"Y","payer_name":{"alternate_full_name":"John Does Test Store"},"country_code":"US"},"shipping_info":{"name":"John, Doe"}}],"account_number":"XPYWY78WX7HNG","start_date":"2020-10-11T11:15:04+0000","end_date":"2020-11-10T11:15:04+0000","last_refreshed_datetime":"2020-12-10T09:59:59+0000","page":1,"total_items":2,"total_pages":1}';
        Test.setMock(HttpCalloutMock.class, httpMock);
        
        HourlySyncBatch hourlySync = new HourlySyncBatch('Payment');
        Database.executeBatch(hourlySync, 1);
        
        Test.stopTest();
    }
    
    @IsTest
    static void hourlySync_When_Failure() {
        List<Payment_Config__mdt> apcs = UnitTests.createAppConfig(1, ProcessorUtil.PAT_PAYPAL);
        
        Test.startTest();
        
        UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
        httpMock.response = '{"name":"INVALID_REQUEST","message":"Invalid request - see details.","debug_id":"633f738a5da84","details":[{"field":"end_date","value":"2020-10-06T09:38:07.410Z","location":"query","issue":"Date range is greater than 31 days"}],"links":[]}';
        httpMock.statusCode = 400; 
        Test.setMock(HttpCalloutMock.class, httpMock);
        
        HourlySyncBatch hourlySync = new HourlySyncBatch('Payment');
        Database.executeBatch(hourlySync, 1);
        
        Test.stopTest();
    }
    } */
}