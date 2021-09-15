@IsTest
private class Test_SecurityUtil {
    @testSetup
    static void setup() {
        String uniqueUserName = 'testuser' + DateTime.now().getTime() + '@testorg.com';
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1 ];
        User user = new User(Alias = 'TestUser', Email = 'testuser@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = prof.Id, TimeZoneSidKey = 'America/Los_Angeles', UserName = uniqueUserName);
        insert user;
        String adminPSName = 'Breadwinner_Payments_Admin_User';
        List<PermissionSet> pset = [SELECT Id FROM PermissionSet WHERE Name = 'Breadwinner_Payments_Admin_User'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = pset[0].Id);
    }
    @IsTest
    static void dmlInsert(){
        BWP_Customer__c cust = new BWP_Customer__c(First_Name__c = 'Test');

        User newUser = createReadOnlyUser();
        // First try without a permission set
        System.runAs(newUser){
            try{
                SecurityUtil.dmlInsert(cust);
                System.assert(false,'Expected a CRUD Error! newUser shouldn\'t be able to insert new BW_Customer record');
            } catch(SecurityUtil.CRUDException crudEx){
                System.assertEquals(BWP_Customer__c.SObjectType,crudEx.objType);
                System.assertEquals(SecurityUtil.DmlOp.DML_INSERT,crudEx.op);
            }
        }

        // Add a permission set with create = false
        String objName = BWP_Customer__c.SObjectType.getDescribe().name;
        PermissionSet ps = createObjectPermission(newUser,objName,false,true,false);
        System.runAs(newUser){
            try{
                SecurityUtil.dmlInsert(cust);
                System.assert(false,'Expected a CRUD Error! newUser shouldn\'t be able to insert new BW_Customer record');
            } catch(SecurityUtil.CRUDException crudEx){
                System.assertEquals(BWP_Customer__c.SObjectType,crudEx.objType);
                System.assertEquals(SecurityUtil.DmlOp.DML_INSERT,crudEx.op);
            }
        }

        // Add 'create' object permission
        createObjectPermission(newUser,objName,true,true,false);
        System.runAs(newUser){
            try{
                SecurityUtil.dmlInsert(cust);
                System.assert(false,'Expected an FLS Exception. newUser shouldn\'t be able to insert into First_Name w/o FLS permission.');
            }
            catch(SecurityUtil.FLSException flse){
                System.assertEquals(BWP_Customer__c.SObjectType,flse.objType);
                System.assertEquals(SecurityUtil.DmlOp.DML_INSERT,flse.op);
                System.assertEquals(BWP_Customer__c.SObjectType.fields.First_Name__c,flse.field);
            }
        }

        // Add FLS Perm but with 'Edit' false
        createFieldPermission(ps,objName,'First_Name__c', true, false);

        System.runAs(newUser){
            try{
                SecurityUtil.dmlInsert(cust);
                System.assert(false,'Expected an FLS Exception. newUser shouldn\'t be able to insert into First_Name w/o edit FLS');
            } catch(SecurityUtil.FLSException flse){
                System.assertEquals(BWP_Customer__c.SObjectType,flse.objType);
                System.assertEquals(SecurityUtil.DmlOp.DML_INSERT,flse.op);
                System.assertEquals(BWP_Customer__c.SObjectType.fields.First_Name__c,flse.field);
            }
        }

        // Now, give the user 'Edit' permissions
       createFieldPermission(ps,objName,'First_Name__c', true, true);
       System.runAs(newUser){
            SecurityUtil.dmlInsert(cust);
        }
    }

