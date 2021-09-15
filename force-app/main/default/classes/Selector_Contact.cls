public with sharing class Selector_Contact extends QuerySelector {

    // Core list of fields
    public static List<Schema.SObjectField> FIELD_LIST {
        get {
            // We are listing fields specifically as we ran into issue with HasOptedOutOfEmail and HasOptedOutOfFax fields, these field are by default hidden so we are getting FLS Exception.
            if (FIELD_LIST == null) {
                FIELD_LIST = new List<Schema.SObjectField>{
                    Contact.Id,
                    Contact.Name,
                    Contact.FirstName,
                    Contact.LastName,
                    Contact.Email,
                    Contact.Phone,
                    Contact.MailingStreet,
                    Contact.MailingCity,
                    Contact.MailingState,
                    Contact.MailingCountry,
                    Contact.MailingPostalCode
                };
            }
            return FIELD_LIST;
        }
        private set;
    }

    // List of commonly queried Account fields
    public static String[] ACCT_FIELDS {
        get {
            if (ACCT_FIELDS == null) {
                ACCT_FIELDS = new String[]{
                    'AccountId',
                    'Account.name',
                    'Account.phone',
                    'Account.website',
                    'Account.BillingStreet',
                    'Account.BillingCity',
                    'Account.BillingState',
                    'Account.BillingCountry',
                    'Account.BillingPostalCode'
                };
            }
            return ACCT_FIELDS;
        }
        private set;
    }

    public Selector_Contact() {
        super();
    }

    public override Schema.SObjectType getSObjectType() {
        return Contact.SObjectType;
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

    public List<Contact> selectWhere(String whereClause, List<String> relatedFields) {
        QueryBuilder qb = newQueryBuilderWithRelatedFields(relatedFields);
        qb.setCondition(whereClause);

        return (List<Contact>) Database.query(qb.toSOQL());
    }

    public List<Contact> selectById_WithCustomers(Set<String> idSet, String childWhere) {
        QueryBuilder conQB = newQueryBuilder();
        conQB.setCondition('Id IN :idSet');
        conQB.addChildQuery(new Selector_BWP_Customer().selectAsChildQueryWhere(childWhere));
        return (List<Contact>) Database.query(conQB.toSOQL());
    }
}