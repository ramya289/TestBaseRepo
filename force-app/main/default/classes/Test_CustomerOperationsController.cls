@IsTest
private class Test_CustomerOperationsController {
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
    private static void onloadTest() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BWP_Processor_Config__c apc = UnitTests.createPayConfig(ProcessorUtil.PAT_STRIPE);
            List<BWP_Customer__c> stripeCustomersCreated = UnitTests.customers(3);
            List<BWP_Customer__c> stripeCustomers = new List<BWP_Customer__c> ();
            List<Schema.SObjectField> conFlds = Selector_Contact.FIELD_LIST;
            List<String> accFlds = Selector_Contact.ACCT_FIELDS;
            for (BWP_Customer__c cus: stripeCustomersCreated) {
                cus.Customer_Name__c += '\\';
                cus.Processor_Org_Id__c = apc.Name;
                cus.Salesforce_Account__c = NULL;
                cus.No_Associated_SF_Account__c = FALSE;
                stripeCustomers.add(cus);
            }
            update stripeCustomers;
            Test.startTest();
            CustomerOperationsController c = new CustomerOperationsController();
            c.jsonUserSelectedActions = '{"' + stripeCustomers[0].Id + '":"'+ProcessorUtil.CMO_DO_NOT_IMPORT+'"}';
            c.submitAndNext();
            