    @IsTest
    static void dmlUpsert(){
        BWP_Customer__c cust = new BWP_Customer__c(First_Name__c = 'Test');

        User newUser = createReadOnlyUser();
        // First try without a permission set
        System.runAs(newUser){
            try{
                SecurityUtil.dmlUpsert(cust);
                System.assert(false,'Expected a CRUD Error! newUser shouldn\'t be able to upsert record w/o permissions.');
            } catch(SecurityUtil.CRUDException crudEx){
                System.assertEquals(BWP_Customer__c.SObjectType,crudEx.objType);
                System.assertEquals(SecurityUtil.DmlOp.DML_UPSERT,crudEx.op);
            }
        }

        // Add a permission set with create & edit false
        String objName = BWP_Customer__c.SObjectType.getDescribe().name;
        PermissionSet ps = createObjectPermission(newUser,objName,false,false,false);
        System.runAs(newUser){
            try{
                SecurityUtil.dmlUpsert(cust);
                System.assert(false,'Expected a CRUD Error! newUser shouldn\'t be able to upsert record without create & edit object permission.');
            } catch(SecurityUtil.CRUDException crudEx){
                System.assertEquals(BWP_Customer__c.SObjectType,crudEx.objType);
                System.assertEquals(SecurityUtil.DmlOp.DML_UPSERT,crudEx.op);
            }
        }

        // Add 'create' object permission
        createObjectPermission(newUser,objName,true,false,false);
        System.runAs(newUser){
            try{
                SecurityUtil.dmlUpsert(cust);
                System.assert(false,'Expected a CRUD Error! newUser shouldn\'t be able to upsert record without edit object permission.');
            } catch(SecurityUtil.CRUDException crudEx){
                System.assertEquals(BWP_Customer__c.SObjectType,crudEx.objType);
                System.assertEquals(SecurityUtil.DmlOp.DML_UPSERT,crudEx.op);
            }
        }

        // Add 'edit' object permission
        createObjectPermission(newUser,objName,true,true,false);
        System.runAs(newUser){
            try{
                SecurityUtil.dmlUpsert(cust);
                System.assert(false,'Expected an FLS Exception. newUser shouldn\'t be able to upsert First_Name w/o FLS permission.');
            }
            catch(SecurityUtil.FLSException flse){
                System.assertEquals(BWP_Customer__c.SObjectType,flse.objType);
                System.assertEquals(SecurityUtil.DmlOp.DML_UPSERT,flse.op);
                System.assertEquals(BWP_Customer__c.SObjectType.fields.First_Name__c,flse.field);
            }
        }

        // Add FLS Perm but with 'Edit' false
        createFieldPermission(ps,objName,'First_Name__c', true, false);

        System.runAs(newUser){
            try{
                SecurityUtil.dmlUpsert(cust);
                System.assert(false,'Expected an FLS Exception. newUser shouldn\'t be able to upsert First_Name w/o edit FLS');
            } catch(SecurityUtil.FLSException flse){
                System.assertEquals(BWP_Customer__c.SObjectType,flse.objType);
                System.assertEquals(SecurityUtil.DmlOp.DML_UPSERT,flse.op);
                System.assertEquals(BWP_Customer__c.SObjectType.fields.First_Name__c,flse.field);
            }
        }

        // Now, give the user 'Edit' permissions
        createFieldPermission(ps,objName,'First_Name__c', true, true);
        System.runAs(newUser){
            SecurityUtil.dmlUpsert(cust);
        }
    }

