@isTest
/*
* This class is to create data for test classes. It's created for more resuability.
* All test methods will be here. This is the only the class for all test cases for all classes.
*/
@namespaceAccessible
public class UnitTests {

    @namespaceAccessible
    public static BreadwinnerUtil.AppConfig getProcessorConfigWrapper(String paymentProcessorType){
        BWP_Processor_Config__c apc = UnitTests.createPayConfig(paymentProcessorType);
        BreadwinnerUtil.AppConfig apcWrapper = BreadwinnerUtil.getProcessorConfigWrapper(apc);
        return apcWrapper;
    }
    
    //Test Data methods
    @namespaceAccessible
    public static BWP_Processor_Config__c createPayConfig(String paymentProcessorType) {
        return createPayConfig(1,paymentProcessorType)[0];
    }

    @namespaceAccessible
    public static List<BWP_Processor_Config__c> createPayConfig(Integer count, String paymentProcessorType) {
        List<BWP_Processor_Config__c> configs = instantiatePayConfig(count,paymentProcessorType);
        BreadwinnerUtil.isBreadwinnerTransaction = true;
        insert configs;
        return configs;
    }
    
    @namespaceAccessible
    public static List<BWP_Processor_Config__c> instantiatePayConfig(Integer count, String paymentProcessorType) {
        Integer settingsCount = [SELECT COUNT() FROM Breadwinner_Settings__c LIMIT 1];
        if (settingsCount == 0) {
            createBWSetting();
        }
        List<BWP_Processor_Config__c> configs = new List<BWP_Processor_Config__c> ();
        for (Integer i = 1; i <= count; i++) {
            BWP_Processor_Config__c config;
            if(paymentProcessorType == ProcessorUtil.PAT_STRIPE){
                config = new BWP_Processor_Config__c(
                    Name = 'acct_1Do5IGeHGxQ9S2f-' + i,
                    Access_token__c = 'sk_live_g1RtS2oGBqEuDJvVefzWqWx',
                    Account_Name__c = 'BW Co.',
                    Default_Currency__c = 'USD',
                    Historical_Customer_Sync_Last_Run__c = System.now()-7,
                    Historical_Payment_Sync_Last_Run__c = System.now()-7,
                    Hourly_Customer_Sync_Last_Run__c = System.now()-1,
                    Hourly_Payment_Sync_Last_Run__c = System.now()-1,
                    Is_Customer_Match_Completed__c = true,
                    Live_Mode__c = true,
                    Refresh_Token__c = 'rt_EIsycxuAZOjoiQ7KODs9MlSkT9hrfYaTJu20HtHodGwCCPH',
                    Scope__c = 'Read/write',
                    Provider_ID__c = 'acct_1Do5IGeHGxQ9S2f-' + i,
                    Card_Creation_Key__c = 'pk_test123456abcde',
                    Need_To_Reconnect__c = false,
                    Payment_Processor_Type__c = ProcessorUtil.PAT_STRIPE,
                    Customer_Match_Type__c = ProcessorUtil.CMT_ACCOUNT
                );
            }
            else if(paymentProcessorType == ProcessorUtil.PAT_BRAINTREE){
                config = new BWP_Processor_Config__c(
                    Name = 'braintree_Account_Name-' + i,
                    Access_token__c = 'PublicKeyandPrivateKey',
                    Account_Name__c = 'braintree_Account_Name',
                    Historical_Customer_Sync_Last_Run__c = System.now()-7,
                    Historical_Payment_Sync_Last_Run__c = System.now()-7,
                    Hourly_Customer_Sync_Last_Run__c = System.now()-1,
                    Hourly_Payment_Sync_Last_Run__c = System.now()-1,
                    Is_Customer_Match_Completed__c = true,
                    Live_Mode__c = true,
                    Provider_ID__c = 'braintree_Account_Name-' + i,
                    Need_To_Reconnect__c = false,
                    Payment_Processor_Type__c = ProcessorUtil.PAT_BRAINTREE,
                    Customer_Match_Type__c = ProcessorUtil.CMT_ACCOUNT
                );
            }
            else if(paymentProcessorType == ProcessorUtil.PAT_SQUARE){
                config = new BWP_Processor_Config__c(
                    Name = 'ML63YCDEY6SCD-' + i,
                    Access_token__c = 'EAAAEOGu_1of52ifoTScKcoruFhlqW6tgpIveMiMvYZF_qSDw2kXpQLU9otiIMAE',
                    Account_Name__c = 'Default Test Account',
                    Default_Currency__c = 'USD',
                    Historical_Customer_Sync_Last_Run__c = System.now()-7,
                    Historical_Payment_Sync_Last_Run__c = System.now()-7,
                    Hourly_Customer_Sync_Last_Run__c = System.now()-1,
                    Hourly_Payment_Sync_Last_Run__c = System.now()-1,
                    Is_Customer_Match_Completed__c = true,
                    Live_Mode__c = true,
                    Refresh_Token__c = 'EQAAEG0G69sY4aDb0TSKDO8l6M0ie9w00nXkiMSF96ci_sOw8kKf5diua4pfBD_Q',
                    Scope__c = 'Read/write',
                    Provider_ID__c = 'ML63YCDEY6SCD-' + i,
                    Need_To_Reconnect__c = false,
                    Payment_Processor_Type__c = ProcessorUtil.PAT_SQUARE,
                    Customer_Match_Type__c = ProcessorUtil.CMT_ACCOUNT
                );
            }
            else if(paymentProcessorType == ProcessorUtil.PAT_PAYPAL){
                config = new BWP_Processor_Config__c(
                        Name = ProcessorUtil.PAT_PAYPAL + '_Account_Name' + i,
                        Access_token__c = 'PublicKeyAndPrivateKey',
                        Account_Name__c = ProcessorUtil.PAT_PAYPAL + '_Account_Name',
                        Historical_Customer_Sync_Last_Run__c = System.now()-7,
                        Historical_Payment_Sync_Last_Run__c = System.now()-7,
                        Hourly_Customer_Sync_Last_Run__c = System.now()-1,
                        Hourly_Payment_Sync_Last_Run__c = System.now()-1,
                        Is_Customer_Match_Completed__c = true,
                        Live_Mode__c = true,
                        Provider_ID__c = ProcessorUtil.PAT_PAYPAL + '_Account_Name' + i,
                        Need_To_Reconnect__c = false,
                        Payment_Processor_Type__c = ProcessorUtil.PAT_PAYPAL,
                        Customer_Match_Type__c = ProcessorUtil.CMT_ACCOUNT
                );
            }
            else if(paymentProcessorType == ProcessorUtil.PAT_AUTHORIZE_NET){
                config = new BWP_Processor_Config__c(
                        Name = ProcessorUtil.PAT_AUTHORIZE_NET + '_Account_Name' + i,
                        Access_token__c = 'accessToken',
                        Account_Name__c = ProcessorUtil.PAT_AUTHORIZE_NET + '_Account_Name',
                        Historical_Customer_Sync_Last_Run__c = System.now()-7,
                        Historical_Payment_Sync_Last_Run__c = System.now()-7,
                        Hourly_Customer_Sync_Last_Run__c = System.now()-1,
                        Hourly_Payment_Sync_Last_Run__c = System.now()-1,
                        Is_Customer_Match_Completed__c = false,
                        Live_Mode__c = false,
                        Provider_ID__c = ProcessorUtil.PAT_AUTHORIZE_NET + '_Account_Name' + i,
                        Need_To_Reconnect__c = false,
                        Payment_Processor_Type__c = ProcessorUtil.PAT_AUTHORIZE_NET,
                        Customer_Match_Type__c = ProcessorUtil.CMT_ACCOUNT
                    );
            }
            configs.add(config);
        }
        
        return configs;
    }
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

