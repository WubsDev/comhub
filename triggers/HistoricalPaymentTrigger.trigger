/**=====================================================================
 * Name: HistoricalPaymentTrigger
 * Description: Trigger to Populate Market Rate on Historical Payments(T-358854)
 * Created Date: Feb 10, 2015
 * Created By: Nishant Bansal (JDC)
 *
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/

trigger HistoricalPaymentTrigger on Historical_Payments__c (before insert, before update) {
	
	// Before insert
    if(trigger.isInsert && trigger.isbefore){        
        HistoricalPaymentTriggerHandler.beforeInsert(trigger.new);  
    }
    
    // Before Update
    if(trigger.isUpdate && trigger.isbefore){        
        HistoricalPaymentTriggerHandler.beforeUpdate(trigger.new,trigger.oldMap);  
    }
 
}