    @IsTest
    static void dmlUpdate(){
        BWP_Customer__c cust = new BWP_Customer__c(First_Name__c = 'Test');

        User newUser = createReadOnlyUser();
        // First try without a permission set
        System.runAs(newUser){
            insert cust;
            cust.First_Name__c = 'Update Test';

            try{
                SecurityUtil.dmlUpdate(cust);
                System.assert(false,'Expected a CRUD Error! newUser shouldn\'t be able to update record w/o a permission set');
            } catch(SecurityUtil.CRUDException crudEx){
                System.assertEquals(BWP_Customer__c.SObjectType,crudEx.objType);
                System.assertEquals(SecurityUtil.DmlOp.DML_UPDATE,crudEx.op);
            }
        }

        // Add a permission set with edit false (shouldn't need 'create' ever)
        String objName = BWP_Customer__c.SObjectType.getDescribe().name;
        PermissionSet ps = createObjectPermission(newUser,objName,false,false,false);
        System.runAs(newUser){
            try{
                SecurityUtil.dmlUpdate(cust);
                System.assert(false,'Expected a CRUD Error! newUser shouldn\'t be able to update record');
            } catch(SecurityUtil.CRUDException crudEx){
                System.assertEquals(BWP_Customer__c.SObjectType,crudEx.objType);
                System.assertEquals(SecurityUtil.DmlOp.DML_UPDATE,crudEx.op);
            }
        }

        // Add 'edit' object permission
        createObjectPermission(newUser,objName,false,true,false);
        System.runAs(newUser){
            try{
                SecurityUtil.dmlUpdate(cust);
                System.assert(false,'Expected an FLS Exception. newUser shouldn\'t be able to update First_Name w/o FLS permission.');
            }
            catch(SecurityUtil.FLSException flse){
                System.assertEquals(BWP_Customer__c.SObjectType,flse.objType);
                System.assertEquals(SecurityUtil.DmlOp.DML_UPDATE,flse.op);
                System.assertEquals(BWP_Customer__c.SObjectType.fields.First_Name__c,flse.field);
            }
        }

        // Add FLS Perm but with 'Edit' false
        createFieldPermission(ps,objName,'First_Name__c', true, false);
        System.runAs(newUser){
            try{
                SecurityUtil.dmlUpdate(cust);
                System.assert(false,'Expected an FLS Exception. newUser shouldn\'t be able to update First_Name w/o edit FLS');
            } catch(SecurityUtil.FLSException flse){
                System.assertEquals(BWP_Customer__c.SObjectType,flse.objType);
                System.assertEquals(SecurityUtil.DmlOp.DML_UPDATE,flse.op);
                System.assertEquals(BWP_Customer__c.SObjectType.fields.First_Name__c,flse.field);
            }
        }

        // Now, give the user 'Edit' permissions
        createFieldPermission(ps,objName,'First_Name__c', true, true);
        System.runAs(newUser){
            SecurityUtil.dmlUpdate(cust);
        }

    }

    @IsTest
    static void dmlDelete(){
        BWP_Customer__c cust = new BWP_Customer__c(First_Name__c = 'Test');

        User newUser = createReadOnlyUser();
        // First try without a permission set
        System.runAs(newUser){
            insert cust;

            try{
                SecurityUtil.dmlDelete(cust);
                System.assert(false,'Expected a CRUD Error! newUser shouldn\'t be able to delete record w/o a permission set');
            } catch(SecurityUtil.CRUDException crudEx){
                System.assertEquals(BWP_Customer__c.SObjectType,crudEx.objType);
                System.assertEquals(SecurityUtil.DmlOp.DML_DELETE,crudEx.op);
            }
        }

        // Add a permission set with remove false
        String objName = BWP_Customer__c.SObjectType.getDescribe().name;
        PermissionSet ps = createObjectPermission(newUser,objName,false,false,false);
        System.runAs(newUser){
            try{
                SecurityUtil.dmlDelete(cust);
                System.assert(false,'Expected a CRUD Error! newUser shouldn\'t be able to delete record');
            } catch(SecurityUtil.CRUDException crudEx){
                System.assertEquals(BWP_Customer__c.SObjectType,crudEx.objType);
                System.assertEquals(SecurityUtil.DmlOp.DML_DELETE,crudEx.op);
            }
        }

        // Add 'remove' object permission (this also requires 'edit')
        createObjectPermission(newUser,objName,false,true,true);
        System.runAs(newUser){
            SecurityUtil.dmlDelete(cust);
        }
    }

