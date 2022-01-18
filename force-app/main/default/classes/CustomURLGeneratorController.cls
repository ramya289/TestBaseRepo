public class CustomURLGeneratorController {

    public Boolean showOriginatingObjects                    {get; private set;}
    public Boolean showFieldsMapping                         {get; private set;}
    public List<SelectOption> objectNames                    {get; private set;}
    public List<SelectOption> accountReferenceFields         {get; private set;}
    public List<SelectOption> contactReferenceFields         {get; private set;}
    public List<SelectOption> sobjectTextFields              {get; private set;}
    public List<SelectOption> sobjectNumberFields            {get; private set;}
    public string parentObjectName                           {get; set;}   
    public string selectedObject                             {get; set;}
    public string parent_object_reference                    {get; set;}
    public string payment_amount                             {get; set;}
    public string payment_currency                           {get; set;}
    public string payment_description                        {get; set;}
    public string url                                        {get; set;}  
    public Boolean showURLBlock                              {get; private set;}
    public String customerMatchType                          {get; private set;}
    public Boolean isProcessorConnected                      {get; private set;}
    private Set<String> breadwinnerObjectNameSet;
    
    public CustomURLGeneratorController (){
        showOriginatingObjects = True;
        showFieldsMapping = False;
        isProcessorConnected = False;
        breadwinnerObjectNameSet = new Set<String>{'BWP_Customer__c', 'BWP_Payment_Method__c', 'BWP_Transaction__c' };
        
        objectNames = fetchObjects();
        
        List<BWP_Processor_Config__c> payConfigList = BreadwinnerUtil.processorConfigList;
        if(!(payConfigList?.isEmpty())){
            customerMatchType = payConfigList[0].Customer_Match_Type__c;
            isProcessorConnected = True;
        }
        else ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,' Please connect to a Payment Processor from the setup section of Breadwinner tab.'));
        customerMatchType = String.isNotBlank(customerMatchType) ? customerMatchType : ProcessorUtil.CMT_Account;

    }
    
    public pagereference parentObjectFields(){          
        if(!string.isBlank(selectedObject)){
            if(Schema.getGlobalDescribe().get(selectedObject).getDescribe().isAccessible()){
                Schema.DescribeSObjectResult parentObjectDescribe = Schema.getGlobalDescribe().get(selectedObject).getDescribe();
                Map <String, Schema.SObjectField> sobjFields =   parentObjectDescribe.fields.getMap();
                parentObjectName = parentObjectDescribe.getlabel();
                List<String> Fields = new List<String>(sobjFields.keySet());
                
                if(breadwinnerObjectNameSet.contains(selectedObject.toLowerCase())){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,' Due to Salesforce Apex limitations, Breadwinner can\'t dynamically access your \"'+parentObjectName+'\" records because Breadwinner has an object with same API name: '+parentObjectName+' object\'s API name (changing label  or tab name is optional)'));
                    return null;
                }
                showOriginatingObjects=false;
                accountReferenceFields = new List<SelectOption>();
                contactReferenceFields = new List<SelectOption>();
                sobjectTextFields = new List<SelectOption>();
                sobjectNumberFields = new List<SelectOption>();
                for(String name : Fields){
                    Schema.DescribeFieldResult fieldDescribe = sobjFields.get(name).getDescribe();
                    string FieldLabel = fieldDescribe.getLabel();
                    if(fieldDescribe.getType() == Schema.DisplayType.STRING)sobjectTextFields.add(new SelectOption(name,FieldLabel+' ('+name+')'));   
                    if((fieldDescribe.getType() == Schema.DisplayType.INTEGER || fieldDescribe.getType() == Schema.DisplayType.DOUBLE || fieldDescribe.getType() == Schema.DisplayType.CURRENCY))sobjectNumberFields.add(new SelectOption(name,FieldLabel+' ('+name+')'));

                    if(fieldDescribe.getType() == Schema.DisplayType.REFERENCE){
                        for(Schema.SObjectType reference : fieldDescribe.getReferenceTo()) { 
                            if(reference.getDescribe().getName() == ProcessorUtil.CMT_ACCOUNT) accountReferenceFields.add(new SelectOption(name,FieldLabel+' ('+name+')'));
                            if(reference.getDescribe().getName() == ProcessorUtil.CMT_CONTACT) contactReferenceFields.add(new SelectOption(name,FieldLabel+' ('+name+')')); 
                        }
                    }
                }
            }
            else{
                System.debug('Do not have Read Permission on '+selectedObject+' Object');
            }
                        
            if(accountReferenceFields.size()>0) accountReferenceFields = selectlistSort(accountReferenceFields);
            if(contactReferenceFields.size()>0) contactReferenceFields = selectlistSort(contactReferenceFields);
            if(sobjectTextFields.size()>0) sobjectTextFields = selectlistSort(sobjectTextFields);
            if(sobjectNumberFields.size()>0) sobjectNumberFields = selectlistSort(sobjectNumberFields);
            showFieldsMapping = true;
        }
        else {
            Apexpages.addmessage(new Apexpages.Message(ApexPages.Severity.ERROR,' Please select an object from which you want to create a Transaction'));
        }
        return null;
    }
    
    public PageReference generateURL() {
        if(string.isBlank(parent_object_reference)){
            Apexpages.addmessage(new Apexpages.Message(ApexPages.Severity.ERROR,' Please select Salesforce '+customerMatchType+' to proceed further.'));
            return null;
        }
        showURLBlock=true;
        showFieldsMapping = true;
        url='';
        url ='/apex/'+BreadwinnerUtil.namespaceApi+'CreateTransaction'+'\n';
        if(!string.isBlank(selectedObject)){
            url +=string.isBlank(selectedObject)?'':'?originating_record={!'+selectedObject+'.id}'+'\n';
            url +=string.isBlank(parent_object_reference)?'':'&parent_id='+parent_object_reference+'\n';                
            url +=string.isBlank(payment_amount) ?'':'&payment_amount='+payment_amount+'\n';
            url +=string.isBlank(payment_currency) ?'':'&payment_currency='+payment_currency+'\n';
            url +=string.isBlank(payment_description) ?'':'&payment_description='+payment_description+'\n';                
        }
        return null;
    }
    
    
    public void goBack(){
        showFieldsMapping = false;
        showURLBlock = false;
        showOriginatingObjects = true;
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