    @isTest
    @namespaceAccessible
    public static Breadwinner_Settings__c createBWSetting() {
        Breadwinner_Settings__c bwSetting = new Breadwinner_Settings__c(
            Name = 'BWSetting',
            Active__c = True,
            Plan_Name__c = 'Basic',
            Plan_Code__c = '50',
            Status__c = 'trial',
            Date_of_Expiration__c = System.now() + 365
        );
        insert bwSetting;

        return bwSetting;

    }    
    
    @IsTest
    static void coverageForProcessorConfigTrigger(){
        //Test insert w/o BW access
        BWP_Processor_Config__c config = new BWP_Processor_Config__c(Name = 'insert config');
        try{
            insert config;
            System.assert(false, 'Expected Exception on insert but got success.');
        } catch(Exception ex){
            System.assert(ex.getMessage().contains('Access denied.'));
        }

        //Test insert with BW access
        BreadwinnerUtil.isBreadwinnerTransaction = true;
        insert config;

        // Test update w/o BW Access
        BreadwinnerUtil.isBreadwinnerTransaction = false;
        try{
            config.Name = 'update config';
            update config;
            System.assert(false, 'Expected Exception on update but got success.');
        } catch(Exception ex){
            System.assert(ex.getMessage().contains('Access denied.'));
        }

        //Test update with BW access
        BreadwinnerUtil.isBreadwinnerTransaction = true;
        update config;

        // Test delete w/o BW Access
        BreadwinnerUtil.isBreadwinnerTransaction = false;
        try{
            delete config;
            System.assert(false, 'Expected Exception on delete but got success.');
        } catch(Exception ex){
            System.assert(ex.getMessage().contains('Access denied.'));
        }

        //Test update with BW access
        BreadwinnerUtil.isBreadwinnerTransaction = true;
        delete config;
    }
    
    private static List<BreadwinnerUtil.AppConfig> createAppConfigWrappers(Integer count) {
        List<BreadwinnerUtil.AppConfig> appConfigList = new List<BreadwinnerUtil.AppConfig> ();
        for (BWP_Processor_Config__c config: createPayConfig(count, ProcessorUtil.PAT_STRIPE)) {
            appConfigList.add(BreadwinnerUtil.getProcessorConfigWrapper(config));
        }
        return appConfigList;
    }

    @TestVisible
    private static List<BWP_Transaction__c> transactions(Integer count) {
        List<BWP_Transaction__c> transactions = new List<BWP_Transaction__c> ();
        for (Integer i = 1; i <= count; i++) {

            BWP_Transaction__c Trxn = new BWP_Transaction__c(
                Amount__c = 100
            );
            transactions.add(Trxn);
        }
        insert transactions;
        return transactions;
    }

