@namespaceAccessible
public with sharing class SecurityUtil {
    @namespaceAccessible
    public static final String INSUFFICIENT_PERMISSION_MESSAGE = 'Insufficient permissions: secure query included inaccessible field';

    // These are fields that we can't modify so don't want to check.
    // Items in the following set must be entered in lower case
    private static Set<String> exceptionFields = new Set<String> {
        'createddate',
        'createdbyid',
        'id',
        'isdeleted',
        'lastmodifiedbyid',
        'lastmodifieddate',
        'lastreferenceddate',
        'lastvieweddate',
        'systemmodstamp'
    };

    @namespaceAccessible public enum DmlOp {DML_INSERT,DML_UPDATE,DML_DELETE,DML_UPSERT, DML_READ}

    @namespaceAccessible public static final String FLS_ACCESSIBLE = 'isAccessible';
    @namespaceAccessible public static final String FLS_CREATABLE = 'isCreateable';
    @namespaceAccessible public static final String FLS_UPDATEABLE = 'isUpdateable';

    @namespaceAccessible public static void dmlInsert(SObject obj){performDML(new List<SObject>{obj},DmlOp.DML_INSERT);}
    @namespaceAccessible public static void dmlUpdate(SObject obj){performDML(new List<SObject>{obj},DmlOp.DML_UPDATE);}
    @namespaceAccessible public static void dmlUpsert(SObject obj){performDML(new List<SObject>{obj},DmlOp.DML_UPSERT);}
    @namespaceAccessible public static void dmlDelete(SObject obj){performDML(new List<SObject>{obj},DmlOp.DML_DELETE);}
    @namespaceAccessible public static void dmlInsert(List<SObject> objList){performDML(objList,DmlOp.DML_INSERT);}
    @namespaceAccessible public static void dmlUpdate(List<SObject> objList){performDML(objList,DmlOp.DML_UPDATE);}
    @namespaceAccessible public static void dmlUpsert(List<SObject> objList){performDML(objList,DmlOp.DML_UPSERT);}
    @namespaceAccessible public static void dmlDelete(List<SObject> objList){performDML(objList,DmlOp.DML_DELETE);}

    @namespaceAccessible
    public static void performDML(List<SObject> objList, DmlOp dmlOperation){
        if (objList.isEmpty()){
            return;
        }

        checkCRUDPermission(objList[0].getSObjectType(),dmlOperation);
        checkFieldRestrictions(objList,dmlOperation);

        if(dmlOperation == DmlOp.DML_INSERT){insert objList;}
        else if (dmlOperation == DmlOp.DML_UPDATE){update objList;}
        else if (dmlOperation == DmlOp.DML_UPSERT){upsert objList;}
        else if (dmlOperation == DmlOp.DML_DELETE){delete objList;}
    }

    @namespaceAccessible
    public static Database.UpsertResult[] databaseUpsert(List<SObject> upsertList) {
        return databaseUpsert(upsertList, null);
    }

    @namespaceAccessible
    public static Database.UpsertResult[] databaseUpsert(List<SObject> upsertList, SObjectField externalIdField) {
        if (upsertList.isEmpty()){
            return new List<Database.UpsertResult>();
        }

        checkCRUDPermission(upsertList[0].getSObjectType(),DmlOp.DML_UPSERT);
        checkFieldRestrictions(upsertList,DmlOp.DML_UPSERT);

        if (externalIdField == null) {
            return Database.upsert(upsertList, false);
        } else {
            return Database.upsert(upsertList, externalIdField, false);
        }

    }

    @namespaceAccessible
    public static Database.DeleteResult[] databaseDelete(List<SObject> deleteList) {
        if (deleteList.isEmpty()){
            return new List<Database.DeleteResult>();
        }
        checkCRUDPermission(deleteList[0].getSObjectType(),DmlOp.DML_DELETE);

        return Database.delete(deleteList, false);
    }

    // Check CRUD permissions for the current user on the object
    private static void checkCRUDPermission(SObjectType objType, DmlOp dmlOperation){
        DescribeSObjectResult describeObject = objType.getDescribe();
        if((dmlOperation == DmlOp.DML_INSERT && !describeObject.isCreateable()) ||
                (dmlOperation == DmlOp.DML_UPDATE && !describeObject.isUpdateable()) ||
                (dmlOperation == DmlOp.DML_DELETE && !describeObject.isDeletable()) ||
                (dmlOperation == DmlOp.DML_UPSERT && !(describeObject.isCreateable() && describeObject.isUpdateable()))) {
            throw new CRUDException(objType,dmlOperation);
        }
    }

    /**
     * Loops through the list for records to be modified and check to make sure the fields being modified have the
     * correct permissions for the requested DML operation.
     * Throws an error if the field does not have to correct permission
     *
     * @param objList List of records being acted on
     * @param dmlOperation DML Operation that should be preformed
     */
    private static void checkFieldRestrictions(List<SObject> objList, DmlOp dmlOperation){
        // no FLS needed for delete
        if (dmlOperation == DmlOp.DML_DELETE){
            return;
        }
        Map<String, Set<String>> flsObjectMap = createFlsObjectMap(objList[0].getSObjectType().getDescribe().fields.getMap());
        for(SObject obj : objList) {
            // the key for getPopulatedFieldsAsMap is the namespaced version of the field
            for (String key : obj.getPopulatedFieldsAsMap().keySet()) {
                checkFLS(flsObjectMap, dmlOperation, obj.getSObjectType(), key.toLowerCase());
            }
        }
    }

    /**
     * Checks to make sure the field passed in has the proper permissions for the requested DML operation
     * @param flsObjectMap set of valid DML Operation for each field that was modified keyed by the fieldName
     * @param dmlOperation DML Operation being performed
     * @param objType objectType the action is being performed on. Needed to throw a readable 'Exception'
     * @param fldName name of the field being acted on. Needed to throw a readable 'Exception'
     */
    private static void checkFLS(Map<String,Set<String>> flsObjectMap, DmlOp dmlOperation, SObjectType objType, String fldName){

        if (exceptionFields.contains(fldName) || fldName.endsWithIgnoreCase('__r')){
            return;
        }

        Set<String> flsPermissions = flsObjectMap.get(fldName);
        if (flsPermissions == null) {
            throw new FLSException(objType, objType.getDescribe().fields.getMap().get(fldName), dmlOperation);
        }

        //doesn't have any permissions. Throw the error
        if (flsPermissions.isEmpty()) {
            throw new FLSException(objType, objType.getDescribe().fields.getMap().get(fldName), dmlOperation);
        }
        if (!flsPermissions.contains(FLS_ACCESSIBLE)) {
            throw new FLSException(objType, objType.getDescribe().fields.getMap().get(fldName), dmlOperation);
        }
        if (dmlOperation == DmlOp.DML_INSERT || dmlOperation == DmlOp.DML_UPSERT) {
            if (!flsPermissions.contains(FLS_CREATABLE)) {
                throw new FLSException(objType, objType.getDescribe().fields.getMap().get(fldName), dmlOperation);
            }
        }
        if (dmlOperation == DmlOp.DML_UPDATE || dmlOperation == DmlOp.DML_UPSERT) {
            if (!flsPermissions.contains(FLS_UPDATEABLE)) {
                throw new FLSException(objType, objType.getDescribe().fields.getMap().get(fldName), dmlOperation);
            }
        }
    }

    /**
     * Returns a map of fields names and the corresponding DML operations that can be performed on the field
     *
     * @param objFieldMap SObject field map
     *
     * @return Map<String, Set<String>> of accessibility options keys by field name
     */
    private static Map<String, Set<String>> createFlsObjectMap(Map<String,Schema.SObjectField> objFieldMap){
        Map<String, Set<String>> newFlsMap = new Map<String, Set<String>>();
        for (SObjectField objField : objFieldMap.values()){
            Set<String> flsSet = new Set<String>();
            DescribeFieldResult fr = objField.getDescribe();

            // Don't include exceptions in the map.  These are SF fields in each object that we can't modify
            if (exceptionFields.contains(fr.getLocalName().toLowerCase())){
                continue;
            }
            // Don't include calculated fields or Name field if it's autogenerated in the map.  We won't be trying to update those.
            if (fr.isCalculated() || fr.isAutoNumber()) {
                continue;
            }
            if (fr.isAccessible()){
                flsSet.add(FLS_ACCESSIBLE);
            }
            if (fr.isCreateable()) {
                flsSet.add(FLS_CREATABLE);
            }
            if (fr.isUpdateable()) {
                flsSet.add(FLS_UPDATEABLE);
            }
            //we want the namespaced version as the key.
            newFlsMap.put(fr.getName().toLowerCase(),flsSet);
        }
        return newFlsMap;
    }

    // Custom Exception Classes
    @namespaceAccessible
    public virtual class SecurityException extends Exception{
        public SObjectType objType {get; private set;}
        public DmlOp op{get; private set;}
    }

    @namespaceAccessible
    public class CRUDException extends SecurityException{
        public CRUDException(SObjectType objType, DmlOp op){
            this('Access Denied: ' + op + ' on ' + objType);
            this.objType = objType;
            this.op = op;
        }
    }

    @namespaceAccessible
    public class FLSException extends SecurityException{
        public SObjectField field{get; private set;}
        public FLSException(SObjectType objType, SObjectField field, dmlOp op){
            this('Access Denied: ' + op + ' on ' + objType + '.' + field);
            this.objType = objType;
            this.op = op;
            this.field = field;
        }
    }
}