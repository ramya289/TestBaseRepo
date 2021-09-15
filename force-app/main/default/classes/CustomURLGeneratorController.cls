public class CustomURLGeneratorController {
    
    
    
    public string Objecttype                                 {get; set;}
    public List<SelectOption> AccountReferenceFields         {get; set;}
    
    
    public Boolean Parent_Object                             {get; set;}
    public List<SelectOption> objectNames                    {get; set;}
    public List<SelectOption> sobjectTextFields              {get; set;}
    public List<SelectOption> sobjectPhoneFields             {get; set;} 
    public List<SelectOption> sobjectTextReferenceFields     {get; set;}
    public List<SelectOption> sobjectTextReferencePhoneFields{get; set;}
    public string selectedObject                             {get; set;}
    public string Parent_Account1                            {get; set;}
    public String Customer_Name                              {get; set;}
    public String Customer_Email                             {get; set;}
    public String Customer_Phone_Number                      {get; set;}
    public String Customer_Description                       {get; set;}
    public String Customer_Address1                          {get; set;}
    public String Customer_Address2                          {get; set;}
    public String Customer_City                              {get; set;}
    public String Customer_State                             {get; set;}
    public String Customer_PostalCode                        {get; set;}
    public String Customer_Country                           {get; set;}
    public String Customer_InvoicePrefix                     {get; set;}
    public String Customer_Language                          {get; set;}
    public String Customer_TaxStatus                         {get; set;}
    public String Customer_TaxType                           {get; set;}
    public String Customer_TaxId                             {get; set;}
    public String Card_Number                                {get; set;}
    public Boolean Object_Fields                             {get; set;}
    public string ParentObjectName                           {get; set;}
    public List<SelectOption> sobjectReferenceFields         {get; set;}
    
    
    public string selectedChildObject                        {get; set;}
    public Boolean Child_Object                              {get; set;}
    public List<SelectOption> ChildSObjectsList              {get; set;}
    public List<SelectOption> childNumberFields              {get; set;}
    public List<SelectOption> childTextFields                {get; set;}
    public string Payment_Amount                             {get; set;}
    public string Payment_Currency                           {get; set;}
    public string Payment_method                             {get; set;}
    public string Payment_Description                        {get; set;}
    public List<SelectOption> childReferenceFields           {get; set;} 
    public string ChildObjectName                            {get; set;}  
    
    
    public Boolean fieldMappingSection                       {get; set;}
    public Boolean generateURLb                              {get; set;}
    public Boolean URLblock                                  {get; set;}
    public string url                                        {get; set;}
    
    
    public Map <String, Schema.SObjectType> schemaMapObjects;
    public Map <String, Schema.SObjectField> SobjFields;
    Set<String> breadwinnerObjectNameSet;
    ///*public List<SelectOption> sobjectFields                  {get; set;}
    ///*public List<SelectOption> ChildSObjectsFields            {get; set;}
    public Map<String,String> ChildSObjectRelationships      {get; set;}
    
    
    public CustomURLGeneratorController (){
        Parent_Object = True;
        Child_Object = False;
        Object_Fields = False;
        fieldMappingSection = False;
        Objecttype = 'sripe_contact';
        breadwinnerObjectNameSet = new Set<String>{'BWP_Customer__c', 'bw_stripe_payment_method__c', 'bw_stripe_payment__c' };
            sobjectTextFields = new List<SelectOption>(); sobjectPhoneFields = new List<SelectOption>();sobjectReferenceFields = new List<SelectOption>();///*sobjectFields =new List<SelectOption>();ChildSObjectsFields = new List<SelectOption>();
        ChildSObjectRelationships = new Map<String,String>();   sobjectTextReferenceFields = new List<SelectOption>(); sobjectTextReferencePhoneFields = new List<SelectOption>();
        
        objectNames = fetchObjects();
        schemaMapObjects = Schema.getGlobalDescribe();
        List<String> entities = new List<String>(schemaMapObjects.keySet());
        String originating_object = ApexPages.currentPage().getParameters().get('originating_object');
        AccountReferenceFields = new List<SelectOption>();
        if(String.isNotBlank(originating_object)){
            selectedObject = originating_object;
        }
        
        ChildSObjectsList = new List<SelectOption>();        
        childTextFields = new List<SelectOption>();
        childNumberFields = new List<SelectOption>();
        childReferenceFields = new List<SelectOption>();
        
    }
    
    public pagereference Childobjects(){          
        Map<String, String> ChildSObjectsListCopy = new Map<String, String>();
        if(!string.isBlank(selectedObject)){
            if(Schema.getGlobalDescribe().get(selectedObject).getDescribe().isAccessible()){
                Schema.DescribeSObjectResult parentObjectDescribe = schemaMapObjects.get(selectedObject).getDescribe();
                SobjFields =   parentObjectDescribe.fields.getMap();
                ParentObjectName = parentObjectDescribe.getlabel();
                List<String> Fields = new List<String>(SobjFields.keySet());
                
                if(breadwinnerObjectNameSet.contains(selectedObject.toLowerCase())){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' Due to Salesforce Apex limitations, Breadwinner can\'t dynamically access your \"'+ParentObjectName+'\" records because Breadwinner has an object with same API name: '+ParentObjectName+' object\'s API name (changing label  or tab name is optional)'));
                    return null;
                }
                Child_Object =true;Parent_Object=false;
                for(String name : Fields){
                    Schema.DescribeFieldResult fieldDescribe = SobjFields.get(name).getDescribe();
                    string FieldLabel = fieldDescribe.getLabel();
                    system.debug(FieldLabel+'==Type=='+fieldDescribe.getType()+'');
                    if(fieldDescribe.getType() == Schema.DisplayType.STRING && fieldDescribe.isAccessible())sobjectTextFields.add(new SelectOption(name,FieldLabel+'('+name+')'));
                    if(fieldDescribe.getType() == Schema.DisplayType.PHONE && fieldDescribe.isAccessible())sobjectPhoneFields.add(new SelectOption(name,FieldLabel+'('+name+')'));
                    if(fieldDescribe.getType() == Schema.DisplayType.REFERENCE && fieldDescribe.isAccessible()){
                        sobjectReferenceFields.add(new SelectOption(name,FieldLabel+'('+name+')'));
                        for(Schema.SObjectType reference : fieldDescribe.getReferenceTo()) { 
                            if(reference.getDescribe().getName()=='Account')          
                                AccountReferenceFields.add(new SelectOption(name,FieldLabel+'('+name+')'));            
                        }
                        
                    }
                    if(fieldDescribe.getType() == Schema.DisplayType.STRING && fieldDescribe.getCalculatedFormula()!=null && fieldDescribe.isAccessible()){
                        AccountReferenceFields.add(new SelectOption(name,FieldLabel+'('+name+')'));                
                    }
                    
                    ///*sobjectFields.add(new SelectOption(name,FieldLabel+'('+name+')'));    
                }
                
                
                List<Schema.ChildRelationship> C = parentObjectDescribe.getChildRelationships();
                //ChildSObjectsList.add(new SelectOption('None',''));
                for (Schema.ChildRelationship cr: C) 
                {    //ChildSObjects.add(cr.getRelationshipName()); 
                    String crName= cr.getRelationshipName();
                    if(Schema.getGlobalDescribe().get(string.valueOf(cr.getChildSObject())).getDescribe().isAccessible() && cr.getRelationshipName()!=null){
                        if(crName != 'ActivityHistories' && crName != 'Attachments' && crName  != 'Notes'  && crName != 'Shares'){
                            ChildSObjectRelationships.put(String.valueof(cr.getChildSObject()), String.valueof(cr.getRelationshipName()));
                            Schema.DescribeSObjectResult s = cr.getChildSObject().getDescribe();
                            if(!(s.getLabel().Tolowercase().contains('history') || s.getLabel().Tolowercase().contains('feed')))
                                ChildSObjectsListCopy.put(s.getLabel()+' ('+cr.getChildSObject()+')', String.valueof(cr.getChildSObject()));
                            //ChildSObjectsListCopy.add(new SelectOption(String.valueOf(cr.getChildSObject()),s.getLabel()+' ('+cr.getChildSObject()+')')); system.debug('child record'+cr.getChildSObject());
                        }
                    }
                    else{
                        System.debug('Do not have Read Permission on '+cr.getChildSObject().getDescribe().getLabel()+' Object');
                    }
                }
            }
            else{
                System.debug('Do not have Read Permission on '+selectedObject+' Object');
            }
            
            List<String> ChildObjs = new list<string>();
            ChildObjs.addall(ChildSObjectsListCopy.keyset());
            ChildObjs.sort();
            for(String Obj : ChildObjs){
                selectOption so = new selectOption(ChildSObjectsListCopy.get(obj),obj);
                ChildSObjectsList.add(so);
            }
            sobjectTextReferenceFields.addAll(sobjectTextFields);
            sobjectTextReferenceFields.addAll(sobjectReferenceFields);
            sobjectTextReferencePhoneFields.addAll(sobjectTextReferenceFields);
            sobjectTextReferencePhoneFields.addAll(sobjectPhoneFields);
            
            if(AccountReferenceFields.size()>0)
                AccountReferenceFields = selectlistSort(AccountReferenceFields);
            if(sobjectTextFields.size()>0)
                sobjectTextFields = selectlistSort(sobjectTextFields);
            if(sobjectReferenceFields.size()>0)
                sobjectReferenceFields = selectlistSort(sobjectReferenceFields);
            if(sobjectPhoneFields.size()>0)
                sobjectPhoneFields = selectlistSort(sobjectPhoneFields);
            if(sobjectTextReferenceFields.size()>0)
                sobjectTextReferenceFields = selectlistSort(sobjectTextReferenceFields);
            if(sobjectTextReferencePhoneFields.size()>0)
                sobjectTextReferencePhoneFields = selectlistSort(sobjectTextReferencePhoneFields);
            
        }
        else {
            Apexpages.addmessage(new Apexpages.Message(ApexPages.Severity.ERROR,' Please select an object from which you want to create an Invoice'));
        }
        
        return null;
    }
    
    
    public pagereference next2(){
        Object_Fields = true; Child_Object = false; generateURLb = true;
        //childTextFields.add(new SelectOption('None',''));
        //childNumberFields.add(new SelectOption('None',''));
        //schema.DescribeSobjectResult myobj = schemaMap.get(selectedChildObject).getDescribe(); 
        if(!string.isBlank(selectedChildObject) && Schema.getGlobalDescribe().get(selectedChildObject).getDescribe().isAccessible()) {  
            ChildObjectName = string.valueof(schemaMapObjects.get(selectedChildObject).getDescribe().getLabel());
            SobjFields =   schemaMapObjects.get(selectedChildObject).getDescribe().fields.getMap();        
            List<String> Fields = new List<String>(SobjFields.keySet());
            
            if(breadwinnerObjectNameSet.contains(selectedChildObject.toLowerCase())){
                Object_Fields = false; Child_Object = true; generateURLb = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' Due to Salesforce Apex limitations, Breadwinner can\'t dynamically access your \"'+ChildObjectName+'\" records because Breadwinner has an object with same API name: '+ChildObjectName+', we request you to rename your '+ChildObjectName+' object\'s API name (changing label or tab name is optional)')); 
                return null;
            }
            
            //fields.addall(SobjFields.keyset());
            for(String name : Fields){
                Schema.DescribeFieldResult fieldDescribe =  SobjFields.get(name).getDescribe();
                string FieldLabel =fieldDescribe.getLabel();
                if((fieldDescribe.getType() == Schema.DisplayType.STRING || fieldDescribe.getType() == Schema.DisplayType.PICKLIST) && fieldDescribe.isAccessible()) childTextFields.add(new SelectOption(name,FieldLabel+'('+name+')'));
                
                if((fieldDescribe.getType() == Schema.DisplayType.INTEGER || fieldDescribe.getType() == Schema.DisplayType.DOUBLE || fieldDescribe.getType() == Schema.DisplayType.CURRENCY) && fieldDescribe.isAccessible())childNumberFields.add(new SelectOption(name,FieldLabel+'('+name+')'));
                
            }///*ChildSObjectsFields.add(new SelectOption(name,FieldLabel+'('+name+')')); 
        }
        else {
            fieldMappingSection = true;
        }
        
        if(childTextFields.size()>0)
            childTextFields = selectlistSort(childTextFields);
        if(childReferenceFields.size()>0)
            childReferenceFields = selectlistSort(childReferenceFields);
        if(childNumberFields.size()>0)
            childNumberFields = selectlistSort(childNumberFields);
        return null;
        
    }
    
    
    public PageReference generateURL() {
        URLblock=true;
        fieldMappingSection = true;
        String appNameSpace = BreadwinnerUtil.namespace!='' ? BreadwinnerUtil.namespace+'__' : '';
        /** if(string.isNotBlank(Parent_Account1)){
Apexpages.addmessage(new Apexpages.Message(ApexPages.Severity.ERROR,' You can not use both a Parent Account and Supplier. You may use either a Invoice Account or Supplier, but not both.'));
return null;
}**/
        if(false){
        }
        else{
            url='';
            url ='/apex/'+appNameSpace+'CreateCustomer'+'\n';
            if(!string.isBlank(selectedObject)){
                url +=string.isBlank(selectedObject)?'':'?originating_record={!'+selectedObject+'.id}'+'\n';
                url +=string.isBlank(Parent_Account1)?'':'&parent_account='+parent_account1+'\n';
                url +=string.isBlank(Customer_Name)?'':'&Customer_Name='+Customer_Name+'\n';
                url +=string.isBlank(Customer_Email)?'':'&Customer_Email='+Customer_Email+'\n';
                url +=string.isBlank(Customer_Phone_Number)?'':'&Customer_Phone_Number='+Customer_Phone_Number+'\n';
                url +=string.isBlank(Customer_Description)?'':'&Customer_Description='+Customer_Description+'\n';
                url +=string.isBlank(Customer_Address1)?'':'&Customer_Address1='+Customer_Address1+'\n';
                url +=string.isBlank(Customer_Address2)?'':'&Customer_Address2='+Customer_Address2+'\n';
                url +=string.isBlank(Customer_City)?'':'&Customer_City='+Customer_City+'\n';
                url +=string.isBlank(Customer_State)?'':'&Customer_State='+Customer_State+'\n';
                url +=string.isBlank(Customer_Country)?'':'&Customer_Country='+Customer_Country+'\n';
                url +=string.isBlank(Customer_PostalCode)?'':'&Customer_PostalCode='+Customer_PostalCode+'\n';
                url +=string.isBlank(Customer_InvoicePrefix)?'':'&Customer_InvoicePrefix='+Customer_InvoicePrefix+'\n';
                url +=string.isBlank(Customer_Language)?'':'&Customer_Language='+Customer_Language+'\n';
                url +=string.isBlank(Customer_TaxStatus)?'':'&Customer_TaxStatus='+Customer_TaxStatus+'\n';
                url +=string.isBlank(Customer_TaxType)?'':'&Customer_TaxType='+Customer_TaxType+'\n';
                url +=string.isBlank(Customer_TaxId)?'':'&Customer_TaxId='+Customer_TaxId+'\n';
                url +=string.isBlank(Card_Number)?'':'&Card_Number='+Card_Number+'\n';
                if(!string.isBlank(selectedChildObject)){
                    url += '&child_relationship_name='+ChildSObjectRelationships.get(selectedChildObject)+'\n';
                    url +=string.isBlank(Payment_Amount) ?'':'&Payment_Amount='+Payment_Amount+'\n';
                    url +=string.isBlank(Payment_Currency) ?'':'&Payment_Currency='+Payment_Currency+'\n';
                    url +=string.isBlank(Payment_Description) ?'':'&Payment_Description='+Payment_Description+'\n';
                    url +=string.isBlank(Payment_method) ?'':'&Payment_method='+Payment_method+'\n'; //url+= +ChildSObjectRelationships+'==selectedChildObject=='+selectedChildObject;
                }
            }
        }
        return null;
    }
    
    
    public void goBackToSecondPage(){
        Child_Object = true;
        generateURLb = false;
        Object_Fields = false;
        fieldMappingSection = false;
        URLblock = false;
    }
    
    public List<selectoption> fetchObjects(){
        List<SelectOption> soList = new List<SelectOption>();
        Map<String, String> soListCopy = new Map<String, String>();
        
        for(Schema.SObjectType objType: Schema.getGlobalDescribe().Values()){        
            Schema.DescribeSObjectResult dsr = objType.getDescribe(); 
            if(dsr.isAccessible() && dsr.isQueryable() && dsr.isCreateable()){             
                String name = dsr.getName();                
                String slabel = dsr.getLabel();
                if(dsr.isCustomSetting() || (!dsr.isCustom() && (name =='Lead' || name.containsIgnoreCase('note') 
                                                                 || name.containsIgnoreCase('permission') || name.containsIgnoreCase('group') || name.containsIgnoreCase('attachment')
                                                                 || name.containsIgnoreCase('document') || name.containsIgnoreCase('history') || name.containsIgnoreCase('folder')  
                                                                 || name.containsIgnoreCase('template') || name.containsIgnoreCase('share') || name.containsIgnoreCase('user') 
                                                                 || name.containsIgnoreCase('vote') || name.containsIgnoreCase('idea') || name.containsIgnoreCase('content') 
                                                                 || name.containsIgnoreCase('macro') || name.containsIgnoreCase('installed') || name.containsIgnoreCase('holiday') 
                                                                 || name.containsIgnoreCase('duplicate')|| name.containsIgnoreCase('search')|| name.containsIgnoreCase('topic') || name.containsIgnoreCase('feed') || name.containsIgnoreCase('apex')))){
                                                                     continue;
                                                                 }
                soListCopy.put(slabel+' ('+name+')', name);
            }
        }
        List<String> Objs = new list<string>();Objs.addall(soListCopy.keyset());objs.sort();
        for(String field : Objs){
            selectOption so = new selectOption(soListCopy.get(field),field);
            soList.add(so);
        }
        
        //soList.sort();
        return soList;
    }
    
    public static List<SelectOption> selectlistSort(List<SelectOption> SortingList){
        Map<string,selectoption> sortMap = new Map<String,SelectOption>();
        Map<string,string> keyswithlowercase = new Map<String,string>();
        List<String> SortLabelsList = new List<String>();
        integer i = 1;
        for(SelectOption s : SortingList ){
            sortMap.put(s.getLabel()+i, s);
            keyswithlowercase.put( (s.getLabel().toLowercase()+ i) , s.getLabel()+i);
            i++;
        }
        SortLabelsList.addAll(keyswithlowercase.keyset());
        SortLabelsList.sort();
        SortingList.clear();
        for(String key : SortLabelsList){
            SortingList.add(sortMap.get(keyswithlowercase.get(key)));        
        }
        return SortingList;        
    }
}