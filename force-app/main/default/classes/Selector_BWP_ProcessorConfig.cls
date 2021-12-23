@namespaceAccessible
public with sharing class Selector_BWP_ProcessorConfig extends QuerySelector {
    @namespaceAccessible
    public static List<Schema.SObjectField> FIELD_LIST {
        get {
            if (FIELD_LIST == null) {
                // We are getting a strange QueryBuilder : Access Denied: DML_READ on the LastViewedDate
                // if we do this FIELD_LIST = BWP_Payment_Method__c.SObjectType.getDescribe().fields.getMap().values();
                // But only when it's installed as a package
                // Instead of wasting more time I decide to just hardcode the list
                FIELD_LIST = new List<Schema.SObjectField>{
                    BWP_Processor_Config__c.Id,
                    BWP_Processor_Config__c.Name,
                    BWP_Processor_Config__c.Access_Token__c,
                    BWP_Processor_Config__c.Refresh_Token__c,
                    BWP_Processor_Config__c.Access_Token_Expiry_Date__c,
                    BWP_Processor_Config__c.Account_Name__c,
                    BWP_Processor_Config__c.Card_Creation_Key__c,
                    BWP_Processor_Config__c.Customer_Match_Config__c,
                    BWP_Processor_Config__c.Customer_Match_Type__c,
                    BWP_Processor_Config__c.Customer_Sync_Config__c,
                    BWP_Processor_Config__c.Default_Currency__c,
                    BWP_Processor_Config__c.End_Date__c,
                    BWP_Processor_Config__c.Historical_Customer_Sync_Last_Run__c,
                    BWP_Processor_Config__c.Historical_Payment_Sync_Last_Run__c,
                    BWP_Processor_Config__c.Hourly_Customer_Sync_Last_Run__c,
                    BWP_Processor_Config__c.Hourly_Payment_Sync_Last_Run__c,
                    BWP_Processor_Config__c.Is_Customer_Match_Completed__c,
                    BWP_Processor_Config__c.Last_Customer_Id__c,
                    BWP_Processor_Config__c.Live_Mode__c,
                    BWP_Processor_Config__c.Need_To_Reconnect__c,
                    BWP_Processor_Config__c.Payment_Processor_Type__c,
                    BWP_Processor_Config__c.Provider_ID__c,
                    BWP_Processor_Config__c.Scope__c,
                    BWP_Processor_Config__c.Start_Date__c
                };
            }
            return FIELD_LIST;
        }
        private set;
    }

    @namespaceAccessible
    public Selector_BWP_ProcessorConfig() {
        super();
    }

    @namespaceAccessible
    public override Schema.SObjectType getSObjectType() {
        return BWP_Processor_Config__c.SObjectType;
    }
    
    private List<Schema.SObjectField> sObjectFieldList;
    @namespaceAccessible
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return sObjectFieldList != null ? sObjectFieldList : FIELD_LIST;
    }
    /**
    * Allows the calling class to override the default FIELD_LIST
    * @param fieldList list of field that will be passed into the query
    */
    @namespaceAccessible
    public void setSObjectFieldList(List<Schema.SObjectField> fieldList){
        this.sObjectFieldList = fieldList;
    }
    
    private String orderBy;
    @namespaceAccessible
    public override String getOrderBy() {
        return String.isBlank(orderBy) ? 'DeveloperName ASC' : orderBy;
    }
    
    @namespaceAccessible
    public List<BWP_Processor_Config__c> getAllAppConfig(){
        QueryBuilder qb = newQueryBuilder();
        return (List<BWP_Processor_Config__c>) Database.query(qb.toSOQL());
    }
    
    @namespaceAccessible
    public List<BWP_Processor_Config__c> selectByProcessorId(Set<String> idSet){
        QueryBuilder qb = newQueryBuilder();
        qb.setCondition('Provider_ID__c IN :idSet');
        return (List<BWP_Processor_Config__c>) Database.query(qb.toSOQL());
    }
    
}