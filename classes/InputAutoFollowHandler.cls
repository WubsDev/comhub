// 
// (c) 2014 Appirio, Inc.
//
// InputAutoFollowHandler
// Used as trigger handler for Input object trigger
//
// 02 Apr, 2015    Ashish Goyal  Original (Ref. T-375827)
//
public class InputAutoFollowHandler{
  
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
}