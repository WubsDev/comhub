/**=====================================================================
 * Name: ForwardContractTrigger
 * Description: Created Trigger to Populate Market Rate on Forward Contracts(T-358848)
 * Created Date: Feb 09, 2015
 * Created By: Nishant Bansal (JDC)
 *
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/

trigger ForwardContractTrigger on Forward_Contracts__c (before insert, before update) {
	
	// Before insert
    if(trigger.isInsert && trigger.isbefore){        
        ForwardContractTriggerHandler.beforeInsert(trigger.new);  
    }
    
    // Before Update
    if(trigger.isUpdate && trigger.isbefore){        
        ForwardContractTriggerHandler.beforeUpdate(trigger.new,trigger.oldMap);  
    }

}