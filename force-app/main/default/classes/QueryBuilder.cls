@namespaceAccessible
public with sharing class QueryBuilder {

    private Schema.SObjectType sObjType;
    private String whereString;
    private String orderBy;
    private Integer limitCount;
    private Boolean enforceFLS;
    private Boolean enforceREAD;
    private Boolean throwFLSException;
    private Set<String> fieldsAsSet;

    private Map<String, Map<String,Schema.SObjectField>> cachedFieldMap = new Map<String, Map<String, Schema.SObjectField>>();
    private Map<String, QueryBuilder> childQueryMap = new Map<String, QueryBuilder>();

    @namespaceAccessible
    public QueryBuilder(Schema.SObjectType objType, Boolean enfRead, Boolean enfFLS, Boolean throwFLS){

        sObjType = objType;
        enforceREAD = enfRead;
        enforceFLS = enfFLS;
        throwFLSException = throwFLS;
        fieldsAsSet = new Set<String>();
        whereString = '';

        // No reason to go any further if the user can't read the object
        unsureObjectReadability(objType);

    }

    /**
     * @param condition Sets the WHERE clause to the string provided.
     * @return QueryBuilder
     *
    **/
    @namespaceAccessible
    public QueryBuilder setCondition(String condition){
        this.whereString = String.isBlank(this.whereString) ? condition : this.whereString + ' AND ' + condition;
        return this;
    }

    /**
     * @param orderBy Sets the ORDER BY clause to the string provided.
     * @return QueryBuilder
     *
    **/
    @namespaceAccessible
    public QueryBuilder setOrderBy(String orderBy){
        this.orderBy = orderBy;
        return this;
    }

    /**
     * @param limitCount Sets the LIMIT to the integer provided. Do not include "LIMIT".
     * @return QueryBuilder
     *
    **/
    @namespaceAccessible
    public QueryBuilder setLimit(Integer limitCount){
        this.limitCount = limitCount;
        return this;
    }

    /**
     * @return full SOQL string to be used in the query
     */
    @namespaceAccessible
    public String toSOQL(){
        List<String> soqlFields = new List<String>();
        soqlFields.addAll(fieldsAsSet);

        String soqlStr = 'SELECT ' + String.join(soqlFields, ',');
        // Append any child queries
        for (String key : childQueryMap.keySet()){
            soqlStr += addChildSOQL(key, childQueryMap.get(key));
        }

        soqlStr += ' FROM ' + sObjType;

        if (String.isNotBlank(whereString)) {
            soqlStr += ' WHERE ' + whereString;
        }
        if (limitCount != null){
            soqlStr += ' LIMIT ' + String.valueOf(limitCount);
        }
        return soqlStr;

    }

    @namespaceAccessible
    public QueryBuilder addSObjectFields(List<Schema.SObjectField> soFieldList){
        for(Schema.SObjectField soField : soFieldList){
            addSObjectField(soField);
        }
        return this;
    }

    private QueryBuilder addSObjectField(Schema.SObjectField soField){
        if (enforceFLS){
            if (!isFieldReadable(soField)) {
                if (throwFLSException) {
                    throw new SecurityUtil.FLSException(sObjType, soField, SecurityUtil.DmlOp.DML_READ);
                } else {
                    return this;
                }
            }
        }
        fieldsAsSet.add(soField.getDescribe().name);
        return this;
    }

    /**
     * Return the SObjectField from the cached map. If the obj is not in the cached map yet then add it
     *
     * @param objType SObject the field is getting retrieved from
     * @param fieldName Specific field we are trying to pull out.
     *
     * @return Schema.SObjectField
     */
    private Schema.SObjectField getSObjectFieldFromMap(Schema.SObjectType objType, String fieldName){
        Map<String, Schema.SObjectField> fieldMap = cachedFieldMap.get(objType.getDescribe().getLocalName().toLowerCase());
        if (fieldMap == null){
            fieldMap = new Map<String, Schema.SObjectField>();
            for (Schema.SObjectField soField: objType.getDescribe().fields.getMap().values()){
                fieldMap.put(soField.getDescribe().getLocalName().toLowerCase(),soField);
            }
            cachedFieldMap.put(objType.getDescribe().getLocalName().toLowerCase(),fieldMap);
        }
        return fieldMap.get(fieldName.toLowerCase());
    }

    public void addRelatedFields(List<String> soFieldList){
        for(String fld : soFieldList){
            addRelatedField(fld);
        }
    }

    /**
     * Converts the related string field into an SObject field to check for permissions.
     * If it passes, the field is added to the list of fields getting queried.
     * Otherwise an exception is thrown or it is just passed over depending "throwFLSException"
     *
     * @param fieldAsString related field being checked
     *
     * @return QueryBuilder - updated fieldsAsSet
     */
    private QueryBuilder addRelatedField(String fieldAsString){

        Schema.SObjectType currentObjType = sObjType;

        if(!fieldAsString.contains('.')){ // field is on the same object
            Schema.SObjectField currentField = getSObjectFieldFromMap(currentObjType, fieldAsString);
            fieldsAsSet.add(currentField.getDescribe().getName());
            return this;
        }

        //We need the namespaced version of the field returned.
        String namespacedFieldName = '';

        for (String field : fieldAsString.split('\\.')){
            // Change __r to __c so we can get the field on the current object.
            // From that sObjectField we can get the reference, which will give us the related object
            String currentObjectFld = field.replace('__r','__c');

            Schema.SObjectField currentField = getSObjectFieldFromMap(currentObjType, currentObjectFld);
            if (currentField == null){
                // The lookup on standard objects, to the account for example, is "account.whatever" but
                // Schema.SObjectType.Contact.fields.getMap() returns accountId instead of account as the lookup field.
                // So if currentField returns null, which it would on "AccountId"
                // let see if the currentObjectFld is an SObject
                Schema.SObjectType newObjType = Schema.getGlobalDescribe().get(currentObjectFld);
                if (newObjType != null){
                    currentObjType = newObjType;
                    unsureObjectReadability(currentObjType);
                    namespacedFieldName += currentObjType.getDescribe().getName().replace('__c','__r') + '.';
                }
                continue;
            }

            DescribeFieldResult fieldDescribe = currentField.getDescribe();

            List<Schema.SObjectType> referenceObjects = fieldDescribe.getReferenceTo();
            if (referenceObjects.isEmpty()){
                // we are finally at the sObjectField because there are no more references. Check FLS
                if (isFieldReadable(currentField)){
                    namespacedFieldName += fieldDescribe.getName();
                    fieldsAsSet.add(namespacedFieldName);
                } else if (throwFLSException) {
                    throw new SecurityUtil.FLSException(currentObjType, currentField, SecurityUtil.DmlOp.DML_READ);
                }
            } else {
                // We are on a related object.  Check Read access to the object.
                // This may be overkill but let's do it anyways.
                currentObjType = referenceObjects[0];
                unsureObjectReadability(currentObjType);
                namespacedFieldName += fieldDescribe.getName().replace('__c','__r') + '.';
            }
        }

        return this;
    }

    @namespaceAccessible
    public QueryBuilder addChildQuery(QueryBuilder childQuery){
        List<Schema.ChildRelationship> crList = sObjType.getDescribe().getChildRelationships();
        for (Schema.ChildRelationship cr : crList) {
            if (cr.getChildSObject() == childQuery.sObjType && cr.getRelationshipName() != null) {
                System.debug('cr: ' + cr);
                childQueryMap.put(cr.getRelationshipName(), childQuery);
            }
        }
        return this;
    }

    private String addChildSOQL(String relationshipName, QueryBuilder qb){
        List<String> soqlFields = new List<String>();
        soqlFields.addAll(qb.fieldsAsSet);

        String soqlStr = ', (SELECT ' + String.join(soqlFields, ',') + ' FROM ' + relationshipName;

        if (String.isNotBlank(qb.whereString)) {
            soqlStr += ' WHERE ' + qb.whereString;
        }
        if (qb.limitCount != null){
            soqlStr += ' LIMIT ' + String.valueOf(qb.limitCount);
        }
        soqlStr += ')';

        return soqlStr;

    }

    private void unsureObjectReadability(Schema.SObjectType ot){
        if (enforceREAD) {
            if (!ot.getDescribe().isAccessible()) {
                throw new SecurityUtil.CRUDException(ot, SecurityUtil.DmlOp.DML_READ);
            }
        }
    }

    private Boolean isFieldReadable(Schema.SObjectField objFld){
        return objFld.getDescribe().isAccessible();
    }
}