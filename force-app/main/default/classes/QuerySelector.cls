@namespaceAccessible
public abstract with sharing class QuerySelector {

    /**
     * Enforce FLS Security
     **/
    private Boolean l_enforceFLS = true;

    /**
     * Enforce READ object Security
     **/
    private Boolean l_enforceRead = true;

    /**
     * If field fails FLS security
     *  - true - will throw the error
     *  - false - will remove the field from the query.
     *
     **/
    private Boolean l_throwFLSException = true;

    @namespaceAccessible
    public QuerySelector() {
        this(true, true);
    }

    @namespaceAccessible
    public QuerySelector(Boolean enforceRead, Boolean enforceFLS) {
        this(enforceRead,enforceFLS,true);
    }

    @namespaceAccessible
    public QuerySelector(Boolean enforceRead, Boolean enforceFLS, Boolean throwFLS) {
        l_enforceRead = enforceRead;
        l_enforceFLS = enforceFLS;
        l_throwFLSException = throwFLS;
    }

    @namespaceAccessible
    public abstract Schema.SObjectType getSObjectType();

    @namespaceAccessible
    public abstract List<Schema.SObjectField> getSObjectFieldList();

    @namespaceAccessible
    public abstract String getOrderBy();

    @namespaceAccessible
    public QueryBuilder newQueryBuilder(){
        QueryBuilder qb = new QueryBuilder(getSObjectType(), l_enforceRead, l_enforceFLS, l_throwFLSException);
        qb.addSObjectFields(getSObjectFieldList());
        return qb;
    }

    @namespaceAccessible
    public QueryBuilder newQueryBuilderWithRelatedFields(List<String> relatedFields){
        QueryBuilder qb = newQueryBuilder();
        if(relatedFields != null) {
            qb.addRelatedFields(relatedFields);
        }
        return qb;
    }

}