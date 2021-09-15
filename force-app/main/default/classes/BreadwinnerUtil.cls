/*
Description - This class contains reusable methods.
*/
@namespaceAccessible
public with sharing class BreadwinnerUtil{

    // It is used to store the Package Version number. We will update this for every release until we find a way to automate values. Existing way is not supporting in the 2GP.
    public static final String PKG_VER_NO = '1.5';

    public static final String OBJ_SYNC_CUSTOMER = 'Customer';
    public static final String OBJ_SYNC_PAYMENT = 'Payment';

    // Current Running Context Variables
    public static final String CNTX_HIST_SYNC = 'HistoricalSyncBatch';
	public static final String CNTX_HOUR_SYNC = 'HourlySyncBatch';
	public static final String CNTX_BWAPI = 'BWAPI';
	public static final String CNTX_BW = 'Breadwinner';

    public static final String SYNC_CNTX_HOURLY = 'BreadwinnerPaymentsHourlySync';
    public static final String SYNC_CNTX_WEEKLY = 'BreadwinnerPaymentsWeeklySync';
    public static final String SYNC_CNTX_MONITOR = 'MonitorBreadwinnerPayments';
    public static final String SYNC_CNTX_ALL = 'BreadwinnerPayments';

    public static final String SB_PACKAGE_NAME = 'Stripe Billing';

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
                Schema.DescribeSObjectResult os = Schema.SObjectType.BWP_Payment__c;
                String[] split = os.getName().split('__');
                if (split.size() > 2) {
                    namespace = split[0];
                }
            }
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
        return processorConfig.size()>0 ? processorConfig[0] : null;
    }
    
    public static String namespaceApi = String.isNotBlank(namespace) ? namespace+'__' : '';
    public static Set<String> zeroDecimalCurrencies = new Set<String>{'BIF', 'CLP', 'DJF', 'GNF', 'JPY', 'KMF', 'KRW', 'MGA', 'PYG', 'RWF', 'VND', 'VUV', 'XAF', 'XOF', 'XPF'};
    public static Id accountId;
    
    //Determining lightning or classic
    public static Boolean isLightning() {
        return (UserInfo.getUiThemeDisplayed() == 'Theme3' && Apexpages.currentPage().getParameters().get('beLightning') == null ? false : true);
    }

    public static Boolean isAdministrator(){
        if(Schema.sObjectType.Profile.isAccessible()) {
            return [SELECT Id, PermissionsModifyAllData FROM Profile WHERE Id=:UserInfo.getProfileId() LIMIT 1].PermissionsModifyAllData;
        }
        return FALSE;
    }

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
    
    public static Breadwinner_Settings__c getBWSetting(){
        return Breadwinner_Settings__c.getAll().values().size() > 0 ? Breadwinner_Settings__c.getAll().values().get(0) : new Breadwinner_Settings__c(Name='Breadwinner', Active__c = true, Read_Only_Mode__c = true, Plan_Name__c='Basic', Plan_Code__c='20', Status__c='trial', Date_of_Expiration__c = System.now()+365);
    }

    /* These methods are related to End point */
    public static String getSupportURL() {
        return 'https://support.breadwinnerhq.com';
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
    public static Boolean isBreadwinnerAdministrator(){
        return (BreadwinnerUtil.isAdministrator() || BreadwinnerUtil.isBWAdminPSAssigned());
    }

    public static Boolean isBWOperationsPSAssigned(){
        return [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name='Breadwinner_Payments_Operations'].size()>0? true:false;
    }

    public static Boolean isBWAdminPSAssigned(){
        return [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name='Breadwinner_Payments_Admin_User'].size()>0? true:false;
    }

    public static Boolean canPerformBreadwinnerOperations(){
        return (isBreadwinnerAdministrator() || isBWOperationsPSAssigned());
    }
    
    public class AppConfig {
        public Id recordId                          {get;set;}
        public String name                          {get;set;}
        public String accountName                   {get;set;}
        public Boolean needToReconnect              {get;set;}
        public String accountId                     {get;set;}
        public Datetime lastHistoricalCustomerSyncDateTime {get;set;}
        public Datetime lastHistoricalPaymentSyncDateTime  {get;set;}
        public String lastPaymentId                 {get;set;}
        public String lastCustomerId                {get;set;}
        public String accessToken                   {get;set;}
        public String refreshToken                  {get;set;}
        public Boolean livemode                     {get;set;}
        public Boolean requireNextCustomerSyncRun   {get;set;}
        public Boolean requireNextPaymentSyncRun    {get;set;}
        public Boolean isCustomerMatchComplete      {get;set;}
        public String customerMatchType             {get;set;}
        public Datetime hourlyCustomerSyncLastRun   {get;set;}
        public Datetime hourlyPaymentSyncLastRun    {get;set;}
        public String defaultCurrency               {get;set;}
        public Boolean isHistoricalCustomerSyncDone {get;set;}
        public Boolean isHistoricalPaymentSyncDone  {get;set;}
        public Boolean isHourlyCustomerSyncDone     {get;set;}
        public Boolean isHourlyPaymentSyncDone      {get;set;}
        public String currentRunningClassContext    {get;set;}
        public String PaymentProcessorType          {get;set;}
        public String customerSyncConfig            {get;set;}
        public String customerMatchConfig           {get;set;}
        public Datetime startDate                   {get;set;}
        public Datetime endDate                     {get;set;}
        public Boolean isEncryptionRotationRequired    {get;set;}
        public Boolean isAlreadyDecrypted           {get;set;}
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
//TODO: Add back in once new payment_config is created
//            ac.startDate = appC.Start_Date__c;
//            ac.endDate = appC.End_Date__c;
            if(ac.PaymentProcessorType == ProcessorUtil.PAT_PAYPAL && (ac.endDate < ac.startDate)){
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
            if(currentRunningObjectName == 'Customer'){
                nextRunningObjectName = 'Payment';
            }
        }
        return nextRunningObjectName;
    }

    @namespaceAccessible
    public static Boolean isBreadwinnerActive() {
        Breadwinner_Settings__c bwSetting = Breadwinner_Settings__c.getall().values().size() > 0 ? Breadwinner_Settings__c.getall().values().get(0) : new Breadwinner_Settings__c(Name='Breadwinner');
        return bwSetting.Active__c;
    }

    public static Boolean isBatchRunning(String batchClassName) {
        Boolean returnValue = FALSE;
        batchClassName = String.escapeSingleQuotes(batchClassName);
        if(String.isNotBlank(batchClassName)) {
            Integer enqueuedJobs = [SELECT COUNT() FROM AsyncApexJob WHERE JobType='BatchApex' AND Status IN ('Processing','Preparing','Queued','Holding') AND ApexClass.Name =: batchClassName];
            returnValue = enqueuedJobs > 0 ? TRUE : FALSE;
        }
        return returnValue;
    }

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
        Breadwinner_Settings__c bwSetting = Breadwinner_Settings__c.getAll().values().size() > 0 ? Breadwinner_Settings__c.getAll().values().get(0) : new Breadwinner_Settings__c(Name='Breadwinner');
        String BW_API_BaseURL = getBW_API_BaseURL();
        return String.isBlank(bwSetting.Support_URL__c)? BW_API_BaseURL : bwSetting.Support_URL__c;
    }
    public static String getBW_API_BaseURL() {
        return 'https://support-staging.breadwinnerhq.com';
    }

    public static String getCreatedViaValue(String currentRunningContext){
        return (currentRunningContext == BreadwinnerUtil.CNTX_HIST_SYNC ? 'Historical Sync' : (currentRunningContext == BreadwinnerUtil.CNTX_HOUR_SYNC ? 'Regular Sync' : (currentRunningContext == BreadwinnerUtil.CNTX_BWAPI ? 'Breadwinner API' : BreadwinnerUtil.CNTX_BW)));
    }
    
    @namespaceAccessible
    public static void upsertAppConfig(BWP_Processor_Config__c config){
        BreadwinnerUtil.isBreadwinnerTransaction = true;
        SecurityUtil.dmlUpsert(config);
        APICallHandler.userInteractionLogPush(false, 'App Config', 'Connected' , 'Connected' + config.Payment_Processor_Type__c + 'Info:' + config.account_Name__c);
    }

    public static List<CronTrigger> getCronTrigger(String name){
        String synName = '%'+name+'%';
        return [SELECT Id, OwnerId, NextFireTime, CronExpression, CronJobDetail.Name FROM CronTrigger Where CronJobDetail.Name LIKE : synName];
    }
    
    public class ProcessorException extends Exception{}
    public class UnsupportedProcessorException extends Exception{}

    public static Boolean isStripeBillingInstalled(){
        Boolean isSBInstalled = FALSE;
        try{
            HttpRequest req = new HttpRequest();
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
            req.setHeader('Content-Type', 'application/json');
            String SFdomainUrl=URL.getSalesforceBaseUrl().toExternalForm();
            String query='Select+SubscriberPackage.NamespacePrefix,SubscriberPackage.Name+FROM+InstalledSubscriberPackage';
            String endpoint = SFdomainUrl+'/services/data/v52.0/tooling/query/?q='+query;
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
                    if(packageName != NULL && packageName == SB_PACKAGE_NAME){
                        isSBInstalled = TRUE;
                    }
                }
                System.debug('isSBInstalled ::: '+isSBInstalled);
            }
        }catch(Exception ex) {
            System.debug('Error occured while checking Stripe Billing package: '+ex.getStackTraceString());
            APICallHandler.userInteractionLogPush(TRUE, 'Packages', 'ERROR' , 'Error occured while checking Stripe Billing package: '+ex.getStackTraceString());
        }
        return isSBInstalled;
    }
    public class Records{
        public List<Record> records;
    }
    public class Record{
        public SubscriberPackage subscriberPackage;
    }
    public class SubscriberPackage{ 
        public String Name;
        public String NamespacePrefix;
    }
}