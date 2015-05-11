// 
// (c) 2014 Appirio, Inc.
//
// UserManager
// Used as Trigger handler for UserUpdateCurrency trigger
//
// 05 May, 2015    Ashish Goyal  Original (Ref. T-392409, T-392431)
//
public with sharing class UserManager {
	public static final String EMAIL_TEMPLATE = 'ManageCashWelcomeEmail';
	
	public static void updateFederationIdBI(List<User> userList){
		for(User tUser : userList){
			if(tUser.Username != null && tUser.FederationIdentifier == null){
				tUser.FederationIdentifier = tUser.Username;
			}
		}
	}
	
	public static void updateFederationIdBU(List<User> userList, Map<Id, User> userMap){
		for(User tUser : userList){
			if((tUser.Username != null && tUser.FederationIdentifier == null)||
					( tUser.Username != null && tUser.Username != userMap.get(tUser.Id).Username)){
				tUser.FederationIdentifier = tUser.Username;
			}
		}
	}
	
	
	public static void updateDisclaimer(List<User> userList){
		system.debug('***updateDisclaimer 1:');
		Map<String, Email_Disclaimer__c> emailDisclaimerMap = new Map<String, Email_Disclaimer__c>();
		for(Email_Disclaimer__c emailDisc : [SELECT Name, Disclaimer__c FROM Email_Disclaimer__c LIMIT 999]){
			emailDisclaimerMap.put(emailDisc.Name, emailDisc);
		}
		system.debug('***updateDisclaimer 2:'+emailDisclaimerMap);
		
		String disclaimer = 'USA';
		for(User tUser : userList){
			if(tUser.Country == null){
				tUser.Disclaimer__c = emailDisclaimerMap.get(disclaimer).Disclaimer__c;
				system.debug('***updateDisclaimer 3.1:'+userList);
			}
			else{
				tUser.Disclaimer__c = emailDisclaimerMap.get(tUser.Country).Disclaimer__c;
				system.debug('***updateDisclaimer 3.2:'+userList);
			}
		}
		system.debug('***updateDisclaimer 3:'+userList);
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
}