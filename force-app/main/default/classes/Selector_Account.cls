public with sharing class Selector_Account extends QuerySelector {

    // Core list of fields
    public static List<Schema.SObjectField> FIELD_LIST {
        get {
            if (FIELD_LIST == null) {
                FIELD_LIST = new List<Schema.SObjectField>{
                        Account.Id,
                        Account.Name,
                        Account.Phone,
                        Account.Description,
                        Account.BillingStreet,
                        Account.BillingCity,
                        Account.BillingState,
                        Account.BillingCountry,
                        Account.BillingPostalCode,
                        Account.OwnerId,
                        Account.Website
                };
            }
            return FIELD_LIST;
        }
        private set;
    }

    public Selector_Account() {
        super();
    }

    public override Schema.SObjectType getSObjectType() {
        return Account.SObjectType;
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

    /**
     * Returns a List of accounts
     * @param idSet set of Account Ids to be queried
     *
     * @return List<Account>
     */
    public List<Account> selectById(Set<String> idSet){
        QueryBuilder qb = newQueryBuilder();
        qb.setCondition('Id IN :idSet');

        return (List<Account>) Database.query(qb.toSOQL());
    }

    /**
     * Returns the list of Accounts and child Customers
     *
     * @param idSet set of Account Ids to be queried
     * @param childWhere optional where clause for the customer quiery
     *
     * @return List<Account>
     */
    public List<Account> selectById_WithCustomers(Set<String> idSet, String childWhere) {
        QueryBuilder accQB = newQueryBuilder();
        accQB.setCondition('Id IN :idSet');
        accQB.addChildQuery(new Selector_BWP_Customer().selectAsChildQueryWhere(childWhere));

        return (List<Account>) Database.query(accQB.toSOQL());
    }

}