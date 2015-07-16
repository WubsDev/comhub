// 
// (c) 2014 Appirio, Inc.
//
// InputAutoFollowHandler
// Used as trigger handler for Input object trigger
//
// 02 Apr, 2015    Ashish Goyal  Original (Ref. T-375827)
//
public without sharing class InputAutoFollowHandler{
  
// AutoFollow the Input records after insert    
    public void triggerHandler_AfterInsert(list<Input__c> listInput){
		set<Id> inputIdToFollow=new set<Id>();
		try{
			for(Input__c inv :listInput){
	            inputIdToFollow.add(inv.Id);
	        }
		    
		    if(inputIdToFollow != null && inputIdToFollow.size()>0){
		    	ID contactId = [Select contactid from User where id =: Userinfo.getUserid()].contactId;
				ID AccOwnerID  = null;
				if(contactId!=null){
					AccOwnerID = [Select AccountID, Account.OwnerId from Contact where id =: contactId and AccountID!=null].Account.OwnerId;
		        	AutoFollowTheRecords.followRecords(inputIdToFollow,AccOwnerID);
				}
			}
		}
		catch(exception ex){
		    system.debug('Exception occur->'+ex);
		}
    }
    
    
    public static void updateOwnerSharing(List<Input__c> listInput){
    	List<Input__c> updateList = new List<Input__c>();
    	Map<Id, List<Input__c>> ownerIdInputListMap = new Map<Id, List<Input__c>>();
    	Map<Id, Id> accountIdInputListMap = new Map<Id, Id>();
    	Set<Id> accountIdSet = new Set<Id>();
    	
    	for(Input__c input : listInput){
    		if(!ownerIdInputListMap.containsKey(input.OwnerId)){
    			ownerIdInputListMap.put(input.OwnerId, new List<Input__c>());
    		}
    		ownerIdInputListMap.get(input.OwnerId).add(input);
    		
    		if(!accountIdInputListMap.containsKey(input.OwnerId)){
    			accountIdInputListMap.put(input.OwnerId, input.Parent_Account__c);
    		}
    	}
    	if(ownerIdInputListMap.size() > 0){
    		system.debug('--------------------ownerIdInputListMap-----------------'+ownerIdInputListMap);
    		for(User tUser : [SELECT Id, Share_Records__c from User Where Id IN :ownerIdInputListMap.keySet()]){
    			if(tUser.Share_Records__c){
    				accountIdSet.add(accountIdInputListMap.get(tUser.Id));
    			}
    		}
    		if(accountIdSet.size() > 0){
    			Map<Id, Account> accountIdObjMap = new Map<Id, Account>([Select Id, OwnerId from Account Where Id IN: accountIdSet]);
    			for(Id ownerId : accountIdInputListMap.keySet()){
    				if(accountIdObjMap.containsKey(accountIdInputListMap.get(ownerId))){
    					for(Input__c testInput : ownerIdInputListMap.get(ownerId)){
    						system.debug('----------------------------------------'+testInput.OwnerId);
    						testInput.Original_Owner__c = testInput.OwnerId;
    						testInput.OwnerId = accountIdObjMap.get(accountIdInputListMap.get(ownerId)).OwnerId;
    						system.debug('----------------------------------------'+testInput.OwnerId);
    						// updateList.add(testInput);
    					}
    				}
    			}
    		}
    	}
    }
}