            boolean doesStripeRecordsExists = c.doesCustomersExistsInPaymentProcessor(UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_STRIPE));
            boolean doesBraintreeeRecordsExists = c.doesCustomersExistsInPaymentProcessor(UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_BRAINTREE));
            boolean doesSqureRecordsExists = c.doesCustomersExistsInPaymentProcessor(UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_SQUARE));
            CustomerOperationsController.RecordMatchWrapper wrapper = new CustomerOperationsController.RecordMatchWrapper(stripeCustomers[0]);
            CustomerOperationsController.RecordMatchWrapper sObjectWrapper = new CustomerOperationsController.RecordMatchWrapper( (Sobject)  stripeCustomers[0]);
            c.getObjectWrapper('Account', wrapper);
            Test.stopTest();
            //System.assert([SELECT count() FROM BWP_Customer__c WHERE Salesforce_Account__c != null OR No_Associated_SF_Account__c = true]>0);
        }
    }
    
    @IsTest
    private static void matchingNameTest() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            Test.setMock(HttpCalloutMock.class, new UnitTests.MockHttpResponse());
            BWP_Processor_Config__c apc = UnitTests.createPayConfig(ProcessorUtil.PAT_STRIPE);
            List<BWP_Customer__c> stripeCustomersCreated = UnitTests.customers(3);
            List<BWP_Customer__c> stripeCustomers = new List<BWP_Customer__c> ();
            List<Account> accnts = new List<Account> ();
            for (BWP_Customer__c cus: stripeCustomersCreated) {
                cus.Customer_Name__c = 'customer';
                cus.Processor_Org_Id__c = apc.Name;
                cus.Salesforce_Account__c = null;
                cus.No_Associated_SF_Account__c = false;
                stripeCustomers.add(cus);
                
                //Creating matching accounts
                Account ac = new Account(
                    Name = cus.Customer_Name__c
                );
                accnts.add(ac);
            }
            update stripeCustomers;
            insert accnts;
            Test.startTest();
            CustomerOperationsController c = new CustomerOperationsController();
            c.noRecordsInProcessor = false;
            c.jsonUserSelectedActions = '{"' + stripeCustomers[0].Id + '":"'+ProcessorUtil.CMO_SUGGESTED_MATCH+'"}';
            c.submitAndNext();
            c.restartHistoricalSync();
            CustomerOperationsController.RecordMatchWrapper wrapper = new CustomerOperationsController.RecordMatchWrapper(stripeCustomers[0]);
            Test.stopTest();
            //System.assert([SELECT count() FROM BWP_Customer__c WHERE Salesforce_Account__c != null ]>0);
        }
    }
    
    @IsTest
    private static void matchingPhoneTest() {User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
                                             System.runAs(adminUser){
                                                 BWP_Processor_Config__c apc = UnitTests.createPayConfig(ProcessorUtil.PAT_STRIPE);
                                                 List<BWP_Customer__c> stripeCustomersCreated = UnitTests.customers(3);
                                                 List<BWP_Customer__c> stripeCustomers = new List<BWP_Customer__c> ();
                                                 List<Account> accnts = new List<Account> ();
                                                 Test.startTest();
                                                 for (BWP_Customer__c cus: stripeCustomersCreated) {
                                                     cus.Customer_Name__c = 'customer';
                                                     cus.Processor_Org_Id__c = apc.Name;
                                                     cus.Salesforce_Account__c = NULL;
                                                     cus.No_Associated_SF_Account__c = FALSE;
                                                     cus.Customer_Phone__c = '1234567890';
                                                     stripeCustomers.add(cus);
                                                     
                                                     //Creating matching accounts
                                                     Account ac = new Account(
                                                         Name = cus.Customer_Name__c,
                                                         Phone = '1234567890'
                                                     );
                                                     accnts.add(ac);
                                                 }
                                                 update stripeCustomers;
                                                 insert accnts;
                                                 
                                                 CustomerOperationsController c = new CustomerOperationsController();
                                                 c.jsonUserSelectedActions = '{"' + stripeCustomers[0].Id + '":"'+ProcessorUtil.CMO_MANUAL_MATCH+'"}';
                                                 c.submitAndNext();
                                                 CustomerOperationsController.RecordMatchWrapper wrapper = new CustomerOperationsController.RecordMatchWrapper(stripeCustomers[0]);
                                                 Test.stopTest();
                                                 System.assert([SELECT count() FROM BWP_Customer__c WHERE Salesforce_Account__c != null] == 0);
                                             }
                                            }
    
    @IsTest
    private static void matchingWebsiteTest() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BWP_Processor_Config__c apc = UnitTests.createPayConfig(ProcessorUtil.PAT_BRAINTREE);
            List<BWP_Customer__c> stripeCustomersCreated = UnitTests.customers(3);
            List<BWP_Customer__c> stripeCustomers = new List<BWP_Customer__c> ();
            List<Account> accnts = new List<Account> ();
            List<Contact> contacts = new List<Contact> ();
            for (BWP_Customer__c cus: stripeCustomersCreated) {
                cus.Processor_Org_Id__c = apc.Name;
                cus.Salesforce_Account__c = NULL;
                cus.No_Associated_SF_Account__c = FALSE;
                stripeCustomers.add(cus);
                
                //Creating matching accounts
                Account ac = new Account(
                    Name = cus.Customer_Name__c,
                    //  Phone = cus.Customer_Phone__c,
                    Website = 'https://breadwinner.com'
                );
                accnts.add(ac);
            }
            update stripeCustomers;
            insert accnts;
            //Creating contacts
            
            Contact c = new Contact(
                LastName = accnts[0].Name,
                Email = stripeCustomers[0].Email__c,
                Accountid = accnts[0].Id
            );
            contacts.add(c);
            insert contacts;
            CustomerOperationsController ctrl = new CustomerOperationsController();
            ctrl.jsonUserSelectedActions = '{"' + stripeCustomers[0].Id + '":"'+ProcessorUtil.CMO_CREATE_NEW+'"}';
            ctrl.submitAndNext();
            CustomerOperationsController.RecordMatchWrapper wrapper = new CustomerOperationsController.RecordMatchWrapper(stripeCustomers[0]);
            ctrl.pagingForCustomers();
            //System.assert([SELECT count() FROM BWP_Customer__c WHERE Salesforce_Account__c != null] > 0);
        }
    }
    
    @IsTest
    private static void matchingAddressTest() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BWP_Processor_Config__c apc = UnitTests.createPayConfig(ProcessorUtil.PAT_SQUARE);
            List<BWP_Customer__c> stripeCustomersCreated = UnitTests.customers(3);
            List<BWP_Customer__c> stripeCustomers = new List<BWP_Customer__c> ();
            List<Account> accnts = new List<Account> ();
            for (BWP_Customer__c cus: stripeCustomersCreated) {
                cus.Processor_Org_Id__c = apc.Name;
                cus.Salesforce_Account__c = NULL;
                cus.No_Associated_SF_Account__c = FALSE;
                cus.Billing_Street_Address_1__c = 'Street 1%%';
                cus.Billing_Street_Address_2__c = 'Street 2'; //+'%%';
                cus.Billing_City__c = 'New York';
                cus.Billing_State__c = 'New York';
                cus.Billing_Country__c = 'US';
                cus.Billing_Postal_Code__c = '500085';
                cus.Customer_Phone__c = '1234567890';
                stripeCustomers.add(cus);
                
                //Creating matching accounts
                String street = String.isNotBlank(cus.Billing_Street_Address_1__c) ? cus.Billing_Street_Address_1__c + ' ' : '';
                street += String.isNotBlank(cus.Billing_Street_Address_2__c) ? cus.Billing_Street_Address_2__c : '';
                Account ac = new Account(
                    Name = cus.Customer_Name__c + 'NotMatching',
                    Phone = '1234567890',
                    billingStreet = street,
                    billingCity = 'New York',
                    billingState = 'New York',
                    billingCountry = 'US',
                    billingPostalCode = '500085',
                    Website = 'https://breadwinner.com'
                );
                accnts.add(ac);
            }
            update stripeCustomers;
            insert accnts;
            CustomerOperationsController c = new CustomerOperationsController();
            c.jsonUserSelectedActions = '{"' + stripeCustomers[0].Id + '":"'+ProcessorUtil.CMO_SUGGESTED_MATCH+'"}';
            c.submitAndNext();
            CustomerOperationsController.RecordMatchWrapper wrapper = new CustomerOperationsController.RecordMatchWrapper(stripeCustomers[0]);
            //System.assert([SELECT count() FROM BWP_Customer__c WHERE Salesforce_Account__c != null] > 0);
        }
    }
    
    @IsTest
    static void accountWrapper(){
        CustomerOperationsController.RecordMatchWrapper wrapper = new CustomerOperationsController.RecordMatchWrapper();
        Boolean noAccount = wrapper.isUnableToCreateAccount;
    }
    
}