    @TestVisible
    private static List<BWP_Customer__c> customers(Integer count) {
        List<BWP_Customer__c> customers = new List<BWP_Customer__c> ();
        for (Integer i = 1; i <= count; i++) {

            BWP_Customer__c customer = new BWP_Customer__c(
                Customer_Name__c = 'Customer',
                Email__c = 'testCustomerMail-' + i + '@breadwinner.com',
                Description__c = 'This is customer description' + i,

                Billing_Street_Address_1__c = 'address line 1',
                Billing_Street_Address_2__c = 'address line 2',
                Billing_City__c = 'AL',
                Billing_Country__c = 'US',
                Billing_Postal_Code__c = '10001',
                Customer_Phone__c = '(555)555-5555',
                Processor_Customer_Id__c = 'cus_abcd-'+i,
                Invoice_Prefix__c = '0967A54',
                Tax_Id__c = 'GST0001',
                Currency__c = 'USD',
                Livemode__c = false,
                No_Associated_SF_Account__c = false
            );
            customers.add(customer);
        }
        insert customers;
        return customers;
    }

    @TestVisible
    private static List<BWP_Payment_Method__c> paymentMethods(Integer count) {
        List<BWP_Payment_Method__c> paymentMethods = new List<BWP_Payment_Method__c> ();
        for (Integer i = 1; i <= count; i++) {

            BWP_Payment_Method__c paymentMethod = new BWP_Payment_Method__c(
                Bank_Account_Holder_Name__c = 'STRIPE'
            );
            paymentMethods.add(paymentMethod);
        }
        insert paymentMethods;
        return paymentMethods;
    }

    /* ********************************** */

    @IsTest
    private static void deauthorization() {
		User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BWP_Processor_Config__c apc = UnitTests.createPayConfig(1, ProcessorUtil.PAT_STRIPE)[0];
            Test.startTest();
            PageReference pageRef = Page.BreadwinnerPayments;
            Test.setCurrentPage(pageRef);
    
            BreadwinnerController b = new BreadwinnerController();
            b.disconnectAppId = apc.Name;
            Breadwinner_Settings__c bs = Breadwinner_Settings__c.getAll().Values()[0];
            bs.Date_of_Expiration__c = System.now() - 7;
            System.debug('bs' + bs);
            update bs;
            b.bwSettings = bs;
            b.disconnect();
            Test.stopTest();
        }

