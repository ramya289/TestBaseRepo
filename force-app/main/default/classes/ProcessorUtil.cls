@namespaceAccessible
public with sharing class ProcessorUtil {

    // Processor Account Types
    public static final String PAT_BRAINTREE = 'Braintree';
    public static final String PAT_PAYPAL = 'PayPal';
    public static final String PAT_SQUARE = 'Square';
    @namespaceAccessible public static final String PAT_STRIPE = 'Stripe';
    public static final String PAT_AUTHORIZE_NET = 'Authorize.Net';

    // API Request Attributes
    public static final String API_ACTION = 'Action';
    public static final String API_PROCESSOR_ID  = 'ProcessorId';
    public static final String API_REQUEST_JSON = 'RequestJSON';
    public static final String API_TIMEOUT = 'Timeout';
    public static final String API_VERSION = 'Version';

    // Response Attributes
    public static final String RESP_API_ERRORS = 'apiErrors';
    public static final String RESP_PROC_ERRORS = 'processingErrors';
    public static final String RESP_VAL_REQ = 'validRequest';
    public static final String RESP_STATUS = 'status';
    public static final String RESP_JSON = 'responseJSON';
    public static final String CHECKOUT_RESP = 'checkoutResponse';
    public static final String CUST_RESP = 'customerResponse';
    public static final String PAYMETHOD_RESP = 'payMethodResponse';
    public static final String PAYMENT_RESP = 'paymentResponse';
    
    //Versions - not really needed right now
    public static final String VER_1 = '1.0';

    // Actions
    public static final String ACT_CHARGE_PROCESSOR = 'ChargeProcessor';
    public static final String ACT_CREATE_BANK_TOKEN = 'CreateBankToken';
    public static final String ACT_CREATE_CARD_TOKEN = 'CreateCardToken';
    public static final String ACT_CREATE_CUSTOMER = 'CreateCustomer';
    public static final String ACT_FETCH_CUSTOMERS_ALL = 'FetchCustomers';
    public static final String ACT_FETCH_TRANSACTIONS_ALL = 'FetchTransactions'; 
    public static final String ACT_FETCH_CUSTOMERS_RECENT = 'FetchRecentCustomers';
    public static final String ACT_FETCH_TRANSACTIONS_RECENT = 'FetchRecentTransactions';
    public static final String ACT_UPDATE_CUSTOMER = 'UpdateCustomer';
    public static final String ACT_VERIFY_BANKACCOUNT = 'VerifyBankAccount';
    public static final String ACT_CREATE_CHECKOUT = 'CreateCheckoutURL';


    public static final String PM_CARD = 'Card';
    public static final String PM_BANK = 'BankAccount';
    public static final String PM_ACH_CREDIT = 'ACHCreditTransfer';

    // Charge Status
    public static final String CHARGE_SUCCEEDED = 'SUCCEEDED';
    public static final String CHARGE_FAILED = 'FAILED';
    public static final String CHARGE_PENDING = 'PENDING';
    public static final String CHARGE_CANCELED = 'CANCELED';
    public static final String CHARGE_VOIDED = 'VOIDED'; 
    public static final String CHARGE_APPROVED = 'APPROVED';
    public static final String CHARGE_REJECTED = 'REJECTED';
    public static final String CHARGE_DECLINED = 'DECLINED';
    public static final String CHARGE_EXCEPTION = 'PAYMENTEXCEPTION';
    
    // Redirect Url
    
    public static final String REDIRECT_URL  = 'https://breadwinner.com/payments-salesforce/processoroauth';
    public static List<String> processorsThatAllowPaymentMethods = new List<String>{PAT_STRIPE, PAT_BRAINTREE, PAT_SQUARE};
    public static List<String> processorsThatAllowPayments = new List<String>{PAT_STRIPE, PAT_BRAINTREE, PAT_SQUARE};
	public static List<String> processorsWithMultiplePmTypes = new List<String>{PAT_STRIPE, PAT_BRAINTREE};
    public static List<String> processorsThatAllowCustomerUpdate = new List<String>{PAT_STRIPE, PAT_BRAINTREE, PAT_SQUARE};
        
    // Customer Match Type
    public static final String CMT_ACCOUNT = 'Account';
    public static final String CMT_CONTACT = 'Contact';

    // Customer Match Options
    public static final String CMO_CREATE_NEW = 'createNew';
    public static final String CMO_SUGGESTED_MATCH = 'suggestedMatch';  
    public static final String CMO_MANUAL_MATCH = 'manualMatch';
    public static final String CMO_DO_NOT_IMPORT = 'doNotImport';
        
    public class ResponseObject {
        public String status;
        public String responseJSON;
        public String checkoutResponseJSON;
        public List<CustomerWrapper> customerList;
        public List<PaymentMethodWrapper> paymentMethodList;
        public List<TransactionWrapper> transactionList;
        public List<Error> errors = new List<Error>();
    }

    public class Error {
        public String message;
        public String code;
        public String detail;

        public Error() {}

        public Error(String codeValue, String messageValue) {
            code = codeValue;
            message = messageValue;
        }
    }

    public class Shipping {
        public Address address;
        public String name;
        public String phone;
    }

    public class Address {
        public String line1;
        public String line2;
        public String city;
        public String state;
        public String country;
        public String postal_code;
    }

    public static Boolean arePersonAccountsEnabled(){
        return Schema.SObjectType.Account.fields.getMap().containsKey( 'isPersonAccount' );
    }

    public static Boolean areRecordTypesEnabled(){
        return Account.getSObjectType().getDescribe().getRecordTypeInfos().size() > 1;
    }

    public static String getDefaultAccountRecordType(){
        Schema.DescribeSObjectResult dsr = Account.SObjectType.getDescribe();
        Schema.RecordTypeInfo defaultRecordType;
        String recordTypeId = '';
        for(Schema.RecordTypeInfo rti : dsr.getRecordTypeInfos()) {
            if(rti.isDefaultRecordTypeMapping() && rti.isAvailable()) {
                defaultRecordType = rti;
                recordTypeId = rti.getRecordTypeId();
                break;
            }
        }
        return recordTypeId;
    }

    public static Boolean isDefaultRecordTypeIsMaster(){
        Schema.DescribeSObjectResult dsr = Account.SObjectType.getDescribe();
        Schema.RecordTypeInfo defaultRecordType;
        Boolean defaultRecordTypeisMaster = false;
        for(Schema.RecordTypeInfo rti : dsr.getRecordTypeInfos()) {
            if(rti.isDefaultRecordTypeMapping() && rti.isAvailable() && rti.isMaster()) {
                defaultRecordType = rti;
                defaultRecordTypeisMaster = rti.isMaster();
                break;
            }
        }
        return defaultRecordTypeisMaster;
    }

    public static Boolean areStateAndCountryPicklistsEnabled(){
        return Account.getSObjectType().getDescribe().fields.getMap().containsKey('billingcountrycode');
    }

    public static List<Account> getAccountsForCustomerSync(Set<String> customerNameSet, Set<String> customerEmailSet){
        QueryBuilder accQB = new QueryBuilder(Account.SObjectType,true,true,true);
        List<SObjectField> FieldsList = new List<SObjectField>{Account.Id, Account.Name};
        accQB.setLimit(20000);
        if(arePersonAccountsEnabled()){
            FieldsList.add(Account.SObjectType.getDescribe().fields.getMap().get('PersonEmail'));
            accQB.setCondition('Name LIKE: customerNameSet OR PersonEmail IN: customerEmailSet');
        } else {
            accQB.setCondition('Name LIKE: customerNameSet');
        }
        accQB.addSObjectFields(FieldsList);
        return (List<Account>) Database.query(accQB.toSOQL());
    }

    public static List<Contact> getContactsForCustomerSync(Set<String> customerNameSet, Set<String> customerEmailSet){
        QueryBuilder conQB = new QueryBuilder(Contact.SObjectType,true,true,true);
        conQB.addSObjectFields(new List<SObjectField>{Contact.Id, Contact.Name, Contact.Email});
        conQB.setLimit(20000);
        conQB.setCondition('Name LIKE: customerNameSet OR Email LIKE: customerEmailSet');
        return (List<Contact>) Database.query(conQB.toSOQL());
    }

    public static void getExistingRecordsSet(String name, string email, Set<String> customerNameSet, Set<String> customerEmailSet){
        if(String.isNotBlank(name)){
            String customerName = name.toLowerCase().replace('\\', '%'); 
            Set<String> relatedNameSet = BreadwinnerUtil.getSimilarAccountNameSet(customerName);
            customerNameSet.addAll(relatedNameSet);
        }
      	if(String.isNotBlank(email)){
            String customerEmail = email.toLowerCase().replace('\\', '%');
            Set<String> relatedNameSet = BreadwinnerUtil.getSimilarAccountNameSet(customerEmail);
            customerNameSet.addAll(relatedNameSet);
            customerEmailSet.add(customerEmail);
        }
        if(ProcessorUtil.arePersonAccountsEnabled() && String.isNotBlank(email)){
            String custEmail = email.toLowerCase().replace('\\', '%');
            customerEmailSet.add(custEmail);
        }
    }

    public static Map<Id,Boolean> getIsPersonRTMap() {
        return new Map<Id, Boolean>();
    }

    private static Set<Id> isPersonRTSet {
        get {
            if (isPersonRTSet == null){
                isPersonRTSet = new Set<Id>{};
                for(SObject rt: Database.query('SELECT Id, IsPersonType FROM RecordType WHERE SobjectType=\'Account\'')){
                    Boolean isPersonRT = Boolean.valueOf(rt.get('IsPersonType'));
                    if (isPersonRT){
                        isPersonRTSet.add(rt.Id);
                    }
                }
            }
            return isPersonRTSet;
        }
        set;
    }

    public static Boolean getIsPersonRecordType(Id recordTypeId){
        return arePersonAccountsEnabled() && isPersonRTSet.contains(recordTypeId);
    }

    public static Boolean isValidResponse(Map<String, Object> response){
        return response.get(RESP_PROC_ERRORS) == null && response.get(RESP_API_ERRORS) == null && response.get(RESP_JSON) != null;
    }

    /**
     * Removes PaymentMethods that no long belong to an existing customer.
     * @param custIdSet Set of customers that were updated
     * @param existingPmIdSet Set of existing PaymentMethods prior to the add/update process
     * @param processorId Id of the payment process we're working on (Stripe, Braintree, ...)
     */
    public static void removePaymentsThatDoNotBelong(Set<Id> custIdSet, Set<String> existingPmIdSet, String processorId ){
        if (custIdSet.size() > 0 && existingPmIdSet.size() > 0) {
            QueryBuilder qb = new QueryBuilder(BWP_Payment_Method__c.SObjectType, true, true, true);
            qb.addSObjectFields(new List<SObjectField>{BWP_Payment_Method__c.Id});

            qb.setCondition('Customer__c IN: custIdSet');
            qb.setCondition('Processor_Id__c NOT IN: existingPmIdSet');
            qb.setCondition('Processor_Org_Id__c =: processorId');

            qb.setLimit(10000);

            List<BWP_Payment_Method__c> pmList = Database.query(qb.toSOQL());
            System.debug('pmList: ' + pmList.size());
            SecurityUtil.databaseDelete(pmList);
        }
    }

    public static List<String> checkForUpsertErrors(Database.UpsertResult[] upsertResultList) {
        List<String> errorList = new List<String>();
        for (Database.UpsertResult ur : upsertResultList){
            if (! ur.isSuccess()){
                for (Database.Error error : ur.getErrors()){
                    errorList.add(error.getStatusCode() + ': ' + error.getMessage());
                }
            }
        }
        return errorList;
    }

    public static Map<String, String> getCardTypeName(){
        Map<String, String> mapOfCards = new Map<String, String>();
        mapOfCards.put('VISA', 'Visa');
        mapOfCards.put('MASTERCARD', 'MasterCard');
        mapOfCards.put('JCB', 'JCB');
        mapOfCards.put('INTERNATIONAL_MAESTRO', 'International Maestro');
        mapOfCards.put('DISCOVER', 'Discover');
        mapOfCards.put('AMERICAN_EXPRESS', 'American Express');
        mapOfCards.put('UNIONPAY', 'UnionPay');

        return mapOfCards;
    }

    public static string getLogAction(String currentRunningContext, String currentAction){
        return (currentRunningContext == BreadwinnerUtil.CNTX_HIST_SYNC ? 'Historical Sync' : (currentRunningContext == BreadwinnerUtil.CNTX_HOUR_SYNC ? 'Hourly Sync' : currentAction));
    }

    /**
     *     Wrapper class that is sent back from the Global API so we are consistent across all processors
     *     This should generally match the BW_Customer__c object fields with the underscores removed
     */
    public class CustomerWrapper{
        public String billingCity;
        public String billingCountry;
        public String billingPostalCode;
        public String billingState;
        public String billingStreetAddress1;
        public String billingStreetAddress2;
        public String company;
        public Datetime createdDateInProcessor;
        public String createdVia;
        public String custCurrency;
        public Decimal customerAccountBalance;
        public String customerId;
        public String customerName;
        public String customerPhone;
        public String defaultSource;
        public Boolean delinquent;
        public String description;
        public String email;
        public String firstName;
        public Boolean hasSuccessfulPayments;
        public String invoicePrefix;
        public Boolean liveMode;
        public String language;
        public String lastName;
        public Boolean noAssociatedSFAccount;
        public Boolean noAssociatedSFContact;
        public String processorCustomerId;
        public String processorOrgId;
        public String processorOrgName;
        public String processorType;
        public String referenceId;
        public Id salesforceAccount;
        public Id salesforceContact;
        public Id salesforceId;  // ID from the BWP_Customer record.  'Id' is too generic
        public String salesforceName;  // Name field from the BWP_Customer record.  'Name' is too generic
        public String shippingAddressee;
        public String shippingCity;
        public String shippingCountry;
        public String shippingPhone;
        public String shippingPostalCode;
        public String shippingState;
        public String shippingStreetAddress1;
        public String shippingStreetAddress2;
        public String taxExempt;
        public String taxId;
        public String taxType;

        //Non salesforce fields
        public String errorMessage;

        public CustomerWrapper(BWP_Customer__c cust) {
            billingCity = cust.Billing_City__c;
            billingCountry = cust.Billing_Country__c;
            billingPostalCode = cust.Billing_Postal_Code__c;
            billingState = cust.Billing_State__c;
            billingStreetAddress1 = cust.Billing_Street_Address_1__c;
            billingStreetAddress2 = cust.Billing_Street_Address_2__c;
            company = cust.Company__c;
            createdDateInProcessor = cust.Created_Date_in_Processor__c;
            createdVia = cust.Created_Via__c;
            custCurrency = cust.Currency__c;
            customerAccountBalance = cust.Customer_Account_Balance__c;
            customerId = cust.Customer_ID__c;
            customerName = cust.Customer_Name__c;
            customerPhone = cust.Customer_Phone__c;
            defaultSource = cust.Default_Source__c;
            delinquent = cust.Delinquent__c;
            description = cust.Description__c;
            email = cust.Email__c;
            firstName = cust.First_Name__c;
            hasSuccessfulPayments = cust.Has_Successful_Payments__c;
            invoicePrefix = cust.Invoice_Prefix__c;
            liveMode = cust.Livemode__c;
            language = cust.Language__c;
            lastName = cust.Last_Name__c;
            noAssociatedSFAccount = cust.No_Associated_SF_Account__c;
            noAssociatedSFContact = cust.No_Associated_SF_Contact__c;
            processorCustomerId = cust.Processor_Customer_Id__c;
            processorOrgId = cust.Processor_Org_Id__c;
            processorOrgName = cust.Processor_Type__c;
            processorType = cust.Processor_Type__c;
            referenceId = cust.Reference_Id__c;
            salesforceAccount = cust.Salesforce_Account__c;
            salesforceContact = cust.Salesforce_Contact__c;
            salesforceId = cust.Id;  // ID from the BWP_Customer record.  'Id' is too generic
            salesforceName = cust.Name;  // Name field from the BWP_Customer record.  'Name' is too generic
            shippingAddressee = cust.Shipping_Addressee__c;
            shippingCity = cust.Shipping_City__c;
            shippingCountry = cust.Shipping_Country__c;
            shippingPhone = cust.Shipping_Phone__c;
            shippingPostalCode = cust.Shipping_Postal_Code__c;
            shippingState = cust.Shipping_State__c;
            shippingStreetAddress1 = cust.Shipping_Street_Address_1__c;
            shippingStreetAddress2 = cust.Shipping_Street_Address_2__c;
            taxExempt = cust.Tax_Exempt__c;
            taxId = cust.Tax_Id__c;
            taxType = cust.Tax_Type__c;
        }
    }
    
    public class PaymentMethodWrapper{
        public Id salesforceAccountId;
        public Decimal amount;
        public String bankAccountHolderName;
        public String accountNumber;
        public String bankName;
        public String routingNumber;
        public String cardBrand;
        public String city;
        public String clientSecret;
        public Id salesforceContact;
        public String createdVia;
        public String customerCurrency;
        public Id salesforceCustomerId;
        public String exiryMonth;
        public String expiryYear;
        public String fingerprint;
        public Boolean livemode;
        public String last4digits;
        public String nameOnCard;
        public String processorCustomerId;
        public String processorId;
        public String processorOrgId;
        public String processorType;
        public String state;
        public String cardStatus;
        public String addressLine1;
        public String addressLine2;
        public String SWIFTCode;
        public String PaymentMethodType;
        public String zipCode;
        public Id salesforceId;        
        public String errorMessage;
        
        public PaymentMethodWrapper(BWP_Payment_Method__c pm) {
            salesforceId = pm.Id;
            salesforceAccountId = pm.Salesforce_Account__c;
            amount = pm.Amount__c;
            bankAccountHolderName = pm.Bank_Account_Holder_Name__c;
            accountNumber = pm.Account_Number__c;
            bankName = pm.Bank_Name__c;
            routingNumber = pm.Routing_Number__c;
            cardBrand = pm.Card_Brand__c;
            city = pm.City__c;
            clientSecret = pm.Client_Secret__c;
            salesforceContact = pm.Salesforce_Contact__c;
            createdVia = pm.Created_Via__c;
            customerCurrency = pm.Currency__c;
            salesforceCustomerId = pm.Customer__c;
            exiryMonth = pm.Expiry_Month__c;
            expiryYear = pm.Expiry_Year__c;
            fingerprint = pm.Fingerprint__c;
            livemode = pm.Livemode__c;
            last4digits = pm.Last_4_digits__c;
            nameOnCard = pm.Name_On_Card__c;
            processorCustomerId = pm.Processor_Customer_Id__c;
            processorId = pm.Processor_Id__c;
            processorOrgId = pm.Processor_Org_Id__c;
            processorType = pm.Processor_Type__c;
            state = pm.State__c;
            cardStatus = pm.Card_Status__c;
            addressLine1 = pm.Address_Line1__c;
            addressLine2 = pm.Address_Line2__c;
            SWIFTCode = pm.SWIFT_Code__c;
            PaymentMethodType = pm.Type__c;
            zipCode = pm.Zip_Code__c;
        }
    }

    public class TransactionWrapper{
        public Id salesforceAccountId;
        public Decimal amount;
        public Decimal amountRefunded;
        public Decimal applicationFee;
        public String billingCity;
        public String billingCountry;
        public String billingPostalCode;
        public String billingStreetAddress1;
        public String billingStreetAddress2;
        public String chargeStatus;
        public Id contact;
        public DateTime createdDateInProcessor;
        public String createdVia;
        public String chargeCurrency;
        public Id customer;
        public String description;
        public Boolean captured;
        public String locationId;
        public Id Source; // payment method
        public String status;
        public Decimal processingFee;
        public String processorCustomerId;
        public String processorId;
        public String processorOrgId;
        public String processorType;
        public String receiptEmail;
		public String receiptNumber;
        public String receiptUrl;
		public String staffName;
		public Id salesforceId;        
        public String errorMessage;
        
        public TransactionWrapper(BWP_Transaction__c pay){
            salesforceId = pay.Id;
            salesforceAccountId = pay.Salesforce_Account__c;
            amount = pay.Amount__c;
            amountRefunded = pay.Amount_Refunded__c;
            applicationFee = pay.Application_Fee__c;
            billingCity = pay.Billing_City__c;
            billingCountry = pay.Billing_Country__c;
            billingPostalCode = pay.Billing_Postal_Code__c;
            billingStreetAddress1 = pay.Billing_Street_Address_1__c;
            billingStreetAddress2 = pay.Billing_Street_Address_2__c;
            chargeStatus = pay.Charge_Status__c;
            contact = pay.Salesforce_Contact__c;
            createdDateInProcessor = pay.Created_Date_in_Processor__c;
            createdVia = pay.Created_Via__c;
            chargeCurrency = pay.Currency__c;
            customer = pay.Customer__c;
            description = pay.Description__c;
            captured = pay.Captured__c;
            locationId = pay.Location_Id__c;
            Source = pay.Source__c; // payment method
            status = pay.Status__c;
            processingFee = pay.Processing_Fee__c;
            processorCustomerId = pay.Processor_Customer_Id__c;
            processorId = pay.Processor_Id__c;
            processorOrgId = pay.Processor_Org_Id__c;
            processorType = pay.Processor_Type__c;
            receiptEmail = pay.Receipt_Email__c;
            receiptNumber = pay.Receipt_Number__c;
            receiptUrl = pay.Receipt_URL__c;
            staffName = pay.Staff_Name__c;
        }
    }

    public class Checkout{
        public String location_id;
        public String customer_id;
        public String reference_id;
        public Boolean ask_for_shipping_address;
        public String merchant_support_email;
        public String buyer_email;
        public Customer.SquareAddress shipping;
        public List<CheckoutLineItem> line_items;
    }
    public class CheckoutLineItem{
        public String quantity;
        public Decimal unit_price;
        public String item_currency;
        public String name;
        public String note;
    }
    
    public static List<CustomerWrapper> upsertAndReturnCustomerList(List<BWP_customer__c> custList, Set<Id> updatedCustomerIdSet, Boolean addToSalesforce){
        List<CustomerWrapper> customerList = new List<CustomerWrapper>();
        // If we're not inserting/updating the record to salesforce then we are done.
       // Send back the properly formatted list of customers
        if(!addToSalesforce){
            for (BWP_Customer__c bwpCust : custList){
                customerList.add(new ProcessorUtil.CustomerWrapper(bwpCust));
            }
            return customerList;
        }
        
        Database.UpsertResult[] results = SecurityUtil.databaseUpsert(custList, BWP_Customer__c.Processor_Customer_Id__c);
        if (results != null){
            // We have a map of customers keyed by the processor cust Id.
            // What we need, to get the records out of the result, is customers keyed by the SF Id
            Map<String,BWP_Customer__c> updatedCustomerMapBySfId = new Map<String,BWP_Customer__c>();
            for (BWP_Customer__c bwpCust : custList){
                updatedCustomerMapBySfId.put(bwpCust.Id, bwpCust);
            }
            for (Database.UpsertResult result : results) {
                ProcessorUtil.CustomerWrapper wrapper = new ProcessorUtil.CustomerWrapper(updatedCustomerMapBySfId.get(result.getId()));
                if (result.isSuccess()) {
                    updatedCustomerIdSet.add(result.getId());
                } else {
                    wrapper.errorMessage = result.getErrors()[0].getMessage();
                }
                customerList.add(wrapper);
            }
        }
        return customerList;
    }
    
    public static List<PaymentMethodWrapper> upsertAndReturnPaymentMethodList(List<BWP_Payment_Method__c> payMethodList){
        List<PaymentMethodWrapper> paymentMethodList = new List<PaymentMethodWrapper>();
        Database.UpsertResult[] results = SecurityUtil.databaseUpsert(payMethodList,BWP_Payment_Method__c.Processor_Id__c);
        if (results != null){
            Map<String,BWP_Payment_Method__c> updatedPayMethodMapBySfId = new Map<String,BWP_Payment_Method__c>();
            for(BWP_Payment_Method__c bwpPM : payMethodList){
                updatedPayMethodMapBySfId.put(bwpPM.Id, bwpPM);
            }
            for (Database.UpsertResult result : results) {
                ProcessorUtil.PaymentMethodWrapper wrapper = new ProcessorUtil.PaymentMethodWrapper(updatedPayMethodMapBySfId.get(result.getId()));
                if (!result.isSuccess()) {
                    wrapper.errorMessage = result.getErrors()[0].getMessage();
                }
                paymentMethodList.add(wrapper);
            }
        }
        return paymentMethodList;
    }
    
    public static List<TransactionWrapper> upsertAndReturnPaymentList(List<BWP_Transaction__c> transactionList){
        List<TransactionWrapper> payList = new List<TransactionWrapper>();
        Database.UpsertResult[] results = SecurityUtil.databaseUpsert(transactionList, BWP_Transaction__c.Processor_Id__c);
        
        Map<String,BWP_Transaction__c> updatedMapBySfId = new Map<String,BWP_Transaction__c>();
        for (BWP_Transaction__c trxn : transactionList){
            updatedMapBySfId.put(trxn.Id, trxn);
        }
        
        if(results != null){
            for (Database.UpsertResult result : results) {
                ProcessorUtil.TransactionWrapper wrapper = new ProcessorUtil.TransactionWrapper(updatedMapBySfId.get(result.getId()));
                if (!result.isSuccess()) {
                    wrapper.errorMessage = result.getErrors()[0].getMessage();
                }
                payList.add(wrapper);
            }
        }
        return payList;
    }
    
    Public static void updateSuccessfulPaymentsCustomers(Boolean doNotImportCustomerAndFailedPayments, Set<String> successfulPaymentsCustomerIdSet){
        Selector_BWP_Customer selectorCustomer = new Selector_BWP_Customer();
        List<BWP_Customer__c> customerUpdateList = new List<BWP_Customer__c>();
        for (BWP_Customer__c successfulPaymentscustomer : selectorCustomer.selectById(successfulPaymentsCustomerIdSet)) {
            successfulPaymentscustomer.Has_Successful_Payments__c = TRUE;
            customerUpdateList.add(successfulPaymentscustomer);
        }
        SecurityUtil.dmlUpdate(customerUpdateList);
    }
    
    public class InvalidAccountConfigurationException extends Exception{}
    @namespaceAccessible public class ConnectionException extends Exception{}
}