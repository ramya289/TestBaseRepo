/**
* Everything that is Processor specific should be tested in this class
*/
@IsTest
private class Test_Processor_Stripe {
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
            Breadwinner.getParameters().put('state', '{"SFMode":"classic","ProMode":"test","ProType":"Stripe","Callback":"https://c.ap16.visual.force.com/apex/BreadwinnerPayments"}');
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"token_type":"bearer","stripe_publishable_key":"{PUBLISHABLE_KEY}","scope":"read_write","livemode":false,"stripe_user_id":"{ACCOUNT_ID}","refresh_token":"{REFRESH_TOKEN}","access_token":"{ACCESS_TOKEN}"}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            BreadwinnerController bc = new BreadwinnerController();
            
            bc.saveStripeCredentials();
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
            Breadwinner.getParameters().put('state', '{"SFMode":"classic","ProMode":"test","ProType":"Stripe","Callback":"https://c.ap16.visual.force.com/apex/BreadwinnerPayments"}');
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"token_type":"bearer","stripe_publishable_key":"{PUBLISHABLE_KEY}","scope":"read_write","livemode":false,"stripe_user_id":"{ACCOUNT_ID}","refresh_token":"{REFRESH_TOKEN}","access_token":"{ACCESS_TOKEN}"}';
            httpMock.statusCode = 400;
            Test.setMock(HttpCalloutMock.class, httpMock);
            BreadwinnerController bc = new BreadwinnerController();
            
            bc.saveStripeCredentials();
        }
        Test.stopTest();
    }
    
    @IsTest
    static void coverageForAuthorizationMethods(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerController bc = new BreadwinnerController();
            bc.getStripeAuthUrl();
            bc.getStripeTestAuthUrl();
        }
    }
    
    @IsTest
    static void coverageForOverrideMethods() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            try{
                Processor_Stripe ps = new Processor_Stripe('12345');
            } catch (Exception ex){}
            BWP_Processor_Config__c apc = UnitTests.createPayConfig(ProcessorUtil.PAT_STRIPE);
            Processor_Stripe ps = new Processor_Stripe(apc.Provider_Id__c);
            try{
                ps.createCustomer('');
            } catch (Exception ex){}
            try{
                ps.createCardToken('');
            } catch (Exception ex){}
            try{
                ps.createBankToken('');
            } catch (Exception ex){}
            try{
                ps.chargeProcessor('', '');
            } catch (Exception ex){}
            try{
                ps.updateCustomer('');
            } catch (Exception ex){}
            try{
                ps.fetchCustomers('');
            } catch (Exception ex){}
            try{
                ps.fetchTransactions('');
            } catch (Exception ex){}
            try{
                ps.verifyBankAccount('');
            } catch (Exception ex){}
        }
    }
    
    @IsTest
    static void createCustomer_When_Success() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_STRIPE);
            
            Account acct = new Account(Name = 'Test Account');
            insert acct;
            
            Test.startTest();
            
            Customer.StripeCustomer stripeCustomer = new Customer.StripeCustomer();
            
            stripeCustomer.name = 'Stella Pavlova';
            stripeCustomer.email = 'test@test.com';
            stripeCustomer.phone = '773-631-4077';
            stripeCustomer.description = 'Customer Created by Breadwinner API at ';
            stripeCustomer.accountId = acct.Id;
            stripeCustomer.balance = 10;
            stripeCustomer.invoice_prefix = '64DFB18A';
            stripeCustomer.tax_exempt = 'exempt';
            //Billing Address
            Customer.Address add = new Customer.Address();
            add.line1 = '134  Poplar Chase Lane';
            add.line2 = 'Boise';
            add.city = 'Boise';
            add.state = 'Pennsylvania';
            add.country = 'US';
            add.postal_code = '19108';
            stripeCustomer.address = add;
            
            //Shipping Address
            Customer.Shipping shipAdd = new Customer.Shipping();
            shipAdd.name = 'Recipient Name';
            shipAdd.address = add;
            shipAdd.phone = '484-581-0499';
            stripeCustomer.shipping = shipAdd;
            
            //Tax
            Customer.Tax_info tax = new Customer.Tax_info();
            tax.stripe_type = 'eu_vat';
            tax.value = 'ATU00000000';
            stripeCustomer.tax_info = tax;
            
            Map<String, List<Customer.StripeCustomer>> customerMap = new Map<String, List<Customer.StripeCustomer>>();
            customerMap.put('customer', new List<Customer.StripeCustomer>{stripeCustomer});
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response ='{"id":"cus_FJsxWLVdjJpHdJ","object":"customer","account_balance":10,"address":{"city":"Boise","country":"US","line1":"134  Poplar Chase Lane","line2":"Boise","postal_code":"19108","state":"Pennsylvania"},"balance":10,"created":1561471196,"currency":"usd","default_source":null,"delinquent":false,"description":"Customer Created by Breadwinner API at 2019-06-25 13:59:55","discount":null,"email":"Stalin-1561471195485@gmail.com","invoice_prefix":"64DFB18A","invoice_settings":{"custom_fields":null,"default_payment_method":null,"footer":null},"livemode":false,"metadata":{},"name":"Customer From API-1561471195484","phone":"484-581-0499","preferred_locales":[],"shipping":{"address":{"city":"Boise","country":"US","line1":"134  Poplar Chase Lane","line2":"Boise","postal_code":"19108","state":"Pennsylvania"},"name":"Recipient Name","phone":"484-581-0499"},"sources":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/customers/cus_FJsxWLVdjJpHdJ/sources"},"subscriptions":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/customers/cus_FJsxWLVdjJpHdJ/subscriptions"},"tax_exempt":"exempt","tax_ids":{"object":"list","data":[{"id":"txi_1EpFBgGeHGxQ9S2fU9oqpZKQ","object":"tax_id","country":"AT","created":1561471196,"customer":"cus_FJsxWLVdjJpHdJ","livemode":false,"type":"eu_vat","value":"ATU00000000","verification":{"status":"pending","verified_address":null,"verified_name":null}}],"has_more":false,"total_count":1,"url":"/v1/customers/cus_FJsxWLVdjJpHdJ/tax_ids"},"tax_info":{"tax_id":"ATU00000000","type":"vat"},"tax_info_verification":{"status":"pending","verified_name":null}}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Stripe.createCustomer(apcWrapper, JSON.serializePretty(customerMap));
            System.debug('response: ' + response);
            System.assert([SELECT count() FROM BWP_Customer__c]>0);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void createCustomer_When_Failure() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_STRIPE);
            
            Test.startTest();
            
            Customer.StripeCustomer stripeCustomer = new Customer.StripeCustomer();
            stripeCustomer.name = 'Stella Pavlova';
            stripeCustomer.email = 'test@test.com';
            stripeCustomer.phone = '773-631-4077';
            stripeCustomer.accountId = '0012w00000MZ1sj';
            Map<String, List<Customer.StripeCustomer>> customerMap = new Map<String, List<Customer.StripeCustomer>>();
            customerMap.put('customer', new List<Customer.StripeCustomer>{stripeCustomer});
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.StatusCode = 400;
            httpMock.response ='{"id":"cus_FJsxWLVdjJpHdJ","object":"customer","account_balance":10,"address":{"city":"Boise","country":"US","line1":"134  Poplar Chase Lane","line2":"Boise","postal_code":"19108","state":"Pennsylvania"},"balance":10,"created":1561471196,"currency":"usd","default_source":null,"delinquent":false,"description":"Customer Created by Breadwinner API at 2019-06-25 13:59:55","discount":null,"email":"Stalin-1561471195485@gmail.com","invoice_prefix":"64DFB18A","invoice_settings":{"custom_fields":null,"default_payment_method":null,"footer":null},"livemode":false,"metadata":{},"name":"Customer From API-1561471195484","phone":"484-581-0499","preferred_locales":[],"shipping":{"address":{"city":"Boise","country":"US","line1":"134  Poplar Chase Lane","line2":"Boise","postal_code":"19108","state":"Pennsylvania"},"name":"Recipient Name","phone":"484-581-0499"},"sources":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/customers/cus_FJsxWLVdjJpHdJ/sources"},"subscriptions":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/customers/cus_FJsxWLVdjJpHdJ/subscriptions"},"tax_exempt":"exempt","tax_ids":{"object":"list","data":[{"id":"txi_1EpFBgGeHGxQ9S2fU9oqpZKQ","object":"tax_id","country":"AT","created":1561471196,"customer":"cus_FJsxWLVdjJpHdJ","livemode":false,"type":"eu_vat","value":"ATU00000000","verification":{"status":"pending","verified_address":null,"verified_name":null}}],"has_more":false,"total_count":1,"url":"/v1/customers/cus_FJsxWLVdjJpHdJ/tax_ids"},"tax_info":{"tax_id":"ATU00000000","type":"vat"},"tax_info_verification":{"status":"pending","verified_name":null}}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Stripe.createCustomer(apcWrapper, JSON.serializePretty(customerMap));
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void createCard_When_Success() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_STRIPE);
            
            Test.startTest();
            
            Customer.StripeCustomer customer = new Customer.StripeCustomer();
            customer.id = 'processorCustomerId';
            List<Customer.Source> datalist = new  list<Customer.Source>();
            Customer.Source data = new Customer.Source();
            data.cardNumber = '4242424242424';
            data.exp_month = '12';
            data.exp_year = '23';
            data.cvc = '111';
            data.name = 'Stella';
            datalist.add(data);
            Customer.Sources data2 = new  Customer.Sources();
            data2.data = datalist;                    
            customer.Sources = data2;
            Map<String, List<Customer.StripeCustomer>> customerMap = new Map<String, List<Customer.StripeCustomer>>();
            customerMap.put('customer', new List<Customer.StripeCustomer>{customer});
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            
            httpMock.response = '{"id": "tok_1HWzW8HS2n7fPYIUC51HPrQC","object": "token"}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Stripe.createCardToken(apcWrapper, JSON.serializePretty(customerMap));
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void createCard_When_Failure() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_STRIPE);
            
            Test.startTest();
            
            Customer.StripeCustomer customer = new Customer.StripeCustomer();
            customer.id = 'processorCustomerId';
            List<Customer.Source> datalist = new  list<Customer.Source>();
            Customer.Source data = new Customer.Source();
            data.cardNumber = '42424242';
            data.exp_month = '12';
            data.exp_year = '23';
            data.cvc = '111';
            data.name = 'Stella';
            datalist.add(data);
            Customer.Sources data2 = new  Customer.Sources();
            data2.data = datalist;                    
            customer.Sources = data2;
            Map<String, List<Customer.StripeCustomer>> customerMap = new Map<String, List<Customer.StripeCustomer>>();
            customerMap.put('customer', new List<Customer.StripeCustomer>{customer});
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"error": {"code": "incorrect_number","message": "Your card number is incorrect." }}';
            httpMock.statusCode = 400;
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Stripe.createCardToken(apcWrapper, JSON.serializePretty(customerMap));
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void createBankAccount_When_Success() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_STRIPE);
            
            Test.startTest();
            
            Customer.StripeCustomer customer = new Customer.StripeCustomer();
            customer.id = 'processorCustomerId';
            List<Customer.Source> datalist = new  list<Customer.Source>();
            Customer.Source data = new Customer.Source();
            data.account_number = '000123456789';
            data.account_holder_name = 'Stella';
            data.routing_number = '1100000000';
            datalist.add(data);
            Customer.Sources data2 = new  Customer.Sources();
            data2.data = datalist;                    
            customer.Sources = data2;
            Map<String, List<Customer.StripeCustomer>> customerMap = new Map<String, List<Customer.StripeCustomer>>();
            customerMap.put('customer', new List<Customer.StripeCustomer>{customer});
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            
            httpMock.response = '{"id": "tok_1HWzW8HS2n7fPYIUC51HPrQC","object": "token"}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Stripe.createBankToken(apcWrapper, JSON.serializePretty(customerMap));
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void createBankAccount_When_Failure() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_STRIPE);
            
            Test.startTest();
            
            Customer.StripeCustomer customer = new Customer.StripeCustomer();
            customer.id = 'processorCustomerId';
            List<Customer.Source> datalist = new  list<Customer.Source>();
            Customer.Source data = new Customer.Source();
            data.account_number = '000123456789';
            data.account_holder_name = 'Stella';
            data.routing_number = '1100000000';
            datalist.add(data);
            Customer.Sources data2 = new  Customer.Sources();
            data2.data = datalist;                    
            customer.Sources = data2;
            Map<String, List<Customer.StripeCustomer>> customerMap = new Map<String, List<Customer.StripeCustomer>>();
            customerMap.put('customer', new List<Customer.StripeCustomer>{customer});
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            
            httpMock.response = '{"id": "tok_1HWzW8HS2n7fPYIUC51HPrQC","object": "token"}';
            httpMock.statusCode = 400;
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Stripe.createBankToken(apcWrapper, JSON.serializePretty(customerMap));
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void createCharge_When_Success() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_STRIPE);
            
            Test.startTest();
            Charge.StripeCharge ch = new Charge.StripeCharge();
            ch.amount = 100;
            ch.customer = 'cus_Id';
            ch.stripe_currency = 'usd';
            ch.paymentMethod = 'paymentMethodId';
            ch.paymentMethodType = ProcessorUtil.PM_CARD;
            
            Map<String, List<Charge.StripeCharge>> chargeMap = new Map<String, List<Charge.StripeCharge>>();
            chargeMap.put('charge', new List<Charge.StripeCharge>{ch});
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"id":"piid","object":"payment_intent","allowed_source_types":["card"],"amount":10000,"amount_capturable":0,"amount_received":10000,"charges":{"object":"list","data":[{"id":"ch","object":"charge","amount":10000,"amount_refunded":0,"application":"ca","application_fee":null,"application_fee_amount":null,"balance_transaction":"txz","billing_details":{"address":{"city":null,"country":null,"line1":null,"line2":null,"postal_code":"13113","state":null},"email":null,"name":null,"phone":null},"captured":true,"created":1565676425,"currency":"usd","customer":"cus_FUgYqCqYcMDBpy","description":"Payment created by API at 2019-08-13 06:07:04","destination":null,"dispute":null,"failure_code":null,"failure_message":null,"livemode":false,"paid":true,"payment_intent":"pi","payment_method":"card","payment_method_details":{"card":{"brand":"discover","checks":{"address_line1_check":null,"address_postal_code_check":"pass","cvc_check":null},"country":"US","exp_month":2,"exp_year":2031,"fingerprint":"re6HpJitwRmamND7","funding":"credit","last4":"9424","three_d_secure":null,"wallet":null},"type":"card"},"receipt_email":null,"receipt_number":null,"receipt_url":"https://pay.stripe.com/receipts/jj","source":{"id":"card","object":"card","address_zip":"13113","address_zip_check":"pass","brand":"Discover","country":"US","customer":"cus_FUgYqCqYcMDBpy","cvc_check":null,"dynamic_last4":null,"exp_month":2,"exp_year":2031,"fingerprint":"re6HpJitwRmamND7","funding":"credit","last4":"9424"},"status":"succeeded","transfer_data":null,"transfer_group":null}],"has_more":false,"total_count":1,"url":"/v1/S2fCQOUsqAm"},"client_secret":"ser","created":1565676425,"currency":"usd","customer":"cus_FUgYqCqYcMDBpy","description":"dfgvd","payment_method_options":{"card":{"request_three_d_secure":"automatic"}},"payment_method_types":["card"],"receipt_email":null,"review":null,"setup_future_usage":null,"shipping":null,"source":"card_1F0QIVGeHGxQ9S2f0B3S4CnH","statement_descriptor":null,"statement_descriptor_suffix":null,"status":"succeeded","transfer_data":null,"transfer_group":null}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Stripe.chargeProcessor(apcWrapper, JSON.serializePretty(chargeMap), '');
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void createCharge_When_Failure() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_STRIPE);
            
            Test.startTest();
            Charge.StripeCharge ch = new Charge.StripeCharge();
            ch.amount = 100;
            ch.customer = 'cus_Id';
            ch.stripe_currency = 'usd';
            ch.paymentMethod = 'paymentMethodId';
            ch.paymentMethodType = ProcessorUtil.PM_CARD;
            
            Map<String, List<Charge.StripeCharge>> chargeMap = new Map<String, List<Charge.StripeCharge>>();
            chargeMap.put('charge', new List<Charge.StripeCharge>{ch});
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"id":"piid","object":"payment_intent","allowed_source_types":["card"],"amount":10000,"amount_capturable":0,"amount_received":10000,"charges":{"object":"list","data":[{"id":"ch","object":"charge","amount":10000,"amount_refunded":0,"application":"ca","application_fee":null,"application_fee_amount":null,"balance_transaction":"txz","billing_details":{"address":{"city":null,"country":null,"line1":null,"line2":null,"postal_code":"13113","state":null},"email":null,"name":null,"phone":null},"captured":true,"created":1565676425,"currency":"usd","customer":"cus_FUgYqCqYcMDBpy","description":"Payment created by API at 2019-08-13 06:07:04","destination":null,"dispute":null,"failure_code":null,"failure_message":null,"livemode":false,"paid":true,"payment_intent":"pi","payment_method":"card","payment_method_details":{"card":{"brand":"discover","checks":{"address_line1_check":null,"address_postal_code_check":"pass","cvc_check":null},"country":"US","exp_month":2,"exp_year":2031,"fingerprint":"re6HpJitwRmamND7","funding":"credit","last4":"9424","three_d_secure":null,"wallet":null},"type":"card"},"receipt_email":null,"receipt_number":null,"receipt_url":"https://pay.stripe.com/receipts/jj","source":{"id":"card","object":"card","address_zip":"13113","address_zip_check":"pass","brand":"Discover","country":"US","customer":"cus_FUgYqCqYcMDBpy","cvc_check":null,"dynamic_last4":null,"exp_month":2,"exp_year":2031,"fingerprint":"re6HpJitwRmamND7","funding":"credit","last4":"9424"},"status":"succeeded","transfer_data":null,"transfer_group":null}],"has_more":false,"total_count":1,"url":"/v1/S2fCQOUsqAm"},"client_secret":"ser","created":1565676425,"currency":"usd","customer":"cus_FUgYqCqYcMDBpy","description":"dfgvd","payment_method_options":{"card":{"request_three_d_secure":"automatic"}},"payment_method_types":["card"],"receipt_email":null,"review":null,"setup_future_usage":null,"shipping":null,"source":"card_1F0QIVGeHGxQ9S2f0B3S4CnH","statement_descriptor":null,"statement_descriptor_suffix":null,"status":"succeeded","transfer_data":null,"transfer_group":null}';
            httpMock.statusCode = 400;
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Stripe.chargeProcessor(apcWrapper, JSON.serializePretty(chargeMap), '');
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void updateCustomer_When_Success() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_STRIPE);
            
            Test.startTest();
            
            Customer.StripeCustomer stripeCustomer = new Customer.StripeCustomer();
            stripeCustomer.id = 'cuc_Id';
            stripeCustomer.name = 'Stella Pavlova';
            stripeCustomer.email = 'test@test.com';
            Map<String, List<Customer.StripeCustomer>> customerMap = new Map<String, List<Customer.StripeCustomer>>();
            customerMap.put('customer', new List<Customer.StripeCustomer>{stripeCustomer});
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response ='{"id":"cus_FJsxWLVdjJpHdJ","object":"customer","account_balance":10,"address":{"city":"Boise","country":"US","line1":"134  Poplar Chase Lane","line2":"Boise","postal_code":"19108","state":"Pennsylvania"},"balance":10,"created":1561471196,"currency":"usd","default_source":null,"delinquent":false,"description":"Customer Created by Breadwinner API at 2019-06-25 13:59:55","discount":null,"email":"Stalin-1561471195485@gmail.com","invoice_prefix":"64DFB18A","invoice_settings":{"custom_fields":null,"default_payment_method":null,"footer":null},"livemode":false,"metadata":{},"name":"Customer From API-1561471195484","phone":"484-581-0499","preferred_locales":[],"shipping":{"address":{"city":"Boise","country":"US","line1":"134  Poplar Chase Lane","line2":"Boise","postal_code":"19108","state":"Pennsylvania"},"name":"Recipient Name","phone":"484-581-0499"},"sources":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/customers/cus_FJsxWLVdjJpHdJ/sources"},"subscriptions":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/customers/cus_FJsxWLVdjJpHdJ/subscriptions"},"tax_exempt":"exempt","tax_ids":{"object":"list","data":[{"id":"txi_1EpFBgGeHGxQ9S2fU9oqpZKQ","object":"tax_id","country":"AT","created":1561471196,"customer":"cus_FJsxWLVdjJpHdJ","livemode":false,"type":"eu_vat","value":"ATU00000000","verification":{"status":"pending","verified_address":null,"verified_name":null}}],"has_more":false,"total_count":1,"url":"/v1/customers/cus_FJsxWLVdjJpHdJ/tax_ids"},"tax_info":{"tax_id":"ATU00000000","type":"vat"},"tax_info_verification":{"status":"pending","verified_name":null}}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Stripe.updateCustomer(apcWrapper, JSON.serializePretty(customerMap));
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void updateCustomer_When_Failure() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_STRIPE);
            
            Test.startTest();
            
            Customer.StripeCustomer stripeCustomer = new Customer.StripeCustomer();
            stripeCustomer.id = 'cuc_Id';
            stripeCustomer.name = 'Stella Pavlova';
            stripeCustomer.email = 'test@test.com';
            Map<String, List<Customer.StripeCustomer>> customerMap = new Map<String, List<Customer.StripeCustomer>>();
            customerMap.put('customer', new List<Customer.StripeCustomer>{stripeCustomer});
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response ='{"id":"cus_FJsxWLVdjJpHdJ","object":"customer","account_balance":10,"address":{"city":"Boise","country":"US","line1":"134  Poplar Chase Lane","line2":"Boise","postal_code":"19108","state":"Pennsylvania"},"balance":10,"created":1561471196,"currency":"usd","default_source":null,"delinquent":false,"description":"Customer Created by Breadwinner API at 2019-06-25 13:59:55","discount":null,"email":"Stalin-1561471195485@gmail.com","invoice_prefix":"64DFB18A","invoice_settings":{"custom_fields":null,"default_payment_method":null,"footer":null},"livemode":false,"metadata":{},"name":"Customer From API-1561471195484","phone":"484-581-0499","preferred_locales":[],"shipping":{"address":{"city":"Boise","country":"US","line1":"134  Poplar Chase Lane","line2":"Boise","postal_code":"19108","state":"Pennsylvania"},"name":"Recipient Name","phone":"484-581-0499"},"sources":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/customers/cus_FJsxWLVdjJpHdJ/sources"},"subscriptions":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/customers/cus_FJsxWLVdjJpHdJ/subscriptions"},"tax_exempt":"exempt","tax_ids":{"object":"list","data":[{"id":"txi_1EpFBgGeHGxQ9S2fU9oqpZKQ","object":"tax_id","country":"AT","created":1561471196,"customer":"cus_FJsxWLVdjJpHdJ","livemode":false,"type":"eu_vat","value":"ATU00000000","verification":{"status":"pending","verified_address":null,"verified_name":null}}],"has_more":false,"total_count":1,"url":"/v1/customers/cus_FJsxWLVdjJpHdJ/tax_ids"},"tax_info":{"tax_id":"ATU00000000","type":"vat"},"tax_info_verification":{"status":"pending","verified_name":null}}';
            httpMock.statusCode = 400;
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Stripe.updateCustomer(apcWrapper, JSON.serializePretty(customerMap));
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void fetchCustomers_When_Success() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_STRIPE);
            
            Test.startTest();
            Processor_Stripe.FetchRequest fetchRequest = new Processor_Stripe.FetchRequest();
            fetchRequest.starting_after = 'id';
            fetchRequest.stripe_limit = '50';
            fetchRequest.email = 'test@test.com';
            fetchRequest.createdGreaterThan = String.valueOf(System.now());
            fetchRequest.createdGreaterThanOrEqual = String.valueOf(System.now());
            fetchRequest.createdLessThan = String.valueOf(System.now());
            fetchRequest.createdLessThanOrEqual = String.valueOf(System.now());
            fetchRequest.ending_before = 'id';
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            
            httpMock.response = '{"object":"list","data":[{"id":"cus_Fk0tuYLi2hoGD7","object":"customer","account_balance":0,"address":{"city": "city","country": "ctry","line1": "line1","line2": "","postal_code": "","state": ""},"balance":0,"created":1567497366,"currency":null,"default_source":null,"delinquent":false,"description":null,"discount":null,"email":null,"invoice_prefix":"35B741BF","invoice_settings":{"custom_fields":null,"default_payment_method":null,"footer":null},"livemode":false,"metadata":{},"name":null,"phone":null,"preferred_locales":[],"shipping":null,"sources":{"object":"list","data":[{"id": "card_1H81y3HS2n7fPYIUCHCHD2Eo","object": "card","address_city": "test city","address_country": "test country","address_line1": "address line1","address_line1_check": null,"address_line2": "null","address_state": "address state","address_zip": "42424","address_zip_check": "pass","brand": "MasterCard","country": "US","customer": "cus_HhQp7UGgWozwko","cvc_check": "pass","exp_month": 12,"exp_year":2023,"fingerprint":"oMylrQnscC1ffRCN","funding": "credit","last4": "4444"}],"has_more":false,"total_count":0,"url":"/v1/customers/cus_Fk0tuYLi2hoGD7/sources"},"subscriptions":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/customers/cus_Fk0tuYLi2hoGD7/subscriptions"},"tax_exempt":"none","tax_ids":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/customers/cus_Fk0tuYLi2hoGD7/tax_ids"},"tax_info":null,"tax_info_verification":null},{"id":"cus_FiCx160BmSxMSW","object":"customer","account_balance":0,"address":null,"balance":0,"created":1567080956,"currency":null,"default_source":null,"delinquent":false,"description":null,"discount":null,"email":"me@me.com","invoice_prefix":"36348D6A","invoice_settings":{"custom_fields":null,"default_payment_method":null,"footer":null},"livemode":false,"metadata":{},"name":"Regular Sync Check at 17:45 29-08","phone":null,"preferred_locales":[],"shipping":{"address":{"city":"","country":"","line1":"","line2":"","postal_code":"","state":""},"name":"Regular Sync Check at 17:45 29-08","phone":""},"sources": {"object":"list","data":[{"id":"card_1G6dmEGZcuOzNASabbkto2Zd","object":"card","address_city":"knr","address_country":"knr","address_line1":"kpt","address_line1_check":"kpt","address_line2":"kpt","address_state":"test","address_zip":"42424","address_zip_check":"pass","brand":"Visa","country":"US","customer":"cus_GdvdUEIDyUZQHd","cvc_check":"pass","dynamic_last4":null,"exp_month":4,"exp_year":2024,"fingerprint":"n3cJX3BYeVmuPLfY","funding":"credit","last4":"4242","name":"test card name"},{"id":"ba_1G6tRfGZcuOzNASa2eXCHZPx","object":"bank_account","account_holder_name":"sam","account_holder_type":"individual","bank_name":"STRIPE TEST BANK","country":"US","currency":"usd","cusomer":"cus_GdvdUEIDyUZQHd","fingerprint":"9XHNRgdny9ngsir5","last4":"6789","routing_number":"110000000","status":"verified"},{"id":"card_1G6dmEGZcuOzNASabbkto2Zd","object":"source","type":"card","brand":"Visa","country":"US","customer":"cus_GdvdUEIDyUZQHd","cvc_check":"pass","dynamic_last4":null,"exp_month":4,"exp_year":2024,"fingerprint":"n3cJX3BYeVmuPLfY","funding":"credit","last4":"4242","name":"test card name"}],"has_more":false,"total_count":0,"url":"/v1/customers/cus_Fk0tuYLi2hoGD7/sources"},"subscriptions":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/customers/cus_FiCx160BmSxMSW/subscriptions"},"tax_exempt":"none","tax_ids":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/customers/cus_FiCx160BmSxMSW/tax_ids"},"tax_info":null,"tax_info_verification":null}],"has_more":true,"url":"/v1/customers"}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Stripe.fetchCustomers(apcWrapper, JSON.serializePretty(fetchRequest));
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void fetchCustomers_When_Failure() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_STRIPE);
            
            Test.startTest();
            Processor_Stripe.FetchRequest fetchRequest = new Processor_Stripe.FetchRequest();
            fetchRequest.starting_after = 'id';
            fetchRequest.stripe_limit = '50';
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"object":"list","data":[],"has_more":true,"url":"/v1/customers"}';
            httpMock.statusCode = 400;
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Stripe.fetchCustomers(apcWrapper, JSON.serializePretty(fetchRequest));
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void fetchTransactions_When_Success() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_STRIPE);
            
            Test.startTest();
            Processor_Stripe.FetchRequest fetchRequest = new Processor_Stripe.FetchRequest();
            fetchRequest.starting_after = 'id';
            fetchRequest.stripe_limit = '50';
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"object":"list","data":[{"id":"ch_1Dw7yUGeHGxQ9S2fYlha4tMV","object":"charge","amount":200000,"amount_refunded":0,"application":null,"captured":true,"created":1548335430,"currency":"usd","customer":"cus_EOsTVosY3hDovU","description":"Payment for invoice 4543104-0001","destination":null,"dispute":null,"failure_code":null,"failure_message":null,"fraud_details":{},"invoice":"in_1Dw729GeHGxQ9S2f376NX5U8","livemode":false,"metadata":{},"on_behalf_of":null,"order":null,"paid":true,"payment_intent":null,"receipt_email":null,"receipt_number":"2135-8515","receipt_url":"https://pay.stripe.com5qmM","source":{"id":"src","object":"source","amount":null,"card":{"exp_month":12,"exp_year":2021,"address_zip_check":"pass","brand":"MasterCard","country":"US","cvc_check":"pass","fingerprint":"rlVW6h291ivmHi02","funding":"debit","last4":"8210","three_d_secure":"optional","name":null,"address_line1_check":null,"tokenization_method":null,"dynamic_last4":null},"client_secret":"src_client_secret_EOvqostGtaNQFqqsD6FcMVUY","created":1548335431,"currency":null,"customer":"cus_EOsTVosY3hDovU","flow":"none","livemode":false,"metadata":{},"owner":{"address":{"city":null,"country":null,"line1":null,"line2":null,"postal_code":"99501","state":null},"email":null,"name":null,"phone":null,"verified_address":null,"verified_email":null,"verified_name":null,"verified_phone":null},"statement_descriptor":null,"status":"chargeable","type":"card","usage":"reusable"},"source_transfer":null,"statement_descriptor":null,"status":"succeeded","transfer_data":null,"transfer_group":null}],"has_more":true,"url":"/v1/charges"}';   
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Stripe.fetchTransactions(apcWrapper, JSON.serializePretty(fetchRequest));
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void fetchTransactions_When_Failure() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_STRIPE);
            
            Test.startTest();
            Processor_Stripe.FetchRequest fetchRequest = new Processor_Stripe.FetchRequest();
            fetchRequest.starting_after = 'id';
            fetchRequest.stripe_limit = '50';
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"object":"list","data":[],"has_more":true,"url":"/v1/charges"}';   
            httpMock.statusCode = 400;
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Stripe.fetchTransactions(apcWrapper, JSON.serializePretty(fetchRequest));
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void verifyBankAccount_When_Success() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_STRIPE);
            
            Test.startTest();
            Customer.verifyBankAccount verify = new Customer.verifyBankAccount();
            verify.customerId = 'cusId';
            verify.bankId = 'pmId';
            verify.firstDeposit = 0.32;
            verify.secondDeposit = 0.45;
            
            Map<String, List<Customer.verifyBankAccount>> verifyMap = new Map<String, List<Customer.verifyBankAccount>>();
            verifyMap.put('verify', new List<Customer.verifyBankAccount>{verify});
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Stripe.verifyBankAccount(apcWrapper, JSON.serializePretty(verifyMap));
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void verifyBankAccount_When_Failure() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_STRIPE);
            
            Test.startTest();
            Customer.verifyBankAccount verify = new Customer.verifyBankAccount();
            verify.customerId = 'cusId';
            verify.bankId = 'pmId';
            verify.firstDeposit = 0.32;
            verify.secondDeposit = 0.45;
            
            Map<String, List<Customer.verifyBankAccount>> verifyMap = new Map<String, List<Customer.verifyBankAccount>>();
            verifyMap.put('verify', new List<Customer.verifyBankAccount>{verify});
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.statusCode = 400;
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Stripe.verifyBankAccount(apcWrapper, JSON.serializePretty(verifyMap));
            System.debug('response: ' + response);
            
            Test.stopTest();
        }
    }    
    
    @IsTest
    static void constructStripePaymentMethod() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_STRIPE);
            
            Test.startTest();
            Customer.Source cardSource = new Customer.Source();
            cardSource.stripe_object = ProcessorUtil.PM_CARD; 
            cardSource.cardNumber = '1122';
            cardSource.exp_month = '10';
            cardSource.exp_year = '2025';
            cardSource.name = 'abc123';
            cardSource.last4 = '4242';
            Processor_Stripe.constructStripePaymentMethod(new BWP_Payment_Method__c(), cardSource, apcWrapper);
            
            Customer.Source cardSourceWithType = new Customer.Source();
            cardSourceWithType.stripe_object = 'source'; 
            cardSourceWithType.stripe_type = 'card';
            Customer.card carddetails = new Customer.card();
            carddetails.brand = 'VISA';
            carddetails.country = 'US';
            carddetails.exp_month = 10;
            carddetails.exp_year = 22;
            carddetails.funding = '1122';
            carddetails.fingerprint = 'fingerprint';
            carddetails.last4 = 4242;
            carddetails.name = 'card name';
            cardSourceWithType.card = carddetails;
            Processor_Stripe.constructStripePaymentMethod(new BWP_Payment_Method__c(), cardSourceWithType, apcWrapper);
            
            Customer.Source bankSource = new Customer.Source();
            bankSource.stripe_object = 'source'; 
            bankSource.stripe_type = 'ach_credit_transfer';
            Customer.ACH_credit_transfer ach = new Customer.ACH_credit_transfer();
            ach.account_number = '000123456789';
            ach.bank_name = 'TEST';
            ach.fingerprint = '4645gdheth';
            ach.swift_code = 'sd3445';
            ach.routing_number = '110000000';
            bankSource.ach_credit_transfer = ach;
            Processor_Stripe.constructStripePaymentMethod(new BWP_Payment_Method__c(), bankSource, apcWrapper);
            
            Customer.Source bankSourceWithType = new Customer.Source();
            bankSourceWithType.stripe_object = 'bank_account'; 
            Processor_Stripe.constructStripePaymentMethod(new BWP_Payment_Method__c(), bankSourceWithType, apcWrapper);
            
            Test.stopTest();
        }
    }
    
    @IsTest
    static void createPEXPayments() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_STRIPE);
            
            BWP_Customer__c bwpCust = new BWP_Customer__c(
                Processor_Customer_Id__c = 'abc123'
            );
            insert bwpCust;
            
            BWP_Payment_Method__c bwpPM = new BWP_Payment_Method__c(
                Processor_Id__c = 'paymentMethodId'
            );
            insert bwpPM;
            
            Charge.StripeCharge ch = new Charge.StripeCharge();
            ch.amount = 100;
            ch.customer = bwpCust.Processor_Customer_Id__c;
            ch.stripe_currency = 'usd';
            ch.paymentMethod = bwpPM.Processor_Id__c;
            ch.paymentMethodType = ProcessorUtil.PM_CARD;
            
            Processor_Stripe.createPEXPayments(ch, apcWrapper);
            
            Processor_Stripe.formatLanguage('en');
        }
    }
}