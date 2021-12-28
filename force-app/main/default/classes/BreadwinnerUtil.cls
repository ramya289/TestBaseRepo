/*
Description - This class contains reusable methods.
*/
@namespaceAccessible
public with sharing class BreadwinnerUtil{

    // It is used to store the Package Version number. We will update this for every release until we find a way to automate values. Existing way is not supporting in the 2GP.
    public static final String PKG_VER_NO = '2.5';

    public static final String OBJ_SYNC_CUSTOMER = 'Customer';
    public static final String OBJ_SYNC_PAYMENT = 'Payment';
    @namespaceAccessible public static final String OBJ_SYNC_PRODUCT = 'Product';
    @namespaceAccessible public static final String OBJ_SYNC_PRICE = 'Price';

    // Current Running Context Variables
    @namespaceAccessible public static final String CNTX_HIST_SYNC = 'HistoricalSyncBatch';
	@namespaceAccessible public static final String CNTX_HOUR_SYNC = 'HourlySyncBatch';
	@namespaceAccessible public static final String CNTX_BWAPI = 'Breadwinner API';
	@namespaceAccessible public static final String CNTX_BW = 'Breadwinner';
    @namespaceAccessible public static final String CNTX_BB_HIST_SYNC = 'BillingHistoricalSyncBatch';

    public static final String SYNC_CNTX_HOURLY = 'BreadwinnerPaymentsHourlySync';
    public static final String SYNC_CNTX_WEEKLY = 'BreadwinnerPaymentsWeeklySync';
    public static final String SYNC_CNTX_MONITOR = 'MonitorBreadwinnerPayments';
    public static final String SYNC_CNTX_ALL = 'BreadwinnerPayments';

    //Permission Sets Name
    public static final String ADMIN_PS_NAME = 'Breadwinner_Payments_Admin_User';
    public static final String OPERATION_PS_NAME = 'Breadwinner_Payments_Operations';
    public static final String STANDARD_PS_NAME = 'Breadwinner_Payments_Standard_User';
    public static final String READONLY_PS_NAME = 'Breadwinner_Payments_Read_Only';

    public static final String BB_EXT_PACKAGE_NAME = 'Breadwinner Billing';

    @namespaceAccessible
    public static Boolean isBreadwinnerTransaction {
        get { 
            if (isBreadwinnerTransaction == null){
                 isBreadwinnerTransaction = false;
            }
            return isBreadwinnerTransaction;
        } 
        set;
    }

    private static Selector_BWP_ProcessorConfig selectorProcessorConfig = new Selector_BWP_ProcessorConfig();

    public static String namespace {
        get {
            if (namespace == null) {
                namespace = '';
                Schema.DescribeSObjectResult os = Schema.SObjectType.BWP_Transaction__c;
                String[] split = os.getName().split('__');
                if (split.size() > 2) {
                    namespace = split[0];
                }
            }
            System.debug('namespace: '+namespace);
            return namespace;
        }
        set;
    }

    @namespaceAccessible
    public static List<BWP_Processor_Config__c> processorConfigList{
        get{
            if(processorConfigList == null){
                processorConfigList = selectorProcessorConfig.getAllAppConfig();
            }
            return processorConfigList;
        }
        set;
    }

    @namespaceAccessible
    public static BWP_Processor_Config__c getProcessorConfig(String processorId){
        List<BWP_Processor_Config__c> processorConfig = selectorProcessorConfig.selectByProcessorId(new Set<String>{processorId});
        return processorConfig.size()>0 ? processorConfig[0] : new BWP_Processor_Config__c();
    }
    
    @namespaceAccessible public static String namespaceApi = String.isNotBlank(namespace) ? namespace+'__' : '';
    public static Set<String> zeroDecimalCurrencies = new Set<String>{'BIF', 'CLP', 'DJF', 'GNF', 'JPY', 'KMF', 'KRW', 'MGA', 'PYG', 'RWF', 'VND', 'VUV', 'XAF', 'XOF', 'XPF'};
    public static Id accountId;
    
    //Determining lightning or classic
    public static Boolean isLightning() {
        return (UserInfo.getUiThemeDisplayed() == 'Theme3' && Apexpages.currentPage().getParameters().get('beLightning') == null ? false : true);
    }

    @namespaceAccessible
    public static Boolean isAdministrator(){
        if(Schema.sObjectType.Profile.isAccessible()) {
            return [SELECT Id, PermissionsModifyAllData FROM Profile WHERE Id=:UserInfo.getProfileId() LIMIT 1].PermissionsModifyAllData;
        }
        return FALSE;
    }

    @namespaceAccessible
    public static Boolean isProcessorConnected(){
        return !processorConfigList.isEmpty() && processorConfigList[0].Access_Token__c != null;
    }

    public static List<PackageLicense> getCurrentPackageList() {
        return (Schema.SobjectType.PackageLicense.isAccessible()) ? [SELECT NamespacePrefix, Id, IsProvisioned, CreatedDate FROM PackageLicense WHERE NamespacePrefix =: namespace LIMIT 1] : new List<PackageLicense>();
    }

    public static String getBW_PackageVersion() {
        if(String.isBlank(namespace)){
            return 'dev';
        } else {
            //Publisher publisher = [SELECT Id, NamespacePrefix, MajorVersion, MinorVersion FROM Publisher WHERE NamespacePrefix =: namespace LIMIT 1];
            String packageVer = PKG_VER_NO;
            if(namespace.containsIgnoreCase('bwp_rc'))
                return 'rc_' + packageVer;
            else
                return packageVer;
        }
    }

    public static Organization orgInfo(){
        if(Schema.sObjectType.Organization.isAccessible()) {
            return [SELECT Country, Id, InstanceName, IsSandbox, Name, NamespacePrefix, OrganizationType, TrialExpirationDate FROM Organization LIMIT 1];
        }
        else return new Organization();
    }

    public static Boolean isSandbox(){
        Organization orgInfo = orgInfo();
        return orgInfo.IsSandbox;
    }

    public static Boolean isSandboxRefresh(){
        Breadwinner_Settings__c bwSetting = getBWSetting();
        return (isSandbox() && (UserInfo.getOrganizationId() != bwSetting.Salesforce_Org_Id__c));
    }

    public static void deleteConfigsWhenSandboxRefresh(){
        if(isSandboxRefresh()){
            try{
                List<Breadwinner_Settings__c> bwSettingList = Breadwinner_Settings__c.getall().values();
                List<BWP_Processor_Config__c> processorConfigList = BreadwinnerUtil.processorConfigList;
                isBreadwinnerTransaction = true;
                SecurityUtil.dmlDelete(processorConfigList);
                SecurityUtil.dmlDelete(bwSettingList);
                abortAllBreadwinnerPaymentsJobs();
            }
            catch(Exception e){
                System.debug('Exception'+e.getMessage());
                APICallHandler.userInteractionLogPush(TRUE, 'Delete Config', 'ERROR' , 'Error occured while deleting Processor Configs and Custom Settings on Sandbox refresh. '+e.getStackTraceString());
            }
        }
    }

    public static void abortAllBreadwinnerPaymentsJobs(){
        for(CronTrigger ct : BreadwinnerUtil.getCronTrigger(BreadwinnerUtil.SYNC_CNTX_ALL)){
            System.abortJob(ct.id);
        }
    }
    
    @namespaceAccessible
    public static Breadwinner_Settings__c getBWSetting(){
        return Breadwinner_Settings__c.getAll().values().size() > 0 ? Breadwinner_Settings__c.getAll().values().get(0) : new Breadwinner_Settings__c(Name=CNTX_BW);
    }
    
    public static Boolean isBreadwinnerInstalled(){
        if(Schema.SobjectType.PackageLicense.isAccessible()){
            return([SELECT NamespacePrefix, Id, IsProvisioned, CreatedDate FROM PackageLicense WHERE NamespacePrefix=:nameSpace LIMIT 1].size()>0);
        }
        else {
            return FALSE;
        }
    }

    /* These methods are related to End point */
    public static String getSupportURL() {
        return isBreadwinnerInstalled() ? 'https://support.breadwinnerhq.com' : 'https://support-staging.breadwinnerhq.com';
    }

    public static String getSupportEndpointBaseURL() {
        if(Schema.SobjectType.Breadwinner_Settings__c.isAccessible()){
            Breadwinner_Settings__c bwSetting = BreadwinnerUtil.getBWSetting();
            String BWSupportBaseURL = getSupportURL();
            return String.isNotBlank(bwSetting.Support_URL__c) ? bwSetting.Support_URL__c : BWSupportBaseURL;
        }
        return '';
    }

    /* These methods are related to Breadwinner Permission Set Module */
    @namespaceAccessible
    public static Boolean isBreadwinnerAdministrator(){
        return (BreadwinnerUtil.isAdministrator() || BreadwinnerUtil.isBWAdminPSAssigned());
    }

    public static Boolean isBWOperationsPSAssigned(){
        return [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name=:BreadwinnerUtil.OPERATION_PS_NAME].size()>0? true:false;
    }

    public static Boolean isBWAdminPSAssigned(){
        return [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name=:BreadwinnerUtil.ADMIN_PS_NAME].size()>0? true:false;
    }

    public static Boolean canPerformBreadwinnerOperations(){
        return (isBreadwinnerAdministrator() || isBWOperationsPSAssigned());
    }
    
    @namespaceAccessible
    public class AppConfig {
        @namespaceAccessible public Id recordId                          {get;set;}
        @namespaceAccessible public String name                          {get;set;}
        @namespaceAccessible public String accountName                   {get;set;}
        @namespaceAccessible public Boolean needToReconnect              {get;set;}
        @namespaceAccessible public String accountId                     {get;set;}
        @namespaceAccessible public Datetime lastHistoricalCustomerSyncDateTime {get;set;}
        @namespaceAccessible public Datetime lastHistoricalPaymentSyncDateTime  {get;set;}
        @namespaceAccessible public String lastCustomerId                {get;set;}
        @namespaceAccessible public String lastPaymentId                 {get;set;}
        @namespaceAccessible public String lastProductId                 {get;set;}
        @namespaceAccessible public String lastPriceId                   {get;set;}
        @namespaceAccessible public String accessToken                   {get;set;}
        @namespaceAccessible public String refreshToken                  {get;set;}
        @namespaceAccessible public Boolean livemode                     {get;set;}
        @namespaceAccessible public Boolean requireNextCustomerSyncRun   {get;set;}
        @namespaceAccessible public Boolean requireNextPaymentSyncRun    {get;set;}
        @namespaceAccessible public Boolean requireNextProductSyncRun    {get;set;}
        @namespaceAccessible public Boolean requireNextPriceSyncRun      {get;set;}
        @namespaceAccessible public Boolean isCustomerMatchComplete      {get;set;}
        @namespaceAccessible public String customerMatchType             {get;set;}
        @namespaceAccessible public Datetime hourlyCustomerSyncLastRun   {get;set;}
        @namespaceAccessible public Datetime hourlyPaymentSyncLastRun    {get;set;}
        @namespaceAccessible public Datetime hourlyProductSyncLastRun    {get;set;}
        @namespaceAccessible public Datetime hourlyPriceSyncLastRun      {get;set;}
        @namespaceAccessible public String defaultCurrency               {get;set;}
        @namespaceAccessible public Boolean isHistoricalCustomerSyncDone {get;set;}
        @namespaceAccessible public Boolean isHistoricalPaymentSyncDone  {get;set;}
        @namespaceAccessible public Boolean isHourlyCustomerSyncDone     {get;set;}
        @namespaceAccessible public Boolean isHourlyPaymentSyncDone      {get;set;}
        @namespaceAccessible public String currentRunningClassContext    {get;set;}
        @namespaceAccessible public String PaymentProcessorType          {get;set;}
        @namespaceAccessible public String customerSyncConfig            {get;set;}
        @namespaceAccessible public String customerMatchConfig           {get;set;}
        @namespaceAccessible public Datetime startDate                   {get;set;}
        @namespaceAccessible public Datetime endDate                     {get;set;}
        @namespaceAccessible public Boolean isEncryptionRotationRequired    {get;set;}
        @namespaceAccessible public Boolean isAlreadyDecrypted           {get;set;}
    }
    
    @namespaceAccessible
    public static AppConfig getProcessorConfigWrapper(BWP_Processor_Config__c appC) {
        appC = appC != null ? appC : new BWP_Processor_Config__c();
        AppConfig ac = new AppConfig();
        try {
            ac.recordId = appC.Id;
            ac.Name = appC.Name;
            ac.accountName = appC.Account_Name__c;
            ac.needToReconnect = appC.Need_To_Reconnect__c;
            ac.accountId = appC.Provider_ID__c;
            ac.lastHistoricalCustomerSyncDateTime = appC.Historical_Customer_Sync_Last_Run__c;
            ac.lastHistoricalPaymentSyncDateTime = appC.Historical_Payment_Sync_Last_Run__c;
            ac.lastCustomerId = appC.Last_Customer_Id__c;
            ac.accessToken = appC.Access_Token__c;
            ac.refreshToken = appC.Refresh_Token__c;
            ac.livemode = appC.Live_Mode__c;
            ac.requireNextCustomerSyncRun = false;
            ac.requireNextPaymentSyncRun = false;
            ac.isCustomerMatchComplete = appC.Is_Customer_Match_Completed__c;
            ac.customerMatchType = appC.Customer_Match_Type__c;
            ac.hourlyCustomerSyncLastRun = appC.Hourly_Customer_Sync_Last_Run__c;
            ac.hourlyPaymentSyncLastRun = appC.Hourly_Payment_Sync_Last_Run__c;
            ac.defaultCurrency = appC.Default_Currency__c;
            ac.isHistoricalCustomerSyncDone = false;
            ac.isHistoricalPaymentSyncDone = false;
            ac.isHourlyCustomerSyncDone = false;
            ac.isHourlyPaymentSyncDone = false;
            ac.currentRunningClassContext = null;
            ac.PaymentProcessorType = appC.Payment_Processor_Type__c;
            ac.customerSyncConfig = appC.Customer_Sync_Config__c;
            ac.customerMatchConfig = appC.Customer_Match_Config__c;
            ac.startDate = appC.Start_Date__c;
            ac.endDate = appC.End_Date__c;
            if(ac.PaymentProcessorType == ProcessorUtil.PAT_AUTHORIZE_NET && (ac.startDate < ac.endDate)){
                ac.requireNextPaymentSyncRun = true;
            }
        }
        catch(Exception ex) {
            System.debug('Error occurred while parsing custom setting:AppConfig. '+ex.getStackTraceString());
            APICallHandler.userInteractionLogPush(TRUE, 'App Config', 'ERROR' , 'Error occured while parsing custom setting:AppConfig. '+ex.getStackTraceString());
        }
        return ac;
    }

    // This method is used to get the object name for Batch class
    public static String findNextSyncName(String currentRunningObjectName){
        String nextRunningObjectName;
        if(String.isNotBlank(currentRunningObjectName)){
            if(currentRunningObjectName == BreadwinnerUtil.OBJ_SYNC_CUSTOMER){
                nextRunningObjectName = BreadwinnerUtil.OBJ_SYNC_PAYMENT;
            }
        }
        return nextRunningObjectName;
    }

    @namespaceAccessible
    public static Boolean isBreadwinnerActive() {
        Breadwinner_Settings__c bwSetting = Breadwinner_Settings__c.getall().values().size() > 0 ? Breadwinner_Settings__c.getall().values().get(0) : new Breadwinner_Settings__c(Name=CNTX_BW);
        return bwSetting.Active__c;
    }

    @namespaceAccessible
    public static Boolean isBatchRunning(String batchClassName) {
        Boolean returnValue = FALSE;
        batchClassName = String.escapeSingleQuotes(batchClassName);
        if(String.isNotBlank(batchClassName)) {
            Integer enqueuedJobs = [SELECT COUNT() FROM AsyncApexJob WHERE JobType='BatchApex' AND Status IN ('Processing','Preparing','Queued','Holding') AND ApexClass.Name =: batchClassName];
            returnValue = enqueuedJobs > 0 ? TRUE : FALSE;
        }
        return returnValue;
    }

    @namespaceAccessible
    public static Boolean isReadOnlyModeEnabled(){
        Breadwinner_Settings__c bwSetting = getBWSetting();
        return bwSetting != null ? bwSetting.Read_Only_Mode__c : false;
    }

    //This method will be called from Account match controller
    public static Set<String> getSimilarAccountNameSet(String name) {
        Set<String> nameTypeSet = new Set<String>();
        if(String.isNotBlank(name)) {
            String accountName = name.toLowerCase().replace('\\','%');
            nameTypeSet.add(accountName);
            Pattern p = Pattern.compile('\\([0-9]{8}\\)');
            Matcher m = p.matcher(accountName);
            String testString = m.find() ? m.group(0) : '';
            String idString = (accountName.SubStringAfterLast(' ') == testString) ? testString : '';
            if(accountName.contains(idString) && String.isNotBlank(idString) ) {
                nameTypeSet.add(accountName.removeEnd(' '+idString));
            }
            if(accountName.contains('&')) {
                nameTypeSet.add(accountName.replaceAll('&','and'));
            }
            if(accountName.contains('and')) {
                nameTypeSet.add(accountName.replaceAll('and','&'));
            }
            if(accountName.contains('ltd.')) {
                nameTypeSet.add(accountName.replaceAll('ltd.','ltd'));
                nameTypeSet.add(accountName.replaceAll('ltd.','limited'));
            }
            else if(accountName.contains('limited')) {
                nameTypeSet.add(accountName.replaceAll('limited','ltd'));
                nameTypeSet.add(accountName.replaceAll('limited','ltd.'));
            }
            else if(accountName.contains('ltd')) {
                nameTypeSet.add(accountName.replaceAll('ltd','ltd.'));
                nameTypeSet.add(accountName.replaceAll('ltd','limited'));
            }

            if(!(System.isBatch() || System.isScheduled() || System.isFuture())) {
                //replace comma, full stop
                if(accountName.contains('.')) {
                    nameTypeSet.add(accountName.replace('.','%'));
                }
                if(accountName.contains(',')) {
                    nameTypeSet.add(accountName.replace(',','%'));
                }
                Set<String> orgTypeSet = new Set<String>{'llc', 'pty', 'inc', 'gbh', 'ltd'};
                    if(accountName.contains('llc') || accountName.contains('pty') || accountName.contains('inc') ||
                       accountName.contains('gbh') || accountName.contains('ltd')) {
                           integer i = 5;
                           while(i>3) {
                               integer len = accountName.length();
                               for(String orgType : orgTypeSet) {
                                   integer foundAt = accountName.lastIndexOf(orgType);
                                   integer diff = len - foundAt;
                                   Boolean lastCondition =  diff < 4 || (diff < 7 && !(accountName.mid(foundAt+3, 1).isAlphanumeric()));
                                   if(accountName.contains(orgType) && (!accountName.startsWith(orgType)) && (!(accountName.mid(foundAt-1, 1).isAlphanumeric())) && lastCondition ) {
                                       String temp = accountName.left(accountName.lastIndexOf(orgType)-1).trim();
                                       nameTypeSet.add(temp);
                                       nameTypeSet.add(temp + '%'+orgType+'%');
                                   }
                               }
                               i--;
                               accountName = accountName.replace('.','').replace(',','');
                           }
                       }
                else{
                    accountName = accountName.replace('.','').replace(',','');
                    nameTypeSet.add(accountName);
                    for(String orgType : orgTypeSet) {
                        nameTypeSet.add(accountName + '%'+orgType+'%');
                    }
                }
            }
        }
        return nameTypeSet;
    }
    // This method will return all the currencies supported by Stripe
    public static List<SelectOption> getStripeCurrencies(){
        List<SelectOption> listOfCurrencies = new List<SelectOption>();
        listOfCurrencies.add(new SelectOption('usd', 'USD - US dollar'));
        listOfCurrencies.add(new SelectOption('aed', 'AED - United Arab Emirates Dirham'));
        listOfCurrencies.add(new SelectOption('afn', 'AFN - Afghan Afghani'));
        listOfCurrencies.add(new SelectOption('all', 'ALL - Albanian Lek'));
        listOfCurrencies.add(new SelectOption('amd', 'AMD - Armenian Dram'));
        listOfCurrencies.add(new SelectOption('ang', 'ANG - Netherlands Antillean Guilder'));
        listOfCurrencies.add(new SelectOption('aoa', 'AOA - Angolan Kwanza'));
        listOfCurrencies.add(new SelectOption('ars', 'ARS - Argentine Peso'));
        listOfCurrencies.add(new SelectOption('aud', 'AUD - Australian Dollar'));
        listOfCurrencies.add(new SelectOption('awg', 'AWG - Aruban Florin'));
        listOfCurrencies.add(new SelectOption('azn', 'AZN - Azerbaijani Manat'));
        listOfCurrencies.add(new SelectOption('bam', 'BAM - Bosnia-Herzegovina Convertible Mark'));
        listOfCurrencies.add(new SelectOption('bbd', 'BBD - Barbadian Dollar'));
        listOfCurrencies.add(new SelectOption('bdt', 'BDT - Bangladeshi Taka'));
        listOfCurrencies.add(new SelectOption('bgn', 'BGN - Bulgarian Lev'));
        listOfCurrencies.add(new SelectOption('bif', 'BIF - Burundian Franc'));
        listOfCurrencies.add(new SelectOption('bmd', 'BMD - Bermudan Dollar'));
        listOfCurrencies.add(new SelectOption('bnd', 'BND - Brunei Dollar'));
        listOfCurrencies.add(new SelectOption('bob', 'BOB - Bolivian Boliviano'));
        listOfCurrencies.add(new SelectOption('brl', 'BRL - Brazilian Real'));
        listOfCurrencies.add(new SelectOption('bsd', 'BSD - Bahamian Dollar'));
        listOfCurrencies.add(new SelectOption('bwo', 'BWP - Botswanan Pula'));
        listOfCurrencies.add(new SelectOption('bzd', 'BZD - Belize Dollar'));
        listOfCurrencies.add(new SelectOption('cad', 'CAD - Canadian Dollar'));
        listOfCurrencies.add(new SelectOption('cdf', 'CDF - Congolese Franc'));
        listOfCurrencies.add(new SelectOption('chf', 'CHF - Swiss Franc'));
        listOfCurrencies.add(new SelectOption('clp', 'CLP - Chilean Peso'));
        listOfCurrencies.add(new SelectOption('cny', 'CNY - Chinese Yuan'));
        listOfCurrencies.add(new SelectOption('cop', 'COP - Colombian Peso'));
        listOfCurrencies.add(new SelectOption('crc', 'CRC - Costa Rican Colón'));
        listOfCurrencies.add(new SelectOption('cve', 'CVE - Cape Verdean Escudo'));
        listOfCurrencies.add(new SelectOption('czk', 'CZK - Czech Koruna'));
        listOfCurrencies.add(new SelectOption('djf', 'DJF - Djiboutian Franc'));
        listOfCurrencies.add(new SelectOption('dkk', 'DKK - Danish Krone'));
        listOfCurrencies.add(new SelectOption('dop', 'DOP - Dominican Peso'));
        listOfCurrencies.add(new SelectOption('dzd', 'DZD - Algerian Dinar'));
        listOfCurrencies.add(new SelectOption('egp', 'EGP - Egyptian Pound'));
        listOfCurrencies.add(new SelectOption('etb', 'ETB - Ethiopian Birr'));
        listOfCurrencies.add(new SelectOption('eur', 'EUR - Euro'));
        listOfCurrencies.add(new SelectOption('fjd', 'FJD - Fijian Dollar'));
        listOfCurrencies.add(new SelectOption('fkp', 'FKP - Falkland Islands Pound'));
        listOfCurrencies.add(new SelectOption('gbp', 'GBP - British Pound'));
        listOfCurrencies.add(new SelectOption('gel', 'GEL - Georgian Lari'));
        listOfCurrencies.add(new SelectOption('gip', 'GIP - Gibraltar Pound'));
        listOfCurrencies.add(new SelectOption('gmd', 'GMD - Gambian Dalasi'));
        listOfCurrencies.add(new SelectOption('gnf', 'GNF - Guinean Franc'));
        listOfCurrencies.add(new SelectOption('gtq', 'GTQ - Guatemalan Quetzal'));
        listOfCurrencies.add(new SelectOption('gyd', 'GYD - Guyanaese Dollar'));
        listOfCurrencies.add(new SelectOption('hkd', 'HKD - Hong Kong Dollar'));
        listOfCurrencies.add(new SelectOption('hnl', 'HNL - Honduran Lempira'));
        listOfCurrencies.add(new SelectOption('hrk', 'HRK - Croatian Kuna'));
        listOfCurrencies.add(new SelectOption('htg', 'HTG - Haitian Gourde'));
        listOfCurrencies.add(new SelectOption('huf', 'HUF - Hungarian Forint'));
        listOfCurrencies.add(new SelectOption('idr', 'IDR - Indonesian Rupiah'));
        listOfCurrencies.add(new SelectOption('ils', 'ILS - Israeli New Shekel'));
        listOfCurrencies.add(new SelectOption('inr', 'INR - Indian Rupee'));
        listOfCurrencies.add(new SelectOption('isk', 'ISK - Icelandic Króna'));
        listOfCurrencies.add(new SelectOption('jmd', 'JMD - Jamaican Dollar'));
        listOfCurrencies.add(new SelectOption('jpy', 'JPY - Japanese Yen'));
        listOfCurrencies.add(new SelectOption('kes', 'KES - Kenyan Shilling'));
        listOfCurrencies.add(new SelectOption('kgs', 'KGS - Kyrgystani Som'));
        listOfCurrencies.add(new SelectOption('khr', 'KHR - Cambodian Riel'));
        listOfCurrencies.add(new SelectOption('kmf', 'KMF - Comorian Franc'));
        listOfCurrencies.add(new SelectOption('krw', 'KRW - South Korean Won'));
        listOfCurrencies.add(new SelectOption('kyd', 'KYD - Cayman Islands Dollar'));
        listOfCurrencies.add(new SelectOption('kzt', 'KZT - Kazakhstani Tenge'));
        listOfCurrencies.add(new SelectOption('lak', 'LAK - Laotian Kip'));
        listOfCurrencies.add(new SelectOption('lbp', 'LBP - Lebanese Pound'));
        listOfCurrencies.add(new SelectOption('lkr', 'LKR - Sri Lankan Rupee'));
        listOfCurrencies.add(new SelectOption('lrd', 'LRD - Liberian Dollar'));
        listOfCurrencies.add(new SelectOption('lsl', 'LSL - Lesotho Loti'));
        listOfCurrencies.add(new SelectOption('mad', 'MAD - Moroccan Dirham'));
        listOfCurrencies.add(new SelectOption('mdl', 'MDL - Moldovan Leu'));
        listOfCurrencies.add(new SelectOption('mga', 'MGA - Malagasy Ariary'));
        listOfCurrencies.add(new SelectOption('mkd', 'MKD - Macedonian Denar'));
        listOfCurrencies.add(new SelectOption('mmk', 'MMK - Myanmar Kyat'));
        listOfCurrencies.add(new SelectOption('mnt', 'MNT - Mongolian Tugrik'));
        listOfCurrencies.add(new SelectOption('mop', 'MOP - Macanese Pataca'));
        listOfCurrencies.add(new SelectOption('mro', 'MRO - Mauritanian Ouguiya'));
        listOfCurrencies.add(new SelectOption('mur', 'MUR - Mauritian Rupee'));
        listOfCurrencies.add(new SelectOption('mvr', 'MVR - Maldivian Rufiyaa'));
        listOfCurrencies.add(new SelectOption('mwk', 'MWK - Malawian Kwacha'));
        listOfCurrencies.add(new SelectOption('mxn', 'MXN - Mexican Peso'));
        listOfCurrencies.add(new SelectOption('myr', 'MYR - Malaysian Ringgit'));
        listOfCurrencies.add(new SelectOption('mzn', 'MZN - Mozambican Metical'));
        listOfCurrencies.add(new SelectOption('nad', 'NAD - Namibian Dollar'));
        listOfCurrencies.add(new SelectOption('ngn', 'NGN - Nigerian Naira'));
        listOfCurrencies.add(new SelectOption('nio', 'NIO - Nicaraguan Córdoba'));
        listOfCurrencies.add(new SelectOption('nok', 'NOK - Norwegian Krone'));
        listOfCurrencies.add(new SelectOption('npr', 'NPR - Nepalese Rupee'));
        listOfCurrencies.add(new SelectOption('nzd', 'NZD - New Zealand Dollar'));
        listOfCurrencies.add(new SelectOption('pab', 'PAB - Panamanian Balboa'));
        listOfCurrencies.add(new SelectOption('pen', 'PEN - Peruvian Sol'));
        listOfCurrencies.add(new SelectOption('pgk', 'PGK - Papua New Guinean Kina'));
        listOfCurrencies.add(new SelectOption('php', 'PHP - Philippine Peso'));
        listOfCurrencies.add(new SelectOption('pkr', 'PKR - Pakistani Rupee'));
        listOfCurrencies.add(new SelectOption('pln', 'PLN - Polish Zloty'));
        listOfCurrencies.add(new SelectOption('pyg', 'PYG - Paraguayan Guarani'));
        listOfCurrencies.add(new SelectOption('qar', 'QAR - Qatari Rial'));
        listOfCurrencies.add(new SelectOption('ron', 'RON - Romanian Leu'));
        listOfCurrencies.add(new SelectOption('rsd', 'RSD - Serbian Dinar'));
        listOfCurrencies.add(new SelectOption('rub', 'RUB - Russian Rouble'));
        listOfCurrencies.add(new SelectOption('rwf', 'RWF - Rwandan Franc'));
        listOfCurrencies.add(new SelectOption('sar', 'SAR - Saudi Riyal'));
        listOfCurrencies.add(new SelectOption('sbd', 'SBD - Solomon Islands Dollar'));
        listOfCurrencies.add(new SelectOption('scr', 'SCR - Seychellois Rupee'));
        listOfCurrencies.add(new SelectOption('sek', 'SEK - Swedish Krona'));
        listOfCurrencies.add(new SelectOption('sgd', 'SGD - Singapore Dollar'));
        listOfCurrencies.add(new SelectOption('shp', 'SHP - St. Helena Pound'));
        listOfCurrencies.add(new SelectOption('sll', 'SLL - Sierra Leonean Leone'));
        listOfCurrencies.add(new SelectOption('sos', 'SOS - Somali Shilling'));
        listOfCurrencies.add(new SelectOption('srd', 'SRD - Surinamese Dollar'));
        listOfCurrencies.add(new SelectOption('std', 'STD - São Tomé & Príncipe Dobra'));
        listOfCurrencies.add(new SelectOption('szl', 'SZL - Swazi Lilangeni'));
        listOfCurrencies.add(new SelectOption('thb', 'THB - Thai Baht'));
        listOfCurrencies.add(new SelectOption('tjs', 'TJS - Tajikistani Somoni'));
        listOfCurrencies.add(new SelectOption('top', 'TOP - Tongan Paʻanga'));
        listOfCurrencies.add(new SelectOption('try', 'TRY - Turkish Lira'));
        listOfCurrencies.add(new SelectOption('ttd', 'TTD - Trinidad & Tobago Dollar'));
        listOfCurrencies.add(new SelectOption('twd', 'TWD - New Taiwan Dollar'));
        listOfCurrencies.add(new SelectOption('tzs', 'TZS - Tanzanian Shilling'));
        listOfCurrencies.add(new SelectOption('uah', 'UAH - Ukrainian Hryvnia'));
        listOfCurrencies.add(new SelectOption('ugx', 'UGX - Ugandan Shilling'));
        listOfCurrencies.add(new SelectOption('uyu', 'UYU - Uruguayan Peso'));
        listOfCurrencies.add(new SelectOption('uzs', 'UZS - Uzbekistani Som'));
        listOfCurrencies.add(new SelectOption('vnd', 'VND - Vietnamese Dong'));
        listOfCurrencies.add(new SelectOption('vuv', 'VUV - Vanuatu Vatu'));
        listOfCurrencies.add(new SelectOption('wst', 'WST - Samoan Tala'));
        listOfCurrencies.add(new SelectOption('xaf', 'XAF - Central African CFA Franc'));
        listOfCurrencies.add(new SelectOption('xcd', 'XCD - East Caribbean Dollar'));
        listOfCurrencies.add(new SelectOption('xof', 'XOF - West African CFA Franc'));
        listOfCurrencies.add(new SelectOption('xpf', 'XPF - CFP Franc'));
        listOfCurrencies.add(new SelectOption('yer', 'YER - Yemeni Rial'));
        listOfCurrencies.add(new SelectOption('zar', 'ZAR - South African Rand'));
        listOfCurrencies.add(new SelectOption('zmw', 'ZMW - Zambian Kwacha'));

        return listOfCurrencies;
    }

    // This method will return zero decimal Stripe currencies
    public static List<String> getZeroDecimalStripeCurrencies() {
        List<String> zeroDecimalStripeCurrencies = new List<String>();
        zeroDecimalStripeCurrencies.add('bif');
        zeroDecimalStripeCurrencies.add('clp');
        zeroDecimalStripeCurrencies.add('djf');
        zeroDecimalStripeCurrencies.add('gnf');
        zeroDecimalStripeCurrencies.add('jpy');
        zeroDecimalStripeCurrencies.add('kmf');
        zeroDecimalStripeCurrencies.add('krw');
        zeroDecimalStripeCurrencies.add('mga');
        zeroDecimalStripeCurrencies.add('pyg');
        zeroDecimalStripeCurrencies.add('rwf');
        //zeroDecimalStripeCurrencies.add('ugx');
        zeroDecimalStripeCurrencies.add('vnd');
        zeroDecimalStripeCurrencies.add('vuv');
        zeroDecimalStripeCurrencies.add('xaf');
        zeroDecimalStripeCurrencies.add('xof');
        zeroDecimalStripeCurrencies.add('xpf');
        return zeroDecimalStripeCurrencies;
    }

    public static String getBaseEndpointURL() {
        Breadwinner_Settings__c bwSetting = Breadwinner_Settings__c.getAll().values().size() > 0 ? Breadwinner_Settings__c.getAll().values().get(0) : new Breadwinner_Settings__c(Name=CNTX_BW);
        String BW_API_BaseURL = getBW_API_BaseURL();
        return String.isBlank(bwSetting.Support_URL__c)? BW_API_BaseURL : bwSetting.Support_URL__c;
    }
    public static String getBW_API_BaseURL() {
        return 'https://support-staging.breadwinnerhq.com';
    }

    @namespaceAccessible
    public static String getCreatedViaValue(String currentRunningContext){
        // This will be used to know from where the record has been created, possible values are: Breadwinner, Breadwinner API, Regular Sync, Historical Sync
        List<String> bwPages  = new List<String>{'CreateCustomer','CreatePaymentMethod','CreateTransaction','CustomerOperations','CustomerRecordInfo','PaymentMethodRecordInfo','TransactionRecordInfo'};
        if (currentRunningContext == CNTX_BWAPI){
            String callingPage = ApexPages.currentPage()?.getUrl();
            if(String.isNotBlank(callingPage)){
                for(String pg : bwPages){
                    if(callingPage.containsIgnoreCase(pg)){
                        return CNTX_BW;
                    }
                }
                return CNTX_BWAPI;
            }
        }
        return (currentRunningContext == BreadwinnerUtil.CNTX_HIST_SYNC ? 'Historical Sync' : (currentRunningContext == BreadwinnerUtil.CNTX_HOUR_SYNC ? 'Regular Sync' : (currentRunningContext == BreadwinnerUtil.CNTX_BWAPI ? 'Breadwinner API' : BreadwinnerUtil.CNTX_BW)));
    }
    
    @namespaceAccessible
    public static void upsertAppConfig(BWP_Processor_Config__c config){
        BreadwinnerUtil.isBreadwinnerTransaction = true;
        SecurityUtil.dmlUpsert(config);
        APICallHandler.userInteractionLogPush(false, 'App Config', 'Connected' , 'Connected to' + config.Payment_Processor_Type__c + 'Processor, Name:' + config.account_Name__c);
    }

    @namespaceAccessible
    public static List<CronTrigger> getCronTrigger(String name){
        String synName = '%'+name+'%';
        return [SELECT Id, OwnerId, NextFireTime, CronExpression, CronJobDetail.Name FROM CronTrigger Where CronJobDetail.Name LIKE : synName];
    }
    
    public class ProcessorException extends Exception{}
    public class UnsupportedProcessorException extends Exception{}

    public static Boolean isBreadwinnerBillingInstalled(){
        Boolean isBBInstalled = FALSE;
        try{
            HttpRequest req = new HttpRequest();
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
            req.setHeader('Content-Type', 'application/json');
            String SFdomainUrl=URL.getSalesforceBaseUrl().toExternalForm();
            String query='Select+SubscriberPackage.NamespacePrefix,SubscriberPackage.Name+FROM+InstalledSubscriberPackage';
            String endpoint = SFdomainUrl+'/services/data/v53.0/tooling/query/?q='+query;
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setTimeout(120000);
            Http h = new Http();
            HttpResponse res = new HttpResponse();
            if (!Test.isRunningTest()) {
                res = h.send(req);
                system.debug('Response ::: '+res.getBody());
            }
            Records rc = new Records();
            if(res.getStatusCode() == 200 && res.getBody() != NULL){
                rc = (Records)JSON.deserialize(res.getBody(), Records.class);
                System.debug('rc ::: '+rc);                
                for(Record rec: rc.records){                
                    String packageName = rec.SubscriberPackage.Name;
                    if(packageName != NULL && packageName == BB_EXT_PACKAGE_NAME){
                        isBBInstalled = TRUE;
                    }
                }
                System.debug('isBBInstalled ::: '+isBBInstalled);
            }
        }catch(Exception ex) {
            System.debug('Error occured while checking Stripe Billing package: '+ex.getStackTraceString());
            APICallHandler.userInteractionLogPush(TRUE, 'Packages', 'ERROR' , 'Error occured while checking Breadwinner Billing package: '+ex.getStackTraceString());
        }
        return isBBInstalled;
    }
    private class Records{
        private List<Record> records;
    }
    private class Record{
        private SubscriberPackage subscriberPackage;
    }
    private class SubscriberPackage{ 
        private String Name;
        private String NamespacePrefix;
    }
}