/**
* Everything that is Processor specific should be tested in this class
*/
@IsTest
private class Test_Processor_Braintree {
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
    static void CoverageForOverrideMethods() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            try{
                Processor_Braintree pb = new Processor_Braintree('12345');
            } catch (Exception ex){}
            
            Processor_Braintree pb = new Processor_Braintree();
            try{
                pb.createCustomer('');
            } catch (Exception ex){}
            try{
                pb.updateCustomer('');
            } catch (Exception ex){}
            try{
                pb.createCardToken('');
            } catch (Exception ex){}
            try{
                pb.createBankToken('');
            } catch (Exception ex){}
            try{
                pb.verifyBankAccount('');
            } catch (Exception ex){}
            try{
                pb.chargeProcessor('', '');
            } catch (Exception ex){}
            try{
                pb.fetchCustomers('');
            } catch (Exception ex){}
            try{
                pb.fetchTransactions('');
            } catch (Exception ex){}
        }
    }
    
    @IsTest
    static void createCustomer_When_Success() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_BRAINTREE);
            Test.startTest();
            
            Customer.BraintreeCustomer bc = new Customer.BraintreeCustomer();
            bc.firstName = 'Kenneth';
            bc.lastName = 'Woodell';
            bc.email = 'test@test.com';
            bc.phoneNumber = '773-631-4077';
            bc.company = 'Hoyden';
            
            Map<String, List<Customer.BraintreeCustomer>> customerMap = new Map<String, List<Customer.BraintreeCustomer>>();
            customerMap.put('customer', new List<Customer.BraintreeCustomer>{bc});
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response =
                '{"data":' +
                '{"createCustomer":' +
                '{"customer":' +
                '{"id":"Y3VzdG9tZXJfMTcwNjE4MDA5","firstName":"' + bc.firstName + '","lastName":"'  + bc.lastName + '","company":"' + bc.company + '","email":"' + bc.email + '","phoneNumber":"' + bc.phoneNumber + '",' +
                '"paymentMethods":{"edges":[{"node":{"id":"Y3VzdG9tZXJfMTcwNjE4MDA5","details":{"verified":null,"uniqueNumberIdentifier":"459e4e62c5c4e58088e36a6f17337424","typename":"CreditCardDetails","routingNumber":null,"last4":"1111","individualOwner":null,"expirationYear":"2021","expirationMonth":"12","cardNumber":null,"cardholderName":"Honey","businessOwner":null,"brandCode":"VISA","bankName":null,"achMandate":null,"accountType":null,"accountNumber":null,"accountholderName":null},"createdAt":null}}]}}'+        
                '}' +
                '}' +
                '}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Braintree.createCustomer(apcWrapper, JSON.serializePretty(customerMap));
            
            Integer custCount = [SELECT COUNT() FROM BWP_Customer__c WHERE First_Name__c = :bc.firstName];
            System.assertEquals(1, custCount);
            Test.stopTest();
        }
        
    }
    
    @IsTest
    static void createCustomer_When_Failure() {
        Test.startTest();
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_BRAINTREE);
            
            Customer.BraintreeCustomer bc = new Customer.BraintreeCustomer();
            bc.firstName = 'Kenneth';
            bc.lastName = 'Woodell';
            bc.email = 'test@test.com';
            bc.phoneNumber = '773-631-4077';
            bc.company = 'Hoyden';
            
            Map<String, List<Customer.BraintreeCustomer>> customerMap = new Map<String, List<Customer.BraintreeCustomer>>();
            customerMap.put('customer', new List<Customer.BraintreeCustomer>{bc});
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.statusCode = 400;
            httpMock.response =
                '{"data":' +
                '{"createCustomer":' +
                '{"customer":' +
                '{"id":"Y3VzdG9tZXJfMTcwNjE4MDA5","firstName":"' + bc.firstName + '","lastName":"'  + bc.lastName + '","company":"' + bc.company + '","email":"' + bc.email + '","phoneNumber":"' + bc.phoneNumber + '"}' +
                '}' +
                '}' +
                '}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            Processor_Braintree.createCustomer(apcWrapper, JSON.serializePretty(customerMap));
            
        }
        Test.stopTest();
    }
    
    @IsTest
    static void updateCustomer_When_Success() {
        Test.startTest();
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_BRAINTREE);
            
            Customer.BraintreeCustomer bc = new Customer.BraintreeCustomer();
            bc.id = 'testprocessorId';
            bc.firstName = 'Kenneth';
            bc.lastName = 'Woodell';
            bc.email = 'test@test.com';
            bc.phoneNumber = '773-631-4077';
            bc.company = 'Hoyden';
            
            Map<String, List<Customer.BraintreeCustomer>> customerMap = new Map<String, List<Customer.BraintreeCustomer>>();
            customerMap.put('customer', new List<Customer.BraintreeCustomer>{bc});
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response =
                '{"data":' +
                '{"createCustomer":' +
                '{"customer":' +
                '{"id":"Y3VzdG9tZXJfMTcwNjE4MDA5","firstName":"' + bc.firstName + '","lastName":"'  + bc.lastName + '","company":"' + bc.company + '","email":"' + bc.email + '","phoneNumber":"' + bc.phoneNumber + '"}' +
                '}' +
                '}' +
                '}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            Processor_Braintree.updateCustomer(apcWrapper, JSON.serializePretty(customerMap));
            
        }
        Test.stopTest();
    }
    
    @IsTest
    static void updateCustomer_When_Failure() {
        Test.startTest();
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_BRAINTREE);
            
            Customer.BraintreeCustomer bc = new Customer.BraintreeCustomer();
            bc.id = 'testprocessorId';
            bc.firstName = 'Kenneth';
            bc.lastName = 'Woodell';
            bc.email = 'test@test.com';
            bc.phoneNumber = '773-631-4077';
            bc.company = 'Hoyden';
            
            Map<String, List<Customer.BraintreeCustomer>> customerMap = new Map<String, List<Customer.BraintreeCustomer>>();
            customerMap.put('customer', new List<Customer.BraintreeCustomer>{bc});
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.statusCode = 400;
            httpMock.response =
                '{"data":' +
                '{"createCustomer":' +
                '{"customer":' +
                '{"id":"Y3VzdG9tZXJfMTcwNjE4MDA5","firstName":"' + bc.firstName + '","lastName":"'  + bc.lastName + '","company":"' + bc.company + '","email":"' + bc.email + '","phoneNumber":"' + bc.phoneNumber + '"}' +
                '}' +
                '}' +
                '}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            Processor_Braintree.updateCustomer(apcWrapper, JSON.serializePretty(customerMap));
            
        }
        Test.stopTest();
    }
    
    @IsTest
    static void createCard_When_Success() {
        Test.startTest();
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_BRAINTREE);
            
            Customer.BraintreeCustomer customer = new Customer.BraintreeCustomer();
            customer.id = 'processorCustomerId';
            List<Customer.PaymentMethodDetails> datalist = new list<Customer.PaymentMethodDetails>();
            Customer.PaymentMethodDetails cardDetails = new Customer.PaymentMethodDetails();
            cardDetails.cardNumber = '4111111111111111';
            cardDetails.expirationMonth = '12';
            cardDetails.expirationYear = '23';
            cardDetails.cardholderName = 'Stella';
            datalist.add(cardDetails);
            customer.paymentMethodDetails = datalist;
            
            Map<String, List<Customer.BraintreeCustomer>> customerMap = new Map<String, List<Customer.BraintreeCustomer>>();
            customerMap.put('customer', new List<Customer.BraintreeCustomer>{customer});
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"data":{"tokenizeCreditCard":{"paymentMethod":{"id":"tokencreditcardacct_bc_f6s7nh_kzspff_yr3j7x_td3yyz_6j6"}}},extensions":{"requestId":"YYw6tLAMlUrW7iOGAdstU8JpeUhIBF11hPWMBdFSvt_9QUlszR1gtg=="}}';
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Braintree.createCardToken(apcWrapper, JSON.serializePretty(customerMap));
            System.debug('response: ' + response);
        }
        Test.stopTest();
    }
    
    @IsTest
    static void createCard_When_Failure() {
        Test.startTest();
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_BRAINTREE);
            
            Customer.BraintreeCustomer customer = new Customer.BraintreeCustomer();
            customer.id = 'processorCustomerId';
            List<Customer.PaymentMethodDetails> datalist = new list<Customer.PaymentMethodDetails>();
            Customer.PaymentMethodDetails cardDetails = new Customer.PaymentMethodDetails();
            cardDetails.cardNumber = '4111111111111111';
            cardDetails.expirationMonth = '01';
            cardDetails.expirationYear = '23';
            cardDetails.cardholderName = 'Stella';
            datalist.add(cardDetails);
            customer.paymentMethodDetails = datalist;
            
            Map<String, List<Customer.BraintreeCustomer>> customerMap = new Map<String, List<Customer.BraintreeCustomer>>();
            customerMap.put('customer', new List<Customer.BraintreeCustomer>{customer});
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"extensions":{"requestId":"2012f2f9-2252-47c4-bd7f-84ae38157aa1"},"data":null,"errors":[{"message":"Unable to process JSON","extensions":{"errorClass":"VALIDATION","errorType":"developer_error"}}]}';
            httpMock.statusCode = 400;
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Braintree.createCardToken(apcWrapper, JSON.serializePretty(customerMap));
            System.debug('response: ' + response);
            
        }
        Test.stopTest();
    }
    
    @IsTest
    static void createBusinessBankAccount_When_Success() {
        Test.startTest();
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_BRAINTREE);
            
            Customer.BraintreeCustomer customer = new Customer.BraintreeCustomer();
            customer.id = 'processorCustomerId';
            List<Customer.PaymentMethodDetails> datalist = new  list<Customer.PaymentMethodDetails>();
            Customer.PaymentMethodDetails cardDetails = new Customer.PaymentMethodDetails();
            cardDetails.accountNumber = '999999999';   
            cardDetails.routingNumber = '307075259';
            cardDetails.accountType = 'CHECKING';
            Customer.BusinessOwner businessOwnerName = new Customer.BusinessOwner();
            businessOwnerName.businessName = 'Test Business';
            cardDetails.businessOwner = businessOwnerName;
            
            cardDetails.achMandate = 'yes';
            datalist.add(cardDetails);
            customer.paymentMethodDetails = datalist;
            Map<String, List<Customer.BraintreeCustomer>> customerMap = new Map<String, List<Customer.BraintreeCustomer>>();
            customerMap.put('customer', new List<Customer.BraintreeCustomer>{customer});
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            
            httpMock.response = '{"data":{"tokenizeUsBankAccount":{"paymentMethod":{"id":"tokenusbankacct_bc_f6s7nh_kzspff_yr3j7x_td3yyz_6j6"}}},"extensions":{"requestId":"YYw6tLAMlUrW7iOGAdstU8JpeUhIBF11hPWMBdFSvt_9QUlszR1gtg=="}}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Braintree.createBankToken(apcWrapper, JSON.serializePretty(customerMap));
            System.debug('response: ' + response);
            
        }
        Test.stopTest();
    }
    
    @IsTest
    static void createIndividualBankAccount_When_Success() {
        Test.startTest();
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_BRAINTREE);
            
            Customer.BraintreeCustomer customer = new Customer.BraintreeCustomer();
            customer.id = 'processorCustomerId';
            List<Customer.PaymentMethodDetails> datalist = new  list<Customer.PaymentMethodDetails>();
            Customer.PaymentMethodDetails cardDetails = new Customer.PaymentMethodDetails();
            cardDetails.accountNumber = '999999999';   
            cardDetails.routingNumber = '307075259';
            cardDetails.accountType = 'CHECKING';
            Customer.IndividualOwner individualOwnerName = new Customer.IndividualOwner();
            individualOwnerName.firstName = 'Alfie';
            individualOwnerName.lastName = 'Hon';
            cardDetails.individualOwner = individualOwnerName;
            cardDetails.achMandate = 'yes';
            datalist.add(cardDetails);
            customer.paymentMethodDetails = datalist;
            Map<String, List<Customer.BraintreeCustomer>> customerMap = new Map<String, List<Customer.BraintreeCustomer>>();
            customerMap.put('customer', new List<Customer.BraintreeCustomer>{customer});
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            
            httpMock.response = '{"data":{"tokenizeUsBankAccount":{"paymentMethod":{"id":"tokenusbankacct_bc_f6s7nh_kzspff_yr3j7x_td3yyz_6j6"}}},"extensions":{"requestId":"YYw6tLAMlUrW7iOGAdstU8JpeUhIBF11hPWMBdFSvt_9QUlszR1gtg=="}}';
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Braintree.createBankToken(apcWrapper, JSON.serializePretty(customerMap));
            System.debug('response: ' + response);
            
        }
        Test.stopTest();
    }
    
    @IsTest
    static void createBusinessBankAccount_When_Failure() {
        Test.startTest();
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_BRAINTREE);
            
            Customer.BraintreeCustomer customer = new Customer.BraintreeCustomer();
            customer.id = 'processorCustomerId';
            List<Customer.PaymentMethodDetails> datalist = new  list<Customer.PaymentMethodDetails>();
            Customer.PaymentMethodDetails cardDetails = new Customer.PaymentMethodDetails();
            cardDetails.accountNumber = '999999999';   
            cardDetails.routingNumber = '307075259';
            cardDetails.accountType = 'CHECKING';
            cardDetails.achMandate = 'yes';
            datalist.add(cardDetails);
            customer.paymentMethodDetails = datalist;
            Map<String, List<Customer.BraintreeCustomer>> customerMap = new Map<String, List<Customer.BraintreeCustomer>>();
            customerMap.put('customer', new List<Customer.BraintreeCustomer>{customer});
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            
            httpMock.response = '{"id": "tok_1HWzW8HS2n7fPYIUC51HPrQC","object": "token"}';
            httpMock.statusCode = 400;
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Braintree.createBankToken(apcWrapper, JSON.serializePretty(customerMap));
            System.debug('response: ' + response);
            
        }
        Test.stopTest();
    }
    
    @IsTest
    static void createCharge_When_Success() {
        Test.startTest();
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_BRAINTREE);
            Charge.BraintreeCharge ch = new Charge.BraintreeCharge();
            Charge.Amount amount = new Charge.Amount();  
            amount.value = '1234567890';
            ch.amount = amount;
            Charge.Customer customer = new Charge.Customer(); 
            customer.id = 'Y3VzdG9tZXJfMTI4NTM5OTMx';
            ch.customer = customer;
            Charge.PaymentMethod paymentMethod = new Charge.PaymentMethod(); 
            paymentMethod.id = 'cGF5bWVudG1ldGhvZF9jY19qeW1jNzRi';
            ch.paymentMethod = paymentMethod;
            Charge.TransactionTaxInput transactionTaxInput = new Charge.TransactionTaxInput(); 
            Charge.Amount taxAmount = new Charge.Amount();  
            taxAmount.value = '1223';
            transactionTaxInput.taxAmount =  taxAmount;
            transactionTaxInput.taxExempt = true;
            ch.transactionTaxInput = transactionTaxInput;
            
            Map<String, List<Charge.BraintreeCharge>> chargeMap = new Map<String, List<Charge.BraintreeCharge>>();
            chargeMap.put('charge', new List<Charge.BraintreeCharge>{ch});
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"dHJhbnNhY3Rpb25fOGNyNHY4eHk":{"transactionTaxInput":null,"status":"SUBMITTED_FOR_SETTLEMENT","paymentMethod":{"id":"cGF5bWVudG1ldGhvZF9jY19qeW1jNzRi"},"merchantAccountId":null,"legacyId":null,"id":"dHJhbnNhY3Rpb25fOGNyNHY4eHk","customer":{"id":"Y3VzdG9tZXJfMTI4NTM5OTMx"},"createdAt":"2020-11-24T11:41:02.000Z","amount":{"value":"123456.00","currencyISOCode":"USD"}}}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Braintree.chargeProcessor(apcWrapper, JSON.serializePretty(chargeMap), '');
            System.debug('response: ' + response);
            
        }
        Test.stopTest();
    }
    
    @IsTest
    static void createCharge_When_Failure() {
        Test.startTest();
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_BRAINTREE);
            Charge.BraintreeCharge ch = new Charge.BraintreeCharge();
            Charge.Amount amount = new Charge.Amount();  
            amount.value = '1234567890';
            ch.amount = amount;
            Charge.Customer customer = new Charge.Customer(); 
            customer.id = 'Y3VzdG9tZXJfMTI4NTM5OTMx';
            ch.customer = customer;
            Charge.PaymentMethod paymentMethod = new Charge.PaymentMethod(); 
            paymentMethod.id = 'cGF5bWVudG1ldGhvZF9jY19qeW1jNzRi';
            ch.paymentMethod = paymentMethod;
            Charge.TransactionTaxInput transactionTaxInput = new Charge.TransactionTaxInput(); 
            Charge.Amount taxAmount = new Charge.Amount();  
            taxAmount.value = '1223';
            transactionTaxInput.taxAmount =  taxAmount;
            transactionTaxInput.taxExempt = true;
            ch.transactionTaxInput = transactionTaxInput;
            
            Map<String, List<Charge.BraintreeCharge>> chargeMap = new Map<String, List<Charge.BraintreeCharge>>();
            chargeMap.put('charge', new List<Charge.BraintreeCharge>{ch});
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"errors":[{"message":"Amount is too large.","locations":[{"line":1,"column":63}],"path":["chargePaymentMethod"],"extensions":{"errorClass":"VALIDATION","errorType":"user_error","inputPath":["input","transaction","amount"],"legacyCode":"81528"}}],"data":{"chargePaymentMethod":null},"extensions":{"requestId":"0f7d2d7d-7029-45b7-b2f5-07eff58c9a45"}}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Braintree.chargeProcessor(apcWrapper, JSON.serializePretty(chargeMap), '');
            System.debug('response: ' + response);
            
        }
        Test.stopTest();
    }
    
    @IsTest
    static void verifyBankAccount_When_Success() {
        Test.startTest();
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_BRAINTREE);
            Customer.verifyBankAccount verify = new Customer.verifyBankAccount();
            verify.customerId = 'cusId';
            verify.bankId = 'pmId';
            verify.firstDeposit = 17;
            verify.secondDeposit = 29;
            
            Map<String, List<Customer.verifyBankAccount>> verifyMap = new Map<String, List<Customer.verifyBankAccount>>();
            verifyMap.put('verify', new List<Customer.verifyBankAccount>{verify});
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"data":{"verifyUsBankAccount":{"verification":{"id":"tokenusbankacct_bc_f6s7nh_kzspff_yr3j7x_td3yyz_6j6"}}},"extensions":{"requestId":"YYw6tLAMlUrW7iOGAdstU8JpeUhIBF11hPWMBdFSvt_9QUlszR1gtg=="}}';
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            ProcessorUtil.ResponseObject response =  Processor_Braintree.verifyBankAccount(apcWrapper, JSON.serializePretty(verifyMap));
            System.debug('response: ' + response);
            
        }
        Test.stopTest();
    }
    
    @IsTest
    static void fetchCustomers_When_Success() {
        //User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        //System.runAs(adminUser){
        BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_BRAINTREE);
        Test.startTest();
        
        UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
        httpMock.response =
            '{"data": ' +
            '{"search":' +
            '{"customers":' +
            '{"pageInfo": ' +
            '{"hasNextPage": true,"startCursor": "WTNWemRHOXRaWEpmTWpBek1USTRNekV6OzIwMTktMTEtMDVUMDc6Mzc6MzNa","endCursor": "WTNWemRHOXRaWEpmTWpBek1USTRNekV6OzIwMTktMTEtMDVUMDc6Mzc6MzNa"},' +
            '"edges": [{"node": {"id": "Y3VzdG9tZXJfMjAzMTI4MzEz","company": null,"createdAt": "2019-11-05T07:37:33.000000Z","firstName": "test 05 th Nov"},"cursor": "WTNWemRHOXRaWEpmTWpBek1USTRNekV6OzIwMTktMTEtMDVUMDc6Mzc6MzNa"}]}' +
            '}' +
            '}' +
            ',"extensions": {"requestId": "sqpdag6n0R2NGBv73fmp0BqhsgKABgH0tNH5rWkjTU3jBg9Z0WCKhg=="}' +
            '}';
        
        Test.setMock(HttpCalloutMock.class, httpMock);
        
        ProcessorUtil.ResponseObject response = Processor_Braintree.fetchCustomers(apcWrapper, '');
        
        //}
        Test.stopTest();
    }
    
    @IsTest
    static void fetchCustomers_When_Failure() {
        //User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        //System.runAs(adminUser){
        BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_BRAINTREE);
        Test.startTest();
        
        UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
        httpMock.statusCode = 400;
        httpMock.response =
            '{"data": ' +
            '{"search":' +
            '{"customers":' +
            '{"pageInfo": ' +
            '{"hasNextPage": true,"startCursor": "WTNWemRHOXRaWEpmTWpBek1USTRNekV6OzIwMTktMTEtMDVUMDc6Mzc6MzNa","endCursor": "WTNWemRHOXRaWEpmTWpBek1USTRNekV6OzIwMTktMTEtMDVUMDc6Mzc6MzNa"},' +
            '"edges": [{"node": {"id": "Y3VzdG9tZXJfMjAzMTI4MzEz","company": null,"createdAt": "2019-11-05T07:37:33.000000Z","firstName": "test 05 th Nov"},"cursor": "WTNWemRHOXRaWEpmTWpBek1USTRNekV6OzIwMTktMTEtMDVUMDc6Mzc6MzNa"}]}' +
            '}' +
            '}' +
            ',"extensions": {"requestId": "sqpdag6n0R2NGBv73fmp0BqhsgKABgH0tNH5rWkjTU3jBg9Z0WCKhg=="}' +
            '}';
        
        Test.setMock(HttpCalloutMock.class, httpMock);
        Processor_Braintree.fetchCustomers(apcWrapper, '');
        
        //}
        Test.stopTest();
    }
    
    @IsTest
    static void fetchTransactions_When_Success() {
        
        BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_BRAINTREE);
        Test.startTest();
        
        UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
        httpMock.response =
            '{"data":' +
            '{"search":' +
            '{"transactions":' +
            '{"pageInfo":' +
            '{"hasNextPage":false,"startCursor":"ZEhKaGJuTmhZM1JwYjI1Zk5qZG5OM0o0YUdzOzIwMjAtMDQtMzBUMDU6NDE6Mjha","endCursor":"ZEhKaGJuTmhZM1JwYjI1ZmFuSXpORGRqWlhnOzIwMjAtMDQtMjJUMTA6MjY6MzVa"},' +
            '"edges":[{"node":{"id":"dHJhbnNhY3Rpb25fNjdnN3J4aGs","legacyId":"67g7rxhk","createdAt":"2020-04-30T05:41:28.000000Z","status":"SETTLED","amount":{"value":"576.12","currencyIsoCode":"USD"},"customer":{"id":"Y3VzdG9tZXJfMTI5MjE5ODQx"},"paymentMethod":{"id":"cGF5bWVudG1ldGhvZF9jY19nd3AydGtn"}}},{"node":{"id":"dHJhbnNhY3Rpb25fcTdjNDFndDU","legacyId":"q7c41gt5","createdAt":"2020-04-30T05:36:34.000000Z","status":"SETTLED","amount":{"value":"576.12","currencyIsoCode":"USD"},"customer":{"id":"Y3VzdG9tZXJfMTI5MjE5ODQx"},"paymentMethod":{"id":"cGF5bWVudG1ldGhvZF9jY19oaGs4NTVn"}}},{"node":{"id":"dHJhbnNhY3Rpb25fMHJucHQxdHA","legacyId":"0rnpt1tp","createdAt":"2020-04-30T05:30:53.000000Z","status":"SETTLED","amount":{"value":"123.56","currencyIsoCode":"USD"},"customer":{"id":"Y3VzdG9tZXJfMTI5MjE5ODQx"},"paymentMethod":{"id":"cGF5bWVudG1ldGhvZF9jY19oaGs4NTVn"}}},{"node":{"id":"dHJhbnNhY3Rpb25fcnN2ZTlwdHQ","legacyId":"rsve9ptt","createdAt":"2020-04-22T10:54:03.000000Z","status":"SETTLED","amount":{"value":"100.00","currencyIsoCode":"USD"},"customer":{"id":"Y3VzdG9tZXJfMjQ5OTAzMzg2"},"paymentMethod":{"id":"cGF5bWVudG1ldGhvZF9jY185N2J6dmdt"}}},{"node":{"id":"dHJhbnNhY3Rpb25fOTdzeDdjcDA","legacyId":"97sx7cp0","createdAt":"2020-04-22T10:52:31.000000Z","status":"SETTLED","amount":{"value":"100.00","currencyIsoCode":"USD"},"customer":{"id":"Y3VzdG9tZXJfNjQzNTA5NTg0"},"paymentMethod":{"id":"cGF5bWVudG1ldGhvZF9jY19odzIzN3Bi"}}},{"node":{"id":"dHJhbnNhY3Rpb25fanIzNDdjZXg","legacyId":"jr347cex","createdAt":"2020-04-22T10:26:35.000000Z","status":"SETTLED","amount":{"value":"500.00","currencyIsoCode":"USD"},"customer":null,"paymentMethod":null}}]' +
            '}' +
            '}' +
            '}' +
            ',"extensions":{"requestId":"FgDYIu43fOphAgJH-ObmgLh9E4byTEGdENHOVA0IWxeqYt-jToybrA=="}' +
            '}';
        
        Test.setMock(HttpCalloutMock.class, httpMock);
        ProcessorUtil.ResponseObject response = Processor_Braintree.fetchTransactions(apcWrapper, '');
        
        Test.stopTest();
    }
    
    @IsTest
    static void fetchTransactions_When_Failure() {
        //User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        //System.runAs(adminUser){
        BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_BRAINTREE);
        Test.startTest();
        
        UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
        httpMock.statusCode = 400;
        httpMock.response =
            '{"data":' +
            '{"search":' +
            '{"transactions":' +
            '{"pageInfo":' +
            '{"hasNextPage":false,"startCursor":"ZEhKaGJuTmhZM1JwYjI1Zk5qZG5OM0o0YUdzOzIwMjAtMDQtMzBUMDU6NDE6Mjha","endCursor":"ZEhKaGJuTmhZM1JwYjI1ZmFuSXpORGRqWlhnOzIwMjAtMDQtMjJUMTA6MjY6MzVa"},' +
            '"edges":[{"node":{"id":"dHJhbnNhY3Rpb25fNjdnN3J4aGs","legacyId":"67g7rxhk","createdAt":"2020-04-30T05:41:28.000000Z","status":"SETTLED","amount":{"value":"576.12","currencyIsoCode":"USD"},"customer":{"id":"Y3VzdG9tZXJfMTI5MjE5ODQx"},"paymentMethod":{"id":"cGF5bWVudG1ldGhvZF9jY19nd3AydGtn"}}},{"node":{"id":"dHJhbnNhY3Rpb25fcTdjNDFndDU","legacyId":"q7c41gt5","createdAt":"2020-04-30T05:36:34.000000Z","status":"SETTLED","amount":{"value":"576.12","currencyIsoCode":"USD"},"customer":{"id":"Y3VzdG9tZXJfMTI5MjE5ODQx"},"paymentMethod":{"id":"cGF5bWVudG1ldGhvZF9jY19oaGs4NTVn"}}},{"node":{"id":"dHJhbnNhY3Rpb25fMHJucHQxdHA","legacyId":"0rnpt1tp","createdAt":"2020-04-30T05:30:53.000000Z","status":"SETTLED","amount":{"value":"123.56","currencyIsoCode":"USD"},"customer":{"id":"Y3VzdG9tZXJfMTI5MjE5ODQx"},"paymentMethod":{"id":"cGF5bWVudG1ldGhvZF9jY19oaGs4NTVn"}}},{"node":{"id":"dHJhbnNhY3Rpb25fcnN2ZTlwdHQ","legacyId":"rsve9ptt","createdAt":"2020-04-22T10:54:03.000000Z","status":"SETTLED","amount":{"value":"100.00","currencyIsoCode":"USD"},"customer":{"id":"Y3VzdG9tZXJfMjQ5OTAzMzg2"},"paymentMethod":{"id":"cGF5bWVudG1ldGhvZF9jY185N2J6dmdt"}}},{"node":{"id":"dHJhbnNhY3Rpb25fOTdzeDdjcDA","legacyId":"97sx7cp0","createdAt":"2020-04-22T10:52:31.000000Z","status":"SETTLED","amount":{"value":"100.00","currencyIsoCode":"USD"},"customer":{"id":"Y3VzdG9tZXJfNjQzNTA5NTg0"},"paymentMethod":{"id":"cGF5bWVudG1ldGhvZF9jY19odzIzN3Bi"}}},{"node":{"id":"dHJhbnNhY3Rpb25fanIzNDdjZXg","legacyId":"jr347cex","createdAt":"2020-04-22T10:26:35.000000Z","status":"SETTLED","amount":{"value":"500.00","currencyIsoCode":"USD"},"customer":null,"paymentMethod":null}}]' +
            '}' +
            '}' +
            '}' +
            ',"extensions":{"requestId":"FgDYIu43fOphAgJH-ObmgLh9E4byTEGdENHOVA0IWxeqYt-jToybrA=="}' +
            '}';
        
        Test.setMock(HttpCalloutMock.class, httpMock);
        Processor_Braintree.fetchTransactions(apcWrapper, '');
        
        //}
        Test.stopTest();
    }
    
    @IsTest
    static void syncCustomers_When_NewCustomer() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_BRAINTREE);
            
            Account acct = new Account(Name='Roger Howe');
            insert acct;
            
            Customer.BraintreeCustomer bc = new Customer.BraintreeCustomer();
            bc.id = 'Y3VzdG9tZXJfODY4NDE5MjI5';
            bc.firstName = 'Roger';
            bc.lastName = 'Howe';
            bc.email = 'test@test.com';
            bc.accountId = acct.Id;
            
            Map<String, Customer.BraintreeCustomer> braintreeCustMap = new Map<String, Customer.BraintreeCustomer>{
                bc.id => bc
                    };
                        
                        Map<String, Object> processorIdToPaymentMap = new Map<String, Object>{
                            ProcessorUtil.PAT_BRAINTREE => braintreeCustMap
                                };
                                    
                                    Processor_Braintree.syncCustomers(processorIdToPaymentMap, apcWrapper, true);
            
            //Verify the customer was added
            Integer custCount = [SELECT COUNT() FROM BWP_Customer__c WHERE First_Name__c = :bc.firstName];
            System.assertEquals(1, custCount);
        }
    }
    
    @IsTest
    static void syncCustomers_When_ExistingCustomer() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_BRAINTREE);
            
            BWP_Customer__c bwpCust = new BWP_Customer__c(
                First_Name__c = 'Roger',
                Last_Name__c = 'Howe',
                Email__c = 'test@test.com',
                Processor_Customer_Id__c = 'Y3VzdG9tZXJfODY4NDE5MjI5'
            );
            insert bwpCust;
            
            //Create a Charge.BraintreeCharge object
            BWP_Payment_Method__c bwpPaymentMethod = new BWP_Payment_Method__c(
                Customer__c = bwpCust.Id,
                Processor_Id__c = bwpCust.Processor_Customer_Id__c
            );
            insert bwpPaymentMethod;
            
            Customer.PaymentMethodDetails pmDetails = new Customer.PaymentMethodDetails();
            pmDetails.last4 = '1122';
            pmDetails.expirationMonth = '10';
            pmDetails.expirationYear = '2025';
            pmDetails.cardholderName = 'Michael Glass';
            pmDetails.brandCode = 'abc123';
            
            Customer.PaymentMethodNode pmNode = new Customer.PaymentMethodNode();
            pmNode.id = bwpPaymentMethod.Processor_Id__c;
            pmNode.details = pmDetails;
            
            Customer.PaymentMethodEdges pmEdge = new Customer.PaymentMethodEdges();
            pmEdge.node = pmNode;
            
            Customer.PaymentMethod pm = new Customer.PaymentMethod();
            pm.edges = new List<Customer.PaymentMethodEdges>{pmEdge};
                
                Customer.BraintreeCustomer bc = new Customer.BraintreeCustomer();
            bc.id = bwpCust.Processor_Customer_Id__c;
            bc.firstName = bwpCust.First_Name__c;
            bc.lastName = bwpCust.Last_Name__c;
            bc.email = bwpCust.Email__c;
            bc.paymentMethods = pm;
            
            Map<String, Customer.BraintreeCustomer> braintreeCustMap = new Map<String, Customer.BraintreeCustomer>{
                bwpCust.Processor_Customer_Id__c => bc
                    };
                        
                        Map<String, Object> processorIdToPaymentMap = new Map<String, Object>{
                            ProcessorUtil.PAT_BRAINTREE => braintreeCustMap
                                };
                                    
                                    Processor_Braintree.syncCustomers(processorIdToPaymentMap, apcWrapper, true);
            
            //Verify the customer was added
            Integer custCount = [SELECT COUNT() FROM BWP_Customer__c WHERE First_Name__c = :bc.firstName];
            System.assertEquals(1, custCount);
        }
        
    }
    
    @IsTest
    static void syncTransactions() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BWP_Processor_Config__c apc = UnitTests.createPayConfig(ProcessorUtil.PAT_BRAINTREE);
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_BRAINTREE);
            
            BWP_Customer__c bwpCust = new BWP_Customer__c(
                First_Name__c = 'Roger',
                Last_Name__c = 'Howe',
                Processor_Customer_Id__c = 'Y3VzdG9tZXJfODY4NDE5MjI5'
            );
            insert bwpCust;
            
            String pmProcessorId = 'cGF5bWVudG1ldGhvZF9jY185dmp5d2cy';
            BWP_Payment_Method__c bwpPM = new BWP_Payment_Method__c(
                Customer__c = bwpCust.Id
            );
            insert bwpPM;
            bwpPM.Processor_Id__c = pmProcessorId;
            update bwpPM;
            
            //Create a Charge.BraintreeCharge object that will get passed into syncTransactions as part of a map
            Charge.Customer chargeCust = new Charge.Customer();
            chargeCust.id = bwpCust.Processor_Customer_Id__c;
            
            Charge.PaymentMethod chargePM = new Charge.PaymentMethod();
            chargePM.id = pmProcessorId;
            
            Charge.BraintreeCharge btCharge = new Charge.BraintreeCharge();
            Charge.Amount btAmount = new Charge.Amount();
            btAmount.value = '15.00';
            btAmount.currencyISOCode = 'USD';
            
            btCharge.amount = btAmount;
            btCharge.customer = chargeCust;
            btCharge.id = apc.Provider_ID__c;
            btCharge.paymentMethod = chargePM;
            btCharge.status = 'SETTLED';
            
            Map<String, Charge.BraintreeCharge> braintreeChargeMap = new Map<String, Charge.BraintreeCharge>{
                apc.Provider_ID__c => btCharge
                    };
                        
                        Map<String, Object> processorIdToPaymentMap = new Map<String, Object>{
                            ProcessorUtil.PAT_BRAINTREE => braintreeChargeMap
                                };
                                    
                                    List<ProcessorUtil.TransactionWrapper> response = Processor_Braintree.syncTransactions(processorIdToPaymentMap, apcWrapper);
            
            //Verify the payment was added
            Integer paymentCount = [SELECT COUNT() FROM BWP_Transaction__c WHERE Customer__c = :bwpCust.Id];
            System.assertEquals(1, paymentCount);
        }
    }
    
    @IsTest
    static void constructBraintreePaymentMethod() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.AppConfig apcWrapper = UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_BRAINTREE);
            
            //Create Customer.PaymentMethodEdges and all child classes
            Customer.paymentMethodEdges src = new Customer.paymentMethodEdges();
            Customer.PaymentMethodNode node = new Customer.PaymentMethodNode();
            Customer.PaymentMethodDetails pmDetails = new Customer.PaymentMethodDetails();
            pmDetails.last4 = '1122';
            pmDetails.expirationMonth = '10';
            pmDetails.expirationYear = '2025';
            pmDetails.cardholderName = 'Michael Glass';
            pmDetails.brandCode = 'abc123';
            
            node.details = pmDetails;
            src.node = node;
            
            Processor_Braintree.constructBraintreePaymentMethod(new BWP_Payment_Method__c(), src, apcWrapper);
        }
        
    }
    
    @IsTest
    static void authorization_Success(){
        Test.startTest();
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"data": {"viewer": {"merchant": { "id": "574rd58fbjsr7hfy","companyName": "Dhruvsoft" }}},"extensions": { "requestId": "e-vZbeartQ=="}}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            BreadwinnerController b = new BreadwinnerController();
            b.braintreePublicKey = 'keihgjh348574385';
            b.braintreePrivateKey = 'ksfgr45oghreo395tohrg35hfdgeg';
            b.saveBraintreeCredentials();
            
        }
        Test.stopTest();
    }
    
    @IsTest
    static void authorization_Failure(){
        Test.startTest();
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response = '{"data": {"viewer": {"merchant": { "id": "574rd58fbjsr7hfy","companyName": "Dhruvsoft" }}},"extensions": { "requestId": "e-vZbeartQ=="}}';
            httpMock.statusCode = 400;
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            BreadwinnerController b = new BreadwinnerController();
            b.braintreePublicKey = 'keihgjh348574385';
            b.braintreePrivateKey = 'ksfgr45oghreo395tohrg35hfdgeg';
            b.saveBraintreeCredentials();
        }
        Test.stopTest();
    }
    
    @IsTest
    static void getRequestBody_ForCodeCoverage(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            Processor_Braintree.getRequestBody(ProcessorUtil.ACT_FETCH_CUSTOMERS_ALL,'');
            Processor_Braintree.getRequestBody(ProcessorUtil.ACT_FETCH_TRANSACTIONS_ALL,'');
            Processor_Braintree.getRequestBody(ProcessorUtil.ACT_FETCH_CUSTOMERS_RECENT,'');
            Processor_Braintree.getRequestBody(ProcessorUtil.ACT_FETCH_TRANSACTIONS_RECENT,'');
        }
    }
    
    /*@IsTest
    static void authorizeAccount_ForCodeCoverage() {        
    UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
    Test.setMock(HttpCalloutMock.class, httpMock);
    Processor_Braintree.authorizeAccount('ABCDEF','12345',false);
    }*/
}