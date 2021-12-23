/**
* Everything that is Processor specific should be tested in this class
*/
@IsTest
private class Test_Processor_Square {
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
            Breadwinner.getParameters().put('state', '{"SFMode":"classic","ProMode":"test","ProType":"Square","Callback":"https://c.ap16.visual.force.com/apex/BreadwinnerPayments"}');
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"access_token":"EAAAEMGf0sY9TkJbjcceA3Ggy6-e8wuREmh81FixEh78hF3R4OTvxveuuWODZgbR","token_type":"bearer","expires_at":"2020-09-23T12:15:27Z","merchant_id":"ML63YCDEY6SCD","refresh_token":"EQAAEGLSWoqU7xlAOj70QmWNi6hAn93-4Y2k4H0KBmu0gFdyAc_ar2v56DrWs6ot"}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            BreadwinnerController bc = new BreadwinnerController();
            
            bc.saveSquareCredentials();
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
            Breadwinner.getParameters().put('state', '{"SFMode":"classic","ProMode":"test","ProType":"Square","Callback":"https://c.ap16.visual.force.com/apex/BreadwinnerPayments"}');
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"access_token":"EAAAEMGf0sY9TkJbjcceA3Ggy6-e8wuREmh81FixEh78hF3R4OTvxveuuWODZgbR","token_type":"bearer","expires_at":"2020-09-23T12:15:27Z","merchant_id":"ML63YCDEY6SCD","refresh_token":"EQAAEGLSWoqU7xlAOj70QmWNi6hAn93-4Y2k4H0KBmu0gFdyAc_ar2v56DrWs6ot"}';
            httpMock.statusCode = 400;
            Test.setMock(HttpCalloutMock.class, httpMock);
            BreadwinnerController bc = new BreadwinnerController();
            
            bc.saveSquareCredentials();
        }
        Test.stopTest();
    }
    @IsTest
    static void coverageForAuthorizationMethods(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BWP_Processor_Config__c apc = UnitTests.createPayConfig(ProcessorUtil.PAT_SQUARE);
            BreadwinnerController bc = new BreadwinnerController();
            bc.getSquareAuthUrl();
            bc.getSquareTestAuthUrl();
            Processor_Square.refreshAccessToken(apc);
        }
    }
    @IsTest
    static void coverageForOverrideMethods() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            try{
                Processor_Square ps = new Processor_Square('12345');
            } catch (Exception ex){}
            BWP_Processor_Config__c apc = UnitTests.createPayConfig(ProcessorUtil.PAT_SQUARE);
            Processor_Square ps = new Processor_Square(apc.Provider_Id__c);
            try{
                ps.createCustomer('');
            } catch (Exception ex){}
            try{
                ps.updateCustomer('');
            } catch (Exception ex){}
            try{
                ps.createCardToken('');
            } catch (Exception ex){}
            try{
                ps.chargeProcessor('', '');
            } catch (Exception ex){}
            try{
                ps.fetchCustomers('');
            } catch (Exception ex){}
            try{
                ps.fetchTransactions('');
            } catch (Exception ex){}
            try{
                ps.createCheckoutURL('');
            } catch (Exception ex){}
        }
    }
    
    @IsTest
    static void createCustomer_When_Success() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_SQUARE);
            
            Account acct = new Account(Name = 'Test Account');
            insert acct;
            
            Test.startTest();
            
            Customer.SquareCustomer squareCustomer = new Customer.SquareCustomer();
            
            squareCustomer.given_name = 'Stella';
            squareCustomer.family_name = 'Pavlova';
            squareCustomer.email_address = 'test@test.com';
            squareCustomer.phone_number = '773-631-4077';
            squareCustomer.note = 'Customer Created by Breadwinner API at ';
            squareCustomer.accountId = acct.Id;
            
            //Billing Address
            Customer.SquareAddress add = new Customer.SquareAddress();
            add.address_line_1 = '134  Poplar Chase Lane';
            add.address_line_2 = 'Boise';
            add.locality = 'Boise';
            add.administrative_district_level_1 = 'Pennsylvania';
            add.country = 'US';
            add.postal_code = '19108';
            squareCustomer.address = add;
            
            Map<String, List<Customer.SquareCustomer>> customerMap = new Map<String, List<Customer.SquareCustomer>>();
            customerMap.put('customer', new List<Customer.SquareCustomer>{squareCustomer});
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"customer":{"id":"NYJYAFBKPCSPV50FFYACHJNKHW","created_at":"2020-12-24T07:56:01.806Z","updated_at":"2021-02-08T15:03:58Z","cards":[{"id":"ccof:0GULx3LHKmnHomzP3GB","card_brand":"MASTERCARD","last_4":"9029","exp_month":4,"exp_year":2023,"billing_address":{"postal_code":"94103"}}],"given_name":"Almas","family_name":"Khan","email_address":"testSquare@gmail.com","phone_number":"2025550186","company_name":"test company","preferences":{"email_unsubscribed":false}}}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Square.createCustomer(apcWrapper, JSON.serializePretty(customerMap));
            System.debug('response: ' + response);
            System.assert([SELECT count() FROM BWP_Customer__c]>0);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void createCustomer_When_Failure() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_SQUARE);
            
            Test.startTest();
            
            Customer.SquareCustomer squareCustomer = new Customer.SquareCustomer();
            squareCustomer.given_name = 'Stella';
            squareCustomer.family_name = 'Pavlova';
            squareCustomer.email_address = 'test@';
            squareCustomer.phone_number = '773-631-4077';
            squareCustomer.accountId = '0012w00000MZ1sj';
            Map<String, List<Customer.SquareCustomer>> customerMap = new Map<String, List<Customer.SquareCustomer>>();
            customerMap.put('customer', new List<Customer.SquareCustomer>{squareCustomer});
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.StatusCode = 400;
            httpMock.response ='{"errors":[{"code":"INVALID_VALUE","detail":"Provided value for `email_address` is invalid.","field":"email_address","category":"INVALID_REQUEST_ERROR"}]}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Square.createCustomer(apcWrapper, JSON.serializePretty(customerMap));
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void updateCustomer_When_Success() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_SQUARE);
            
            Test.startTest();
            
            Customer.SquareCustomer squareCustomer = new Customer.SquareCustomer();
            squareCustomer.id = 'testprocessorId';
            squareCustomer.given_name = 'Kenneth';
            squareCustomer.family_name = 'Woodell';
            squareCustomer.email_address = 'test@gmail.com';
            squareCustomer.phone_number = '773-631-4077';
            squareCustomer.company_name = 'Hoyden';
            Map<String, List<Customer.SquareCustomer>> customerMap = new Map<String, List<Customer.SquareCustomer>>();
            customerMap.put('customer', new List<Customer.SquareCustomer>{SquareCustomer});
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"customer":{"id":"NYJYAFBKPCSPV50FFYACHJNKHW","created_at":"2020-12-24T07:56:01.806Z","updated_at":"2021-02-08T15:03:58Z","cards":[{"id":"ccof:0GULx3LHKmnHomzP3GB","card_brand":"MASTERCARD","last_4":"9029","exp_month":4,"exp_year":2023,"billing_address":{"postal_code":"94103"}}],"given_name":"Almas","family_name":"Khan","email_address":"testSquare@gmail.com","phone_number":"2025550186","company_name":"test company","preferences":{"email_unsubscribed":false}}}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Square.updateCustomer(apcWrapper, JSON.serializePretty(customerMap));
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }
    
    @isTest
    static void updateCustomer_When_Failure(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_SQUARE);
            
            Test.startTest();
            
            Customer.SquareCustomer squareCustomer = new Customer.SquareCustomer();
            squareCustomer.id = 'testprocessorId';
            squareCustomer.given_name = 'Almas';
            squareCustomer.family_name = 'Khan';
            squareCustomer.email_address = 'test';
            squareCustomer.phone_number = '773-631-4077';
            squareCustomer.company_name = 'test inc.';
            Map<String, List<Customer.SquareCustomer>> customerMap = new Map<String, List<Customer.SquareCustomer>>();
            customerMap.put('customer', new List<Customer.SquareCustomer>{SquareCustomer});
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response ='{"errors":[{"code":"INVALID_VALUE","detail":"Provided value for `email_address` is invalid.","field":"email_address","category":"INVALID_REQUEST_ERROR"}]}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Square.updateCustomer(apcWrapper, JSON.serializePretty(customerMap));
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void createCard_When_Success() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_SQUARE);
            
            Test.startTest();
            
            Customer.SquareCustomer customer = new Customer.SquareCustomer();
            customer.id = 'processorCustomerId';
            List<Customer.SquareCard> datalist = new  list<Customer.SquareCard>();
            Customer.SquareCard card = new Customer.SquareCard();
            card.card_nonce = 'cnon:card-nonce-ok';
            card.cardholder_name = 'Stella';
            Customer.SquareAddress add = new Customer.SquareAddress();
            add.address_line_1 = '134  Poplar Chase Lane';
            add.address_line_2 = 'Boise';
            add.locality = 'Boise';
            add.administrative_district_level_1 = 'Pennsylvania';
            add.country = 'US';
            add.postal_code = '19108';
            card.billing_address = add;
            datalist.add(card);
            customer.cards = datalist;
            
            Map<String, List<Customer.SquareCustomer>> customerMap = new Map<String, List<Customer.SquareCustomer>>();
            customerMap.put('customer', new List<Customer.SquareCustomer>{customer});
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            
            httpMock.response = '{"card":{"id":"ccof:k2Cmq9q7SZopxZin3GB","card_brand":"AMERICAN_EXPRESS","last_4":"6550","exp_month":11,"exp_year":2022,"cardholder_name":"Afreen Waheed","billing_address":{"address_line_1":"line1","address_line_2":"line2","locality":"San Marcos","administrative_district_level_1":"city","postal_code":"94103","country":"US"}}}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Square.createCardToken(apcWrapper, JSON.serializePretty(customerMap));
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void createCard_When_Failure() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_SQUARE);
            
            Test.startTest();
            Customer.SquareCustomer customer = new Customer.SquareCustomer();
            customer.id = 'processorCustomerId';
            List<Customer.SquareCard> datalist = new  list<Customer.SquareCard>();
            Customer.SquareCard card = new Customer.SquareCard();
            //  card.card_nonce = 'cnon:card-nonce-ok';
            card.cardholder_name = 'Stella';
            datalist.add(card);
            customer.cards = datalist;
            Map<String, List<Customer.SquareCustomer>> customerMap = new Map<String, List<Customer.SquareCustomer>>();
            customerMap.put('customer', new List<Customer.SquareCustomer>{customer});
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"errors":[{"category":"INVALID_REQUEST_ERROR","code":"MISSING_REQUIRED_PARAMETER","detail":"Field must be set","field":"card_nonce"}]}';
            httpMock.statusCode = 400;
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Square.createCardToken(apcWrapper, JSON.serializePretty(customerMap));
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void createCharge_When_Success() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_SQUARE);
            
            Test.startTest();
            Charge.SquareCharge ch = new Charge.SquareCharge();
            Charge.Money money = new Charge.Money();
            money.amount = 100;
            money.square_currency = 'USD';
            ch.customer_id = 'cus_Id';
            ch.source_id = 'paymentMethodId';
            ch.idempotency_key = '0e7f6987-557a-4af0-807b-84c4bf3020e4';
            ch.amount_money = money;
            Map<String, List<Charge.SquareCharge>> chargeMap = new Map<String, List<Charge.SquareCharge>>();
            chargeMap.put('charge', new List<Charge.SquareCharge>{ch});
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"payment":{"id":"DZ6ZRMPTtDcHcis8kshew8hsEjGZY","created_at":"2020-11-24T10:50:28.245Z","updated_at":"2020-11-24T10:50:28.405Z","amount_money":{"amount":11000,"currency":"USD"},"status":"COMPLETED","delay_duration":"PT168H","source_type":"CARD","card_details":{"status":"CAPTURED","card":{"card_brand":"AMERICAN_EXPRESS","last_4":"6550","exp_month":11,"exp_year":2022,"fingerprint":"sq-1-q8oHndkEYkFpToVfkmwpKg0Og5Zi9RDrrKZQtryM6nR9q0UbhBkY11F4UcdqxarNGg","card_type":"CREDIT","prepaid_type":"NOT_PREPAID","bin":"371263"},"entry_method":"ON_FILE","cvv_status":"CVV_NOT_CHECKED","avs_status":"AVS_ACCEPTED","statement_description":"SQ *DEFAULT TEST ACCOUNT"},"location_id":"LS8683GRB251W","order_id":"dEqhPVeRPFCxQdInW8LpadeI1k7YY","risk_evaluation":{"created_at":"2020-11-24T10:50:28.353Z","risk_level":"NORMAL"},"customer_id":"0EW5N1YEBS4M72SZCE53QDSJFR","total_money":{"amount":11000,"currency":"USD"},"receipt_number":"DZ6Z","receipt_url":"https://squareupsandbox.com/receipt/preview/DZ6ZRMPTtDcHcis8kshew8hsEjGZY","delay_action":"CANCEL","delayed_until":"2020-12-01T10:50:28.245Z"}}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Square.chargeProcessor(apcWrapper, JSON.serializePretty(chargeMap), '');
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void createCharge_When_Failure() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_SQUARE);
            
            Test.startTest();
            
            Charge.SquareCharge ch = new Charge.SquareCharge();
            Charge.Money money = new Charge.Money();
            money.amount = 100;
            money.square_currency = 'USD';
            ch.customer_id = 'cus_Id';
            ch.source_id = 'paymentMethodId';
            //ch.idempotency_key = '0e7f6987-557a-4af0-807b-84c4bf3020e4';
            ch.amount_money = money;
            Map<String, List<Charge.SquareCharge>> chargeMap = new Map<String, List<Charge.SquareCharge>>();
            chargeMap.put('charge', new List<Charge.SquareCharge>{ch});
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"errors":[{"code":"VALUE_EMPTY","detail":"Field must not be blank","field":"idempotency_key","category":"INVALID_REQUEST_ERROR"}]}';
            httpMock.statusCode = 400;
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response = Processor_Square.chargeProcessor(apcWrapper, JSON.serializePretty(chargeMap), '');
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void fetchCustomers_When_Success() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_SQUARE);
            
            Test.startTest();
            
            Processor_Square.FetchRequest fetchRequest = new Processor_Square.FetchRequest();
            fetchRequest.cursor = 'id';
            fetchRequest.square_limit = '50';
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"customers":[{"id":"SWGYZ9TY7D6BSBSE4P6HAXP5WC","created_at":"2020-08-21T12:32:09.729Z","updated_at":"2020-08-21T12:32:10Z","cards":[{"id":"ccof:s2ubjSqliLxt0JRz3GB","card_brand":"VISA","last_4":"5858","exp_month":8,"exp_year":2022,"cardholder_name": "Amelia Earhart","billing_address":{"address_line_1":"500 Electric Ave","address_line_2":"Suite 600","locality":"New York","administrative_district_level_1":"NY","postal_code":"10003","country":"US"}}],"given_name":"Acme Start","email_address":"acme@gmail.com", "address":{"address_line_1":"500 Electric Ave","address_line_2":"Suite 600","locality":"New York","administrative_district_level_1":"NY","postal_code":"10003","country":"US"}, "groups":[{"id":"ML63YCDEY6SCD.REACHABLE","name":"Reachable"},{"id":"ML63YCDEY6SCD.CARDS_ON_FILE","name":"Cards on File"}],"creation_source":"DIRECTORY","segment_ids":["ML63YCDEY6SCD.REACHABLE","ML63YCDEY6SCD.CARDS_ON_FILE"]}],"cursor":"Cg1AEQAQ=="}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Square.fetchCustomers(apcWrapper, JSON.serializePretty(fetchRequest));
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void fetchCustomers_When_Failure() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_SQUARE);
            
            Test.startTest();
            
            Processor_Square.FetchRequest fetchRequest = new Processor_Square.FetchRequest();
            fetchRequest.cursor = 'id';
            fetchRequest.square_limit = '50';
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"errors":[{"code":"INVALID_ENUM_VALUE","detail":"`Dec` is not a valid enum value for `sort_order`.","field":"sort_order","category":"INVALID_REQUEST_ERROR"}]}';
            httpMock.statusCode = 400;
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Square.fetchCustomers(apcWrapper, JSON.serializePretty(fetchRequest));
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void fetchTransactions_When_Success() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_SQUARE);
            
            Test.startTest();
            
            Processor_Square.FetchRequest fetchRequest = new Processor_Square.FetchRequest();
            fetchRequest.cursor = 'id';
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"payments":[{"id":"ifrBnAil7rRfDtd27cdf9g9WO8paB","created_at":"2019-07-09T14:36:13.745Z","updated_at":"2019-07-09T14:36:13.883Z","amount_money":{"amount":1000,"currency":"USD"},"app_fee_money":{"amount":1000,"currency":"USD"},"refunded_money":{"amount":100,"currency":"USD"},"total_money":{"amount":1000,"currency":"USD"},"status":"APPROVED","source_type":"CARD","card_details":{"status":"AUTHORIZED","card":{"card_brand":"VISA","last_4":"5858","exp_month":8,"exp_year":2022,"fingerprint":"sq-1-lHpUJIUyqOPQmH89b6GuQEljmc-mZmu4kSTaMlkLDkJI7NVjAl4Zirn2sk3OeyVKVA"},"entry_method":"KEYED","cvv_status":"CVV_ACCEPTED","avs_status":"AVS_ACCEPTED","auth_result_code":"NQbV3A"},"location_id":"QLIJX16Q3UZ0A","order_id":"MvfIilKnIYKBium4rauH67wFzRxv"},{"id":"GQTFp1ZlXdpoW4o6eGiZhbjosiDFf","created_at":"2019-07-08T01:00:51.607Z","updated_at":"2019-07-08T01:13:58.508Z","amount_money":{"amount":1000,"currency":"USD"},"total_money":{"amount":1000,"currency":"USD"},"status":"COMPLETED","source_type":"CARD","card_details":{"status":"CAPTURED","card":{"card_brand":"VISA","last_4":"2796","exp_month":7,"exp_year":2026,"fingerprint":"sq-1-TpmjbNBMFttvtaqXw"},"entry_method":"ON_FILE","cvv_status":"CVV_ACCEPTED","avs_status":"AVS_ACCEPTED","auth_result_code":"vPIr0K"},"billing_address":{"address_line_1":"500 Electric Ave","address_line_2":"Suite 600","locality":"New York","administrative_district_level_1":"NY","postal_code":"10003","country":"US"},"location_id":"XTI0H92143A39","order_id":"m2Hr8Hk8A3CTyQQ1k4ynExg92tO3","customer_id":"RDX9Z4XTIZR7MRZJUXNY9HUK6I","processing_fee":[{"effective_at":"2019-07-08T03:00:53.000Z","type":"INITIAL","amount_money":{"amount":59,"currency":"USD"}}]}],"cursor":"2TT6ifRa"}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Square.fetchTransactions(apcWrapper, JSON.serializePretty(fetchRequest));
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void fetchTransactions_When_Failure() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_SQUARE);
            
            Test.startTest();
            
            Processor_Square.FetchRequest fetchRequest = new Processor_Square.FetchRequest();
            fetchRequest.cursor = 'id';
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"errors":[{"code":"BAD_REQUEST","detail":"begin_time must be in RFC 3339 format","category":"INVALID_REQUEST_ERROR"}]}';
            httpMock.statusCode = 400;
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Square.fetchTransactions(apcWrapper, JSON.serializePretty(fetchRequest));
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }

    @IsTest
    static void createCheckoutURL_When_Success() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_SQUARE);
            
            Test.startTest();
            Map<String, Object> checkoutMap = new Map<String, Object>();
            checkoutMap.put('ask_for_shipping_address', true);
            checkoutMap.put('customer_id', 'abc12345');
            checkoutMap.put('location_id', 'abc12345');
            checkoutMap.put('merchant_support_email', 'testmt@test.com');
            checkoutMap.put('buyer_email', 'testbuyer@test.com');

            Map<String,Object> shipping = new Map<String,Object>();
                shipping.put('first_name', 'Sannith Reddy');
                shipping.put('last_name', 'Nevuri');
                shipping.put('email', 'testshipping@test.com');
                shipping.put('address_line_1', 'address_line_1');
                shipping.put('address_line_2', 'address_line_2');
                shipping.put('locality', 'NY');
                shipping.put('administrative_district_level_1','Texas');
                shipping.put('country', 'US');
                shipping.put('postal_code', '12345');
            checkoutMap.put('shipping', shipping);

            Map<String,Object> line_item = new Map<String,Object>();
                line_item.put('quantity', '5');
                line_item.put('unit_price', '100');
                line_item.put('item_currency', 'USD');
                line_item.put('name', 'Ball');
                line_item.put('note', 'To play cricket');
            List<Object> line_items = new List<Object>();
                line_items.add(line_item);    	
            checkoutMap.put('line_items', line_items);
            Map<String, Object> requestJSONMap = new Map<String, Object>();
            requestJSONMap.put('checkout', new List<Object>{checkoutMap});
                    
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"checkout":{"id":"CBASEIdKLdVKFzXqmOuY4JsbRN0","checkout_page_url":"https://connect.squareupsandbox.com/v2/checkout?c=CBASEIdKLdVKFzXqmOuY4JsbRN0\u0026l=L562DM0KHSY9B","ask_for_shipping_address":true,"merchant_support_email":"testmt@test.com","pre_populate_buyer_email":"testbuyer@test.com","order":{"id":"7LVFLEHWAx6DvdMjTfDq8vH6Wg4F","location_id":"L562DM0KHSY9B","reference_id":"null","source":{"name":"Sandbox for sq0idp-m0EwPLnKnMT6zfU_vq6YRA"},"customer_id":"XXXXXXX","line_items":[{"uid":"ZkezNBa2cT5YTGN1HvJx8C","name":"Ball","quantity":"5","note":"To play cricket","item_type":"ITEM","base_price_money":{"amount":100,"currency":"USD"},"variation_total_price_money":{"amount":500,"currency":"USD"},"gross_sales_money":{"amount":500,"currency":"USD"},"total_tax_money":{"amount":0,"currency":"USD"},"total_discount_money":{"amount":0,"currency":"USD"},"total_money":{"amount":500,"currency":"USD"}},{"uid":"lADIOT37fsAwoYyP3NqbjD","name":"Laptop","quantity":"1","note":"For gaming","item_type":"ITEM","base_price_money":{"amount":75000,"currency":"USD"},"variation_total_price_money":{"amount":75000,"currency":"USD"},"gross_sales_money":{"amount":75000,"currency":"USD"},"total_tax_money":{"amount":0,"currency":"USD"},"total_discount_money":{"amount":0,"currency":"USD"},"total_money":{"amount":75000,"currency":"USD"}}],"net_amounts":{"total_money":{"amount":75500,"currency":"USD"},"tax_money":{"amount":0,"currency":"USD"},"discount_money":{"amount":0,"currency":"USD"},"tip_money":{"amount":0,"currency":"USD"},"service_charge_money":{"amount":0,"currency":"USD"}},"created_at":"2021-10-08T13:12:50.223Z","updated_at":"2021-10-08T13:12:50.223Z","state":"OPEN","version":1,"total_money":{"amount":75500,"currency":"USD"},"total_tax_money":{"amount":0,"currency":"USD"},"total_discount_money":{"amount":0,"currency":"USD"},"total_tip_money":{"amount":0,"currency":"USD"},"total_service_charge_money":{"amount":0,"currency":"USD"}},"created_at":"2021-10-08T13:12:50Z"}}';
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Square.createCheckoutURL(apcWrapper, JSON.serializePretty(requestJSONMap));
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void createCheckoutURL_When_Failure() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_SQUARE);            
            Test.startTest();            
            Map<String, Object> checkoutMap = new Map<String, Object>();
            checkoutMap.put('ask_for_shipping_address', true);
            checkoutMap.put('customer_id', 'abc12345');
            Map<String, Object> requestJSONMap = new Map<String, Object>();
            requestJSONMap.put('checkout', new List<Object>{checkoutMap});
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"errors":[{"category":"INVALID_REQUEST_ERROR","code":"VALUE_TOO_LOW","detail":"`order.total_money.amount` must be greater than 1.","field":"order.total_money.amount"}]}';
            httpMock.statusCode = 400;
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Square.createCheckoutURL(apcWrapper, JSON.serializePretty(requestJSONMap));
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }
        
    @IsTest
    static void historicalPaymentSync_When_Success() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_SQUARE);
            
            Test.startTest();
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"payments":[{"id":"jhiugi","created_at":"2019-07-09T14:36:13.745Z","updated_at":"2019-07-09T14:36:13.883Z","amount_money":{"amount":1000,"currency":"USD"},"app_fee_money":{"amount":1000,"currency":"USD"},"refunded_money":{"amount":100,"currency":"USD"},"total_money":{"amount":1000,"currency":"USD"},"status":"APPROVED","source_type":"CARD","card_details":{"status":"AUTHORIZED","card":{"card_brand":"VISA","last_4":"5858","exp_month":8,"exp_year":2022,"fingerprint":"sq-1-lHpUJIUyqOPQmH8KVA"}},"location_id":"QLIJX16Q3UZ0A","order_id":"MvfIiFzRxv"},{"id":"GQTFp1osiDFf","created_at":"2019-07-08T01:00:51.607Z","updated_at":"2019-07-08T01:13:58.508Z","amount_money":{"amount":1000,"currency":"USD"},"total_money":{"amount":1000,"currency":"USD"},"status":"COMPLETED","source_type":"CARD","card_details":{"status":"CAPTURED","card":{"card_brand":"VISA","last_4":"2796","exp_month":7,"exp_year":2026,"fingerprint":"sq-1-TpmjbNBMFdibiIjpQI5LiRgNUBC7u1689i0TgHjnlyHEWYB7tnn-K4QbW4ttvtaqXw"},"entry_method":"ON_FILE","cvv_status":"CVV_ACCEPTED","avs_status":"AVS_ACCEPTED","auth_result_code":"vPIr0K"},"billing_address":{"address_line_1":"500 Electric Ave","address_line_2":"Suite 600","locality":"New York","administrative_district_level_1":"NY","postal_code":"10003","country":"US"},"location_id":"XTI0H92143A39","order_id":"jhui","customer_id":"jh","processing_fee":[{"effective_at":"2019-07-08T03:00:53.000Z","type":"INITIAL","amount_money":{"amount":59,"currency":"USD"}}]}],"cursor":"2TT6ifRa"}';
            Test.setMock(HttpCalloutMock.class, httpMock);
            HistoricalSyncBatch historicalSync = new HistoricalSyncBatch('Payment');
            
            Database.executeBatch(historicalSync, 1);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void historicalPaymentSync_When_Failure() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_SQUARE);
            
            Test.startTest();
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"errors":[{"code":"BAD_REQUEST","detail":"begin_time must be in RFC 3339 format","category":"INVALID_REQUEST_ERROR"}]}';
            httpMock.statusCode = 400;
            Test.setMock(HttpCalloutMock.class, httpMock);
            HistoricalSyncBatch historicalSync = new HistoricalSyncBatch('Payment');
            
            Database.executeBatch(historicalSync, 1);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void syncCustomers_When_NewCustomer() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_SQUARE);
            
            //Create card and all child classes
            Customer.SquareAddress addr = new Customer.SquareAddress();
            addr.address_line_1 = 'addr1';
            addr.address_line_2 = 'add2';
            
            Customer.SquareCard sqCard = new Customer.SquareCard();
            sqCard.last_4 = '1122';
            sqCard.exp_month = 10;
            sqCard.exp_year = 2025;
            sqCard.cardholder_name = 'Michael Glass';
            sqCard.card_brand = 'abc123';
            sqCard.billing_address = addr;
            
            Customer.SquareCustomer sqCust = new Customer.SquareCustomer();
            sqCust.id = 'Y3VzdG9tZXJfODY4NDE5MjI5';
            sqCust.company_name = 'Acme Inc.';
            sqCust.email_address = 'test@test.com';
            sqCust.created_at = '2020-08-21T12:32:09.729Z';
            sqCust.address = addr;
            sqCust.cards = new List<Customer.SquareCard>{sqCard};
                
                Map<String, Customer.SquareCustomer> squareCustMap = new Map<String, Customer.SquareCustomer>{
                    sqCust.id => sqCust
                        };
                            
                            Map<String, Object> processorIdToPaymentMap = new Map<String, Object>{
                                ProcessorUtil.PAT_SQUARE => squareCustMap
                                    };
                                        
                                        Processor_Square.syncCustomers(processorIdToPaymentMap, apcWrapper, true);
            
            //TODO: Verify the customer was added
            Integer custCount = [SELECT COUNT() FROM BWP_Customer__c WHERE Company__c = :sqCust.company_name];
            System.assertEquals(1, custCount);
        }
    }
    
    @IsTest
    static void syncTransactions() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BWP_Processor_Config__c apc = UnitTests.createPayConfig(ProcessorUtil.PAT_SQUARE);
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_SQUARE);
            
            BWP_Customer__c bwpCust = new BWP_Customer__c(
                First_Name__c = 'Roger',
                Last_Name__c = 'Howe',
                Processor_Customer_Id__c = 'Y3VzdG9tZXJfODY4NDE5MjI5'
            );
            insert bwpCust;
            
            //Create a Charge.BraintreeCharge object that will get passed into syncTransactions as part of a map
            Charge.Customer chargeCust = new Charge.Customer();
            chargeCust.id = bwpCust.Processor_Customer_Id__c;
            
            Charge.PaymentMethod chargePM = new Charge.PaymentMethod();
            chargePM.id = 'id=cGF5bWVudG1ldGhvZF9jY185dmp5d2cy';
            
            Charge.SquareCharge sqCharge = new Charge.SquareCharge();
            Charge.Money sqAmount = new Charge.Money();
            sqAmount.amount = 15.00;
            sqAmount.square_currency = 'USD';
            
            sqCharge.amount_money = sqAmount;
            sqCharge.customer_id = bwpCust.Id;
            sqCharge.id = apc.Provider_ID__c;
            sqCharge.status = 'SETTLED';
            
            Map<String, Charge.SquareCharge> squareChargeMap = new Map<String, Charge.SquareCharge>{
                apc.Provider_ID__c => sqCharge
                    };
                        
                        Map<String, Object> processorIdToPaymentMap = new Map<String, Object>{
                            ProcessorUtil.PAT_SQUARE => squareChargeMap
                                };
                                    
                                    List<ProcessorUtil.TransactionWrapper> response = Processor_Square.syncTransactions(processorIdToPaymentMap, apcWrapper);
            
            // TODO: Verify the payment was added
            // Integer paymentCount = [SELECT COUNT() FROM BWP_Payment__c WHERE Customer__c = :bwpCust.Id];
            // System.assertEquals(1, paymentCount);
        }
        
    }
    
    @IsTest
    static void constructSquarePaymentMethod() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_SQUARE);
            
            //Create card and all child classes
            Customer.SquareAddress addr = new Customer.SquareAddress();
            addr.address_line_1 = 'addr1';
            addr.address_line_2 = 'add2';
            
            Customer.SquareCard sqCard = new Customer.SquareCard();
            sqCard.last_4 = '1122';
            sqCard.exp_month = 10;
            sqCard.exp_year = 2025;
            sqCard.cardholder_name = 'Michael Glass';
            sqCard.card_brand = 'abc123';
            sqCard.billing_address = addr;
            
            Processor_Square.constructSquarePaymentMethod(new BWP_Payment_Method__c(), sqCard, apcWrapper);
        }
    }
    
    @IsTest
    static void constructSquareCustomer() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_SQUARE);
            
            Customer.SquareAddress addr = new Customer.SquareAddress();
            addr.address_line_1 = 'addr1';
            addr.address_line_2 = 'add2';
            Customer.SquareCustomer sqCust = new Customer.SquareCustomer();
            
            sqCust.address = addr;
            sqCust.created_at = '2020-08-21T12:32:09.729Z';
            
            Processor_Square.constructSquareCustomer(new BWP_Customer__c(), sqCust, apcWrapper);
        }
    }
    @IsTest
    static void constructSquareTransaction() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_SQUARE);
            
            Customer.SquareAddress addr = new Customer.SquareAddress();
            addr.address_line_1 = 'addr1';
            addr.address_line_2 = 'add2';
            
            Charge.Money amt = new Charge.Money();
            amt.amount = 4.44;
            
            Charge.Money appFee = new Charge.Money();
            appFee.amount = 2.22;
            
            Charge.Money procFeeAmt = new Charge.Money();
            procFeeAmt.amount = 3.33;
            
            Charge.processingFee procFee  = new Charge.processingFee();
            procFee.amount_money = procFeeAmt;
            List<Charge.processingFee> procFees = new List<Charge.processingFee>{procFee};
                
                Charge.SquareCharge sqCharge = new Charge.SquareCharge();
            sqCharge.amount_money = amt;
            sqCharge.app_fee_money = appFee;
            sqCharge.processing_fee = procFees;
            sqCharge.billing_address = addr;
            sqCharge.created_at = '2020-08-21T12:32:09.729Z';
            
            Processor_Square.constructSquareTransaction(new BWP_Transaction__c(), sqCharge, apcWrapper);
        }
    }
    
}