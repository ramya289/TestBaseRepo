public with sharing class Selector_User extends QuerySelector {

    // Core list of fields
    public static List<Schema.SObjectField> FIELD_LIST {
        get {
            if (FIELD_LIST == null) {
                FIELD_LIST = new List<Schema.SObjectField>{
                    User.Alias,
                    User.City,
                    User.CommunityNickname,
                    User.ContactId,
                    User.Country,
                    User.Email,
                    User.EmailEncodingKey,
                    User.FirstName,
                    User.Id,
                    User.IsActive,
                    User.LanguageLocaleKey,
                    User.LastName,
                    User.LocaleSidKey,
                    User.Name,
                    User.Phone,
                    User.PostalCode,
                    User.State,
                    User.Street,
                    User.TimeZoneSidKey,
                    User.Username,
                    User.UserType
                };
            }
            return FIELD_LIST;
        }
        private set;
    }

    public Selector_User() {
        super();
    }

    public override Schema.SObjectType getSObjectType() {
         return User.SObjectType;
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

    public List<User> selectById(Set<String> idSet){
        QueryBuilder qb = newQueryBuilder();
        qb.setCondition('Id IN :idSet');

        return (List<User>) Database.query(qb.toSOQL());
    }

    public Integer selectCount(Boolean activeOnly, Integer lim){
        // For the count queries just return zero instead of throwing an exception
        if(!Schema.SObjectType.User.isAccessible()){
            return 0;
        }

        String qry = 'SELECT COUNT() FROM User';
        if (activeOnly) {
            qry += ' WHERE IsActive = TRUE';
        }
        if (lim != null){
            qry += ' LIMIT ' + String.valueOf(lim);
        }

        return Database.countQuery(qry);
    }
}