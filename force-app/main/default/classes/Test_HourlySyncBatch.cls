/**
* Hourly Sync should be tested in this class
*/
@IsTest
private class Test_HourlySyncBatch {
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
    static void stripe_HourlySync_When_Success() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BWP_Processor_Config__c apc = UnitTests.createPayConfig(ProcessorUtil.PAT_STRIPE);
            Test.startTest();
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"object":"list","data":[{"id":"cus_Fk0tuYLi2hoGD7","object":"customer","account_balance":0,"address":null,"balance":0,"created":1567497366,"currency":null,"default_source":null,"delinquent":false,"description":null,"discount":null,"email":null,"invoice_prefix":"35B741BF","invoice_settings":{"custom_fields":null,"default_payment_method":null,"footer":null},"livemode":false,"metadata":{},"name":null,"phone":null,"preferred_locales":[],"shipping":null,"sources":{"object":"list","data":[{"id": "card_1G6dmEGZcuOzNASabbkto2Zd","object": "card","address_city": "knr", "address_country": "knr","address_line1": "kpt","address_line1_check": "kpt","address_line2": "kpt","address_state": "test","address_zip": "42424","address_zip_check": "pass","brand": "Visa","country": "US","customer": "cus_GdvdUEIDyUZQHd", "cvc_check": "pass","dynamic_last4": null, "exp_month": 4, "exp_year": 2024,"fingerprint": "n3cJX3BYeVmuPLfY","funding": "credit","last4": "4242","name": "test card name"},{ "id": "ba_1G6tRfGZcuOzNASa2eXCHZPx", "object": "bank_account","account_holder_name": "sam", "account_holder_type": "individual", "bank_name": "STRIPE TEST BANK","country": "US","currency": "usd", "cusomer": "cus_GdvdUEIDyUZQHd","fingerprint": "9XHNRgdny9ngsir5","last4": "6789","routing_number": "110000000","status": "verified"},{"id": "card_1G6dmEGZcuOzNASabbkto2Zd","object": "source","type":"card","brand": "Visa","country": "US","customer": "cus_GdvdUEIDyUZQHd", "cvc_check": "pass","dynamic_last4": null, "exp_month": 4, "exp_year": 2024,"fingerprint": "n3cJX3BYeVmuPLfY","funding": "credit","last4": "4242","name": "test card name"}],"has_more":false,"total_count":0,"url":"/v1/customers/cus_Fk0tuYLi2hoGD7/sources"},"subscriptions":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/customers/cus_Fk0tuYLi2hoGD7/subscriptions"},"tax_exempt":"none","tax_ids":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/customers/cus_Fk0tuYLi2hoGD7/tax_ids"},"tax_info":null,"tax_info_verification":null},{"id":"cus_FiCx160BmSxMSW","object":"customer","account_balance":0,"address":null,"balance":0,"created":1567080956,"currency":null,"default_source":null,"delinquent":false,"description":null,"discount":null,"email":"me@me.com","invoice_prefix":"36348D6A","invoice_settings":{"custom_fields":null,"default_payment_method":null,"footer":null},"livemode":false,"metadata":{},"name":"Regular Sync Check at 17:45 29-08","phone":null,"preferred_locales":[],"shipping":{"address":{"city":"","country":"","line1":"","line2":"","postal_code":"","state":""},"name":"Regular Sync Check at 17:45 29-08","phone":""},"sources":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/customers/cus_FiCx160BmSxMSW/sources"},"subscriptions":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/customers/cus_FiCx160BmSxMSW/subscriptions"},"tax_exempt":"none","tax_ids":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/customers/cus_FiCx160BmSxMSW/tax_ids"},"tax_info":null,"tax_info_verification":null}],"has_more":false,"url":"/v1/customers"}';
            Test.setMock(HttpCalloutMock.class, httpMock);
            HourlySyncBatch HourlySync = new HourlySyncBatch('Customer');
            Database.executeBatch(HourlySync, 1);
            Test.stopTest();
        }
    }
    
    @IsTest
    static void stripe_HourlySync_When_Failure() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BWP_Processor_Config__c apc = UnitTests.createPayConfig(ProcessorUtil.PAT_STRIPE);
            Test.startTest();
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"object":"list","data":[],"has_more":false,"url":"/v1/customers"}';
            httpMock.statusCode = 400;
            Test.setMock(HttpCalloutMock.class, httpMock);
            HourlySyncBatch HourlySync = new HourlySyncBatch('Customer');
            Database.executeBatch(HourlySync, 1);
            Test.stopTest();
        }
    }
    
    @IsTest
    static void braintree_HourlySync_When_Success() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BWP_Processor_Config__c apc = UnitTests.createPayConfig(ProcessorUtil.PAT_BRAINTREE);
            apc.Customer_Match_Type__c = ProcessorUtil.CMT_CONTACT;
            BreadwinnerUtil.isBreadwinnerTransaction = true;
            update apc;
            Test.startTest();
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response =
                '{"data": ' +
                '{"search":' +
                '{"customers":' +
                '{"pageInfo": ' +
                '{"hasNextPage": true,"startCursor": "WTNWemRHOXRaWEpmTWpBek1USTRNekV6OzIwMTktMTEtMDVUMDc6Mzc6MzNa","endCursor": "WTNWemRHOXRaWEpmTWpBek1USTRNekV6OzIwMTktMTEtMDVUMDc6Mzc6MzNa"},' +
                '"edges": [{"node": {"id": "Y3VzdG9tZXJfMjAzMTI4MzEz","company": null,"createdAt": "2019-11-05T07:37:33.000000Z","firstName": "test", "lastName" : "customer", "paymentMethods": {"edges":[{"node":{"id":"cGF5bWVudG1ldGhvZF9jY19mdGh5dzNy","usage":"MULTI_USE","details":{"__typename":"CreditCardDetails"}}}]}},"cursor": "WTNWemRHOXRaWEpmTWpBek1USTRNekV6OzIwMTktMTEtMDVUMDc6Mzc6MzNa"}]}' +
                '}' +
                '}' +
                ',"extensions": {"requestId": "sqpdag6n0R2NGBv73fmp0BqhsgKABgH0tNH5rWkjTU3jBg9Z0WCKhg=="}' +
                '}';
            Test.setMock(HttpCalloutMock.class, httpMock);
            HourlySyncBatch customerHourlySync = new HourlySyncBatch('Customer');
            Database.executeBatch(customerHourlySync, 1);
            HourlySyncBatch paymentHourlySync = new HourlySyncBatch('Payment');
            Database.executeBatch(paymentHourlySync, 1);
            Test.stopTest();
        }
    }

    @IsTest
    static void square_HourlySync_When_Success() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BWP_Processor_Config__c apc = UnitTests.createPayConfig(ProcessorUtil.PAT_SQUARE);
            Test.startTest();
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"customers":[{"id":"SWGYZ9TY7D6BSBSE4P6HAXP5WC","created_at":"2020-08-21T12:32:09.729Z","updated_at":"2020-08-21T12:32:10Z","cards":[{"id":"ccof:s2ubjSqliLxt0JRz3GB","card_brand":"VISA","last_4":"5858","exp_month":8,"exp_year":2022,"cardholder_name": "Amelia Earhart","billing_address":{"address_line_1":"500 Electric Ave","address_line_2":"Suite 600","locality":"New York","administrative_district_level_1":"NY","postal_code":"10003","country":"US"}}],"given_name":"Acme Start","email_address":"acme@gmail.com", "address":{"address_line_1":"500 Electric Ave","address_line_2":"Suite 600","locality":"New York","administrative_district_level_1":"NY","postal_code":"10003","country":"US"}}],"cursor":"C=="}';
            Test.setMock(HttpCalloutMock.class, httpMock);
            HourlySyncBatch HourlySync = new HourlySyncBatch('Customer');
            Database.executeBatch(HourlySync, 1);
            Test.stopTest();
        }
    }    

    @IsTest
    static void square_HourlyPaymentSync_When_Success() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BWP_Processor_Config__c apc = UnitTests.createPayConfig(ProcessorUtil.PAT_SQUARE);
            Test.startTest();
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"payments":[{"id":"jhiugi","created_at":"2019-07-09T14:36:13.745Z","updated_at":"2019-07-09T14:36:13.883Z","amount_money":{"amount":1000,"currency":"USD"},"app_fee_money":{"amount":1000,"currency":"USD"},"refunded_money":{"amount":100,"currency":"USD"},"total_money":{"amount":1000,"currency":"USD"},"status":"APPROVED","source_type":"CARD","card_details":{"status":"AUTHORIZED","card":{"card_brand":"VISA","last_4":"5858","exp_month":8,"exp_year":2022,"fingerprint":"sq-1-lHpUJIUyqOPQmH8KVA"}},"location_id":"QLIJX16Q3UZ0A","order_id":"MvfIiFzRxv"},{"id":"GQTFp1osiDFf","created_at":"2019-07-08T01:00:51.607Z","updated_at":"2019-07-08T01:13:58.508Z","amount_money":{"amount":1000,"currency":"USD"},"total_money":{"amount":1000,"currency":"USD"},"status":"COMPLETED","source_type":"CARD","card_details":{"status":"CAPTURED","card":{"card_brand":"VISA","last_4":"2796","exp_month":7,"exp_year":2026,"fingerprint":"sq-1-TpmjbNBMFdibiIjpQI5LiRgNUBC7u1689i0TgHjnlyHEWYB7tnn-K4QbW4ttvtaqXw"},"entry_method":"ON_FILE","cvv_status":"CVV_ACCEPTED","avs_status":"AVS_ACCEPTED","auth_result_code":"vPIr0K"},"billing_address":{"address_line_1":"500 Electric Ave","address_line_2":"Suite 600","locality":"New York","administrative_district_level_1":"NY","postal_code":"10003","country":"US"},"location_id":"XTI0H92143A39","order_id":"jhui","customer_id":"jh","processing_fee":[{"effective_at":"2019-07-08T03:00:53.000Z","type":"INITIAL","amount_money":{"amount":59,"currency":"USD"}}]}],"cursor":"2TT6ifRa"}';
            Test.setMock(HttpCalloutMock.class, httpMock);
            HourlySyncBatch HourlySync = new HourlySyncBatch('Payment');
            Database.executeBatch(HourlySync, 1);
            Test.stopTest();
        }
    }

    @IsTest
    static void square_HourlySync_When_Failure() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BWP_Processor_Config__c apc = UnitTests.createPayConfig(ProcessorUtil.PAT_SQUARE);
            Test.startTest();
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"errors":[{"code":"INVALID_ENUM_VALUE","detail":"`Dec` is not a valid enum value for `sort_order`.","field":"sort_order","category":"INVALID_REQUEST_ERROR"}]}';
            httpMock.statusCode = 400;
            Test.setMock(HttpCalloutMock.class, httpMock);
            HourlySyncBatch HourlySync = new HourlySyncBatch('Customer');
            Database.executeBatch(HourlySync, 1);
            HourlySyncBatch paymentHourlySync = new HourlySyncBatch('Payment');
            Database.executeBatch(paymentHourlySync, 1);
            Test.stopTest();
        }
    }

    /* Removing until we actually need this for code coverage
    @IsTest
    static void paypal_HourlySync_When_Success() {
        BWP_Processor_Config__c apc = UnitTests.createPayConfig(ProcessorUtil.PAT_PAYPAL);
        Test.startTest();
        UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
        httpMock.response = '{"transaction_details":[{"transaction_info":{"paypal_account_id":"D42UKH3SM7GLW","transaction_id":"60U965010N787725U","transaction_event_code":"T0001","transaction_initiation_date":"2020-10-15T09:20:14+0000","transaction_updated_date":"2020-10-15T09:20:14+0000","transaction_amount":{"currency_code":"USD","value":"1.87"},"transaction_status":"S","transaction_subject":"You have a payout!","transaction_note":"You have received a payout! Thanks for using our service!","ending_balance":{"currency_code":"USD","value":"5939.90"},"available_balance":{"currency_code":"USD","value":"5939.90"},"custom_field":"201403140001","protection_eligibility":"02"},"payer_info":{"account_id":"D42UKH3SM7GLW","email_address":"sb-mrlyn3212482@business.example.com","address_status":"N","payer_status":"Y","payer_name":{"alternate_full_name":"John Doe Test Store"},"country_code":"US"},"shipping_info":{"name":"John, Doe"}},{"transaction_info":{"paypal_account_id":"D42UKH3SM7GLW","transaction_id":"5FL977279A849764V","transaction_event_code":"T0001","transaction_initiation_date":"2020-10-15T12:04:15+0000","transaction_updated_date":"2020-10-15T12:04:15+0000","transaction_amount":{"currency_code":"USD","value":"1.87"},"transaction_status":"S","transaction_subject":"You have a payout!","transaction_note":"You have received a payout! Thanks for using our service!","ending_balance":{"currency_code":"USD","value":"5960.47"},"available_balance":{"currency_code":"USD","value":"5960.47"},"custom_field":"201403140001","protection_eligibility":"02"},"payer_info":{"account_id":"D42UKH3SM7GLW","email_address":"sb-mrlyn3212482@business.example.com","address_status":"N","payer_status":"Y","payer_name":{"alternate_full_name":"John Does Test Store"},"country_code":"US"},"shipping_info":{"name":"John, Doe"}}],"account_number":"XPYWY78WX7HNG","start_date":"2020-10-11T11:15:04+0000","end_date":"2020-11-10T11:15:04+0000","last_refreshed_datetime":"2020-12-10T09:59:59+0000","page":1,"total_items":2,"total_pages":1}';
        Test.setMock(HttpCalloutMock.class, httpMock);
        HourlySyncBatch HourlySync = new HourlySyncBatch('Payment');
        Database.executeBatch(HourlySync, 1);
        Test.stopTest();
    }
    
    @IsTest
    static void paypal_HourlySync_When_Failure() {
        BWP_Processor_Config__c apc = UnitTests.createPayConfig(ProcessorUtil.PAT_PAYPAL);
        Test.startTest();
        UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
        httpMock.response = '{"name":"INVALID_REQUEST","message":"Invalid request - see details.","debug_id":"633f738a5da84","details":[{"field":"end_date","value":"2020-10-06T09:38:07.410Z","location":"query","issue":"Date range is greater than 31 days"}],"links":[]}';
        httpMock.statusCode = 400;
        Test.setMock(HttpCalloutMock.class, httpMock);
        HourlySyncBatch HourlySync = new HourlySyncBatch('Payment');
        Database.executeBatch(HourlySync, 1);
        Test.stopTest();
    } */

    @IsTest
    static void auth_Net_HourlyCustomerSync_When_Success() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            List<BWP_Processor_Config__c> apcs = UnitTests.createPayConfig(1, ProcessorUtil.PAT_AUTHORIZE_NET);
            Test.startTest();
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"ids":["47988","47997","48458","48468","189118","190178"],"messages":{"resultCode":"Ok","message":[{"code":"I00001","text":"Successful."}]}}';
            Test.setMock(HttpCalloutMock.class, httpMock);
            HourlySyncBatch HourlySync = new HourlySyncBatch('Customer');
            Database.executeBatch(HourlySync, 1);
            Test.stopTest();
        }
    }

    @IsTest
    static void auth_Net_HourlyPaymentSync_When_Success() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            List<BWP_Processor_Config__c> apcs = UnitTests.createPayConfig(1, ProcessorUtil.PAT_AUTHORIZE_NET);
            Test.startTest();
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"batchList":[{"batchId":"11856714","settlementTimeUTC":"2021-07-02T04:14:18Z","settlementTimeLocal":"2021-07-01T21:14:18","settlementState":"settledSuccessfully","paymentMethod":"creditCard","marketType":"eCommerce","product":"Card Not Present"},{"batchId":"11870986","settlementTimeUTC":"2021-07-07T02:46:47Z","settlementTimeLocal":"2021-07-06T19:46:47","settlementState":"settledSuccessfully","paymentMethod":"creditCard","marketType":"eCommerce","product":"Card Not Present"}],"messages":{"resultCode":"Ok","message":[{"code":"I00001","text":"Successful."}]}}';   
            Test.setMock(HttpCalloutMock.class, httpMock);
            HourlySyncBatch HourlySync = new HourlySyncBatch('Payment');
            Database.executeBatch(HourlySync, 1);
            Test.stopTest();
        }
    }
}