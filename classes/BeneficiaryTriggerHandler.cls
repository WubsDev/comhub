/******************************************************************************
 Created By : Appirio
 Created Date : Feb. 13, 2015
 Description : Handler class for BeneficiaryTrigger
******************************************************************************/
public class BeneficiaryTriggerHandler {
    
    public static void checkDuplicate(List<Beneficiary__c> listNew, map<Id, Beneficiary__c> mapOld, boolean isInsert, boolean isUpdate){
        
        Set<Id> setAccountIds = new Set<Id>();
        Set<String> setBenfNames = new Set<String>();
        
        for(Beneficiary__c b : listNew){
            if(isInsert || (isUpdate && (b.Name != mapOld.get(b.Id).Name))){
                setAccountIds.add(b.Account_Name__c);
                setBenfNames.add(b.Name);
            }
        }
        
        Map<Id, Set<String>> mapAccIdExistingBenefNames = new Map<Id, Set<String>>();
        
        for(Beneficiary__c b : [SELECT Name, Account_Name__c 
                                FROM Beneficiary__c
                                Where Account_Name__c in :setAccountIds
                                and Name in : setBenfNames]){
            if(!mapAccIdExistingBenefNames.containsKey(b.Account_Name__c)){
                mapAccIdExistingBenefNames.put(b.Account_Name__c, new Set<String>{b.Name});
            }else{
                mapAccIdExistingBenefNames.get(b.Account_Name__c).add(b.Name);
            }
        }
        
        for(Beneficiary__c b : listNew){
            if(mapAccIdExistingBenefNames.containsKey(b.Account_Name__c) &&
                mapAccIdExistingBenefNames.get(b.Account_Name__c).contains(b.Name)){
                    b.addError('Another Beneficiary with the same name already exists for this account.');
                }
        }
        
    }
}