    //This is for code coverage.  All the security stuff was covered in other tests
    @IsTest
    static void codeCoverage() {
        User adminUser =  [SELECT Id FROM User WHERE Alias = 'TestUser' LIMIT 1];
        System.runAs(adminUser){
            BWP_Customer__c cust1 = new BWP_Customer__c(First_Name__c = 'Insert Test');
            BWP_Customer__c cust2 = new BWP_Customer__c(First_Name__c = 'Upsert Test');
    
            SecurityUtil.dmlInsert(new List<BWP_Customer__c>{cust1});
            SecurityUtil.dmlUpsert(new List<BWP_Customer__c>{cust2});
            SecurityUtil.dmlUpdate(new List<BWP_Customer__c>{cust1});
            SecurityUtil.dmlDelete(new List<BWP_Customer__c>{cust2});
    
            SecurityUtil.performDML(new List<SObject>(), SecurityUtil.DmlOp.DML_INSERT);
    
            BWP_Customer__c cust3 = new BWP_Customer__c(First_Name__c = 'Cust 3');
            BWP_Customer__c cust4 = new BWP_Customer__c(First_Name__c = 'Cust 4');
            List<BWP_Customer__c> custList = new List<BWP_Customer__c>{cust3,cust4};
    
            Database.UpsertResult[] upsertRslt = SecurityUtil.databaseUpsert(custList);
            System.assertEquals(2, upsertRslt.size());
    
            Database.DeleteResult[] deleteRslt = SecurityUtil.databaseDelete(custList);
            System.assertEquals(2, deleteRslt.size());
        }

    }

    private static User createReadOnlyUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Read Only' OR Name='ReadOnly'];

        User newUser = new User(Alias = 'reado',
                Email='readonly@testorg.com',
                EmailEncodingKey='UTF-8',
                LastName='Testing',
                LanguageLocaleKey='en_US',
                LocaleSidKey='en_US',
                ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles',
                Username='readOnlyUuser@testorg.com'
        );
        insert newUser;

        return newUser;
    }

    private static PermissionSet createObjectPermission(User u, String objectName, Boolean create, Boolean edit, Boolean remove){
        String psName = 'Enable_' + objectName.remove('__c').remove(BreadwinnerUtil.namespaceApi);
        PermissionSet ps = new PermissionSet(Name = psName, Label = 'Enable ' + objectName);
        try{
            ps = [SELECT Id FROM PermissionSet WHERE Name = :psName];
        } catch (QueryException qEx){
            insert ps;
        }

        ObjectPermissions oPerm = new ObjectPermissions(ParentId = ps.Id, SobjectType = objectName);
        try {
            oPerm = [SELECT Id FROM ObjectPermissions WHERE ParentId = :ps.Id AND SobjectType = :objectName];
        } catch (QueryException qEx){ }

        oPerm.PermissionsRead = true; // Read is required for any action
        oPerm.PermissionsCreate = create;
        oPerm.PermissionsEdit = edit;
        oPerm.PermissionsDelete = remove;
        upsert oPerm;

        PermissionSetAssignment assign = new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
        try {
            assign = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :u.Id AND PermissionSetId = :ps.Id];
        } catch (QueryException qEx){
            // Only create if it doesn't already exist
            insert assign;
        }

        return ps;
    }

    // create field permission for specific field
    private static FieldPermissions createFieldPermission(PermissionSet ps, String objectType, String fieldName, Boolean readPerm, Boolean editPerm){
        String fldName = objectType + '.' + BreadwinnerUtil.namespaceApi + fieldName;
         FieldPermissions fp = new FieldPermissions(
             ParentId = ps.Id,
             SobjectType = objectType,
             Field = fldName
         );

        try {
            fp = [SELECT Id FROM FieldPermissions WHERE SobjectType= :objectType AND ParentId = :ps.Id AND Field = :fldName];
        } catch (QueryException qEx){}

        fp.PermissionsRead = readPerm;
        fp.PermissionsEdit= editPerm;
        upsert fp;

        return fp;
    }
}