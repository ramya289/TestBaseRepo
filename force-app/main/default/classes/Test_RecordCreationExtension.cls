@IsTest
private class Test_RecordCreationExtension {
    //Set up the test data to use across all methods
    @testSetup
    static void setup() {
        //Creating the User with Admin PS
        String uniqueUserName = 'testuser' + DateTime.now().getTime() + '@testorg.com';
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1 ];
        User user = new User(Alias = 'TestUser', Email = 'testuser@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = prof.Id, TimeZoneSidKey = 'America/Los_Angeles', UserName = uniqueUserName);
        insert user;
        String adminPSName = BreadwinnerUtil.ADMIN_PS_NAME;
        List<PermissionSet> pset = [SELECT Id FROM PermissionSet WHERE Name = :BreadwinnerUtil.ADMIN_PS_NAME];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = pset[0].Id);
    }
    @IsTest
    private static void createStripeCustomerFromNewCustomerPage(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            UnitTests.createPayConfig(ProcessorUtil.PAT_STRIPE);
            BWP_Customer__c customer = new BWP_Customer__c();
            Test.startTest();
            Test.setCurrentPage(page.CreateCustomer);
            ApexPages.StandardController sc = new ApexPages.StandardController(customer);
            RecordCreationExtension cc =new RecordCreationExtension(sc);
            
            cc.selectedProcessorAccountType = ProcessorUtil.PAT_STRIPE;
            cc.newCustomer.Customer_Name__c='Alfie';
            cc.newCustomer.Language__c='English';
            cc.newCustomer.Email__c='alfie@gmail.com';
            cc.newCustomer.Customer_Phone__c='1234567890';
            cc.newCustomer.Description__c='Test Description';
            cc.newCustomer.Invoice_Prefix__c='A6A3A8D5';
            cc.newCustomer.Tax_Type__c = 'eu_vat';
            cc.newCustomer.Tax_Id__c = 'DE123456789';
            cc.newCustomer.Language__c='English';
            cc.newCustomer.Billing_Street_Address_1__c='Street 1';
            cc.newCustomer.Billing_Street_Address_2__c='Street 2';
            cc.newCustomer.Billing_City__c='city';
            cc.newCustomer.Billing_Country__c='US';
            cc.newCustomer.Billing_Postal_Code__c='12345';
            
            cc.createCustomer();
            Test.stopTest();
        }        
    }
    
    @IsTest
    private static void createStripeChargeFromNewPaymentPage(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            UnitTests.createPayConfig(ProcessorUtil.PAT_STRIPE);
            BWP_Customer__c customer = UnitTests.customers(1)[0];
            Test.startTest();
            BWP_Payment_Method__c payMethod = UnitTests.paymentMethods(1)[0];
            payMethod.Type__c = ProcessorUtil.PM_CARD;
            update payMethod;
            
            Test.setCurrentPage(Page.CreateCustomer);
            ApexPages.StandardController sc = new ApexPages.StandardController(customer);
            RecordCreationExtension cc =new RecordCreationExtension(sc);
            
            cc.customerInfo = new BWP_Customer__c(Processor_Type__c = ProcessorUtil.PAT_STRIPE);
            cc.newTransaction.Customer__c = customer.Id;
            cc.newTransaction.Source__c = payMethod.Id;
            cc.newTransaction.Amount__c = 123.00;
            cc.newTransaction.Description__c = 'test payment';
            
            cc.chargeCustomer();
            
            Test.stopTest();
        }
    }
    
    @IsTest
    private static void createStripeCardFromNewCustomerPage(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            UnitTests.createPayConfig(ProcessorUtil.PAT_STRIPE);
            BWP_Customer__c customer = UnitTests.customers(1)[0];
            
            Test.startTest();
            test.setCurrentPage(page.CreateCustomer);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(customer);
            RecordCreationExtension cc =new RecordCreationExtension(sc);
            
            cc.PMType = ProcessorUtil.PM_CARD;
            cc.selectedBWPCustomer = customer.id;
            cc.PMTokenValue = 'tokenValue';
            cc.cardHolderName = 'Anna';
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
    private static void createStripeBankAccountFromNewCustomerPage(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            UnitTests.createPayConfig(ProcessorUtil.PAT_STRIPE);
            BWP_Customer__c customer = UnitTests.customers(1)[0];
            
            Test.startTest();
            Test.setCurrentPage(Page.CreateCustomer);
            ApexPages.StandardController sc = new ApexPages.StandardController(customer);
            RecordCreationExtension cc =new RecordCreationExtension(sc);
            cc.PMType = ProcessorUtil.PM_BANK;
            cc.bankPMCountry = 'US';
            cc.bankPMCurrency = 'USD';
            cc.bankPMAccountHolderName = 'Anna';
            cc.bankPMAccountHolderType = 'Bank';
            cc.bankPMAccountNumber = '123456789';
            cc.bankPMRoutingNumber = '123456789';
            cc.bankPMConfirmAccountNumber = cc.bankPMAccountNumber;
            cc.isBankAuthAccepted = true;
            
            cc.createPaymentMethod();
            
            Test.stopTest();
        }
    }
    
    @IsTest
    private static void createStripeCustomerFromNewPaymentPage(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            Test.startTest();
            UnitTests.createPayConfig(ProcessorUtil.PAT_STRIPE);
            BWP_Customer__c customer = new BWP_Customer__c();
            Account account = new Account (Name = 'test Account');
            insert account;
            
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response ='{"id":"cus_FJsxWLVdjJpHdJ","object":"customer","account_balance":10,"address":{"city":"Boise","country":"US","line1":"134  Poplar Chase Lane","line2":"Boise","postal_code":"19108","state":"Pennsylvania"},"balance":10,"created":1561471196,"currency":"usd","default_source":null,"delinquent":false,"description":"Customer Created by Breadwinner API at 2019-06-25 13:59:55","discount":null,"email":"Stalin-1561471195485@gmail.com","invoice_prefix":"64DFB18A","invoice_settings":{"custom_fields":null,"default_payment_method":null,"footer":null},"livemode":false,"metadata":{},"name":"Customer From API-1561471195484","phone":"484-581-0499","preferred_locales":[],"shipping":{"address":{"city":"Boise","country":"US","line1":"134  Poplar Chase Lane","line2":"Boise","postal_code":"19108","state":"Pennsylvania"},"name":"Recipient Name","phone":"484-581-0499"},"sources":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/customers/cus_FJsxWLVdjJpHdJ/sources"},"subscriptions":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/customers/cus_FJsxWLVdjJpHdJ/subscriptions"},"tax_exempt":"exempt","tax_ids":{"object":"list","data":[{"id":"txi_1EpFBgGeHGxQ9S2fU9oqpZKQ","object":"tax_id","country":"AT","created":1561471196,"customer":"cus_FJsxWLVdjJpHdJ","livemode":false,"type":"eu_vat","value":"ATU00000000","verification":{"status":"pending","verified_address":null,"verified_name":null}}],"has_more":false,"total_count":1,"url":"/v1/customers/cus_FJsxWLVdjJpHdJ/tax_ids"},"tax_info":{"tax_id":"ATU00000000","type":"vat"},"tax_info_verification":{"status":"pending","verified_name":null}}';
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            test.setCurrentPage(page.CreateCustomer);
            System.currentPageReference().getParameters().put('originating_record', account.id);
            //System.currentPageReference().getParameters().put('Child_Relationship_Name', 'Contacts');
            System.currentPageReference().getParameters().put('parent_id', 'id');
            
            ApexPages.StandardController sc = new ApexPages.StandardController(customer);
            RecordCreationExtension cc = new RecordCreationExtension(sc);
            cc.newCustomer.Customer_Name__c = 'Test Customer';
            cc.newCustomer.Description__c = 'test description';
            cc.newCustomer.Salesforce_Account__c = account.id;
            
            cc.createCustomer();
            cc.updateOrgDetails();
            Test.stopTest();
        }
    }
    
    @IsTest
    private static void createBraintreeCustomerFromNewCustomerPage(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            UnitTests.createPayConfig(ProcessorUtil.PAT_BRAINTREE);
            BWP_Customer__c customer = new BWP_Customer__c();
            Account account = new Account (Name = 'test Account');
            insert account;
            
            Test.startTest();
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response ='{"data":{"createCustomer":{"customer":{"id":"Y3VzdG9tZXJfMjQzNzE0MjI5","firstName":"Affu","lastName":"Hon","company":"DS","email":"affu@gmail.com","phoneNumber":"2025550186"}}},"extensions":{"requestId":"nZ26_x_qaN5jlHEEaurKjSmS0VKsbYAmPTYLzEkzjORxtmSOpLqOlg=="}}';
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            test.setCurrentPage(page.CreateCustomer);
            ApexPages.StandardController sc = new ApexPages.StandardController(customer);
            RecordCreationExtension cc =new RecordCreationExtension(sc);
            cc.selectedProcessorAccountType = ProcessorUtil.PAT_BRAINTREE;
            cc.newCustomer.First_Name__c = 'Alfie';
            cc.newCustomer.Last_Name__c = 'Hon';
            cc.newCustomer.Email__c='alfie@gmail.com';
            cc.newCustomer.Customer_Phone__c='1234567890';
            cc.newCustomer.Company__c='DS';
            
            cc.createCustomer();
            Test.stopTest();
        }
    }
    
    @IsTest
    private static void createBraintreeCardFromNewCustomerPage(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            UnitTests.createPayConfig(ProcessorUtil.PAT_BRAINTREE);
            BWP_Customer__c customer = UnitTests.customers(1)[0];
            
            Test.startTest();
            Test.setCurrentPage(Page.CreateCustomer);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(customer);
            RecordCreationExtension cc = new RecordCreationExtension(sc);
            
            cc.PMType = ProcessorUtil.PM_CARD;
            cc.selectedBWPCustomer = customer.Id;
            cc.PMTokenValue = 'tokenValue';
            cc.createPaymentMethod();
            Test.stopTest();
        }
        
    }
    
    @IsTest
    private static void createBraintreeBusinessBankAccountFromNewCustomerPage(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BWP_Processor_Config__c apc = UnitTests.createPayConfig(ProcessorUtil.PAT_BRAINTREE);
            BWP_Customer__c customer = UnitTests.customers(1)[0];
            customer.Company__c = 'Test company';
            update customer;
            Test.startTest();
            Test.setCurrentPage(Page.CreateCustomer);
            ApexPages.StandardController sc = new ApexPages.StandardController(customer);
            RecordCreationExtension cc =new RecordCreationExtension(sc);
            cc.PMType = ProcessorUtil.PM_BANK;
            cc.selectedBWPCustomer = customer.Id;
            cc.bankPMAccountNumber = '1000000000';
            cc.bankPMRoutingNumber = '011000015';
            cc.bankPMBankAccountType = 'Checking';
            cc.bankPMAccountHolderType = 'Business';
            cc.bankPMBusinessOwnerName = 'Test Bizz';
            cc.isBankAuthAccepted = true;
            cc.changeOwner();
            cc.bankPMBusinessOwnerName = 'Test Business';
            cc.createPaymentMethod();
            Test.stopTest();
        }
        
    }
    
    @IsTest
    private static void createBraintreeIndividualBankAccountFromNewCustomerPage(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            UnitTests.createPayConfig(ProcessorUtil.PAT_BRAINTREE);
            BWP_Customer__c customer = UnitTests.customers(1)[0];
            
            Test.startTest();
            Test.setCurrentPage(Page.CreateCustomer);
            ApexPages.StandardController sc = new ApexPages.StandardController(customer);
            RecordCreationExtension cc =new RecordCreationExtension(sc);
            cc.PMType = ProcessorUtil.PM_BANK;
            cc.bankPMAccountNumber = '1000000000';
            cc.bankPMRoutingNumber = '011000015';
            cc.bankPMBankAccountType = 'Checking';
            cc.bankPMAccountHolderType = 'Individual';
            cc.bankPMIndividualOwnerFirstName = 'Test';
            cc.bankPMIndividualOwnerLastName = 'Name';
            cc.isBankAuthAccepted = true;
            cc.createPaymentMethod();
            Test.stopTest();
        }
    }
    
    @IsTest
    private static void createSquareCustomerFromNewCustomerPage(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            UnitTests.createPayConfig(ProcessorUtil.PAT_SQUARE);
            BWP_Customer__c customer = new BWP_Customer__c();
            Account account = new Account (Name = 'test Account');
            insert account;
            
            Test.startTest();
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response ='{"customer":{"id":"ZQQAMMK6N4WJ3E2SYSHMD70GMM","created_at":"2020-11-24T07:37:22.74Z","updated_at":"2020-11-24T07:37:23Z","given_name":"Alfie","family_name":"Hon","nickname":"Afreen Naaz","email_address":"alfie@gmail.com","phone_number":"1234567890","note":"Test Customer","company_name":"DS","preferences":{"email_unsubscribed":false},"creation_source":"THIRD_PARTY"}}';
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            test.setCurrentPage(page.CreateCustomer);
            ApexPages.StandardController sc = new ApexPages.StandardController(customer);
            RecordCreationExtension cc =new RecordCreationExtension(sc);
            cc.selectedProcessorAccountType = ProcessorUtil.PAT_SQUARE;
            cc.newCustomer.First_Name__c = 'Alfie';
            cc.newCustomer.Last_Name__c = 'Hon';
            cc.newCustomer.Email__c='alfie@gmail.com';
            cc.newCustomer.Customer_Phone__c='1234567890';
            cc.newCustomer.Company__c='DS';
            
            cc.createCustomer();
            Test.stopTest();
        }
    }
    
    @IsTest
    private static void createSquareCardFromNewCustomerPage(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            UnitTests.createPayConfig(ProcessorUtil.PAT_SQUARE);
            BWP_Customer__c customer = UnitTests.customers(1)[0];
            
            Test.startTest();
            Test.setCurrentPage(Page.CreateCustomer);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(customer);
            RecordCreationExtension cc = new RecordCreationExtension(sc);
            
            cc.PMType = ProcessorUtil.PM_CARD;
            cc.selectedBWPCustomer = customer.Id;
            cc.cardHolderName = 'Anna';
            cc.cardStreetLine1 = 'address line 1';
            cc.cardStreetLine2 = 'address line 2';
            cc.cardCity = 'Hyd';
            cc.cardState = 'TS';
            cc.cardPostalCode = '500082';
            cc.cardCountry = 'US';
            cc.PMTokenValue = 'abc123';
            cc.createPaymentMethod();
            Test.stopTest();
        }
        
    }
    
    @IsTest
    private static void createStripeCustomerFromNewPayMethodPage(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response ='{"id":"cus_FJsxWLVdjJpHdJ","object":"customer","account_balance":10,"address":{"city":"Boise","country":"US","line1":"134  Poplar Chase Lane","line2":"Boise","postal_code":"19108","state":"Pennsylvania"},"balance":10,"created":1561471196,"currency":"usd","default_source":null,"delinquent":false,"description":"Customer Created by Breadwinner API at 2019-06-25 13:59:55","discount":null,"email":"Stalin-1561471195485@gmail.com","invoice_prefix":"64DFB18A","invoice_settings":{"custom_fields":null,"default_payment_method":null,"footer":null},"livemode":false,"metadata":{},"name":"Customer From API-1561471195484","phone":"484-581-0499","preferred_locales":[],"shipping":{"address":{"city":"Boise","country":"US","line1":"134  Poplar Chase Lane","line2":"Boise","postal_code":"19108","state":"Pennsylvania"},"name":"Recipient Name","phone":"484-581-0499"},"sources":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/customers/cus_FJsxWLVdjJpHdJ/sources"},"subscriptions":{"object":"list","data":[],"has_more":false,"total_count":0,"url":"/v1/customers/cus_FJsxWLVdjJpHdJ/subscriptions"},"tax_exempt":"exempt","tax_ids":{"object":"list","data":[{"id":"txi_1EpFBgGeHGxQ9S2fU9oqpZKQ","object":"tax_id","country":"AT","created":1561471196,"customer":"cus_FJsxWLVdjJpHdJ","livemode":false,"type":"eu_vat","value":"ATU00000000","verification":{"status":"pending","verified_address":null,"verified_name":null}}],"has_more":false,"total_count":1,"url":"/v1/customers/cus_FJsxWLVdjJpHdJ/tax_ids"},"tax_info":{"tax_id":"ATU00000000","type":"vat"},"tax_info_verification":{"status":"pending","verified_name":null}}';
            
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            Breadwinner_Settings__c bwSetting = UnitTests.createBWSetting();
            bwSetting.Read_Only_Mode__c = false;
            update bwSetting;
            
            UnitTests.createPayConfig(ProcessorUtil.PAT_STRIPE);
            BWP_Payment_Method__c payMethod = new BWP_Payment_Method__c();
            Test.startTest();
            Test.setCurrentPage(page.CreatePaymentMethod);
            ApexPages.StandardController sc = new ApexPages.StandardController(payMethod);
            RecordCreationExtension cc =new RecordCreationExtension(sc);
            
            cc.selectedProcessorAccountType = ProcessorUtil.PAT_STRIPE;
            cc.newCustomer.Customer_Name__c='Alfie';
            cc.newCustomer.Language__c='English';
            cc.newCustomer.Email__c='alfie@gmail.com';
            cc.newCustomer.Customer_Phone__c='1234567890';
            cc.newCustomer.Description__c='Test Description';
            cc.newCustomer.Invoice_Prefix__c='A6A3A8D5';
            cc.newCustomer.Tax_Type__c = 'eu_vat';
            cc.newCustomer.Tax_Id__c = 'DE123456789';
            cc.newCustomer.Language__c='English';
            cc.newCustomer.Billing_Street_Address_1__c='Street 1';
            cc.newCustomer.Billing_Street_Address_2__c='Street 2';
            cc.newCustomer.Billing_City__c='city';
            cc.newCustomer.Billing_Country__c='US';
            cc.newCustomer.Billing_Postal_Code__c='12345';
            
            cc.createCustomer();
            cc.standardNewPayMethodButtonToCreateNewCustomer();
            cc.clearPMValues();
            Test.stopTest();
        }
    }
    
    @IsTest
    private static void createSquareChargeFromNewPaymentPage(){User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
                                                               System.runAs(adminUser){
                                                                   UnitTests.createPayConfig(ProcessorUtil.PAT_SQUARE);
                                                                   BWP_Customer__c customer = UnitTests.customers(1)[0];
                                                                   Test.startTest();
                                                                   BWP_Payment_Method__c payMethod = UnitTests.paymentMethods(1)[0];
                                                                   payMethod.Type__c = ProcessorUtil.PM_CARD;
                                                                   update payMethod;
                                                                   
                                                                   Test.setCurrentPage(Page.CreateCustomer);
                                                                   ApexPages.StandardController sc = new ApexPages.StandardController(customer);
                                                                   RecordCreationExtension cc =new RecordCreationExtension(sc);
                                                                   
                                                                   cc.customerInfo = new BWP_Customer__c(Processor_Type__c = ProcessorUtil.PAT_SQUARE);
                                                                   cc.newTransaction.Customer__c = customer.Id;
                                                                   cc.newTransaction.Source__c = payMethod.Id;
                                                                   cc.newTransaction.Amount__c = 12345;
                                                                   
                                                                   cc.chargeCustomer();
                                                                   
                                                                   Test.stopTest();
                                                               }
                                                              }
    
    @IsTest
    private static void verifyStripeBankAccount(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            UnitTests.MockHttpResponse httpMock = new UnitTests.MockHttpResponse();
            httpMock.response ='{ "id": "ba_1H5PFkBAlBFISuDb0b1zhrZW", "object": "bank_account", "account_holder_name": "safd", "account_holder_type": "individual", "bank_name": "STRIPE TEST BANK", "country": "US", "currency": "usd", "customer": "cus_HeqtU2dmXJVy0R", "fingerprint": "hmvfqs0GbJqEGtl7", "last4": "6789", "metadata": { }, "routing_number": "110000000", "status": "verified"}';
            Test.setMock(HttpCalloutMock.class, httpMock);
            
            UnitTests.createPayConfig(ProcessorUtil.PAT_STRIPE);
            
            Test.startTest();
            
            BWP_Customer__c customer = UnitTests.customers(1)[0];
            Test.setCurrentPage(Page.CreateCustomer);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(customer);
            RecordCreationExtension verifyBa = new RecordCreationExtension(sc);
            
            verifyBa.selectedBWPCustomer = 'customerId';
            verifyBa.createdPayMethodId = 'paymentmethodId';
            verifyBa.firstDeposit = 0.32;
            verifyBa.secondDeposit = 0.45;
            
            verifyBa.verifyBankAccount();
            
            Test.stopTest();
        }
    }
    
    @IsTest
    private static void coverCreateCustomerExtension(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BWP_Customer__c customer = new BWP_Customer__c();
            BWP_Payment_Method__c payMethod = UnitTests.paymentMethods(1)[0];
            payMethod.Type__c = ProcessorUtil.PM_CARD;
            update payMethod;
            Test.startTest();
            
            test.setCurrentPage(page.CreateCustomer);
            Test.setMock(HttpCalloutMock.class, new UnitTests.MockHttpResponse());
            
            ApexPages.StandardController sc = new ApexPages.StandardController(customer);
            RecordCreationExtension cc =new RecordCreationExtension(sc);
            cc.newTransaction = new BWP_Transaction__c(Salesforce_Account__c = UnitTests.generateId(Account.SObjectType));
            cc.standardNewPaymentButtonToCreateNewCustomer();
            cc.redirectToNewTransactionPage();
            cc.confirmAccountNumber();
            cc.getTaxTypes();
            cc.getLanguages();
            cc.next();
            cc.cancel();
            cc.cancelProcess();
            cc.updateOrgDetails();
            cc.showCustomerPanel();
            cc.updateSelectedPaymentMethodDetails();
            cc.changingPM();
            cc.getListOfPaymentMethods('cus_id');
        }
    }
    
    @IsTest
    private static void getListOfPaymentMethods(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            String cusProcId = 'cus_id';
            BWP_Customer__c customer = new BWP_Customer__c(Processor_Customer_Id__c = cusProcId);
            insert customer;
            
            BWP_Payment_Method__c cardPM = new BWP_Payment_Method__c(
                Processor_Id__c = cusProcId,
                Type__c = ProcessorUtil.PM_CARD,
                Card_Brand__c = 'Visa',
                Customer__c = customer.Id
            );
            insert cardPM;
            
            BWP_Payment_Method__c bankPM = new BWP_Payment_Method__c(
                Processor_Id__c = cusProcId,
                Type__c = ProcessorUtil.PM_BANK,
                Bank_Name__c = 'Bank too big to fail',
                Card_Status__c = 'Verified',
                Customer__c = customer.Id
            );
            insert bankPM;
            
            Test.setCurrentPage(Page.CreateCustomer);
            ApexPages.StandardController sc = new ApexPages.StandardController(customer);
            RecordCreationExtension cc =new RecordCreationExtension(sc);
            
            List<SelectOption> pmOptions = cc.getListOfPaymentMethods(cusProcId);
            System.assertEquals(2, pmOptions.size());
        }
    }
    
    @IsTest
    private static void createBraintreeChargeFromNewPaymentPage(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            UnitTests.createPayConfig(ProcessorUtil.PAT_BRAINTREE);
            BWP_Customer__c customer = UnitTests.customers(1)[0];
            Test.startTest();
            BWP_Payment_Method__c payMethod = UnitTests.paymentMethods(1)[0];
            payMethod.Type__c = ProcessorUtil.PM_CARD;
            update payMethod;
            
            Test.setCurrentPage(Page.CreateCustomer);
            ApexPages.StandardController sc = new ApexPages.StandardController(customer);
            RecordCreationExtension cc =new RecordCreationExtension(sc);
            
            cc.customerInfo = new BWP_Customer__c(Processor_Type__c = ProcessorUtil.PAT_BRAINTREE);
            cc.newTransaction.Customer__c = customer.Id;
            cc.newTransaction.Source__c = payMethod.Id;
            cc.newTransaction.Amount__c = 123.00;
            cc.newTransaction.Description__c = 'test payment';
            cc.chargeCustomer();
            Test.stopTest();
        }
    }
    
    @IsTest
    private static void cancelProcess() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            Test.setCurrentPage(Page.CreateCustomer);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(new BWP_Customer__c());
            RecordCreationExtension ccExt = new RecordCreationExtension(sc);
            ccExt.isCreateCustomerPage = true;
         
            ccExt.newCustomer = new BWP_Customer__c(Salesforce_Contact__c = UnitTests.generateId(Contact.SObjectType));
            ccExt.cancelProcess();
            
            ccExt.newCustomer = new BWP_Customer__c(Salesforce_Account__c = UnitTests.generateId(Account.SObjectType));
            ccExt.cancelProcess();
            
            ccExt.originatingRecordId = UnitTests.generateId(Account.SObjectType);
            ccExt.cancelProcess();
            
            ccExt.newCustomerPageFromPaymentMethod = true;
            ccExt.cancelProcess();
            
            ccExt.isCreateCustomerPage = false;
            ccExt.isCreatePayMethodPage = true;
            ccExt.newPayMethod = new BWP_Payment_Method__c (Salesforce_Contact__c = UnitTests.generateId(Contact.SObjectType));
            ccExt.cancelProcess();
            
            ccExt.isCreatePayMethodPage = false;
            ccExt.newTransaction = new BWP_Transaction__c(Salesforce_Account__c = UnitTests.generateId(Account.SObjectType));
            ccExt.cancelProcess();
        }
        
    }
    
    @IsTest
    private static void additionalCoverage_CreateCustomerExtension(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            Test.setCurrentPage(Page.PaymentMethodRecordInfo);
            UnitTests.createPayConfig(ProcessorUtil.PAT_BRAINTREE);
            ApexPages.StandardController sc = new ApexPages.StandardController(new BWP_Transaction__c());
            RecordCreationExtension ccExt = new RecordCreationExtension(sc);
            
            List<SelectOption> taxStatus = ccExt.TaxStatus;
            List<SelectOption> pmOptions = RecordCreationExtension.PaymentMethodOptions;
            system.assert(!pmOptions.isEmpty());
            List<SelectOption> currOptions = ccExt.getCurrencies();
            ccExt.newTransaction = new BWP_Transaction__c();
            String defaultSelection = ccExt.defaultSelection;
            String bankauthMessage = RecordCreationExtension.bankAuthMessage();
            system.assert(String.isNotBlank(bankauthMessage));
            String authorizeBankMessage = RecordCreationExtension.authorizeBankMessage(UnitTests.customers(1)[0]);
            Boolean hasMultiplePmTypes = RecordCreationExtension.hasMultiplePmTypes(ProcessorUtil.PAT_STRIPE);
            system.assert(hasMultiplePmTypes, 'Stripe has multiple payment method types');
            try {
                ccExt.querySelectedAccount('abc123');
            } catch(Exception ex){}
            
            try {
                ccExt.queryCustomerInfo('12345');
            } catch(Exception ex){}
            
            ccExt.redirectToNewTransactionPage();
            ccExt.selectedBWPCustomer = '';
            try {
                ccExt.redirectToPaymentMethodPage();
            } catch (Exception ex) {}
            
            try {
                ccExt.redirectToTransactionPage();
            } catch (Exception ex){}
            
            ccExt.showPaymentMethodPanel();
            
            ccExt.isCustomerCreated = true;
            ccExt.createPayment();
        }
    }
    
}