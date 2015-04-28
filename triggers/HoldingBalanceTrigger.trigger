/**=====================================================================
 * Name: HoldingBalanceTrigger
 * Description: Trigger to Populate Market Rate on Holding Balance(T-358826)
 * Created Date: Feb 09, 2015
 * Created By: Nishant Bansal (JDC)
 *
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/

trigger HoldingBalanceTrigger on Holding_Balance__c (before insert, before update) {
	
	// Before insert
    if(trigger.isInsert && trigger.isbefore){        
        HoldingBalanceTriggerHandler.beforeInsert(trigger.new);  
    }
    
    // Before Update
    if(trigger.isUpdate && trigger.isbefore){        
        HoldingBalanceTriggerHandler.beforeUpdate(trigger.new,trigger.oldMap);  
    }

}