/******************************************************************************
 Created By : Appirio
 Created Date : April. 16, 2015
 Description : Trigger on Input-Beneficiary object
******************************************************************************/
trigger InputBeneficiaryTrigger on Input_Beneficiary__c (before insert, before update) {
	InputBeneficiaryTriggerHandler triggerHandler =new InputBeneficiaryTriggerHandler();
	if(Trigger.isAfter){
		if(Trigger.isInsert){
			triggerHandler.triggerHandler_BeforeInsert(trigger.New);
		}
		if(Trigger.isUpdate){
			triggerHandler.triggerHandler_BeforeUpdate(trigger.New, trigger.oldMap);
		}
	}
}