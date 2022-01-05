public with sharing class BreadwinnerController {

    private Selector_BWP_Customer selectorCustomer = new Selector_BWP_Customer();
    private Selector_BWP_Payment_Method selectorPaymentMethod = new Selector_BWP_Payment_Method();
    Selector_BWP_Transaction selectorTransaction = new Selector_BWP_Transaction();

    public Boolean isProcessorConnected          {get;set;}
    public Boolean needToReconnect               {get;set;}
    public String connectedAppName               {get;set;}
    public String contactSupportPrameters        {get;set;} 
    public String connectionMode                 {get;set;}
    public Boolean isAdministrator               {get;set;}
    public String disconnectAppId                {get;set;}
    public BreadwinnerUtil.AppConfig appC        {get;set;}
    public Integer unMatchedRecordCount          {get;set;}
    public Boolean isCustomerMatchStarted       {get;set;}
    public Boolean isAccountMatchStarted        {get;set;}
    public Boolean isContactMatchStarted        {get;set;}
    public Boolean displayCustomerMatchOptions   {get;set;}
    public String customerMatchType              {get;set;}
    public String pkgVersion                     {get;set;}
    public BWP_Processor_Config__c config        {get;set;}
    public Organization orgInfo                  {get;set;}
    public Boolean isBatchStarted                {get;set;}
    public Integer customersCount                {get;set;}
    public Integer paymentMethodsCount           {get;set;}
    public Integer bwpTransCount                 {get;set;}
    public Integer productsCount                 {get;set;}
    public Integer pricesCount                   {get;set;}
    public String objectName                     {get;set;}
    public Breadwinner_Settings__c bwSettings    {get;set;}
    public BreadwinnerSetting bwSetting          {get;set;}
    public Integer noOfDaysLeft                  {get;set;}
    public String BW_API_BaseURL                 {get;set;}
    public String BW_SupportPortalURL            {get;set;}
    public Boolean unableToAddRemoteSiteSetting  {get;set;}
    public Boolean showGeneralSection            {get; set;}
    public Boolean isUnauthorizedEndpoint        {get; private set;}
    public List<BWP_Processor_Config__c> processorConfigList {get; private set;}
    String namespacePrefix = '';
    public Boolean isBreadwinnerInstalled = false;
    
    //Auth
    public Boolean isAppConfigUpdated            {get;set;}
    public String sfMode                         {get;set;} 
    public String breadwinnerPageName            {get;set;}
    public Boolean showBWSetupContent            {get;set;} 
    public Boolean isEditSettingSection			 {get;set;}
    public Boolean isMultiProcessorEnabled		 {get;set;}
    public List<BreadwinnerUtil.AppConfig> appConfigList	{get;set;}
    public Map<String,Boolean> unmatchedCustomersStatusMap  {get; private set;}
    public Boolean areThereUnmatchedCustomers 				{get; private set;}
    public Boolean isAccountMatchDoneForAllProcessors		{get; private set;}
    public String selectedProcessorType                     {get; set;}
    // Braintree Auth fields
    public String braintreePublicKey                        {get; set;}
    public String braintreePrivateKey                       {get; set;} 
    public String braintreeTokenizationKey                   {get; set;} 
    public Boolean isBraintreeProduction                    {get; set;}
    public static String braintreeAuthErrors                {get; set;}
    public Boolean isBraintreeConnected                     {get; set;}
    public String disconnectPaymentProcessorType            {get; set;}
    public String syncName                                  {get; set;}
    public String syncProcessor      						{get; set;}
    public String processorAccountId                        {get; set;}
    // Breadwinner Permission variables
    public Boolean canPerformBreadwinnerOperations          {get; private set;}
    public Boolean isBreadwinnerAdministrator               {get; private set;}
    public Boolean canAssignPermissionSets                  {get; private set;}
    public String selectedPermissionSet                     {get; set;}
    public String selectedPermissionSetId                   {get; set;}
    public List<User> assignedPermissionSetUsers            {get; set;}
    public List<User> usersWithModifyAllDataPermission      {get; set;}
    public List<wrapPermissionUsers> wrapPermissionUsersList{get; set;}
    public String sortDirection                             {get; set;}
    public String modifyAllDataSortDirection                {get; set;}
    public String sortExpression                            {get; set;}
    public String modifyAllDataSortExpression               {get; set;}
    public String support_URL                               {get; set;}
    public Boolean showEndpointURLSetting                   {get; set;}
    public String planName                                  {get; set;}
    public Boolean excludeNoValidPaymentsCustomersInAccMatch{get; set;}
    public String customerSyncConfigValue                   {get; set;}
    //Square Auth fields
    public String connectingAppName                         {get; set;}

    public Boolean isScheduledJobsRunByActiveUser           {get; set;}
    public Boolean isScheduledJobsRunByAdmin                {get; set;}
    public Boolean isBreadwinnerBillingInstalled            {get; set;}

    public Boolean getCanUpdatePageLayouts(){
        return (isAdministrator && isCustomerMatchStarted && bwSetting.Active && !unableToAddRemoteSiteSetting && !isLayoutUpdated && isProcessorConnected);
    }
    public Boolean isLayoutUpdated                {
        get{
            return bwSetting==null? false: bwSetting.pageLayoutsUpdated;
        }
         set;}  
    
    public List<SelectOption> getAvailableEndpointURLs() {
        return new List<SelectOption>{
            new SelectOption(support_URL, 'Breadwinner Support'),
            new SelectOption('https://support-staging.breadwinnerhq.com', 'Breadwinner Staging'),
            new SelectOption('https://support-testing.breadwinnerhq.com', 'Breadwinner Testing')
        };
    }
    public Map<String, BWP_Processor_Config__c> payConfigMap;
    //method to call onload of the Breadwinner page.
    public void initializeApp(){
        try {
            // Get the latest Breadwinner Settings from POW
            if(isAdministrator){
                if(BreadwinnerUtil.isSandboxRefresh()){
                    BreadwinnerUtil.deleteConfigsWhenSandboxRefresh();
                    refreshAppConfig();
                    APICallHandler.asyncGetSFOrgInfo();
                }
                else APICallHandler.AccountResponse ar = APICallHandler.SyncBreadwinnerSetting();
            }
            bwSettings = BreadwinnerUtil.getBWSetting();
            bwsetting = getBreadwinnerSettingWrapper(bwsettings);
            noOfDaysLeft = bwsetting.Date_of_Expiration != null ? calculateNoOfDaysLeft(String.valueOf(bwSetting.Date_of_Expiration)): 0;

            checkAndScheduleBreadwinnerMonitor();
            HistoricalSyncBatch.scheduleWeeklyHistoricalSync();
        }
        catch(Exception e){
            System.debug('initializeApp ::: Exception: '+e+', Stack Trace: '+e.getStackTraceString());
        }
        
    }
    
    public BreadwinnerController() {
        processorConfigList = new List<BWP_Processor_Config__c>();
        payConfigMap = new Map<String, BWP_Processor_Config__c>();
        customerSyncConfigValue = '';
        excludeNoValidPaymentsCustomersInAccMatch = FALSE;
        support_URL = BreadwinnerUtil.getSupportURL();
        showBWSetupContent = false;
        showEndpointURLSetting = false;
        isBatchStarted = false;
        pkgVersion = BreadwinnerUtil.getBW_PackageVersion();
        orgInfo = BreadwinnerUtil.orgInfo();
        customersCount = 0;
        paymentMethodsCount = 0;
        bwpTransCount = 0;
        productsCount = 0;
        pricesCount = 0;
        unMatchedRecordCount = 0;
        unableToAddRemoteSiteSetting = unableToAddRemoteSiteSetting != null && Boolean.valueOf(unableToAddRemoteSiteSetting) ? true : false;
        isUnauthorizedEndpoint = false;
        selectedProcessorType = ProcessorUtil.PAT_STRIPE;
        isBraintreeProduction = false;
        disconnectPaymentProcessorType = '';
        namespacePrefix = BreadwinnerUtil.namespaceApi;
        isBraintreeConnected = false;
        isEditSettingSection = false;
        syncName = '';
        processorAccountId = '';
        isCustomerMatchStarted = false;
        isAccountMatchStarted = false;
        isContactMatchStarted = false;
        displayCustomerMatchOptions = true;
        canPerformBreadwinnerOperations = BreadwinnerUtil.canPerformBreadwinnerOperations();
        isBreadwinnerAdministrator = BreadwinnerUtil.isBreadwinnerAdministrator();
        canAssignPermissionSets = false;
        showGeneralSection = false;
        //Square fields
        connectingAppName = '';
        connectionMode = '';
        if(Schema.SobjectType.Profile.IsAccessible() && Profile.getSobjectType().getDescribe().fields.getMap().keySet().contains('permissionsassignpermissionsets')){
            String assignPermissionSets = (Profile.getSObjectType().getDescribe().fields.getmap().get('PermissionsAssignPermissionSets').getDescribe().isAccessible())?',PermissionsAssignPermissionSets':'';
            for(SObject ps: Database.query('SELECT Id '+assignPermissionSets+' FROM Profile WHERE Id= \''+UserInfo.getProfileId()+'\' LIMIT 1')){
                canAssignPermissionSets = (Boolean) ps.get('PermissionsAssignPermissionSets');
            }
        }
        appConfigList = new List<BreadwinnerUtil.AppConfig>();
        contactSupportPrameters = orgInfo != null ? ('&SF_org_id='+orgInfo.Id+'&SF_app_name=Stripe'+'&SF_app_version='+pkgVersion+'&SF_company_name='+orgInfo.Name+'&SF_environment='+orgInfo.OrganizationType):''; 
        
        config = BreadwinnerUtil.processorConfigList.size() > 0 ? BreadwinnerUtil.processorConfigList[0] : new BWP_Processor_Config__c();
        appC = BreadwinnerUtil.getProcessorConfigWrapper(config);
        connectedAppName = appC.accountName;
        isProcessorConnected = appC.accessToken != null; //(appC.accessToken != null);
        needToReconnect = appc.needToReconnect;
        connectionMode = appc.livemode ? 'live' : 'test';

        bwSettings = BreadwinnerUtil.getBWSetting();
        bwSetting  = getBreadwinnerSettingWrapper(bwSettings);
        isMultiProcessorEnabled = bwSettings.Multi_Processor_Enabled__c;
        noOfDaysLeft = bwSettings.Date_of_Expiration__c != null ? calculateNoOfDaysLeft(String.valueOf(bwSettings.Date_of_Expiration__c)): 0;
        isAdministrator = BreadwinnerUtil.isAdministrator();
        Set<String> selectedMatchType = new Set<String>();
        for(BWP_Processor_Config__c appC : BreadwinnerUtil.processorConfigList){
            if(appC.Is_Customer_Match_Completed__c && String.isNotBlank(appC.Customer_Match_Type__c)){
                selectedMatchType.add(appC.Customer_Match_Type__c);
            }
            processorConfigList.add(appC);
            payConfigMap.put(appC.Provider_ID__c, appC);
            appConfigList.add(BreadwinnerUtil.getProcessorConfigWrapper(appC));
            if(!isMultiProcessorEnabled)
                break;
        }
        if(selectedMatchType.size()>1){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ' You can only match Account or Contact, not Both'));
        }
        customerMatchType = !(selectedMatchType.isEmpty())  ? (new list<string>(selectedMatchType))[0] : ProcessorUtil.CMT_ACCOUNT;
        if(appConfigList.size()>0){
            checkCustomerMatch();
        }
        refreshAppConfig(); 
        String PageURL = Apexpages.currentPage().getUrl();
        
        breadwinnerPageName =  PageURL!= null && PageURL.Contains('/apex/')? (PageURL.subStringAfter('/apex/').contains('?')?PageURL.subStringAfter('/apex/').subStringBefore('?'):PageURL.subStringAfter('/apex/')) : ''; // Reverify for main package. "capitalize()" should be removed.//BreadwinnerUtil.namespaceApi + 'Breadwinner';
        String namespaceInLowerCase = breadwinnerPageName.substringBefore('__');

        if(String.isNotBlank(namespaceInLowerCase) && breadwinnerPageName.contains('__')){
            breadwinnerPageName = breadwinnerPageName.replace(namespaceInLowerCase, BreadwinnerUtil.namespace);
        }

        String state = Apexpages.currentPage().getParameters().get('state');
        if(String.isNotBlank(state)){
            system.debug('state-----'+state);
            Map<String, Object> stateDeserialize = new Map<String, Object>();
            try{
                stateDeserialize = (Map<String, Object>)JSON.deserializeUntyped(state);
            }
            catch(Exception ex){
                stateDeserialize = (Map<String, Object>)JSON.deserializeUntyped(convertToJSON(state));
            }
            sfMode = (stateDeserialize.containsKey('SFMode') && stateDeserialize.get('SFMode') != NULL) ? stateDeserialize.get('SFMode').toString() : '';
            connectionMode = (stateDeserialize.containsKey('ProMode') && stateDeserialize.get('ProMode') != NULL) ? stateDeserialize.get('ProMode').toString() : '';
            connectingAppName = (stateDeserialize.containsKey('ProType') && stateDeserialize.get('ProType') != NULL) ? stateDeserialize.get('ProType').toString() : '';

        }else{
            showBWSetupContent = true;
        }

        /*if(String.isNotBlank(state)){
            List<String> strList = state.split('-');
            if(strList.size() == 3){
                sfMode = strList[0];
                connectionMode = strList[1];
                connectingAppName = strList[2];
            }
        }else{
            showBWSetupContent = true;
        }*/
        //To check Account match is completed
        //To Query Users with Assigned Breadwinner Permission Sets
        selectedPermissionSet = 'Overview';
        assignedPermissionSetUsers = new List<User>();
        usersWithModifyAllDataPermission = new List<User>();
        wrapPermissionUsersList = new List<wrapPermissionUsers>();
        sortDirection = 'ASC';
        modifyAllDataSortDirection = 'ASC';
        sortExpression = 'Name';
        modifyAllDataSortExpression = 'Name';
        queryPermissionSetAssignedUsers();
        customerConfigValues();
        isBreadwinnerBillingInstalled = BreadwinnerUtil.isBreadwinnerBillingInstalled();
    }
    public void refreshAppConfig(){
        processorConfigList = new Selector_BWP_ProcessorConfig().getAllAppConfig();
        appConfigList = new List<BreadwinnerUtil.AppConfig>();
        if(!processorConfigList.isEmpty()){
            for(BWP_Processor_Config__c appC : processorConfigList){
                payConfigMap.put(appC.Name, appC);
                appConfigList.add(BreadwinnerUtil.getProcessorConfigWrapper(appC));
                if(!isMultiProcessorEnabled)
                    break;
            }
            config = processorConfigList[0];
            appC = BreadwinnerUtil.getProcessorConfigWrapper(config);
            isProcessorConnected = true;
            if(String.isBlank(appC.customerSyncConfig))
                appC.customerSyncConfig = 'NONAME_AND_NOEMAIL';
        } else{
            isProcessorConnected = false;
        }
        //Finding count of unmatched processor customers
        String whereStr = customerMatchQuery(config, customerMatchType);
        unMatchedRecordCount = selectorCustomer.selectCount(whereStr, null);
        System.debug('--unMatchedRecordCount---'+unMatchedRecordCount);
        areThereUnmatchedCustomers = checkUnmatchedCustomersStatus();
        isAccountMatchDoneForAllProcessors = true;
        if(!processorConfigList.isEmpty()){
            for(BWP_Processor_Config__c  appC : processorConfigList){
                if(appC.Is_Customer_Match_Completed__c == false){
                    isAccountMatchDoneForAllProcessors = false;
                    break;
                }
            }
        }
    }

    private Map<Id,User> userMap {
        get{
            if (userMap == null){
                ID salesforceUserLicenseId =[SELECT Id,Name FROM UserLicense WHERE name='Salesforce' LIMIT 1].Id;
                List<ID> profilesIds = new List<ID>();
                for(Profile pfID : [SELECT Id FROM Profile WHERE UserLicenseId =:salesforceUserLicenseId ]){
                    profilesIds.add(pfID.Id);
                }
                userMap = new map<Id,User>([SELECT Id FROM User WHERE IsActive=true AND ProfileId IN: profilesIds]);
            }
            return userMap;
        }
        set;
    }
 
    public Boolean isPermissionSetAssigned = false;
    public Boolean getIsPermissionSetAssigned(){
        String sQuery ='SELECT id,Name FROM PermissionSet WHERE Name IN : allPMSets';
        String namespace = BreadwinnerUtil.namespace;
        sQuery += String.isNotBlank(namespace) ? ' AND NamespacePrefix=: namespace' : '';
        Map<ID,PermissionSet> PermissionsetMap = new Map<ID,PermissionSet>();
        PermissionsetMap.putAll((list<PermissionSet>)database.query(sQuery));
        list<PermissionSetAssignment> pmsetAssignmentList= [SELECT AssigneeId FROM PermissionSetAssignment WHERE AssigneeId IN: userMap.keyset() AND PermissionSetId IN: PermissionsetMap.keyset()];
        if(pmsetAssignmentList?.size()>0){
            isPermissionSetAssigned = true;
        }
        return isPermissionSetAssigned;
    }

    private Set<String> allPMSets = new Set<String>{
        BreadwinnerUtil.ADMIN_PS_NAME, 
        BreadwinnerUtil.OPERATION_PS_NAME, 
        BreadwinnerUtil.STANDARD_PS_NAME, 
        BreadwinnerUtil.READONLY_PS_NAME
    };
    public PageReference rerenderThisPage(){
        system.debug('rerender this page');
        PageReference pageRef = Page.BreadwinnerPayments;//ApexPages.currentPage();
        pageRef.setRedirect(true);
        return pageRef;
    }

    /*
    * Description  - To set the Boolean variable for displaying edit setting section of multi org pop up
    * Invoked from - "." link at the end of setup sub tab
    */
    public void showEditSettingSection(){
        isEditSettingSection = true;
    }
     /*
    * Description  - To insert or update the custom setting record
    * Invoked from - Save button of multi org pop up
    */
    public Pagereference saveSettingSection(){
        Breadwinner_Settings__c updatebwSettings;
        updatebwSettings = Breadwinner_Settings__c.getAll().Values().size()>0 ? Breadwinner_Settings__c.getAll().Values().get(0) : new Breadwinner_Settings__c(Name=BreadwinnerUtil.CNTX_BW);
        system.debug('updatebwSettings----'+updatebwSettings);
        try{
            updatebwSettings.Multi_Processor_Enabled__c = bwSetting.multiProcessorEnabled;
            SecurityUtil.dmlUpdate(updatebwSettings);
            Pagereference p = Page.BreadwinnerPayments;//ApexPages.currentPage();
            p.setredirect(true);
            return P;
        }
        catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage())); 
            return null;                          
        }
        
    }  
    public void cancelSettingSection(){
        isEditSettingSection = false;
        bwSettings = Breadwinner_Settings__c.getAll().Values().size()>0 ? Breadwinner_Settings__c.getAll().Values().get(0) : new Breadwinner_Settings__c(Name=BreadwinnerUtil.CNTX_BW);
    }
    // This Method will return list of Payment Processors
    public List<SelectOption> getPaymentProcessorsList(){
        List<SelectOption> paymentProcessorsList = new List<selectOption>();
        paymentProcessorsList.add(new SelectOption('none', '--Select a Payment Processor--'));
        paymentProcessorsList.add(new SelectOption(ProcessorUtil.PAT_STRIPE.toLowerCase(), ProcessorUtil.PAT_STRIPE));
        paymentProcessorsList.add(new SelectOption(ProcessorUtil.PAT_BRAINTREE.toLowerCase(), ProcessorUtil.PAT_BRAINTREE));
        paymentProcessorsList.add(new SelectOption(ProcessorUtil.PAT_SQUARE.toLowerCase(), ProcessorUtil.PAT_SQUARE));
        paymentProcessorsList.add(new SelectOption(ProcessorUtil.PAT_AUTHORIZE_NET.toLowerCase(), ProcessorUtil.PAT_AUTHORIZE_NET));
        // removing until we actually build this out.
        // paymentProcessorsList.add(new SelectOption(ProcessorUtil.PAT_PAYPAL.toLowerCase(), ProcessorUtil.PAT_PAYPAL));
        return paymentProcessorsList;
    }

    /**
     *  Saves Stripe Connected app info(works in both cases connect and reconnect)
     */
    public void saveStripeCredentials() {
        try {
            config = Processor_Stripe.saveAppCredentials(connectionMode,config);
            startHistoricalCustomerSync(config);

            isAppConfigUpdated = true;
            showBWSetupContent = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, ' Connection with Stripe is completed. You will be redirected to Breadwinner Payments page now.'));
        } catch (Exception ex) {
            config.Need_To_Reconnect__c = true;
            System.debug('Error occurred while authorizing with Stripe.'+ex.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ' Error occurred while connecting with Stripe. You will be redirected to Breadwinner Payments page now. Try to connect again.'));
            APICallHandler.userInteractionLogPush(false, 'Connecting To Stripe', 'ERROR', ex.getMessage());
        }
    }
    
    //Building URL to perform authorization with Stripe in live mode. Live credentials will be used.
    public String  getStripeAuthUrl(){
        try{
            return Processor_Stripe.getAuthUrl();
        } catch(Exception ex){
            APICallHandler.userInteractionLogPush(false, 'Connecting To Stripe', 'ERROR' , ex.getmessage());
        }
        return null;
    }
    
    //Building URL to perform authorization with Stripe in test mode. Test credentials will be used.
    public String  getStripeTestAuthUrl(){
        try{
            return Processor_Stripe.getTestAuthUrl();
        } catch(Exception ex){
            APICallHandler.userInteractionLogPush(false, 'Connecting To Stripe', 'ERROR' , ex.getmessage());
        }
        return null;
    }

    public void saveBraintreeCredentials() {
        try {
            if(String.isBlank(braintreePublicKey) || String.isBlank(braintreePrivateKey)){
                braintreeAuthErrors = String.isNotBlank(braintreePublicKey) ? ('Please enter Private Key.') : ('Please enter Public Key.');
                return;
            }
            if(String.isBlank(braintreeTokenizationKey)){
                braintreeAuthErrors = 'Please enter Tokenization Key.';
                return;
            }
            config = Processor_Braintree.saveAppCredentials(config, braintreePublicKey, braintreePrivateKey, braintreeTokenizationKey, isBraintreeProduction);
            if(String.isNotBlank(braintreeAuthErrors)){
                return;
            }
            else{
                isBraintreeConnected = true;
            }
            startHistoricalCustomerSync(config);
            isAppConfigUpdated = true;
            showBWSetupContent = true;
        } catch (Exception ex) {
            config.Need_To_Reconnect__c = true;
            braintreeAuthErrors = ex.getMessage();
            APICallHandler.userInteractionLogPush(false, 'Connecting To Braintree', 'ERROR', ex.getMessage());
        }
    }

    // URL to perform authorization with Square in live mode.
    public String  getSquareAuthUrl(){
        try{
            return Processor_Square.getAuthUrl();
        }
        catch(Exception ex){
            APICallHandler.userInteractionLogPush(FALSE, 'Connecting To Squre', 'ERROR' , ex.getmessage());
        }
        return null;
    }

    // URL to perform authorization with Square in Test mode.
    public String  getSquareTestAuthUrl(){
        try{
            return Processor_Square.getTestAuthUrl();
        }
        catch(Exception ex){
            APICallHandler.userInteractionLogPush(FALSE, 'Connecting To Squre', 'ERROR' , ex.getmessage());
        }
        return null;
    }
    
    public void saveSquareCredentials() {
        try {
            config = Processor_Square.saveAppCredentials(connectionMode,config);
            startHistoricalCustomerSync(config);

            isAppConfigUpdated = true;
            showBWSetupContent = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, ' Connection with Square is completed. You will be redirected to Breadwinner Payments page now.'));
        } catch (Exception ex) {
            config.Need_To_Reconnect__c = true;
            System.debug('Error occurred while authorizing with Square.'+ex.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ' Error occurred while connecting with Square. You will be redirected to Breadwinner Payments page now. Try to connect again.'));
            APICallHandler.userInteractionLogPush(false, 'Connecting To Square', 'ERROR', ex.getMessage());
        }
    }

    // URL to perform authorization with PayPal in live mode.
    public String  getPayPalAuthUrl(){
        try{
            return Processor_PayPal.getAuthUrl();
        }
        catch(Exception ex){
            APICallHandler.userInteractionLogPush(FALSE, 'Connecting To PayPal', 'ERROR' , ex.getmessage());
        }
        return null;
    }

    // URL to perform authorization with PayPal in Test mode.
    public String  getPayPalTestAuthUrl(){
        try{
            return Processor_PayPal.getTestAuthUrl();
        }
        catch(Exception ex){
            APICallHandler.userInteractionLogPush(FALSE, 'Connecting To PayPal', 'ERROR' , ex.getmessage());
        }
        return null;
    }
    public void savePayPalCredentials() {
        try {
            Processor_PayPal.saveAppCredentials(connectionMode,config);
            isAppConfigUpdated = true;
            showBWSetupContent = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, ' Connection with PayPal is completed. You will be redirected to Breadwinner Payments page now.'));
        } catch (Exception ex) {
            config.Need_To_Reconnect__c = true;
            System.debug('Error occurred while authorizing with PayPal.'+ex.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ' Error occurred while connecting with PayPal. You will be redirected to Breadwinner Payments page now. Try to connect again.'));
            APICallHandler.userInteractionLogPush(false, 'Connecting To PayPal', 'ERROR', ex.getMessage());
        }
    }

    // URL to perform authorization with Authorize.Net in live mode.
    public String  getAuthorizeNetAuthUrl(){
        try{
            return Processor_Authorize_Net.getAuthUrl();
        }
        catch(Exception ex){
            APICallHandler.userInteractionLogPush(FALSE, 'Connecting To Authorize.Net', 'ERROR' , ex.getmessage());
        }
        return null;
    }

    // URL to perform authorization with Authorize.Net in Test mode.
    public String  getAuthorizeNetTestAuthUrl(){
        try{
            return Processor_Authorize_Net.getTestAuthUrl();
        }
        catch(Exception ex){
            APICallHandler.userInteractionLogPush(FALSE, 'Connecting To Authorize.Net', 'ERROR' , ex.getmessage());
        }
        return null;
    }

    public void saveAuthorizeNetCredentials() {
        try {
            Processor_Authorize_Net.saveAppCredentials(connectionMode,config);
            isAppConfigUpdated = true;
            showBWSetupContent = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, ' Connection with Authorize.Net is completed. You will be redirected to Breadwinner Payments page now.'));
        } catch (Exception ex) {
            config.Need_To_Reconnect__c = true;
            System.debug('Error occurred while authorizing with Authorize.Net.'+ex.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ' Error occurred while connecting with Authorize.Net. You will be redirected to Breadwinner Payments page now. Try to connect again.'));
            APICallHandler.userInteractionLogPush(false, 'Connecting To Authorize.Net', 'ERROR', ex.getMessage());
        }
    }
     //Disconnect from Payment Processor
     public PageReference disconnect() {
        BWP_Processor_Config__c payConfig = BreadwinnerUtil.getProcessorConfig(disconnectAppId);
        try{
            if(payConfig != NULL){
                String orgName = payConfig.Account_Name__c;
                BreadwinnerUtil.isBreadwinnerTransaction = true;
                SecurityUtil.dmlDelete(payConfig);
                APICallHandler.userInteractionLogPush(false, 'Disconnecting to '+payConfig.Payment_Processor_Type__c, 'Success' , payConfig.Payment_Processor_Type__c+' org is disconnected');
            }
            if(BreadwinnerUtil.processorConfigList.size() == 0) {
                isProcessorConnected = false;
            }
            PageReference pr = ApexPages.currentPage();
            pr.setRedirect(true);
            return pr;
        }
        catch(exception ex){
            ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.ERROR, ' Disconnection is failed. Try again.'+ex.getStackTraceString())); 
            APICallHandler.userInteractionLogPush(FALSE, 'Disconnecting to '+payConfig.Payment_Processor_Type__c, 'ERROR' , ex.getmessage()); 
        }
        return null;
    }
    
    //To reschedule all hourly sync batches.
    public void rescheduleHourlySync(){
        try{
            if(isBreadwinnerAdministrator){
                HourlySyncBatch.scheduleBreadwinnerHourlySync(1,true);
                APICallHandler.userInteractionLogPush(FALSE, 'Restarted Hourly Sync', 'Troubleshoot-General' , 'Restarted Hourly Sync from the Troubleshoot section of Breadwinnner tab');
            }
        }
        catch(exception e){
            APICallHandler.userInteractionLogPush(FALSE, 'Restarted Hourly Sync', 'ERROR' , 'Error occurred while restarting Hourly Sync from the Troubleshoot section of Breadwinnner tab' +e);
        }
    }

    //To reschedule all hourly sync batches.
    public void rescheduleBillingHourlySync(){
        try{
            if(isBreadwinnerAdministrator){
                Schedulable instance = (Schedulable) Type.forName('RamyaTestBWP','BillingHourlySyncBatch').newInstance();
                APICallHandler.userInteractionLogPush(FALSE, 'Restarted Hourly Sync', 'Troubleshoot-General' , 'Restarted Billing Hourly Sync from the Troubleshoot section of Breadwinnner tab');
            }
        }
        catch(exception e){
            APICallHandler.userInteractionLogPush(FALSE, 'Restarted Hourly Sync', 'ERROR' , 'Error occurred while restarting Hourly Sync from the Troubleshoot section of Breadwinnner tab' +e);
        }
    }

    public void startHistoricalCustomerSync(BWP_Processor_Config__c config){
        BreadwinnerUtil.AppConfig apcWrapper = BreadwinnerUtil.getProcessorConfigWrapper(config);
        HistoricalSyncBatch historicalSync = new HistoricalSyncBatch(BreadwinnerUtil.OBJ_SYNC_CUSTOMER, new List<BreadwinnerUtil.AppConfig>{apcWrapper});
        Database.executeBatch(historicalSync, 1);
        APICallHandler.userInteractionLogPush(false, 'Restarted Historical Sync', 'Breadwinnner Tab', 'Historical Sync is started automatically after connection/reconnection');
    }
    
    //To rerun historical customer sync batch.
    public void restartHistoricalSync(){
        isBatchStarted = false;    
        String runningSyncName = String.isNotBlank(syncName) ? syncName : BreadwinnerUtil.OBJ_SYNC_CUSTOMER;
        try{
            if(String.isNotBlank(syncProcessor) && appC.accountId == syncProcessor && !BreadwinnerUtil.isBatchRunning(BreadwinnerUtil.CNTX_HIST_SYNC)){
                HistoricalSyncBatch historicalSync = new HistoricalSyncBatch(syncName, new List<BreadwinnerUtil.AppConfig>{appC});
                historicalSync.runThisSyncOnly = String.isNotBlank(syncName) ? true : false;
                Database.executeBatch(historicalSync, 1);
            }
            else{
                HistoricalSyncBatch.runHistoricalSyncBatch(runningSyncName);
            }
            isBatchStarted = true;
            APICallHandler.userInteractionLogPush(false, 'Restarted Historical '+runningSyncName+' Sync', 'Troubleshoot-'+(String.isNotBlank(syncProcessor) ? 'Connection' : 'General'), 'Restarted Historical Sync from the Troubleshoot section of Breadwinnner tab '+(String.isNotBlank(syncProcessor) ? ' for Processor : '+ appC.paymentProcessorType+' ('+appC.accountName+')' : ' '));
        }
        catch(exception e){
            APICallHandler.userInteractionLogPush(FALSE, 'Restarted Historical '+runningSyncName+' Sync', 'ERROR' , 'Error occurred while restarting Historical Sync from the Troubleshoot section of Breadwinnner tab '+(String.isNotBlank(syncProcessor) ? ' for Processor : '+ appC.paymentProcessorType+' ('+appC.accountName+').' : '.') +e.getMessage());
        }
    }

    public void restartBillingHistoricalSync(){
        isBatchStarted = false;    
        String runningSyncName = String.isNotBlank(syncName) ? syncName : BreadwinnerUtil.OBJ_SYNC_PRODUCT;
        try {
            if(!BreadwinnerUtil.isBatchRunning(BreadwinnerUtil.CNTX_BB_HIST_SYNC)){
                Type t = Type.forName('RamyaTestBWP','BillingHistoricalSyncBatch');
                Schedulable instance = (Schedulable) t.newInstance();
                Map<String, Object> variableMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(instance));
                if(BreadwinnerUtil.getBWSetting().Active__c && String.isNotBlank(syncProcessor) && appC.accountId == syncProcessor && !appC.needToReconnect && appC.accessToken != NULL) {
                    variableMap.put('appConfig', appC);
                }
                variableMap.put('runningObjectName', runningSyncName);
                variableMap.put('runThisSyncOnly', String.isNotBlank(syncName) ? true : false);
                instance = (Schedulable)JSON.deserialize(JSON.serialize(variableMap), t);

                DateTime nextScheduleTime = System.now().addMinutes(1);
                String CronExpression = '0 ' + nextScheduleTime.minute() + ' ' + nextScheduleTime.hour() + ' ' + nextScheduleTime.day() + ' ' + nextScheduleTime.month() + ' ? ' + nextScheduleTime.year() + ' BillingHistoricalSync';
                System.schedule('BreadwinnerBillingHistoricalSync', CronExpression, instance);
            }
            isBatchStarted = true;
            APICallHandler.userInteractionLogPush(false, 'Restarted Billing Historical '+runningSyncName+' Sync', 'Troubleshoot-'+(String.isNotBlank(syncProcessor) ? 'Connection' : 'General'), 'Restarted Billing Historical Sync from the Troubleshoot section of Breadwinnner tab '+(String.isNotBlank(syncProcessor) ? ' for Processor : '+ appC.paymentProcessorType+' ('+appC.accountName+')' : ' '));
        } catch (Exception e) {
            APICallHandler.userInteractionLogPush(FALSE, 'Restarted Billing Historical '+runningSyncName+' Sync', 'ERROR' , 'Error occurred while restarting Billing Historical Sync from the Troubleshoot section of Breadwinnner tab '+(String.isNotBlank(syncProcessor) ? ' for Processor : '+ appC.paymentProcessorType+' ('+appC.accountName+').' : '.') +e.getMessage());
        }
    }
    
    public void restartWeeklySync(){
        try{
            isBatchStarted = false;
            String runningSyncName = '';
            HistoricalSyncBatch.runHistoricalSyncBatch(runningSyncName);
            isBatchStarted = true;
            HistoricalSyncBatch.scheduleWeeklyHistoricalSync();
            APICallHandler.userInteractionLogPush(false, 'Restarted Historical Sync', 'Troubleshoot-General', 'Restarted Historical Sync from the Troubleshoot section of Breadwinnner tab.');
        }
        catch(exception e){
            APICallHandler.userInteractionLogPush(FALSE, ' Restarted Historical Sync', 'ERROR' , 'Error occurred while restarting Historical Sync from the Troubleshoot section of Breadwinnner tab.' +e.getMessage());
        }
    }
      
    public void restartScheduledJobs(){
        BreadwinnerUtil.abortAllBreadwinnerPaymentsJobs();
        HourlySyncBatch.runHourlySyncBatch();
        HistoricalSyncBatch.runHistoricalSyncBatch('');
        HistoricalSyncBatch.scheduleWeeklyHistoricalSync();
        checkAndScheduleBreadwinnerMonitor();
        APICallHandler.userInteractionLogPush(false, 'Restarted Scheduled Jobs', 'Troubleshoot', 'All Breadwinner jobs are scheduled under logged in user from the Troubleshoot section.');
    }
    
    public static Map<String,boolean> scheduledJobsRunByActiveOrAdminUserMap(){
        Map<String,boolean> isActiveAdmin = new Map<String,boolean>();
        Set<Id> userIds = new Set<Id>();
        list<User> inActiveUsers = new list<User>();
        list<User> assignedBWAdminPSUsers = new list<User>();
        Set<ID> allUsers = new Set<ID>();
        for(CronTrigger ct : BreadwinnerUtil.getCronTrigger(BreadwinnerUtil.SYNC_CNTX_ALL)){
            userIds.add(ct.ownerid);
        }
        for(User u : [select id, isActive,ProfileId from user where id in :userids]){
            if(u.isActive == false){
                inActiveUsers.add(u);
            }
            else
                allUsers.add(u.ProfileId);
        }
        String adminPSName = BreadwinnerUtil.namespaceApi + BreadwinnerUtil.ADMIN_PS_NAME;
        assignedBWAdminPSUsers = [SELECT Id, Name, Username FROM User WHERE Id IN (select AssigneeId from PermissionSetAssignment where PermissionSet.Name Like: adminPSName and AssigneeId in :userids)];
        list<Profile> nonAdmins = [SELECT PermissionsModifyAllData FROM Profile WHERE Id in :allUsers and PermissionsModifyAllData = false LIMIT 1];
        if(inActiveusers.size() == 0) isActiveAdmin.put('isActiveUser', true);
        else isActiveAdmin.put('isActiveUser', false);
        
        if(nonAdmins.size() == 0 || assignedBWAdminPSUsers.size()>0) isActiveAdmin.put('isAdmin', true);
        else isActiveAdmin.put('isAdmin', false);
        return isActiveAdmin;          
    }
    
    
    public void changeBreadwinnerMode(){
        try {
            bwsettings.Read_Only_Mode__c = bwsetting.activeMode ? FALSE : TRUE;
            SecurityUtil.dmlUpdate(bwsettings);
        }
        catch(Exception e) { System.debug('changeBreadwinnerMode ::: Exception: '+e+', Stack Trace: '+e.getStackTraceString()); }
    }

    public static Integer calculateNoOfDaysLeft(String expirationDateTime){
        Integer noOfDaysLeft;
        try{
            if(String.isNotBlank(expirationDateTime)){
                if(expirationDateTime.contains(' ')){
                    String expirationDate = expirationDateTime.split(' ',2).get(0);
                    List<String> splittedDate = expirationDate.split('-',3);
                    
                    Integer year = Integer.valueOf(splittedDate.get(0));
                    Integer month = Integer.valueOf(splittedDate.get(1));
                    Integer day = Integer.valueOf(splittedDate.get(2));
                    
                    Date dExpirationDate = Date.newinstance(year, month, day);
                    
                    noOfDaysLeft = System.today().daysBetween(dExpirationDate);
                }
            }
        }
        catch(Exception ex){
            System.debug(' Exception in calculateNoOfDaysLeft::'+ex.getStackTraceString()+'--'+ex.getMessage());
        }
        return noOfDaysLeft;
    }
    
    public void checkCustomerMatch(){
        Integer checkAccountMatchCount = selectorCustomer.selectCount('Salesforce_Account__c != null OR No_Associated_SF_Account__c = true', 1);
        isAccountMatchStarted = checkAccountMatchCount > 0 ? true : false;

        Integer checkContactMatchCount = selectorCustomer.selectCount('Salesforce_Contact__c != null OR No_Associated_SF_Contact__c = true', 1);
        isContactMatchStarted = checkContactMatchCount > 0 ? true : false;
      
        if(isAccountMatchStarted || isContactMatchStarted){
            isCustomerMatchStarted = true;
            displayCustomerMatchOptions = false;
        }
        if(!isAccountMatchStarted && !isContactMatchStarted)
            displayCustomerMatchOptions = true;
    }
    public static string customerMatchQuery(BWP_Processor_Config__c appConfig, String customerMatchType){
        String whereStr = 'Processor_Org_Id__c =\'' + String.valueOf(appConfig.Name)+'\'';
        if(customerMatchType == ProcessorUtil.CMT_ACCOUNT)
            whereStr += ' AND Salesforce_Account__c = Null AND No_Associated_SF_Account__c = False';
        else if(customerMatchType == ProcessorUtil.CMT_CONTACT)
            whereStr += ' AND Salesforce_Contact__c = Null AND No_Associated_SF_Contact__c = False';
        if(String.isBlank(appConfig.Customer_Match_Config__c) || (String.isNotBlank(appConfig.Customer_Match_Config__c) && appConfig.Customer_Match_Config__c.contains('NO_VALID_PAYMENTS')))
            whereStr += ' AND Has_Successful_Payments__c = true';
        return whereStr;
    }    

    public void TroubleshootGeneralInitialize(){
        syncProcessor = '';
        showGeneralSection = true;
        pkgVersion = BreadwinnerUtil.getBW_PackageVersion();
        planName = Boolean.ValueOf(bwsetting.status == 'trial') ? 'You are currently in a Free Trial' : String.isNotBlank(bwsetting.Plan_Name) ? String.valueOf(bwsetting.Plan_Name) : 'Professional';
        isScheduledJobsRunByActiveUser = isBreadwinnerAdministrator ? scheduledJobsRunByActiveOrAdminUserMap().get('isActiveUser') : false; 
        isScheduledJobsRunByAdmin = isBreadwinnerAdministrator ? scheduledJobsRunByActiveOrAdminUserMap().get('isAdmin') : false; 
        if(!isProcessorConnected){
            customersCount = selectorCustomer.selectCount(null,10000);
            paymentMethodsCount = selectorPaymentMethod.selectCount(null,35000);
            bwpTransCount = selectorTransaction.selectCount(null,35000);
            if(isBreadwinnerBillingInstalled){
                productsCount = getBillingRecordsCount('BWP_Product__c', null, 10000);
                pricesCount = getBillingRecordsCount('BWP_Price__c', null, 10000);
            }
        }
   }

    public void OrgWideRecordsCount(){
        String processorId = String.isNotBlank(processorAccountId) ? processorAccountId : '';
        if(String.isNotBlank(processorId)){
            appC = BreadwinnerUtil.getProcessorConfigWrapper(BreadwinnerUtil.getProcessorConfig(processorId));
            customersCount = selectorCustomer.selectCount('Processor_Org_Id__c = \'' + processorId + '\'',10000);
            paymentMethodsCount = selectorPaymentMethod.selectCount('Processor_Org_Id__c = \'' + processorId + '\'',35000);
            bwpTransCount = selectorTransaction.selectCount('Processor_Org_Id__c = \'' + processorId + '\'',35000);
            if(isBreadwinnerBillingInstalled){
                productsCount = getBillingRecordsCount('BWP_Product__c','Processor_Org_Id__c = \'' + processorId + '\'',10000);
                pricesCount = getBillingRecordsCount('BWP_Price__c','Processor_Org_Id__c = \'' + processorId + '\'',10000);
            }
        }
    }
    // to check unmatched Customers status
    public Boolean checkUnmatchedCustomersStatus(){
        unmatchedCustomersStatusMap = new Map<String,Boolean>();
        Boolean unmatchedExist = false;
        if(processorConfigList== NULL || processorConfigList.isEmpty())
           return false;
        else
        {
            /* Updated this section to avoid any exceptions. Previously the query was in for loop, now Using AggregateResult. 
               The purpose of the query is to know whether there are any customers unmatched to any Account/Contact. 
               We also need to check with Customer_Match_Config value in processorConfig. If it is checked then we should only look for Customers with Successful Payments
            */
            AggregateResult[] aggregateResults;
            String [] customerAccessFields = new String [] {
                BreadwinnerUtil.namespaceApi + 'Processor_Org_Id__c',
                BreadwinnerUtil.namespaceApi + 'Processor_Org_Name__c',
                BreadwinnerUtil.namespaceApi + 'Salesforce_Account__c',
                BreadwinnerUtil.namespaceApi + 'No_Associated_SF_Account__c',
                BreadwinnerUtil.namespaceApi + 'Salesforce_Contact__c',
                BreadwinnerUtil.namespaceApi + 'No_Associated_SF_Contact__c',
                BreadwinnerUtil.namespaceApi + 'Has_Successful_Payments__c'
            };
            Map<String,Schema.SObjectField> customerFields = Schema.SObjectType.BWP_Customer__c.fields.getMap(); 
            for (String fieldToCheck : customerAccessFields) { 
                if (!customerFields.get(fieldToCheck).getDescribe().isAccessible()) {
                 throw new System.NoAccessException(); 
                } 
            } 
            if(customerMatchType == ProcessorUtil.CMT_ACCOUNT){
                aggregateResults = [SELECT Processor_Org_Id__c processorId, Has_Successful_Payments__c hasPmnts, COUNT_DISTINCT(Processor_Org_Name__c) processorCount FROM BWP_Customer__c WHERE Salesforce_Account__c = Null AND No_Associated_SF_Account__c = False GROUP BY Processor_Org_Id__c ,Has_Successful_Payments__c];
            }
            else if(customerMatchType == ProcessorUtil.CMT_CONTACT){
                aggregateResults = [SELECT Processor_Org_Id__c processorId,Has_Successful_Payments__c hasPmnts , COUNT(Processor_Org_Name__c) processorCount FROM BWP_Customer__c WHERE Salesforce_Contact__c = Null AND No_Associated_SF_Contact__c = False GROUP BY Processor_Org_Id__c ,Has_Successful_Payments__c];
            }

            Map<String, List<AggregateResult>> processorsWithCustomers = new Map<String, List<AggregateResult>>();
            for(AggregateResult ar : aggregateResults) {
                System.debug('ar: ' + ar);
                if(processorsWithCustomers.size()>0 && processorsWithCustomers.containsKey((String) ar.get('processorId'))){
                    processorsWithCustomers.get((String) ar.get('processorId')).add(ar);
                }
                else{
                    processorsWithCustomers.put((String) ar.get('processorId'), new List<AggregateResult>{ar});
                }
            }
            System.debug('processorsWithCustomers: ' + processorsWithCustomers);
            
            for(BWP_Processor_Config__c processorConfig : BreadwinnerUtil.processorConfigList){
                Boolean isValidPayments = (processorConfig.Customer_Match_Config__c == 'NO_VALID_PAYMENTS' ? true : false);
                Boolean isCriteriaMatched = false;
                if(processorsWithCustomers.containsKey(processorConfig.name)){
                    if(processorsWithCustomers.get(processorConfig.name).size() > 1){
                        if(processorsWithCustomers.get(processorConfig.name)[0].get('hasPmnts') == isValidPayments){
                            isCriteriaMatched = true;
                        }
                        else if(processorsWithCustomers.get(processorConfig.name)[1].get('hasPmnts') == isValidPayments){
                            isCriteriaMatched = true;
                        }
                    }
                    else if(processorsWithCustomers.get(processorConfig.name)[0].get('hasPmnts') == isValidPayments){
                        isCriteriaMatched = true;
                    }
                }
                if(isCriteriaMatched){
                    unmatchedExist = true;
                    unmatchedCustomersStatusMap.put(processorConfig.Provider_ID__c,TRUE);
                }
                else{
                    unmatchedCustomersStatusMap.put(processorConfig.Provider_ID__c,FALSE);
                }
            }
            return unmatchedExist;
        }
    }
    
    public void deleteRecords(){
        try{
            if(objectName == 'Customers' && customersCount > 0){ 
                deleteCustomers(); 
            }
            else if(objectName == 'PaymentMethods' && paymentMethodsCount > 0){
                deletePaymentMethods();
            }
            else if(objectName == 'Payments' && bwpTransCount > 0){
                deleteBwpTransactions();
            }
            else if(objectName == 'Products' && productsCount > 0){
                if(isProcessorConnected) deleteBillingRecords('BWP_Product__c', 'Processor_Org_Id__c = \'' + processorAccountId + '\'', 9000);
                else deleteBillingRecords('BWP_Product__c', null, 9000);
            }
            else if(objectName == 'Prices' && pricesCount > 0){
                if(isProcessorConnected) deleteBillingRecords('BWP_Price__c', 'Processor_Org_Id__c = \'' + processorAccountId + '\'', 9000);
                else deleteBillingRecords('BWP_Price__c', null, 9000);
            }
        }   
        catch(Exception e){
            system.debug('Exception from delete'+ objectName +' Records. '+e);
            APICallHandler.userInteractionLogPush(FALSE, 'Deleting Records', 'ERROR' , e.getmessage());
        }
    }
    
    public void deleteCustomers() {
        //Don't throw the FLS exception if the user doesn't have access
        Selector_BWP_Customer selCust = new Selector_BWP_Customer(true, true, false);
        // Return only the Id, which is all we need.
        selCust.setSObjectFieldList(new List<SObjectField>{BWP_Customer__c.Id});
        if(isProcessorConnected){
            List<BWP_Customer__c> deleteList = selectorCustomer.selectByProcessorOrgId(processorAccountId, 9000);
            SecurityUtil.dmlDelete(deleteList);
            customersCount = selectorCustomer.selectCount('Processor_Org_Id__c = \'' + processorAccountId + '\'', 10000);
        } else{
            List<BWP_Customer__c> deleteList = selectorCustomer.selectWithLimit(9000);
            SecurityUtil.dmlDelete(deleteList);
            customersCount = selectorCustomer.selectCount(null, 10000);
        }
        APICallHandler.userInteractionLogPush(FALSE, 'Deleting Records', 'SUCCESS' , 'Successfully deleted the '+customersCount+' Customers.');
    }
    
    public void deletePaymentMethods(){
        //Don't throw the FLS exception if the user doesn't have access
        Selector_BWP_Payment_Method selPaymentMethod = new Selector_BWP_Payment_Method(true, true, false);
        // Return only the Id, which is all we need.
        selPaymentMethod.setSObjectFieldList(new List<SObjectField>{BWP_Customer__c.Id});

        if(isProcessorConnected){
            List<BWP_Payment_Method__c> deleteList = selPaymentMethod.selectByProcessorOrgId(new Set<String>{processorAccountId}, 9000);
            SecurityUtil.dmlDelete(deleteList);
            paymentMethodsCount = paymentMethodsCount = selectorPaymentMethod.selectCount('Processor_Org_Id__c = \'' + processorAccountId + '\'',10000);
        } else{
            List<BWP_Payment_Method__c> deleteList = selPaymentMethod.selectWithLimit(9000);
            SecurityUtil.dmlDelete(deleteList);
            paymentMethodsCount = paymentMethodsCount = selectorPaymentMethod.selectCount(null,10000);
        }
        APICallHandler.userInteractionLogPush(FALSE, 'Deleting Records', 'SUCCESS' , 'Successfully deleted the '+paymentMethodsCount+' Payment Methods.');
    }
    
    public void deleteBwpTransactions(){
        //Don't throw the FLS exception if the user doesn't have access
        Selector_BWP_Transaction selectorTransaction = new Selector_BWP_Transaction(true, true, false);
        // Return only the Id, which is all we need.
        selectorTransaction.setSObjectFieldList(new List<SObjectField>{BWP_Customer__c.Id});

        if(isProcessorConnected){
            List<BWP_Transaction__c> deleteList = selectorTransaction.selectByProcessorOrgId(new Set<String>{processorAccountId}, 9000);
            SecurityUtil.dmlDelete(deleteList);
            bwpTransCount  = selectorTransaction.selectCount('Processor_Org_Id__c = \'' + processorAccountId + '\'',10000);
        } else{
            List<BWP_Transaction__c> deleteList = selectorTransaction.selectWithLimit(9000);
            SecurityUtil.dmlDelete(deleteList);
            bwpTransCount  = selectorTransaction.selectCount(null,10000);
        }
        APICallHandler.userInteractionLogPush(FALSE, 'Deleting Records', 'SUCCESS' , 'Successfully deleted the '+bwpTransCount+' Transactions.');
    }

    public void deleteBillingRecords(String ObjName, String whereString, Integer lim){
        if(isBreadwinnerBillingInstalled){
            SObjectType sObjType = ((SObject) Type.forName(ObjName).newInstance()).getSObjectType();
            QueryBuilder qb = new QueryBuilder(sObjType, true, true, true);
            qb.addSObjectFields(sObjType.getDescribe().fields.getMap().values());
            if(String.isNotBlank(whereString)) qb.setCondition(whereString);
            if(lim != null) qb.setLimit(lim);
            System.debug('qb.toSOQL() ::: '+qb.toSOQL());
            List<Sobject> deleteList = Database.query(qb.toSOQL());
            System.debug('deleteList ::: '+deleteList);
            SecurityUtil.dmlDelete(deleteList);
    
            if(isProcessorConnected){
                if(ObjName == 'BWP_Product__c') productsCount = getBillingRecordsCount(ObjName, 'Processor_Org_Id__c = \'' + processorAccountId + '\'', 10000);
                else if(ObjName == 'BWP_Price__c') pricesCount = getBillingRecordsCount(ObjName, 'Processor_Org_Id__c = \'' + processorAccountId + '\'', 10000);
            }
            else{
                if(ObjName == 'BWP_Product__c') productsCount = getBillingRecordsCount(ObjName, null, 10000);
                else if(ObjName == 'BWP_Price__c') pricesCount = getBillingRecordsCount(ObjName, null, 10000);
            }
            APICallHandler.userInteractionLogPush(FALSE, 'Deleting Records', 'SUCCESS' , 'Successfully deleted the '+ObjName+' Records.');
        }
    }

    public Integer getBillingRecordsCount(String ObjName, String whereString, Integer lim){
        Integer countOfRecords = 0;
        if(isBreadwinnerBillingInstalled){
            Type t = Type.forName(ObjName);
            SObjectType sObjType;
            if(t != NULL) sObjType = ((SObject) t.newInstance()).getSObjectType();
            QueryBuilder qb = new QueryBuilder(sObjType, true, true, true);
            if(String.isNotBlank(whereString)) qb.setCondition(whereString);
            if(lim != null) qb.setLimit(lim);
            System.debug('qb.toCountSOQL() ::: '+qb.toCountSOQL());
            countOfRecords = Database.countQuery(qb.toCountSOQL());
        }
        return countOfRecords;
    }

    public PageReference queryPermissionSetAssignedUsers(){
        try{
            if(Schema.SobjectType.User.IsAccessible() && Schema.SobjectType.PermissionSetAssignment.IsAccessible()){
                string sortFullExp = sortExpression  + ' ' + sortDirection;
                string modifyAllDataSortFullExp = modifyAllDataSortExpression  + ' ' + modifyAllDataSortDirection;
                System.debug('selectedPermissionSet: '+selectedPermissionSet);
                if(selectedPermissionSet == 'All_Permission_Sets'){
                    String whereString = 'PermissionSet.Name IN : allPMSets ';
                    assignedPermissionSetUsers = database.query('SELECT Id, Name, Username, Profile.Name, (SELECT PermissionSet.Name FROM PermissionSetAssignments WHERE '+whereString+') FROM User WHERE Id IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE '+whereString+') AND IsActive = TRUE ORDER BY '+sortFullExp);
                    System.debug('assignedPermissionSetUsers: All users: '+assignedPermissionSetUsers);
                } else if(selectedPermissionSet != '' && selectedPermissionSet != 'Overview') {
                    selectedPermissionSetId = [SELECT Id, Name FROM PermissionSet WHERE Name =: selectedPermissionSet LIMIT 1].Id;
                    assignedPermissionSetUsers = database.query('SELECT Id, Name, Username, Profile.Name FROM User WHERE Id IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = \''+selectedPermissionSet+'\') AND IsActive = TRUE ORDER BY '+sortFullExp+' LIMIT 10');
                    System.debug('assignedPermissionSetUsers: Specific: '+assignedPermissionSetUsers);
                    if(selectedPermissionSet == BreadwinnerUtil.ADMIN_PS_NAME){
                        usersWithModifyAllDataPermission = database.query('SELECT Id, Name, Username, Profile.Name FROM User WHERE Profile.PermissionsModifyAllData = TRUE AND Id NOT IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = \''+selectedPermissionSet+'\') AND IsActive = TRUE ORDER BY '+modifyAllDataSortFullExp);
                        System.debug('usersWithModifyAllDataPermission :: '+usersWithModifyAllDataPermission);
                    }
                }
                if(wrapPermissionUsersList.size()>0) wrapPermissionUsersList.clear();
                for(User u: assignedPermissionSetUsers){
                    Boolean adminSelected = false;
                    Boolean operationsSelected = false;
                    Boolean standardSelected = false;
                    Boolean readOnlySelected = false;
                    for(PermissionSetAssignment ps:u.PermissionSetAssignments){
                        if(ps.PermissionSet.Name == BreadwinnerUtil.ADMIN_PS_NAME) adminSelected = true;
                        if(ps.PermissionSet.Name == BreadwinnerUtil.OPERATION_PS_NAME) operationsSelected = true;
                        if(ps.PermissionSet.Name == BreadwinnerUtil.STANDARD_PS_NAME) standardSelected = true;
                        if(ps.PermissionSet.Name == BreadwinnerUtil.READONLY_PS_NAME) readOnlySelected = true;
                    }
                    wrapPermissionUsersList.add(new wrapPermissionUsers(u.Name, u.Username, u.Profile.Name, adminSelected, operationsSelected, standardSelected, readOnlySelected));
                }
            }else{
                System.debug('Do not have sufficient access on User and PermissionSetAssignment Objects');
            }
        }catch(Exception e){
            System.debug('Exception in queryPermissionSetAssignedUsers ::: '+e);
        }
        return null;
    }

    public void showEndpointUrlEditor(){
        showEndpointURLSetting = TRUE;
    }

    public void updateEndpointUrl(){
        if(String.isNotBlank(bwSetting.endpointURL)){
            try {
                String supportRSURL = bwSetting.endpointURL.contains('staging') || bwSetting.endpointURL.contains('testing') ? 'https://support-staging.breadwinnerhq.com' : BreadwinnerUtil.getSupportURL();
                MetadataService.MetadataPort service = createService();
                system.debug('create remote sites--');
                MetadataService.RemoteSiteSetting supportRS = new MetadataService.RemoteSiteSetting();
                supportRS.FullName = 'BreadwinnerSupportStaging';
                supportRS.Description = 'Created by Breadwinner';
                supportRS.DisableProtocolSecurity = TRUE;
                supportRS.IsActive = TRUE;
                supportRS.URL = supportRSURL;
                List<MetadataService.UpsertResult> results = service.upsertMetadata(new MetadataService.Metadata[]{supportRS});
                bwSettings.Support_URL__c = supportRSURL;
                SecurityUtil.dmlUpdate(bwSettings);
                showEndpointURLSetting = FALSE;
            }
            catch(Exception e) { System.debug('updateEndpointUrl ::: Exception: '+e+', Stack Trace: '+e.getStackTraceString()); }
        }
    }

    public void hideEndpointUrlEditor(){
        showEndpointURLSetting = FALSE;
        bwSettings = Breadwinner_Settings__c.getAll().Values().size()>0 ? Breadwinner_Settings__c.getAll().Values().get(0) : new Breadwinner_Settings__c(Name=BreadwinnerUtil.CNTX_BW);
    }

    // This method is used to know the Customer sync configuration values
    public void customerConfigValues(){
        String processorId = '';
        processorId = String.isNotBlank(processorAccountId) ? processorAccountId : appC.accountId;
        BWP_Processor_Config__c appConfig = payConfigMap.get(processorId);
        appC = BreadwinnerUtil.getProcessorConfigWrapper(appConfig);
        if(String.isBlank(appC.customerSyncConfig))
            appC.customerSyncConfig = 'NONAME_AND_NOEMAIL';
        // Code related to Customer Match Config
        String customerMatchConfigValues = (appConfig != NULL && String.isNotBlank(appConfig.Customer_Match_Config__c)) ? appConfig.Customer_Match_Config__c : '';
        if(customerMatchConfigValues.Contains('NO_VALID_PAYMENTS') || String.isBlank(customerMatchConfigValues)){
            excludeNoValidPaymentsCustomersInAccMatch = TRUE;
        }
        else{
            excludeNoValidPaymentsCustomersInAccMatch = FALSE;
        }
    }

    // This method is used to save the Customer Sync Configuration values
    public void saveCustomerConfigurationValues(){
        try{
            Boolean isSuccess = false;
            String processorId = '';
            processorId = String.isNotBlank(processorAccountId) ? processorAccountId : appC.accountId;
            BWP_Processor_Config__c appConfig = payConfigMap.get(processorId);

            // Code related to Customer Sync Config
            
            String getCustomerSyncConfigValue = String.isNotBlank(customerSyncConfigValue) ? customerSyncConfigValue : appC.customerSyncConfig;
            appConfig.Customer_Sync_Config__c = getCustomerSyncConfigValue;

            // Code related to Customer Match Config
            String customerMatchConfigValue = '';
            if(excludeNoValidPaymentsCustomersInAccMatch){
                customerMatchConfigValue = 'NO_VALID_PAYMENTS';
            }
            else{
                customerMatchConfigValue = 'NONE';
            }
            appConfig.Customer_Match_Config__c = customerMatchConfigValue;
            BreadwinnerUtil.isBreadwinnerTransaction = true;
            SecurityUtil.dmlUpsert(appConfig);
            isSuccess = true;

            if(isSuccess)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, ' Your changes are successfully saved.'));
        }
        catch(Exception e){
            system.debug('Error occured while saving Customer configuration values'+e.getStackTraceString());
            ApexPages.addMessage(NEW ApexPages.Message(ApexPages.Severity.ERROR, ' Error occured while saving the Customer Configuration values'+e.getMessage()));     
            APICallHandler.userInteractionLogPush(FALSE, 'Customer Configuration', 'ERROR' , e.getmessage());
        }
    }
    public static void checkAndScheduleBreadwinnerMonitor() {
        try {
            List<CronTrigger> listCronTrigger = BreadwinnerUtil.getCronTrigger(BreadwinnerUtil.SYNC_CNTX_MONITOR);
            Boolean scheduleBreadwinnerMonitor = true;

            if( listCronTrigger.size() > 0) {
                scheduleBreadwinnerMonitor = false;
                if(listCronTrigger.get(0).NextFireTime == null) {
                    scheduleBreadwinnerMonitor = true;
                    System.abortJob(listCronTrigger.get(0).Id);
                }
            }
            if(scheduleBreadwinnerMonitor) {
                String BreadwinnerMonitorSchedulerStartTime = '0 0 0/4 ? * * * MonitorBWPayments';
                System.schedule(BreadwinnerUtil.SYNC_CNTX_MONITOR, BreadwinnerMonitorSchedulerStartTime, new BreadwinnerMonitor());
            }
        }
        catch(Exception e) {
            System.debug('Exception while scheduling the BreadwinnerMonitor Job' +e);
        }
    }

     // Description - To update Account/Contact Layout using Metadata API    
     public pagereference updatePageLayouts(){   
        try{
            String objectToUpdate = '';
            if(customerMatchType == ProcessorUtil.CMT_ACCOUNT){
                objectToUpdate = ProcessorUtil.CMT_ACCOUNT;
            } else if(customerMatchType == ProcessorUtil.CMT_CONTACT){
                objectToUpdate = ProcessorUtil.CMT_CONTACT;
            }
            Map<String, List<List<String>>> MapofObjectandlistOfLayoutsList = new Map<String, List<List<String>>>{objectToUpdate => new List<List<String>>()};
            Map<String, List<String>> MapofObjectandlistOfLayouts = new Map<String, List<String>>{objectToUpdate => new List<String>()};
            Map<String, Boolean> MapofObjectandUpdatedLayoutBoolean = new Map<String, Boolean>{objectToUpdate => FALSE};
            Map<String, Integer> MapofObjectandLayoutsCount = new Map<String, Integer>{objectToUpdate => 0};
            
            MetadataService.MetadataPort service = createService();
            service.SessionHeader.sessionId = UserInfo.getSessionId();
            List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();        
            MetadataService.ListMetadataQuery listLayouts = new MetadataService.ListMetadataQuery();
            listLayouts.type_x = 'Layout';
            queries.add(listLayouts);     
            if(!test.isRunningTest()){
                MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, 33);
                for(MetadataService.FileProperties fileProperty : fileProperties){
                    if(fileProperty.manageableState == 'unmanaged' || String.isBlank(fileProperty.namespacePrefix)){
                        string layoutName = fileProperty.fullName;
                        string nameSpace = fileProperty.namespacePrefix;
                        if(string.isNotBlank(layoutName) && (layoutName.startsWith(ProcessorUtil.CMT_ACCOUNT+'-') || layoutName.startsWith('PersonAccount-') || layoutName.startsWith(ProcessorUtil.CMT_CONTACT+'-'))){
                            layoutName = string.isNotBlank(nameSpace)? layoutName.substringBefore('-')+'-'+nameSpace+'__'+layoutName.substringAfter('-'): layoutName;
                            if(layoutName.startsWith(objectToUpdate+'-') || (objectToUpdate == ProcessorUtil.CMT_ACCOUNT && layoutName.startsWith('PersonAccount-'))){
                                MapofObjectandlistOfLayouts.get(objectToUpdate).add(layoutName);
                                MapofObjectandLayoutsCount.put(objectToUpdate, MapofObjectandLayoutsCount.get(objectToUpdate)+1);
                                if(MapofObjectandlistOfLayouts.get(objectToUpdate).size() == 10){
                                    MapofObjectandlistOfLayoutsList.get(objectToUpdate).add(MapofObjectandlistOfLayouts.get(objectToUpdate));
                                    MapofObjectandlistOfLayouts.put(objectToUpdate, new List<String>());
                                }
                            }
                        }
                    }
                }
                
                if(MapofObjectandlistOfLayouts.get(objectToUpdate).size() > 0 && MapofObjectandlistOfLayouts.get(objectToUpdate).size() < 10) MapofObjectandlistOfLayoutsList.get(objectToUpdate).add(MapofObjectandlistOfLayouts.get(objectToUpdate));
            }
            
            List<MetadataService.Layout> layouts = new List<MetadataService.Layout>();
            List<String> messages = new List<String>();
            
            system.debug('LayoutList ::: '+MapofObjectandlistOfLayoutsList.get(objectToUpdate));

            if(MapofObjectandlistOfLayoutsList.get(objectToUpdate).size() > 0){
                List<List<MetadataService.Layout>> allAccLayoutsToBeUpdated = new List<List<MetadataService.Layout>>(); 
                for(List<String> accLayouts: MapofObjectandlistOfLayoutsList.get(objectToUpdate)){
                    List<MetadataService.Layout> accLayoutsToBeUpdated = new List<MetadataService.Layout>();
                    if(accLayouts.size()>0){
                        for(MetadataService.Layout layout :  (List<MetadataService.Layout>) ((system.Test.isRunningTest())? new List<MetadataService.Layout>{new MetadataService.Layout()} :service.readMetadata('Layout',  accLayouts ).getRecords()) ){
                            if(layout.fullName == null) continue;
                            layout = modifyPageLayout(layout, objectToUpdate);
                            accLayoutsToBeUpdated.add(layout);
                        }
                        allAccLayoutsToBeUpdated.add(accLayoutsToBeUpdated);
                    }
                }
                Map<String,Object> varNameToValueMap = updateModifiedLayouts(allAccLayoutsToBeUpdated);
                MapofObjectandUpdatedLayoutBoolean.put(objectToUpdate, !Boolean.valueOf(varNameToValueMap.get('isLayoutUpdateFailed')));
                messages.addAll((List<String>)varNameToValueMap.get('exceptionMessages'));
            } 
            
            String updateSuccessObjects = '';
            String updateFailedObjects = '';
            for(String obj : MapofObjectandUpdatedLayoutBoolean.KeySet()){
                if(MapofObjectandUpdatedLayoutBoolean.get(obj))
                    updateSuccessObjects += obj+',';
                else
                    updateFailedObjects += obj+',';
            }
            if(String.isNotBlank(updateSuccessObjects)) updateSuccessObjects = updateSuccessObjects.removeEnd(',');
            if(String.isNotBlank(updateFailedObjects)) updateFailedObjects = updateFailedObjects.removeEnd(',');
            
            if(String.isBlank(updateSuccessObjects) && String.isNotBlank(updateFailedObjects)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, ' Breadwinner was unable to update your page layouts. Please try again later or update them manually.'));
                APICallHandler.userInteractionLogPush(FALSE, 'Page Layouts', 'ERROR', 'Breadwinner was unable to update your page layouts. Please try again later or update them manually. Exception: '+messages);
            }
            else if(String.isNotBlank(updateSuccessObjects) && String.isNotBlank(updateFailedObjects)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, ' Breadwinner was able to update the Layouts of '+updateSuccessObjects+'. But was unable to update the layouts of '+updateFailedObjects+'.'));
                APICallHandler.userInteractionLogPush(FALSE, 'Page Layouts', 'ERROR', 'Exception: Breadwinner was able to update the Layouts of '+updateSuccessObjects+'. But was unable to update the layouts of '+updateFailedObjects+'. Exception: '+messages);
            }
            else if(String.isNotBlank(updateSuccessObjects) && String.isBlank(updateFailedObjects)){
                Breadwinner_Settings__c updatebwSettings = BreadwinnerUtil.getBWSetting();
                updatebwSettings.Page_Layouts_Updated__c = true;
                SecurityUtil.dmlUpdate(updatebwSettings);
                bwsetting = getBreadwinnerSettingWrapper(updatebwSettings);
                
                String successCountMessage = '';
                for(String obj: MapofObjectandLayoutsCount.keySet()){
                    if(successCountMessage == '')successCountMessage = MapofObjectandLayoutsCount.get(obj)+' '+obj+' Layouts';
                    else{
                        successCountMessage = successCountMessage+' and '+MapofObjectandLayoutsCount.get(obj)+' '+obj+' Layouts';
                    }
                    system.debug('obj:: '+obj+' and successCountMessage '+successCountMessage);
                }
                APICallHandler.userInteractionLogPush(FALSE, 'Page Layouts', 'INFO', 'Breadwinner has succesfully updated '+successCountMessage);
            }
        }
        catch(Exception e ){
            system.debug('Exception ::: '+e.getMessage());
            ApexPages.addMessages(e);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, ' Exception: Breadwinner was unable to update your page layouts. Please try again later.'));
            APICallHandler.userInteractionLogPush(FALSE, 'Page Layouts', 'ERROR', 'Exception while updating page layouts ' +e.getMessage());
        }
        return null;
    }
    @TestVisible private MetadataService.Layout modifyPageLayout(MetadataService.Layout layout, String objectToUpdate){

       List<MetadataService.RelatedListItem> newRelatedLists = new List<MetadataService.RelatedListItem>();
       
        if(layout.relatedLists==null)
            
            layout.relatedLists = new List<MetadataService.RelatedListItem>();
        
        MetadataService.RelatedListItem newRelatedListItem = new MetadataService.RelatedListItem();
        newRelatedListItem.relatedList = namespacePrefix+'BWP_Customer__c.'+namespacePrefix+(objectToUpdate == ProcessorUtil.CMT_ACCOUNT ? 'Salesforce_Account__c' : 'Salesforce_Contact__c');
        newRelatedListItem.fields = new List<string>{'NAME',namespacePrefix+'Email__c',namespacePrefix+'Processor_Type__c',namespacePrefix+'Processor_Org_Name__c',namespacePrefix+'Livemode__c'};

        newRelatedLists.add(newRelatedListItem);
        
        MetadataService.RelatedListItem newRelatedListItem2 = new MetadataService.RelatedListItem();
        newRelatedListItem2.relatedList = namespacePrefix+'BWP_Payment_Method__c.'+namespacePrefix+(objectToUpdate == ProcessorUtil.CMT_ACCOUNT ? 'Salesforce_Account__c' : 'Salesforce_Contact__c');
        newRelatedListItem2.fields = new List<string>{'NAME',namespacePrefix+'Type__c',namespacePrefix+'Name_On_Card__c',namespacePrefix+'Card_Status__c',namespacePrefix+'Processor_Type__c'};
        newRelatedLists.add(newRelatedListItem2);

        MetadataService.RelatedListItem newRelatedListItem3 = new MetadataService.RelatedListItem();
        newRelatedListItem3.relatedList = namespacePrefix+'BWP_Transaction__c.'+namespacePrefix+(objectToUpdate == ProcessorUtil.CMT_ACCOUNT ? 'Salesforce_Account__c' : 'Salesforce_Contact__c');
        newRelatedListItem3.fields = new List<string>{'NAME',namespacePrefix+'Amount__c',namespacePrefix+'Currency__c',namespacePrefix+'Status__c',namespacePrefix+'Processor_Type__c'};
        newRelatedLists.add(newRelatedListItem3);

        layout.relatedLists = newRelatedLists;
        return layout;
    }

    public Map<String,Object> updateModifiedLayouts(List<List<MetadataService.Layout>> listOfLayoutList){
        Boolean isLayoutUpdateFailed = FALSE;
        List<String> exceptionMessages = new List<String>();
        Map<String,String> relatedListNameToFieldMap = new Map<String,String>();
        for(List<MetadataService.Layout> layoutsToBeUpdated : listOfLayoutList){
            List<MetadataService.Metadata> metadataList = (List<MetadataService.Metadata>) layoutsToBeUpdated;
            MetadataService.MetadataPort service = createService();
            if(metadataList.isEmpty()){
                isLayoutUpdateFailed = TRUE;
            }
            else{
                MetadataService.SaveResult layoutSaveResult = service.updateMetadata( metadataList )[0];
                if(layoutSaveResult==null || layoutSaveResult.success){
                    isLayoutUpdateFailed = FALSE;
                }
                else{
                    isLayoutUpdateFailed = TRUE;
                    system.debug('layoutSaveResult.errors :::::: '+layoutSaveResult.errors);
                    exceptionMessages.add((layoutSaveResult.errors.size()==1 ? 'Error ' : 'Errors ') + 'occurred processing component ' + layoutSaveResult.fullName + '.');
                    
                    for(MetadataService.Error error : layoutSaveResult.errors){
                        String errorMessage = error.message;
                        exceptionMessages.add( errorMessage + ' (' + error.statusCode + ').' + ( error.fields!=null && error.fields.size()>0 ? ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
                        if( error.statusCode.contains('FIELD_INTEGRITY_EXCEPTION') && errorMessage.containsIgnoreCase('related list:') && errorMessage.containsIgnoreCase('Invalid field:')){
                            String relatedListName = errorMessage.substringAfter('related list:');
                            String fieldName = errorMessage.substringBetween('Invalid field:',' in');
                            relatedListNameToFieldMap.put(relatedListName,fieldName);
                        }
                    }
                    break;
                }
            }
        }
        if(!exceptionMessages.isEmpty()){
            system.debug('Exception while updating page layouts ' +exceptionMessages);
            APICallHandler.userInteractionLogPush(TRUE, 'Page Layouts', 'ERROR', 'Exception while updating page layouts ' +exceptionMessages);
        }
        if(!relatedListNameToFieldMap.isEmpty()){
            listOfLayoutList = removeFLS_HiddenFieldsFromLayouts(listOfLayoutList, relatedListNameToFieldMap);
            relatedListNameToFieldMap = new Map<String,String>();
            return updateModifiedLayouts(listOfLayoutList);
        }
        
        return new Map<String,Object>{'isLayoutUpdateFailed' => isLayoutUpdateFailed, 'exceptionMessages' => exceptionMessages};
    }
    
    public List<List<MetadataService.Layout>> removeFLS_HiddenFieldsFromLayouts(List<List<MetadataService.Layout>> listOfLayoutList, Map<String,String> relatedListNameToFieldMap){
        for(List<MetadataService.Layout> layoutsToBeUpdated : listOfLayoutList){
            for(MetadataService.Layout layout: layoutsToBeUpdated){
                if(!relatedListNameToFieldMap.isEmpty()){
                    List<MetadataService.RelatedListItem> relatedlist = new List<MetadataService.RelatedListItem>();
                    relatedlist = layout.RelatedLists;
                    for(MetadataService.RelatedListItem item : relatedlist){
                        if(relatedListNameToFieldMap.containsKey(item.relatedList)){
                            Set<String> relatedListFieldSet = new Set<String>();
                            relatedListFieldSet.addAll(item.fields);
                            if(relatedListFieldSet.contains(relatedListNameToFieldMap.get(item.relatedList))){
                                relatedListFieldSet.remove(relatedListNameToFieldMap.get(item.relatedList));
                            }
                            List<String> relatedListFields = new List<String>();
                            relatedListFields.addAll(relatedListFieldSet);
                            item.fields = relatedListFields;
                        }
                    }
                }
            }
        }
        return listOfLayoutList;
    }
    
    // Description - Used to create Metadata service
    public static MetadataService.MetadataPort createService(){
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }


    public class Merchant{
        public List<SquareAccountInfo> merchant;
    }

    public static String convertToJSON(String stringToJSON){
        List<String> finalString = new List<String>();
        stringToJSON = stringToJSON.removeStart('{').removeEnd('}');
        List<String> keyValues = stringToJSON.split(',');
        for(Integer i=0;i<keyValues.size();i++){
            List<String> arrayValues = keyValues[i].split(':');
            String arrayString ='"'+arrayValues[0]+'"'+':'+'"'+arrayValues[1]+'"';
            finalString.add(arrayString);
        }
        String jsonDataString = '{'+finalString.toString().remove('(').remove(')')+'}';
        return jsonDataString;

    }
    //Square Account Info wrapper
    public class SquareAccountInfo {
        public String id;
        public String business_name;
        public String country; 
        public String default_currency; 
        public String status;
    }

    //Stripe Account info wrapper
    public class StripeTokenInfo {
        public String access_token;
        public Boolean livemode;
        public String refresh_token;
        public String token_type;
        public String stripe_publishable_key;
        public String stripe_user_id;
        public String scope;
    } 
    
    public class StripeAccountInfo {
        public String id;
        public String business_name;
        public String display_name; 
        public String default_currency; 
        public AccountSettings settings;
    }
    
    public class AccountSettings {
        public Dashboard dashboard; 
    }
    
    public class Dashboard {
        public String display_name;
    }

    public class wrapPermissionUsers {
        public String fullName				{get; set;}
        public String userName				{get; set;}
        public String profileName           {get; set;}
        public Boolean adminSelected		{get; set;}
        public Boolean operationsSelected	{get; set;}
        public Boolean standardSelected		{get; set;}
        public Boolean readOnlySelected		{get; set;}
        public wrapPermissionUsers(String fname, String uname, String profName, Boolean adminSel, Boolean opSel, Boolean stdSel, Boolean readSel){
            fullName = fname;
            userName = uname;
            profileName = profName;
            adminSelected = adminSel;
            operationsSelected = opSel;
            standardSelected = stdSel;
            readOnlySelected = readSel;
        }
    }
    
    @RemoteAction
    public static void pushInteractionLogOnTabEnter(String tabName) {
        try{
            APICallHandler.userInteractionLogPush(TRUE, 'tab view', tabName + ' Tab', 'Entered ' +tabName + ' Tab');
        }catch(exception e){system.debug(e);}
    }
    @remoteAction
    public static List<LogWrapper> getTableChartData(){
       List<LogWrapper> logList = new List<LogWrapper>();
       String endPointBaseURL = BreadwinnerUtil.getSupportEndpointBaseURL();
        //-- creating http request callout
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setHeader('Accept', 'application/json');
        APICallHandler.authorize(request);
        String requestUrl = endPointBaseURL+'/api/internal/error_logs/' + UserInfo.getOrganizationId() +'?app=Payments';
        request.setEndpoint(requestUrl);
        request.setTimeout(120000);
        string tableChartData = '';
        try{
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 200){
                system.debug(response.getBody());
                JSONParser parser = JSON.createParser(response.getBody());  
                while (parser.nextToken() != null){
                    while(parser.getCurrentToken() == JSONToken.START_OBJECT ){
                        LogWrapper logObj = (LogWrapper)parser.readValueAs(LogWrapper.class);
                        
                        Datetime timeStampDate = datetime.valueOfGmt(logObj.timestamp);
                        TimeZone tz = UserInfo.getTimeZone();
                        Long LogTime = timeStampDate.getTime();
                        Long CurrentTime= system.now().getTime();
                        Long milliseconds = CurrentTime - LogTime;
                        Long seconds = milliseconds / 1000;
                        long minutes = seconds / 60;
                        long hours = minutes / 60;
                        long days = hours / 24;
                        
                        logObj.timestamp = days>0? days+ (days==1? ' day ago': ' days ago'): hours>0? hours + (hours==1? ' hour ago': ' hours ago'): minutes + ' minutes ago';
                        logList.add(logObj);
                    }
                }
            }
            
        }
        catch(Exception e){
            system.debug(e.getMessage());
        }
        return logList;
    }
    
    public class LogWrapper{
        public string log_id            {get; set;}
        public string event_type        {get; set;}
        public string event_detail      {get; set;}
        public string additional_detail {get; set;}
        public string timestamp         {get; set;}
        public string package_version   {get; set;}
    }

    /* All Wrappers */
    public class BreadwinnerSetting {
        public Boolean Active                          {get; set;}
        public String Plan_Code                        {get; set;}
        public String Plan_Name                        {get; set;}
        public String Status                           {get; set;}
        public Datetime Date_of_Expiration             {get; set;}
        public Boolean multiProcessorEnabled           {get; set;}
        public Boolean activeMode                      {get; set;}
        public String endpointURL                      {get; set;}
        public Boolean pageLayoutsUpdated              {get; set;}

        public String overridePlanCode                {get; set;}
        public String overridePlanName                {get; set;}
        public DateTime overridePlanExpDateTime       {get; set;}
        public Boolean isOverridePlanExpired          {get; set;}
        public String overridePlanExpiresInDaysText   {get; set;}

    }
    //This method is used to convert a Breadwinner_Settings custom setting record into BreadwinnerSetting wrapper record
    @TestVisible
    private static BreadwinnerSetting getBreadwinnerSettingWrapper(Breadwinner_Settings__c bws) {
        bws = bws != null ? bws : new Breadwinner_Settings__c();
        BreadwinnerSetting bwSetting = new BreadwinnerSetting();
        try {
            bwSetting.Active = bws.Active__c;
            bwSetting.Plan_Code = bws.Plan_Code__c;
            bwSetting.Plan_Name = bws.Plan_Name__c;
            bwSetting.Status = bws.Status__c;
            bwSetting.Date_of_Expiration = bws.Date_of_Expiration__c;
            bwSetting.multiProcessorEnabled = bws.Multi_Processor_Enabled__c;
            bwSetting.activeMode = bws.Read_Only_Mode__c ? FALSE : TRUE;
            bwSetting.endpointURL = bws.Support_URL__c;
            bwSetting.pageLayoutsUpdated = bws.Page_Layouts_Updated__c;

            bwSetting.overridePlanCode = bws.Override_Plan_Code__c;
            bwSetting.overridePlanName = bws.Override_Plan_Name__c;
            bwSetting.overridePlanExpDateTime = bws.Override_Plan_Expiration_Date__c;
            
            bwSetting.isOverridePlanExpired = TRUE;
            if(bwSetting.overridePlanExpDateTime!=NULL){
                bwSetting.isOverridePlanExpired = (bwSetting.overridePlanExpDateTime<Datetime.now());
                Integer days = system.now().date().daysBetween(bwSetting.overridePlanExpDateTime.date());
                String expirationDatetext = 'expires ';
                switch on days {
                    when 0  {
                        expirationDatetext+='Today';
                    }
                    when 1  {
                        expirationDatetext+='Tomorrow';
                    }
                    when else {
                        expirationDatetext+='in '+days+' days';
                    }
                }
                
                bwSetting.overridePlanExpiresInDaysText = expirationDatetext;
            }
        }
        catch(Exception ex) {
            System.debug('Error occurred while parsing custom setting:AppConfig. '+ex.getStackTraceString());
            APICallHandler.userInteractionLogPush(TRUE, 'App Config', 'ERROR' , 'Error occured while parsing custom setting:AppConfig. '+ex.getStackTraceString());
        }
        return bwSetting;
    }

}