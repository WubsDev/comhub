// 
// (c) 2014 Appirio, Inc.
//
// UserManager
// Used as Trigger handler for UserUpdateCurrency trigger
//
// 05 May, 2015    Ashish Goyal  Original (Ref. T-392409, T-392431)
//
// Updated By : 18 June 2015		Ashish Goyal	Ref: T-410586
//
public with sharing class UserManager {
	public static final String EMAIL_TEMPLATE = 'ManageCashWelcomeEmail2';
	public static Set<Id> commProfileIdSet = new Set<Id>();
	
	public static void updateFederationIdBI(List<User> userList){
		getProfileId();
		for(User tUser : userList){			
			if(commProfileIdSet.contains(tUser.ProfileId) && tUser.Username != null && tUser.FederationIdentifier == null){
				tUser.FederationIdentifier = tUser.Username;
			}
			/*if(tUser.CurrencyIsoCode != null){
				UserCurrencyAndDisclaimer__c myCS1 = UserCurrencyAndDisclaimer__c.getValues(tUser.CurrencyIsoCode);
				if(myCS1 != null){
					tUser.Region__c = myCS1.Disclaimer__c;
				}
			}*/
		}
	}
	
	// @author : @Ashish Goyal (Ref : T-410586) 
	// @desc : handle the before update event on User
	// @param : List of User object record 
	// @param : Map of Id and User object record 
	// @return : void	
	
	public static void updateFederationIdBU(List<User> userList, Map<Id, User> userMap){
		getProfileId();
		Set<Id> updateSharingUserIdSet = new Set<Id>();
		Set<Id> resetSharingUserIdSet = new Set<Id>();
		
		for(User tUser : userList){
			if(commProfileIdSet.contains(tUser.ProfileId) && ((tUser.Username != null && tUser.FederationIdentifier == null)||
					( tUser.Username != null && tUser.Username != userMap.get(tUser.Id).Username))){
				tUser.FederationIdentifier = tUser.Username;
			}			
			
			if(tUser.Share_Records__c && tUser.Share_Records__c != userMap.get(tUser.Id).Share_Records__c){
				updateSharingUserIdSet.add(tUser.Id);
			}
			if(!tUser.Share_Records__c && tUser.Share_Records__c != userMap.get(tUser.Id).Share_Records__c){
				resetSharingUserIdSet.add(tUser.Id);
		}
	}
	
		if(updateSharingUserIdSet.size() > 0){
			InputInvoiceSharingManager.updateSharingPermission(updateSharingUserIdSet);
		}
		if(resetSharingUserIdSet.size() > 0){
			InputInvoiceSharingManager.resetSharingPermission(resetSharingUserIdSet);
			}
	}
	
	
	
	/*
	public static void sendAccountOwnerEmail(List<User> userList, Map<Id, User> userMap){
		String prof = '%'+Label.UserProfile+'%';
		Set<Id> profileIdSet = new Set<Id>();
		for(Profile pf : [Select Id from Profile Where Name like : prof]){
			profileIdSet.add(pf.Id);
		}
		List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
		
		EmailTemplate emailTemp = [Select Id from EmailTemplate WHERE Name =:EMAIL_TEMPLATE];
		if(emailTemp == null){
			
		}
		Map<Id, List<Id>> contactIdUserIdMap = new Map<Id, List<Id>>();
		for(User tUser : userList){
			if(tUser.ContactId != null && tUser.IsActive && profileIdSet.contains(tUser.ProfileId)){
				if(!contactIdUserIdMap.containsKey(tUser.ContactId)){
					contactIdUserIdMap.put(tUser.ContactId, new List<Id>());
				}
				contactIdUserIdMap.get(tUser.ContactId).add(tUser.Id);
			}
		}
		if(contactIdUserIdMap.size() > 0){
			Messaging.SingleEmailMessage emailMsj;
			for(Contact testCon : [SELECT ID, AccountId, Account.OwnerId, Account.Owner.Email,
										Account.Owner.Name FROM Contact
										WHERE Id IN: contactIdUserIdMap.keySet()]){
				for(Id userId : contactIdUserIdMap.get(testCon.Id)){
					User testUser = userMap.get(userId);
					emailMsj = new Messaging.SingleEmailMessage();
					emailMsj.setSenderDisplayName(testCon.Account.Owner.Name);
					if(emailTemp != null){
						emailMsj.setTemplateId(emailTemp.Id);
					}else{
						emailMsj.setPlainTextBody('Welcome..!!!');
					}
					emailMsj.setTargetObjectId(testUser.Id);
					emailMsj.setReplyTo(testCon.Account.Owner.Email);
					emailMsj.setToAddresses(new List<String>{testUser.Email});
					emailMsj.setSaveAsActivity(false);
					emailList.add(emailMsj);
				}
			}
			
			if(emailList.size() > 0){
				try{
					Messaging.sendEmail(emailList);
				}catch(Exception ex){
					system.debug('-----ashish-----------------'+ex);
				}
			}
		}
	}*/
	
	
	public static void getProfileId(){
		String prof = '%'+Label.Community_Profile+'%';
		for(Profile pf : [SELECT Id from Profile WHERE Name like : prof]){
			commProfileIdSet.add(pf.Id);
		}
	}
	
	
	public static void updateContactAI(List<User> userList){
		Set<Id> contactIdSet = new Set<Id>();
		List<Contact> contactToUpdate = new List<Contact>();
		for(User tUser : userList){
			if(tUser.ContactId != null){
				contactIdSet.add(tUser.ContactId);
			}
		}
		if(contactIdSet.size() > 0){
			for(Contact con : [SELECT Id, hasCMPUser__c FROM Contact where Id IN:contactIdSet]){
				con.hasCMPUser__c = true;
				contactToUpdate.add(con);
			}
			if(contactToUpdate.size() > 0){
				update contactToUpdate;
			}
		}
	}
	
	
	public static void updateContactAU(List<User> userList, Map<Id, User> userMap){
		Set<Id> contactIdSet = new Set<Id>();
		List<Contact> contactToUpdate = new List<Contact>();
		for(User tUser : userList){
			if(tUser.ContactId == null && tUser.ContactId != userMap.get(tUser.Id).ContactId){
				contactIdSet.add(userMap.get(tUser.Id).ContactId);
			}
		}
		if(contactIdSet.size() > 0){
			for(Contact con : [SELECT Id, hasCMPUser__c FROM Contact where Id IN:contactIdSet]){
				con.hasCMPUser__c = false;
				contactToUpdate.add(con);
			}
			if(contactToUpdate.size() > 0){
				update contactToUpdate;
			}
		}
	}
	
}