trigger BWPProcessorConfigTrigger on BWP_Processor_Config__c (before insert, before update, before delete) {
    if(trigger.isBefore){
        if (!BreadwinnerUtil.isBreadwinnerTransaction){
            for(BWP_Processor_Config__c bwp : (trigger.isDelete? trigger.old : trigger.new)){
                bwp.addError('Access denied. This operation can be performed only from within Breadwinner.');
            }
        }
    }
}