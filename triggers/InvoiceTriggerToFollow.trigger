trigger InvoiceTriggerToFollow on Invoice__c (after insert ,before insert ,before update) {
	InvoiceAutoFollowHandler objHandler=new InvoiceAutoFollowHandler();
    // if insert
    if(trigger.isInsert && trigger.isAfter){        
        objHandler.triggerHandler_AfterInsert(trigger.new);
    }
    
    if(trigger.isBefore && trigger.isUpdate) {
    	objHandler.triggerHandler_BeforeUpdate(trigger.new);
    }
    
    if(trigger.isBefore && trigger.isInsert) {
    	objHandler.triggerHandler_BeforeInsert(trigger.new);
    }
    
    
    // if update
   /* if(trigger.isUpdate){       
        objHandler.triggerHandler_AfterUpdate(trigger.oldMap,trigger.new);
    }*/
}