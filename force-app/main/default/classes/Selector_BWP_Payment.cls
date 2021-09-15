/**
 * Created by Mike Honekamp on 10/6/2020.
 */

public with sharing class Selector_BWP_Payment extends QuerySelector {

    // Core list of fields
    public static List<Schema.SObjectField> FIELD_LIST {
        get {
            if (FIELD_LIST == null) {
                FIELD_LIST = BWP_Payment__c.SObjectType.getDescribe().fields.getMap().values();
            }
            return FIELD_LIST;
        }
        private set;
    }

    public Selector_BWP_Payment() {
        this(true, true, true);
    }

    public Selector_BWP_Payment(Boolean enforceRead, Boolean enforceFLS, Boolean throwFLSException) {
        super(enforceRead, enforceFLS, throwFLSException);
    }

    public override Schema.SObjectType getSObjectType() {
        return BWP_Payment__c.SObjectType;
    }

    private List<Schema.SObjectField> sObjectFieldList;
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return sObjectFieldList != null ? sObjectFieldList : FIELD_LIST;
    }
    /**
     * Allows the calling class to override the default FIELD_LIST
     * @param fieldList list of field that will be passed into the query
     */
    public void setSObjectFieldList(List<Schema.SObjectField> fieldList){
        this.sObjectFieldList = fieldList;
    }

    private String orderBy;
    public override String getOrderBy() {
        return String.isBlank(orderBy) ? 'Name ASC' : orderBy;
    }

    public List<BWP_Payment__c> selectById(Set<String> idSet){
        QueryBuilder qb = newQueryBuilder();
        qb.setCondition('Id IN :idSet');

        return (List<BWP_Payment__c>) Database.query(qb.toSOQL());
    }

    public List<BWP_Payment__c> selectByProcessorId(Set<String> idSet, List<String> relatedFields){
        QueryBuilder qb = newQueryBuilderWithRelatedFields(relatedFields);
        qb.setCondition('Processor_Id__c IN :idSet');
        return (List<BWP_Payment__c>) Database.query(qb.toSOQL());
    }

    public List<BWP_Payment__c> selectByProcessorOrgId(Set<String> idSet, Integer lim) {
        QueryBuilder qb = newQueryBuilder();
        qb.setCondition('Processor_Org_Id__c IN :idSet');
        if (lim != null) {
            qb.setLimit(lim);
        }
        return (List<BWP_Payment__c>) Database.query(qb.toSOQL());
    }

    public List<BWP_Payment__c> selectByCustomerId(Set<String> idSet, List<String> relatedFields, Integer lim){
        QueryBuilder qb = newQueryBuilderWithRelatedFields(relatedFields);
        qb.setCondition('Customer__c IN :idSet');
        if (lim != null) {
            qb.setLimit(lim);
        }
        return (List<BWP_Payment__c>) Database.query(qb.toSOQL());
    }

    public List<BWP_Payment__c> selectBySourceId(Set<String> idSet, Integer lim){
        QueryBuilder qb = newQueryBuilder();
        qb.setCondition('Source__c IN :idSet');
        if (lim != null) {
            qb.setLimit(lim);
        }
        return (List<BWP_Payment__c>) Database.query(qb.toSOQL());
    }

    public List<BWP_Payment__c> selectWithLimit(Integer lim){
        QueryBuilder qb = newQueryBuilder();
        if (lim != null){
            qb.setLimit(lim);
        }
        return (List<BWP_Payment__c>) Database.query(qb.toSOQL());
    }

    public Integer selectCount(String whereString, Integer lim){
        // For the count queries just return zero instead of throwing an exception
        if(!Schema.SObjectType.BWP_Payment__c.isAccessible()){
            return 0;
        }
        String qry = 'SELECT COUNT() FROM BWP_Payment__c';
        if (String.isNotBlank(whereString)){
            qry += ' WHERE ' + whereString;
        }
        if (lim != null){
            qry += ' LIMIT ' + String.valueOf(lim);
        }
        System.debug('qry: ' + qry);
        return Database.countQuery(qry);
    }

}