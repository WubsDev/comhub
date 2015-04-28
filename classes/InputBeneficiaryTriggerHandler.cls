/******************************************************************************
 Created By : Appirio
 Created Date : Feb. 13, 2015
 Description : Handler class for InputBeneficiaryTrigger
******************************************************************************/
public without sharing class InputBeneficiaryTriggerHandler {
	public void triggerHandler_BeforeInsert(List<Input_Beneficiary__c> listNew){
		checkDuplicate(listNew, null, true, false);
	}
	public void triggerHandler_BeforeUpdate(List<Input_Beneficiary__c> listNew, map<Id, Input_Beneficiary__c> mapOld){
		checkDuplicate(listNew, mapOld, false, true);
	}
	public void checkDuplicate(List<Input_Beneficiary__c> listNew, map<Id, Input_Beneficiary__c> mapOld, boolean isInsert, boolean isUpdate){
        
        Set<Id> setAccountIds = new Set<Id>();
        Set<String> setBenfNames = new Set<String>();
        
        for(Input_Beneficiary__c b : listNew){
            if(isInsert || (isUpdate && (b.Name != mapOld.get(b.Id).Name))){
                setAccountIds.add(b.account__c);
                setBenfNames.add(b.Name);
            }
        }
        
        Map<Id, Set<String>> mapAccIdExistingBenefNames = new Map<Id, Set<String>>();
        
        for(Input_Beneficiary__c b : [SELECT Name, account__c 
                                FROM Input_Beneficiary__c
                                Where account__c in :setAccountIds
                                and Name in : setBenfNames]){
            if(!mapAccIdExistingBenefNames.containsKey(b.account__c)){
                mapAccIdExistingBenefNames.put(b.account__c, new Set<String>{b.Name});
            }else{
                mapAccIdExistingBenefNames.get(b.account__c).add(b.Name);
            }
        }
        
        for(Input_Beneficiary__c b : listNew){
            if(mapAccIdExistingBenefNames.containsKey(b.account__c) &&
                mapAccIdExistingBenefNames.get(b.account__c).contains(b.Name)){
                    b.addError('Another Beneficiary with the same name already exists for this account.');
                }
        }
        
    }	
}