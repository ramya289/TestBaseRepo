/**
* Created by Mike on 11/5/2020.
*/

@IsTest
private class Test_RecordInfoExtension {
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
    private static void TransactionRecordInfo() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            UnitTests.transactions(1);
            List<String> breadWinnerFieldsList = new List<String> ();
            for (Schema.SObjectField field: BWP_Transaction__c.sObjectType.getDescribe().fields.getMap().values()) {
                breadWinnerFieldsList.add(field.getDescribe().getName());
            }
            List <String> customFields = new List<String> {
                'Customer__r.Name', 'Customer__r.Email__c', 'Source__r.Card_Brand__c', 'Source__r.Last_4_digits__c', 'Source__r.Type__c', 'Source__r.Bank_Account_Holder_Name__c', 'Source__r.Bank_Name__c', 'Source__r.Account_Number__c'
                    };
                        
                        BWP_Transaction__c testPayment = Database.query('Select ' + String.join(breadWinnerFieldsList, ', ') + ',' + String.join(customFields, ', ') + ' FROM BWP_Transaction__c LIMIT 1');
            //insert testPayment;
            PageReference pageRef = Page.TransactionRecordInfo;
            pageRef.getParameters().put('id', String.valueOf(testPayment.Id));
            pageRef.getParameters().put('showBWLayout', 'true');
            Test.setCurrentPage(pageRef);
            Test.setMock(HttpCalloutMock.class, new UnitTests.MockHttpResponse());
            ApexPages.StandardController sc = new ApexPages.StandardController(testPayment);
            RecordInfoExtension transactionInfo = new RecordInfoExtension(sc);
            transactionInfo.newPMType = ProcessorUtil.PM_BANK;
            transactionInfo.confirmnumber();
            transactionInfo.getCurrencies();
            transactionInfo.isChargeSuccess = true;
            transactionInfo.renderpage();
            //  System.assert(paymentInfo.recordId != null);
        }
    }
    
    @IsTest
    private static void chargeCustomer_When_ProcessorStripe() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            PageReference pageRef = Page.CustomerRecordInfo;
            pageRef.getParameters().put('showBWLayout', 'true');
            Test.setCurrentPage(pageRef);
            BWP_Customer__c customer = UnitTests.customers(1)[0];
            List<BWP_Payment_Method__c> pms = new List<BWP_Payment_Method__c> ();
            Integer i = 0;
            for (BWP_Payment_Method__c pm: UnitTests.paymentMethods(3)) {
                pm.Customer__c = customer.Id;
                pm.Card_Brand__c = 'Visa';
                if (i == 0) {
                    pm.Type__c = ProcessorUtil.PM_CARD;
                }
                if (i == 1) {
                    pm.Type__c = ProcessorUtil.PM_BANK;
                }
                if (i == 2) {
                    pm.Type__c = ProcessorUtil.PM_ACH_CREDIT;
                }
                pms.add(pm);
                i++;
            }
            
            update pms;
            
            ApexPages.StandardController sc = new ApexPages.StandardController(customer);
            RecordInfoExtension customerInfo = new RecordInfoExtension(sc);
            
            customerInfo.config = UnitTests.createPayConfig(ProcessorUtil.PAT_STRIPE);
            customerInfo.chargingDescription = 'Charge Customer';
            customerInfo.chargeAmount = 100;
            customerInfo.chargeCustomer();
            customerInfo.changingPM();
            customerInfo.renderpage();
            // System.assert(customerInfo.recordId != null);
        }
    }
    
    @IsTest
    private static void chargeCustomer_When_ProcessorBraintree() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            PageReference pageRef = Page.CustomerRecordInfo;
            pageRef.getParameters().put('showBWLayout', 'true');
            Test.setCurrentPage(pageRef);
            BWP_Customer__c customer = UnitTests.customers(1)[0];
            List<BWP_Payment_Method__c> pms = new List<BWP_Payment_Method__c> ();
            Integer i = 0;
            for (BWP_Payment_Method__c pm: UnitTests.paymentMethods(3)) {
                pm.Customer__c = customer.Id;
                pm.Card_Brand__c = 'Visa';
                if (i == 0) {
                    pm.Type__c = ProcessorUtil.PM_CARD;
                }
                if (i == 1) {
                    pm.Type__c = ProcessorUtil.PM_BANK;
                }
                if (i == 2) {
                    pm.Type__c = 'ACH Transfer';
                }
                pms.add(pm);
                i++;
            }
            
            update pms;
            
            ApexPages.StandardController sc = new ApexPages.StandardController(customer);
            RecordInfoExtension customerInfo = new RecordInfoExtension(sc);
            
            customerInfo.config = UnitTests.createPayConfig(ProcessorUtil.PAT_BRAINTREE);
            customerInfo.chargingDescription = 'Charge Customer';
            customerInfo.chargeAmount = 100;
            customerInfo.chargeCustomer();
            customerInfo.changingPM();
            customerInfo.renderpage();
            // System.assert(customerInfo.recordId != null);
        }
    }
    
    @IsTest
    private static void chargeCustomer_When_ProcessorSquare() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            PageReference pageRef = Page.CustomerRecordInfo;
            pageRef.getParameters().put('showBWLayout', 'true');
            Test.setCurrentPage(pageRef);
            BWP_Customer__c customer = UnitTests.customers(1)[0];
            List<BWP_Payment_Method__c> pms = new List<BWP_Payment_Method__c> ();
            Integer i = 0;
            for (BWP_Payment_Method__c pm: UnitTests.paymentMethods(3)) {
                pm.Customer__c = customer.Id;
                pm.Card_Brand__c = 'Visa';
                if (i == 0) {
                    pm.Type__c = ProcessorUtil.PM_CARD;
                }
                if (i == 1) {
                    pm.Type__c = ProcessorUtil.PM_BANK;
                }
                if (i == 2) {
                    pm.Type__c = 'ACH Transfer';
                }
                pms.add(pm);
                i++;
            }
            
            update pms;
            
            ApexPages.StandardController sc = new ApexPages.StandardController(customer);
            RecordInfoExtension customerInfo = new RecordInfoExtension(sc);
            customerInfo.config = UnitTests.createPayConfig(ProcessorUtil.PAT_SQUARE);
            customerInfo.chargeAmount = 100;
            customerInfo.chargeCustomer();
            customerInfo.changingPM();
            customerInfo.renderPMpage();
            // System.assert(customerInfo.recordId != null);
        }
    }
    
    @IsTest
    private static void paymentMethodRecordInfo() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            PageReference pageRef = Page.PaymentMethodRecordInfo;
            pageRef.getParameters().put('showBWLayout', 'true');
            Test.setCurrentPage(pageRef);
            BWP_Payment_Method__c pm = UnitTests.paymentMethods(1)[0];
            BWP_Transaction__c payment = new BWP_Transaction__c();
            payment.Source__c = pm.id;
            payment.Amount__c = 100;
            insert payment;
            ApexPages.StandardController sc = new ApexPages.StandardController(pm);
            RecordInfoExtension paymentMethodInfo = new RecordInfoExtension(sc);
            BreadwinnerUtil.processorConfigList = UnitTests.createPayConfig(1, ProcessorUtil.PAT_STRIPE);
            paymentMethodInfo.config = BreadwinnerUtil.processorConfigList[0];
        }
    }
    @IsTest
    private static void customerRecordInfo() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            PageReference pageRef = Page.CustomerRecordInfo;
            pageRef.getParameters().put('showBWLayout', 'true');
            Test.setCurrentPage(pageRef);
            BWP_Customer__c cust = UnitTests.customers(1)[0];
            BWP_Transaction__c payment = new BWP_Transaction__c();
            payment.Customer__c = cust.id;
            payment.Amount__c = 100;
            payment.Created_Date_in_Processor__c = System.today();
            payment.Currency__c = 'USD';
            insert payment;
            ApexPages.StandardController sc = new ApexPages.StandardController(cust);
            RecordInfoExtension custInfo = new RecordInfoExtension(sc);
            BreadwinnerUtil.processorConfigList = UnitTests.createPayConfig(1, ProcessorUtil.PAT_STRIPE);
            custInfo.config = BreadwinnerUtil.processorConfigList[0];
        }
    }
    @IsTest
    private static void additionalCoverage_RecordInfoExtension() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.processorConfigList = UnitTests.createPayConfig(1, ProcessorUtil.PAT_STRIPE);
            BWP_Customer__c customer = UnitTests.customers(1)[0];
            ApexPages.StandardController sc = new ApexPages.StandardController(customer);
            RecordInfoExtension recordInfo = new RecordInfoExtension(sc);
            recordInfo.confirmnumber();
            recordInfo.getCurrencies();
            List<SelectOption> PaymentMethodOptions = recordInfo.getPaymentMethodOptions();
            Boolean canCreatePaymentMethod = recordInfo.canCreatePaymentMethod(ProcessorUtil.PAT_STRIPE);
            Boolean canCreateTransaction = recordInfo.canCreateTransaction(ProcessorUtil.PAT_STRIPE);
            Boolean canUpdateCustomer = recordInfo.canUpdateCustomer(ProcessorUtil.PAT_STRIPE);
        }
    }
    @IsTest
    private static void createPaymentMethod_When_ProcessorStripeAndPMTypeCard(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.processorConfigList = UnitTests.createPayConfig(1, ProcessorUtil.PAT_STRIPE);
            BWP_Customer__c customer = UnitTests.customers(1)[0];
            Test.startTest();
            test.setCurrentPage(page.CustomerRecordInfo);
            ApexPages.StandardController sc = new ApexPages.StandardController(customer);
            RecordInfoExtension cc =new RecordInfoExtension(sc);
            cc.config = BreadwinnerUtil.processorConfigList[0];
            cc.newPMType = ProcessorUtil.PM_CARD;
            cc.cardNumber =  '4242424242424242';
            cc.cardExpiryMonth = '12';
            cc.cardExpiryYear = '23';
            cc.cardCVC = '123';
            cc.cardHolderName = 'stella';
            cc.cardStreetLine1 = 'address line 1';
            cc.cardStreetLine2 = 'address line 2';
            cc.cardCity = 'Hyd';
            cc.cardState = 'TS';
            cc.cardPostalCode = '500082';
            cc.cardCountry = 'US';
            cc.createPaymentMethod();
            Test.stopTest();
        }
    }
    
    @IsTest
    private static void createPaymentMethod_When_ProcessorStripeAndPMTypeBank(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.processorConfigList = UnitTests.createPayConfig(1, ProcessorUtil.PAT_STRIPE);
            BWP_Customer__c customer = UnitTests.customers(1)[0];
            Test.startTest();
            test.setCurrentPage(page.CustomerRecordInfo);
            ApexPages.StandardController sc = new ApexPages.StandardController(customer);
            RecordInfoExtension cc =new RecordInfoExtension(sc);
            cc.config = BreadwinnerUtil.processorConfigList[0];
            cc.newPMType = ProcessorUtil.PM_BANK;
            cc.bankPMAccountNumber = '123456789';
            cc.bankPMRoutingNumber = '123456789';
            cc.bankPMAccountHolderName = 'Stella';
            cc.bankPMBankAccountType = 'Checking';
            cc.bankPMConfirmAccountNumber = cc.bankPMAccountNumber;
            cc.bankPMCountry = 'US';
            cc.isBankAuthAccepted = true;
            
            cc.createPaymentMethod();
            Test.stopTest();
        }
    }
    
    @IsTest
    private static void createPaymentMethod_When_ProcessorBraintreeAndPMTypeCard(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.processorConfigList = UnitTests.createPayConfig(1, ProcessorUtil.PAT_BRAINTREE);
            BWP_Customer__c customer = UnitTests.customers(1)[0];
            Test.startTest();
            test.setCurrentPage(page.CustomerRecordInfo);
            ApexPages.StandardController sc = new ApexPages.StandardController(customer);
            RecordInfoExtension cc =new RecordInfoExtension(sc);
            cc.config = BreadwinnerUtil.processorConfigList[0];
            cc.newPMType = ProcessorUtil.PM_CARD;
            cc.cardNumber =  '4242424242424242';
            cc.cardExpiryMonth = '12';
            cc.cardExpiryYear = '23';
            cc.cardCVC = '123';
            cc.cardHolderName = 'stella';
            cc.cardStreetLine1 = 'address line 1';
            cc.cardStreetLine2 = 'address line 2';
            cc.cardCity = 'Hyd';
            cc.cardState = 'TS';
            cc.cardPostalCode = '500082';
            cc.cardCountry = 'US';
            cc.createPaymentMethod();
            Test.stopTest();
        }
    }
    
    @IsTest
    private static void createPaymentMethod_When_ProcessorBraintreeAndPMTypeBusinessBank(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.processorConfigList = UnitTests.createPayConfig(1, ProcessorUtil.PAT_BRAINTREE);
            BWP_Customer__c customer = UnitTests.customers(1)[0];
            customer.Company__c = 'Test compnay';
            update customer;
            System.debug('--customer.Company__c--'+customer.Company__c);
            Test.startTest();
            test.setCurrentPage(page.CustomerRecordInfo);
            ApexPages.StandardController sc = new ApexPages.StandardController(customer);
            RecordInfoExtension cc =new RecordInfoExtension(sc);
            cc.config = BreadwinnerUtil.processorConfigList[0];
            cc.newPMType = ProcessorUtil.PM_BANK;
            cc.bankPMAccountNumber = '1000000000';
            cc.bankPMRoutingNumber = '011000015';
            cc.bankPMBankAccountType = 'Checking';
            cc.bankPMAccountHolderType = 'Business';
            cc.bankPMBusinessOwnerName = 'Test Bizz';
            cc.bankPMIndividualOwnerFirstName = 'Yazdan';
            cc.bankPMIndividualOwnerLastName = 'Hazi';
            cc.isBankAuthAccepted = true;
            
            cc.changeOwner();
            cc.createPaymentMethod();
            Test.stopTest();
        }
    }
    
    @IsTest
    private static void createPaymentMethod_When_ProcessorBraintreeAndPMTypeIndividualBank(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.processorConfigList = UnitTests.createPayConfig(1, ProcessorUtil.PAT_BRAINTREE);
            BWP_Customer__c customer = UnitTests.customers(1)[0];
            customer.Company__c = 'Test compnay';
            update customer;
            System.debug('--customer.Company__c--'+customer.Company__c);
            Test.startTest();
            test.setCurrentPage(page.CustomerRecordInfo);
            ApexPages.StandardController sc = new ApexPages.StandardController(customer);
            RecordInfoExtension cc =new RecordInfoExtension(sc);
            cc.config = BreadwinnerUtil.processorConfigList[0];
            cc.newPMType = ProcessorUtil.PM_BANK;
            cc.bankPMAccountNumber = '1000000000';
            cc.bankPMRoutingNumber = '011000015';
            cc.bankPMBankAccountType = 'Checking';
            cc.bankPMAccountHolderType = 'Individual';
            cc.bankPMIndividualOwnerFirstName = 'Test';
            cc.bankPMIndividualOwnerLastName = 'Name';
            cc.isBankAuthAccepted = true;
            
            cc.changeOwner();
            cc.createPaymentMethod();
            Test.stopTest();
        }
    }
    
    @IsTest
    private static void createPaymentMethod_When_ProcessorSquareAndPMTypeCard(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.processorConfigList = UnitTests.createPayConfig(1, ProcessorUtil.PAT_SQUARE);
            BWP_Customer__c customer = UnitTests.customers(1)[0];
            Test.startTest();
            test.setCurrentPage(page.CustomerRecordInfo);
            ApexPages.StandardController sc = new ApexPages.StandardController(customer);
            RecordInfoExtension cc =new RecordInfoExtension(sc);
            cc.config = BreadwinnerUtil.processorConfigList[0];
            cc.newPMType = ProcessorUtil.PM_CARD;
            cc.cardNumber =  '4242424242424242';
            cc.cardExpiryMonth = '12';
            cc.cardExpiryYear = '23';
            cc.cardCVC = '123';
            cc.cardHolderName = 'stella';
            cc.cardStreetLine1 = 'address line 1';
            cc.cardStreetLine2 = 'address line 2';
            cc.cardCity = 'Hyd';
            cc.cardState = 'TS';
            cc.cardPostalCode = '500082';
            cc.cardCountry = 'US';
            cc.createPaymentMethod();
            Test.stopTest();
        }
    }
    
    @IsTest
    private static void updateStripeCustomerFromCustomerRecordInfoPage(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response ='{"id":"cus_FJsxWLVdjJpHdJ","object":"customer","account_balance":10,"address":{"city":"Boise","country":"US","line1":"134  Poplar Chase Lane","line2":"Boise","postal_code":"19108","state":"Pennsylvania"},"balance":10,"created":1561471196,"currency":"usd","default_source":null,"delinquent":false,"description":"Customer Created by Breadwinner API at 2019-06-25 13:59:55","discount":null,"email":"Stalin-1561471195485@gmail.com","invoice_prefix":"64DFB18A","invoice_settings":{"custom_fields":null,"default_payment_method":null,"footer":null},"livemode":false,"metadata":{},"name":"Customer From API-1561471195484","phone":"484-581-0499","preferred_locales":[],"shipping":{"address":{"city":"Boise","country":"US","line1":"134  Poplar Chase Lane","line2":"Boise","postal_code":"19108","state":"Pennsylvania"},"name":"Recipient Name","phone":"484-581-0499"},"sources":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/customers/cus_FJsxWLVdjJpHdJ/sources"},"subscriptions":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/customers/cus_FJsxWLVdjJpHdJ/subscriptions"},"tax_exempt":"exempt","tax_ids":{"object":"list","data":[{"id":"txi_1EpFBgGeHGxQ9S2fU9oqpZKQ","object":"tax_id","country":"AT","created":1561471196,"customer":"cus_FJsxWLVdjJpHdJ","livemode":false,"type":"eu_vat","value":"ATU00000000","verification":{"status":"pending","verified_address":null,"verified_name":null}}],"has_more":false,"total_count":1,"url":"/v1/customers/cus_FJsxWLVdjJpHdJ/tax_ids"},"tax_info":{"tax_id":"ATU00000000","type":"vat"},"tax_info_verification":{"status":"pending","verified_name":null}}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            Account account = new Account (Name = 'test Account');
            insert account;
            test.setCurrentPage(page.CustomerRecordInfo);
            BWP_Customer__c customer = UnitTests.customers(1)[0];
            customer.Customer_Name__c='Alfie';
            customer.Language__c='English';
            customer.Email__c='alfie@gmail.com';
            customer.Customer_Phone__c='123456789';
            customer.Description__c='Test Descrption';
            customer.Invoice_Prefix__c='A6A3A8D5';
            customer.Language__c='English';
            customer.Billing_Street_Address_1__c='Street 1';
            customer.Billing_Street_Address_2__c='Street 2';
            customer.Billing_City__c='city';
            customer.Billing_Country__c='US';
            customer.Billing_Postal_Code__c='12345';
            customer.Processor_Type__c = 'Stripe';
            Update customer;
            
            BWP_Payment_Method__C paymentmethod = UnitTests.paymentMethods(1)[0];
            paymentmethod.Card_Brand__c='Visa';
            paymentmethod.Customer__c= customer.id;
            System.debug('--Card_Brand__c--'+paymentmethod.Card_Brand__c);
            update paymentmethod;
            
            RecordInfoExtension.getLanguages();
            
            ApexPages.StandardController sc = new ApexPages.StandardController(customer);
            RecordInfoExtension updatecust = new RecordInfoExtension(sc);
            BreadwinnerUtil.processorConfigList = UnitTests.createPayConfig(1, ProcessorUtil.PAT_STRIPE);
            updatecust.config = BreadwinnerUtil.processorConfigList[0];
            updatecust.updateCustomer();
        }
    }
    
    @IsTest
    private static void updateBraintreeCustomerFromCustomerRecordInfoPage(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response ='{"data":{"updateCustomer":{"customer":{"id":"Y3VzdG9tZXJfMjk0NDUyNTEw","firstName":"test","lastName":"customer","company":"Test company","email":"testcustmr@gmail.com","phoneNumber":"1234567890"}}},"extensions":{"requestId":"4e41a932-5614-4904-a29c-3e815435e2df"}}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            test.setCurrentPage(page.CustomerRecordInfo);
            BWP_Customer__c customer = UnitTests.customers(1)[0];
            customer.First_Name__c='Alfie';
            customer.Last_Name__c='Honey';
            customer.Email__c='alfie@gmail.com';
            customer.Customer_Phone__c='123456789';
            customer.Company__c='Test Company';
            customer.Processor_Type__c = 'Braintree';
            Update customer;
            
            ApexPages.StandardController sc = new ApexPages.StandardController(customer);
            RecordInfoExtension updatecust = new RecordInfoExtension(sc);
            BreadwinnerUtil.processorConfigList = UnitTests.createPayConfig(1, ProcessorUtil.PAT_BRAINTREE);
            updatecust.config = BreadwinnerUtil.processorConfigList[0];
            updatecust.updateCustomer();
            updatecust.renderPMpage();
        }
        
    }
    
    @IsTest
    private static void updateSquareCustomerFromCustomerRecordInfoPage(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response ='{"customer":{"id":"NYJYAFBKPCSPV50FFYACHJNKHW","created_at":"2020-12-24T07:56:01.806Z","updated_at":"2021-02-05T09:14:35Z","given_name":"Almas","family_name":"Khan","email_address":"testSquare@gmail.com","phone_number":"2025550186","company_name":"square inc","preferences":{"email_unsubscribed":false},"creation_source":"THIRD_PARTY"}}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            test.setCurrentPage(page.CustomerRecordInfo);
            BWP_Customer__c customer = UnitTests.customers(1)[0];
            customer.First_Name__c='Almas';
            customer.Last_Name__c='Khan';
            customer.Email__c='almas@gmail.com';
            customer.Customer_Phone__c='1234567890';
            customer.Company__c='Test Company';
            customer.Processor_Type__c = 'Square';
            Update customer;
            
            ApexPages.StandardController sc = new ApexPages.StandardController(customer);
            RecordInfoExtension updatecust = new RecordInfoExtension(sc);
            BreadwinnerUtil.processorConfigList = UnitTests.createPayConfig(1, ProcessorUtil.PAT_SQUARE);
            updatecust.config = BreadwinnerUtil.processorConfigList[0];
            updatecust.updateCustomer();
        }
        
    }
    
    @IsTest
    private static void verifyStripeBankAccountFromPaymentMethodRecordInfoPage(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.processorConfigList = UnitTests.createPayConfig(1, ProcessorUtil.PAT_STRIPE);
            BWP_Processor_Config__c apc = BreadwinnerUtil.processorConfigList[0];
            Test.startTest();
            List<BWP_Customer__c> customers = UnitTests.customers(1);
            BWP_Payment_Method__C paymentmethod1 = UnitTests.paymentMethods(1)[0];
            paymentmethod1.Processor_Id__c='ba_1H5PFkBAlBFISuDb0b1zhrZW';
            paymentmethod1.Processor_Customer_Id__c = customers[0].Processor_Customer_Id__c;
            update paymentmethod1;
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response ='{ "id": "ba_1H5PFkBAlBFISuDb0b1zhrZW", "object": "bank_account", "account_holder_name": "safd", "account_holder_type": "individual", "bank_name": "STRIPE TEST BANK", "country": "US", "currency": "usd", "customer": "cus_HeqtU2dmXJVy0R", "fingerprint": "hmvfqs0GbJqEGtl7", "last4": "6789", "metadata": { }, "routing_number": "110000000", "status": "verified"}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            PageReference pageRef = Page.CustomerRecordInfo;
            pageRef.getParameters().put('showBWLayout', 'true');
            Test.setCurrentPage(pageRef);
            
            
            ApexPages.StandardController sc = new ApexPages.StandardController(paymentmethod1);
            RecordInfoExtension verifyBa = new RecordInfoExtension(sc);
            verifyBa.config = apc;
            verifyBa.firstDeposit = 0.32;
            verifyBa.secondDeposit = 0.45;
            verifyBa.verifyBankAccount();
            
            Test.stopTest();
        }
    }
    
    @IsTest
    private static void verifyBraintreeBankAccountFromPaymentMethodRecordInfoPage(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerUtil.processorConfigList = UnitTests.createPayConfig(1, ProcessorUtil.PAT_BRAINTREE);
            BWP_Processor_Config__c apc = BreadwinnerUtil.processorConfigList[0];
            Test.startTest();
            List<BWP_Customer__c> customers = UnitTests.customers(1);
            BWP_Payment_Method__C paymentmethod1 = UnitTests.paymentMethods(1)[0];
            paymentmethod1.Processor_Id__c = '7vpb7mvmhm57wpj3';
            paymentmethod1.Processor_Customer_Id__c = customers[0].Processor_Customer_Id__c;
            update paymentmethod1;
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response ='{"data":{"confirmMicroTransferAmounts":{"status":"CONFIRMED","verification":{"status":"VERIFIED"}}},"extensions":{"requestId":"1fb400d7-a618-4879-b160-9b968414a888"}}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            PageReference pageRef = Page.CustomerRecordInfo;
            pageRef.getParameters().put('showBWLayout', 'true');
            Test.setCurrentPage(pageRef);
            
            
            ApexPages.StandardController sc = new ApexPages.StandardController(paymentmethod1);
            RecordInfoExtension verifyBa = new RecordInfoExtension(sc);
            verifyBa.config = apc;
            verifyBa.firstDeposit = 17;
            verifyBa.secondDeposit = 19;
            verifyBa.verifyBankAccount();
            
            Test.stopTest();
        }
    }
    
}