       // System.assert(BreadwinnerUtil.processorConfigList.size() == 0);
    }

    @IsTest
    private static void deleteCustomersConnected() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            PageReference pageRef = Page.BreadwinnerPayments;
            Test.setCurrentPage(pageRef);
            UnitTests.customers(5);
            UnitTests.paymentMethods(5);
            UnitTests.transactions(5);
            BreadwinnerController b = new BreadwinnerController();
            b.customerMatchType = ProcessorUtil.CMT_ACCOUNT;
            b.isProcessorConnected = true; 
            b.customersCount = 5;
            b.paymentMethodsCount = 5;
            b.bwpTransCount  = 5;
            b.objectName = 'Customers';
            b.deleteRecords();
            b.objectName = 'PaymentMethods';
            b.deleteRecords();
            b.objectName = 'Payments';
            b.deleteRecords();
    
            System.assert([Select Id from BWP_Customer__c].size() == 0);
            System.assert([Select Id from BWP_Transaction__c].size() == 0);
            System.assert([Select Id from BWP_Payment_Method__c].size() == 0);
        }
    }

   
    @IsTest
    static void deleteCustomersDisonnected() {
        Test.startTest();
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            PageReference pageRef = Page.BreadwinnerPayments;
            Test.setCurrentPage(pageRef);
            UnitTests.customers(5);
            UnitTests.paymentMethods(5);
            UnitTests.transactions(5);
            BreadwinnerController b = new BreadwinnerController();
            b.customerMatchType = ProcessorUtil.CMT_CONTACT;
            b.isProcessorConnected = false;
            b.customersCount = 5;
            b.paymentMethodsCount = 5;
            b.bwpTransCount  = 5;
            b.objectName = 'Customers';
            b.deleteRecords();
            b.objectName = 'PaymentMethods';
            b.deleteRecords();
            b.objectName = 'Payments';
            b.deleteRecords();
            
            b.syncName = 'Customer';
            b.appC =  UnitTests.getProcessorConfigWrapper(ProcessorUtil.PAT_STRIPE);
            b.syncProcessor = b.appC.accountId;
            b.restartHistoricalSync();
            HourlySyncBatch runHourlSync = new HourlySyncBatch(b.syncName, new List<BreadwinnerUtil.AppConfig>{b.appC});
            
            
            System.assert([Select Id from BWP_Customer__c].size() == 0);
            System.assert([Select Id from BWP_Transaction__c].size() == 0);
            System.assert([Select Id from BWP_Payment_Method__c].size() == 0);
        }
        Test.stopTest();
    }

    @IsTest
    private static void additionalCoverage_BreadwinnerUtil(){
        List<PackageLicense> currentPackageList=  BreadwinnerUtil.getCurrentPackageList();
        Boolean isBWOperationsPSAssigned = BreadwinnerUtil.isBWOperationsPSAssigned();
        Boolean isBWAdminPSAssigned = BreadwinnerUtil.isBWAdminPSAssigned();
        Map<String, String> cardTypeName = ProcessorUtil.getCardTypeName();
        List<SelectOption> stripeCurrencies = BreadwinnerUtil.getStripeCurrencies();
        List<String> zeroDecimalStripeCurrencies = BreadwinnerUtil.getZeroDecimalStripeCurrencies();
        String baseEndpointURL = BreadwinnerUtil.getBaseEndpointURL();
        String baseAPIURL = BreadwinnerUtil.getBW_API_BaseURL();
    }

    @IsTest
    private static void coverCreatedViaMethod_When_CRCV_ISNULL(){
        String createdVia = BreadwinnerUtil.getCreatedViaValue(null);
        System.assertEquals(createdVia, 'Breadwinner');
    }
    @IsTest
    private static void coverCreatedViaMethod_When_CRCV_ISBLANK(){
        String createdVia = BreadwinnerUtil.getCreatedViaValue('');
        System.assertEquals(createdVia, 'Breadwinner');
    }
    @IsTest
    private static void coverCreatedViaMethod_When_CRCV_HistoricalSync(){
        String createdVia = BreadwinnerUtil.getCreatedViaValue(BreadwinnerUtil.CNTX_HIST_SYNC);
        System.assertEquals(createdVia, 'Historical Sync');
    }
    @IsTest
    private static void coverCreatedViaMethod_When_CRCV_HourlySync(){
        String createdVia = BreadwinnerUtil.getCreatedViaValue(BreadwinnerUtil.CNTX_HOUR_SYNC);
        System.assertEquals(createdVia, 'Regular Sync');
    }
    @IsTest
    private static void coverCreatedViaMethod_When_CRCV_BW(){
        String createdVia = BreadwinnerUtil.getCreatedViaValue(BreadwinnerUtil.CNTX_BW);
        System.assertEquals(createdVia, 'Breadwinner');
    }
    @IsTest
    private static void coverCreatedViaMethod_When_CRCV_BWAPI(){
        String createdVia = BreadwinnerUtil.getCreatedViaValue(BreadwinnerUtil.CNTX_BWAPI);
        System.assertEquals(createdVia, 'Breadwinner API');
    }
    @IsTest
    private static void coverCreatedViaMethod_When_CP_CreateCustomer(){
        PageReference pageRef = Page.CreateCustomer;
        Test.setCurrentPage(pageRef);
        String createdVia = BreadwinnerUtil.getCreatedViaValue(BreadwinnerUtil.CNTX_BWAPI);
        System.assertEquals(createdVia, 'Breadwinner');
    }
    @IsTest
    private static void coverCreatedViaMethod_When_CP_BreadwinnerPayments(){
        PageReference pageRef = Page.BreadwinnerPayments;
        Test.setCurrentPage(pageRef);
        String createdVia = BreadwinnerUtil.getCreatedViaValue(BreadwinnerUtil.CNTX_BWAPI);
        System.assertEquals(createdVia, 'Breadwinner API');
    }

    @IsTest
    private static void additionalCoverage_ProcessorUtil(){
        Map<String, String> cardTypeName = ProcessorUtil.getCardTypeName();
    }

    @IsTest
    private static void checkmonitor() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BWP_Processor_Config__c apc = UnitTests.createPayConfig(1, ProcessorUtil.PAT_STRIPE)[0];
            breadwinnerMonitor sw= new breadwinnerMonitor();
            String CRON_EXP = '0 0 0 15 3 ? *';
            PageReference Breadwinner = Page.BreadwinnerPayments;
            BreadwinnerController b = new BreadwinnerController();
            Test.startTest();
            String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new breadwinnerMonitor());
            b.rescheduleHourlySync();
            BreadwinnerController.checkAndScheduleBreadwinnerMonitor();
            Test.stopTest();
        }
    }

    @IsTest
    private static void testCustomURLGeneration(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            Test.setCurrentPageReference(new PageReference('Page.CustomURLGenerator'));
            System.currentPageReference().getParameters().put('originating_object', 'Account');
            createPayConfig(ProcessorUtil.PAT_STRIPE);
            CustomURLGeneratorController CUG= new CustomURLGeneratorController();
            CUG.ParentObjectName = 'Account';
            CUG.selectedObject ='Account';
            test.startTest();
            CUG.parentObjectFields();
            CUG.generateURL();
            CUG.goBack();
            test.stopTest();
        }
    }

    @IsTest
    private static void testCryptoUtil() {
        Test.startTest();
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            Blob keyBlob1 = Crypto.generateAesKey(256);
            Blob keyBlob2 = Crypto.generateAesKey(256);
            String cKey1 = EncodingUtil.convertToHex(keyBlob1);
            String cKey2 = EncodingUtil.convertToHex(keyBlob2);
            
            CryptoUtil.cryptoKeyMap = new Map<String,String>{'Crypto_Key'=> cKey1, 'Crypto_Key_Legacy'=>cKey1};
            BWP_Processor_Config__c pConfig = instantiatePayConfig(1, ProcessorUtil.PAT_STRIPE)[0];
            String rawAccessToken = pConfig.Access_Token__c;
            BreadwinnerUtil.AppConfig appC = BreadwinnerUtil.getProcessorConfigWrapper(pConfig);
            BreadwinnerUtil.AppConfig encAppC = CryptoUtil.encryptSecrets(appC);
            System.assertEquals(rawAccessToken, CryptoUtil.decryptAES256(encAppC.accessToken, keyBlob1), 'Encryption using Crypto Key failed');
            
            //Can't test the following as the encryption value changes every time.
            //System.assertEquals(CryptoUtil.encryptWithAES256(rawConsumerKey, EncodingUtil.convertFromHex(cKey1)), encAppC.ConsumerKey);
            pConfig = CryptoUtil.encryptSecrets(pConfig);
            BreadwinnerUtil.isBreadwinnerTransaction = TRUE;
            insert pConfig;
            
            BreadwinnerUtil.AppConfig decAppC = CryptoUtil.decryptSecrets(encAppC);
            System.assertEquals(rawAccessToken, decAppC.accessToken);
            System.assertEquals(FALSE, decAppC.isEncryptionRotationRequired);
            System.assertEquals(TRUE, decAppC.isAlreadyDecrypted);
            
            
            BreadwinnerUtil.AppConfig encAppC2 = CryptoUtil.encryptSecrets(appC);
            //it's taking the same instance of appC from encAppC and decAppC - so we are unsetting isAlreadyDecrypted
            encAppC2.isAlreadyDecrypted = FALSE;
            
            //Changing the Crypto Key metadata record
            CryptoUtil.cryptoKeyMap = new Map<String,String>{'Crypto_Key'=> cKey2, 'Crypto_Key_Legacy'=>cKey1};
            BreadwinnerUtil.AppConfig decAppC2 = CryptoUtil.decryptSecrets(encAppC2);
            System.assertEquals(TRUE, decAppC2.isEncryptionRotationRequired);
            //code coverage of exceptions
            decAppC2 = CryptoUtil.decryptSecrets(decAppC2);
            
            //rotation
            CryptoUtil.verifyAndRotateEncryption(pConfig);
            BWP_Processor_Config__c pConfig2 = [SELECT Id, Name, Access_Token__c FROM BWP_Processor_Config__c WHERE Id =: pConfig.Id LIMIT 1];
            System.assertEquals(rawAccessToken, CryptoUtil.decryptAES256(pConfig2.Access_token__c, keyBlob2), 'Crypto Key rotation failed');
            
        }
        Test.stopTest();
    }

    @IsTest
    private static void postInstall() {
        Test.startTest();
        PostInstallHandler postinstall = new PostInstallHandler();
        Test.testInstall(postinstall, null);
        Test.testInstall(postinstall, new Version(1,0), true);
        Test.stopTest();
    }

    // Dummy Metadata API web service mock class
    private class WebServiceMockImpl implements WebServiceMock {
        public void doInvoke (
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
            if(request instanceof MetadataService.updateMetadata_element)
                response.put('response_x', new MetadataService.updateMetadataResponse_element());
            else if(request instanceof  MetadataService.deleteMetadata_element)
                response.put('response_x', new MetadataService.deleteMetadataResponse_element());
            else if(request instanceof  MetadataService.upsertMetadata_element)
                response.put('response_x', new MetadataService.upsertMetadataResponse_element());
            else if(request instanceof  MetadataService.createMetadata_element)
                response.put('response_x', new MetadataService.createMetadataResponse_element());
            else if(request instanceof MetadataService.listMetadata_element)
                response.put('response_x', new MetadataService.listMetadataResponse_element());
            return;
        }
    }

    @IsTest
    private static void coverBreadwinnerController(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            Breadwinner_Settings__c bwSetting = UnitTests.createBWSetting();
            bwSetting.Name = 'bwpsetting';
            bwSetting.Support_URL__c = 'test.com';
            update bwSetting;
            BreadwinnerController bc = new BreadwinnerController();
            bc.initializeApp();
            bc.getAvailableEndpointURLs();
            bc.refreshAppConfig();
            bc.showEditSettingSection();
            bc.saveSettingSection();
            bc.getPaymentProcessorsList();
            bc.restartHistoricalSync();
            bc.restartWeeklySync();
            bc.changeBreadwinnerMode();
            bc.OrgWideRecordsCount();
            bc.showEndpointUrlEditor();
            bc.updateEndpointUrl();
            bc.hideEndpointUrlEditor();
            bc.saveCustomerConfigurationValues();
            bc.restartWeeklySync();
            bc.restartScheduledJobs();
            bc.saveCustomerConfigurationValues();
            bc.getCanUpdatePageLayouts();
            bc.getIsPermissionSetAssigned();
            BWP_Processor_Config__c config = createPayConfig(1, ProcessorUtil.PAT_STRIPE)[0];
            bc.startHistoricalCustomerSync(config);
            bc.updatePageLayouts();
            BreadwinnerController.scheduledJobsRunByActiveOrAdminUserMap();
            bc.TroubleshootGeneralInitialize();
            bc.BW_API_BaseURL = 'Test';
            bc.BW_SupportPortalURL = 'BW_SupportPortalURL';
            Boolean jobRunningByActiveUser = bc.isScheduledJobsRunByActiveUser;
            Boolean jobRunningByAdmin = bc.isScheduledJobsRunByAdmin;
            bc.checkCustomerMatch();
            BreadwinnerController.getBreadwinnerSettingWrapper(createBWSetting());
            BreadwinnerController.wrapPermissionUsers permission =  new BreadwinnerController.wrapPermissionUsers('firstname', 'userName', 'profileName', false, false, false, false);
        }
    }

    @isTest static void testStatusLogTable(){
        MockHttpResponse httpMock = new MockHttpResponse();
        httpMock.response = '[{"org_id": "00D5g000004zd9UEAQ","company_name": "Dhruvsoft","event_type": "Connecting To Stripe","event_detail": "ERROR","log_id": 64978667,"first_name": "Ramya","last_name": "Peddammala","additional_detail": "Read timed out","org_type": "production","package_version": "dev","app": "Payments","email": "ramya@dhruvsoft.com","timestamp": "2021-05-11 12:16:28"}]';
        Test.setMock(HttpCalloutMock.class, httpMock);
        BreadwinnerController.LogWrapper l = new BreadwinnerController.LogWrapper();
        l.log_id='';
        l.event_type = '';
        l.event_detail = '';
        l.additional_detail = '';
        l.timestamp = '';
        l.package_version = '';
        
        Test.startTest();
        
        List<BreadwinnerController.LogWrapper> loglist = BreadwinnerController.getTableChartData();
        Test.StopTest();
    }

    @IsTest
    private static void coverProcessorUtil(){
        ProcessorUtil.getDefaultAccountRecordType();
        ProcessorUtil.areStateAndCountryPicklistsEnabled();
    }

    @IsTest
    private static void coverGeneratedCodeCRUDOperations() {
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataService metaDataService = new MetadataService();
        // Invoke operations
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
        try {
            metaDataPort.listMetadata(null, null);
        }
        catch(Exception e ) {
            system.debug(e);
        }
    }

    @IsTest
    private static void coverGeneratedCodeFileBasedOperations1() {
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataService metaDataService = new MetadataService();
        // Invoke operations
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();

        try {
            metaDataPort.upsertMetadata(null);
        }
        catch(Exception e ) {
            system.debug(e);
        }
    }

    @IsTest
    private static void coverGeneratedCodeFileBasedOperations2() {
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataService metaDataService = new MetadataService();
        // Invoke operations
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();

        try {
            metaDataPort.readMetadata(null,null);
        }
        catch(Exception e) {
            system.debug(e);
        }
        try {
            metaDataPort.upsertMetadata(null);
        }
        catch(Exception e) {
            system.debug(e);
        }

        try {
            metaDataPort.createMetadata(null);
        }
        catch(Exception e) {
            system.debug(e);
        }
        try {
            metaDataPort.deleteMetadata(null, null);
        }
        catch(Exception e) {
            system.debug(e);
        }
    }

    @IsTest
    static void breadwinnerPaymentsAPI_call_when_InvalidConfig_Expect_apiError() {
        // no processor configured
        Breadwinner_Settings__c settings = createBWSetting();
        settings.Read_Only_Mode__c = false;
        update settings;

        createPayConfig(1, ProcessorUtil.PAT_STRIPE);

        Test.startTest();

        Customer.BraintreeCustomer braintreeCustomer = new Customer.BraintreeCustomer();
        braintreeCustomer.firstName = 'Kenneth';
        braintreeCustomer.lastName = 'Woodell';
        braintreeCustomer.email = 'test@test.com';
        braintreeCustomer.phoneNumber = '773-631-4077';
        braintreeCustomer.company = 'Hoyden';

        Map<String,Object> request = new Map<String,Object>();
        request.put(ProcessorUtil.API_ACTION,ProcessorUtil.ACT_CREATE_CUSTOMER);
        request.put(ProcessorUtil.API_VERSION, ProcessorUtil.VER_1);
        request.put(ProcessorUtil.API_PROCESSOR_ID,'something');
        request.put(ProcessorUtil.API_REQUEST_JSON, JSON.serializePretty(braintreeCustomer));
        Map<String, Object> response =  BreadwinnerPaymentsAPI.call(request);

        List<ProcessorUtil.Error> apiErrors = (List<ProcessorUtil.Error>) response.get(ProcessorUtil.RESP_API_ERRORS);
        System.assertEquals(false, (Boolean) response.get(ProcessorUtil.RESP_VAL_REQ));
        System.assert(apiErrors != null,'Expecting apiErrors to exist but it does not.');
       // System.assertEquals('INVALID_PROCESSOR', apiErrors[0].code);
        Test.stopTest();
    }

    @IsTest
    static void breadwinnerPaymentsAPI_ValidateBreadwinnerConfig() {
		User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            try{
                breadwinnerPaymentsAPI.validateBreadwinnerConfig(ProcessorUtil.ACT_CREATE_CUSTOMER);
                System.assert(false, 'Expected INVALID_SUBSCRIPTION_Exception but got success.');
            } catch (BreadwinnerPaymentsAPI.INVALID_SUBSCRIPTION_Exception ex) {}
    
            Breadwinner_Settings__c settings = createBWSetting();
            try{
                breadwinnerPaymentsAPI.validateBreadwinnerConfig(ProcessorUtil.ACT_CREATE_CUSTOMER);
                System.assert(false, 'Expected READ_ONLY_MODE_ENABLED_Exception but got success.');
            } catch (BreadwinnerPaymentsAPI.READ_ONLY_MODE_ENABLED_Exception ex){}
    
    
            settings.Read_Only_Mode__c = false;
            update settings;
    
            createPayConfig(ProcessorUtil.PAT_STRIPE);
            breadwinnerPaymentsAPI.validateBreadwinnerConfig(ProcessorUtil.ACT_CREATE_CUSTOMER);
        }
    }

    @IsTest
    private static void codeCoverage_APICallHandler(){
        APICallHandler.synchronousLogPush('','','');
        APICallHandler.BreadwinnerORGCreation(false);
        APICallHandler.parseAccountResponse('');
        APICallHandler.updateBWCustomSettingRecord(new APICallHandler.AccountResponse());
    }

    @IsTest
    private static void codeCoverage_LogPush(){
        APICallHandler.synchronousLogPush('','','');
    }

    @IsTest
    private static void codeCoverage_BreadWinnerController(){
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BreadwinnerController bwCon = new BreadwinnerController();
            bwCon.rerenderThisPage();
            bwCon.cancelSettingSection();
            BreadwinnerController.createService();
        }
    }

    @IsTest
    private static void coverGeneratedCodeTypes() {
        new MetadataService();
        new MetadataService.CallOptions_element();
        new MetadataService.CompactLayout();
        new MetadataService.Container();
        new MetadataService.createMetadata_element();
        new MetadataService.createMetadataResponse_element();
        new MetadataService.CustomConsoleComponents();
        new MetadataService.CustomPageWebLink();
        new MetadataService.CustomPageWebLinkTranslation();
        new MetadataService.DebuggingHeader_element();
        new MetadataService.DebuggingInfo_element();
        new MetadataService.describeMetadata_element();
        new MetadataService.DescribeMetadataObject();
        new MetadataService.Error();
        new MetadataService.FeedLayout();
        new MetadataService.FeedLayoutComponent();
        new MetadataService.FeedLayoutFilter();
        new MetadataService.FieldOverride();
        new MetadataService.Group_x();
        new MetadataService.HomePageComponent();
        new MetadataService.HomePageLayout();
        new MetadataService.Layout();
        new MetadataService.LayoutColumn();
        new MetadataService.LayoutItem();
        new MetadataService.LayoutSection();
        new MetadataService.LayoutSectionTranslation();
        new MetadataService.LayoutTranslation();
        new MetadataService.ListViewFilter();
        new MetadataService.LogInfo();        
        new MetadataService.Metadata();
        new MetadataService.MetadataPort();
        new MetadataService.MetadataWithContent();
        new MetadataService.MiniLayout();
        new MetadataService.NameSettings();
        new MetadataService.Picklist();
        new MetadataService.PicklistValue();
        new MetadataService.PrimaryTabComponents();
        new MetadataService.ProfileLayoutAssignment();
        new MetadataService.QuickAction();
        new MetadataService.QuickActionLayout();
        new MetadataService.QuickActionLayoutColumn();
        new MetadataService.QuickActionLayoutItem();
        new MetadataService.QuickActionList();
        new MetadataService.QuickActionListItem();
        new MetadataService.QuickActionTranslation();
        new MetadataService.readCompactLayoutResponse_element();
        new MetadataService.ReadCompactLayoutResult();
        new MetadataService.readCustomPageWebLinkResponse_element();
        new MetadataService.ReadCustomPageWebLinkResult();
        new MetadataService.readHomePageComponentResponse_element();
        new MetadataService.ReadHomePageComponentResult();
        new MetadataService.readHomePageLayoutResponse_element();
        new MetadataService.ReadHomePageLayoutResult();
        new MetadataService.readLayoutResponse_element();
        new MetadataService.ReadLayoutResult();
        new MetadataService.readMetadata_element();
        new MetadataService.readMetadataResponse_element();
        new MetadataService.readPicklistValueResponse_element();
        new MetadataService.ReadPicklistValueResult();
        new MetadataService.ReadGlobalPicklistValueResult();
        new MetadataService.readGlobalPicklistValueResponse_element();
        new MetadataService.ReadCustomObjectResult();
        new MetadataService.readCustomObjectResponse_element();
        new MetadataService.ReadBusinessProcessResult();
        new MetadataService.readBusinessProcessResponse_element();
        new MetadataService.ReadFieldSetResult();
        new MetadataService.readFieldSetResponse_element();
        new MetadataService.ReadCustomFieldResult();
        new MetadataService.readCustomFieldResponse_element();
        new MetadataService.ReadSharingReasonResult();
        new MetadataService.readSharingReasonResponse_element();
        new MetadataService.ReadValidationRuleResult();
        new MetadataService.readValidationRuleResponse_element();
        new MetadataService.ReadCustomApplicationResult();
        new MetadataService.readQuickActionResponse_element();
        new MetadataService.ReadQuickActionResult();
        new MetadataService.ReadResult();
        new MetadataService.readWebLinkResponse_element();
        new MetadataService.ReadWebLinkResult();
        new MetadataService.RelatedContent();
        new MetadataService.RelatedContentItem();
        new MetadataService.RelatedList();
        new MetadataService.RelatedListItem();
        new MetadataService.ReportChartComponentLayoutItem();
        new MetadataService.SaveResult();
        new MetadataService.SearchLayouts();
        new MetadataService.SessionHeader_element();
        new MetadataService.SidebarComponent();
        new MetadataService.SubtabComponents();
        new MetadataService.SummaryLayout();
        new MetadataService.SummaryLayoutItem();
        //new MetadataService.UpdateMetadata();
        new MetadataService.updateMetadata_element();
        new MetadataService.updateMetadataResponse_element();
        new MetadataService.upsertMetadata_element();
        new MetadataService.upsertMetadataResponse_element();
        new MetadataService.UpsertResult();
        new MetadataService.DeleteResult();
        new MetadataService.SaveResult();
        new MetadataService.WebLink();
        new MetadataService.FileProperties();
        new MetadataService.listMetadata_element();
        new MetadataService.ListMetadataQuery();
        new MetadataService.listMetadataResponse_element();
        new MetadataService.CustomMetadata();
        new MetadataService.CustomMetadataValue();
        new MetadataService.FieldValue();
        new MetadataService.PackageTypeMembers();
        new MetadataService.PackageVersion();
        new MetadataService.AllOrNoneHeader_element();
        new MetadataService.ChannelLayoutItem();
        new MetadataService.SharedTo();
        new MetadataService.ListView();
        new MetadataService.FeedItemSettings();
        new MetadataService.FlexiPage();
        new MetadataService.PlatformActionList();
        new MetadataService.CustomShortcut();
        new MetadataService.FeedFilterCriterion();
        new MetadataService.FieldSet();
        new MetadataService.VisualizationType();
        new MetadataService.ComponentInstance();
        new MetadataService.ChannelLayout();
        new MetadataService.AppMenuItem();
        new MetadataService.RecordType();
        new MetadataService.PlatformActionListItem();
        new MetadataService.renameMetadata_element();
        new MetadataService.AnalyticsCloudComponentLayoutItem();
        new MetadataService.ActionLinkGroupTemplate();
        new MetadataService.RecordTypePicklistValue();
        new MetadataService.FlexiPageRegion();
        new MetadataService.CustomApplicationComponent();
        new MetadataService.ComponentInstanceProperty();
        new MetadataService.OpportunityListFieldsSelectedSettings();
        new MetadataService.ListPlacement();
        new MetadataService.renameMetadataResponse_element();
        new MetadataService.SynonymGroup();
        new MetadataService.CustomFeedFilter();
        new MetadataService.ProfileRecordTypeVisibility();
        new MetadataService.ReadListViewResult();
        new MetadataService.readListViewResponse_element();
        new MetadataService.ReadRecordTypeResult();
        new MetadataService.readRecordTypeResponse_element();
        new MetadataService.ReadGroupResult();
        new MetadataService.readGroupResponse_element();
        new MetadataService.ReadFlexiPageResult();
        new MetadataService.readFlexiPageResponse_element();
        new MetadataService.ReadRemoteSiteSettingResult();
        new MetadataService.readRemoteSiteSettingResponse_element();
        new MetadataService.ReadCustomMetadataResult();
        new MetadataService.ReadActionLinkGroupTemplateResult();
        new MetadataService.readActionLinkGroupTemplateResponse_element();
        new MetadataService.ReadMetadataWithContentResult();
        new MetadataService.readMetadataWithContentResponse_element();
        new MetadataService.ActionLinkTemplate();
        new MetadataService.DescribeMetadataResult();
        new MetadataService.RemoteSiteSetting();
        new MetadataService.PagesToOpen();
        new MetadataService.describeMetadataResponse_element();
        new MetadataService.FieldSetItem();
        new MetadataService.CustomApplication();
        new MetadataService.CustomApplicationComponents();
        new MetadataService.DomainWhitelist();
        new MetadataService.TabLimitConfig();
        new MetadataService.readCustomApplicationResponse_element();
        new MetadataService.ReadCustomMetadataResult();
        new MetadataService.CustomObject();
        new MetadataService.CustomField();
        new MetadataService.ValidationRule();
        new MetadataService.SharingReason();
        new MetadataService.SharingRecalculation();
        new MetadataService.Index();
        new MetadataService.IndexField();
        new MetadataService.HistoryRetentionPolicy();
        new MetadataService.ValueSettings();
        new MetadataService.ValueSetValuesDefinition();
        new MetadataService.ValueSet();
        new MetadataService.FilterItem();
        new MetadataService.LookupFilter();
        new MetadataService.BusinessProcess();
        new MetadataService.ArticleTypeTemplate();
        new MetadataService.ArticleTypeChannelDisplay();
        new MetadataService.ActionOverride();
    }
    
    @namespaceAccessible
    public class MockHttpResponse implements HttpCalloutMock {
        public Integer statusCode = 200;
        public String response = '';

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(response);
            res.setStatusCode(statusCode);
            return res;
        }
    }

    /**
     * Generate a fake Salesforce Id for the given SObjectType
     *
     * @param sobjectType object ID should be created for
     *
     * @return random Id of object passed in
     */
    public static Id generateId(Schema.SObjectType sobjectType) {
        String keyPrefix = sobjectType.getDescribe().getKeyPrefix();

        Integer randomNumber = 0;
        while (randomNumber < 100) {
            randomNumber = Crypto.getRandomInteger();
        }

        String randNum = String.valueOf(randomNumber).right(3);
        return Id.valueOf(keyPrefix + '000000000' + randNum);
    }
    
}