global class SendLogInNoticationToContactBatch  implements Database.Batchable<sObject> {
	global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Name, OwnerId, Owner.Email FROM Account Order By Name';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Account> scope) {
    	Set<Id> accountIdSet = new Set<Id>();
    	Map<id, List<Account>> userIdListAccountObjMap = new Map<Id, List<Account>>();
    	Map<Id, String> userLoggedInSevenDays = new Map<Id, String>();
    	Map<Id, String> userNotLoggedInSevenDays = new Map<Id, String>();
    	List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
    	for(Account acc : scope){
    		accountIdSet.add(acc.Id);
    		if(!userIdListAccountObjMap.containsKey(acc.OwnerId)){
    			userIdListAccountObjMap.put(acc.OwnerId, new List<Account>());
    		}
    		userIdListAccountObjMap.get(acc.OwnerId).add(acc);
    	}
		system.debug('-----------userIdListAccountObjMap----------'+userIdListAccountObjMap);
    	String profName = '% '+Label.Community_Profile +'%';
    	for(User usr : [SELECT Id,Name, LastLoginDate,Email, ContactId, Contact.AccountId, Contact.Account.OwnerId, 
    									Contact.Account.Name, ProfileId FROM User Where Contact.AccountId IN :accountIdSet
    									AND Profile.Name LIKE :profName]){
    		String mailBody = '';
			if(usr.LastLoginDate == null || Date.valueOf(usr.LastLoginDate) < System.today().addDays(-7)){
				if(!userNotLoggedInSevenDays.containsKey(usr.Contact.AccountId)){
					mailBody = '';
					userNotLoggedInSevenDays.put(usr.Contact.AccountId, mailBody);
				}
				String emailText = userNotLoggedInSevenDays.get(usr.Contact.AccountId);
				emailText += '<tr><td style="border: 1px solid grey;">'+usr.Name+'</td><td style="border: 1px solid grey;">'+usr.Email+'</td><td style="border: 1px solid grey;">'+usr.Contact.Account.Name+'</td></tr>';
				userNotLoggedInSevenDays.put(usr.Contact.AccountId, emailText);
			}
			else if(usr.LastLoginDate != null && (System.today().daysBetween(Date.valueOf(usr.LastLoginDate))) <= 7){
				if(!userLoggedInSevenDays.containsKey(usr.Contact.AccountId)){
					mailBody = '';
					userLoggedInSevenDays.put(usr.Contact.AccountId, mailBody);					
				}
				String emailText2 = userLoggedInSevenDays.get(usr.Contact.AccountId);
				emailText2 += '<tr><td style="border: 1px solid grey;">'+usr.Name+'</td><td style="border: 1px solid grey;">'+usr.Email+'</td><td style="border: 1px solid grey;">'+usr.Contact.Account.Name+'</td></tr>';
				userLoggedInSevenDays.put(usr.Contact.AccountId, emailText2);
			}
    	}
    	
    	for(Id userId : userIdListAccountObjMap.keySet()){
    		Messaging.SingleEmailMessage email = new Messaging.Singleemailmessage();
    		email.setSubject('CMP Customer Pulse');
    		email.setSaveAsActivity(false);	            
		    email.setTargetObjectId(userId);
		    email.setReplyTo('managecashflow@WesternUnion.com');
		    email.setHtmlBody('Hi<br />');
		    String emailBodyNotLoggedIn = '<br />Contacts Who Did Not Log In to CMP.<br /><table style="border: 1px solid grey;"><tr><th style="border: 1px solid grey;">Contact Name</th>'+
											+'<th style="border: 1px solid grey;">Contact Email</th><th style="border: 1px solid grey;">Account Name</th></tr>';
		    String emailBodyLoggedIn = '<br />Contacts Who Logged In to CMP.<br /><table style="border: 1px solid grey;"><tr><th style="border: 1px solid grey;">Contact Name</th>'+
	            							+'<th style="border: 1px solid grey;">Contact Email</th><th style="border: 1px solid grey;">Account Name</th></tr>';
		    
			for(Account testAcc : userIdListAccountObjMap.get(userId)){
				email.setToAddresses(new List<String>{testAcc.Owner.Email});
				if(userNotLoggedInSevenDays.containsKey(testAcc.Id)){	
					emailBodyNotLoggedIn = emailBodyNotLoggedIn+''+userNotLoggedInSevenDays.get(testAcc.Id);
				}       
				if(userLoggedInSevenDays.containsKey(testAcc.Id)){
	            	emailBodyLoggedIn = emailBodyLoggedIn+''+ userLoggedInSevenDays.get(testAcc.Id);
				}
	        }
	        emailBodyLoggedIn = emailBodyLoggedIn + '</table><br />';
	        emailBodyNotLoggedIn = emailBodyNotLoggedIn + '</table><br />';
	        email.setHtmlBody(email.getHtmlBody()+''+emailBodyLoggedIn+''+emailBodyNotLoggedIn+'<br /> <br />Thanks,<br />Western Union');	        
	        sendEmailList.add(email);
    	}
        if(sendEmailList.size() > 0){
        	try{
        		system.debug('-----ashish-----------------'+sendEmailList);
				Messaging.sendEmail(sendEmailList);
			}catch(Exception ex){
				system.debug('-----ashish----error-------------'+ex);
			}
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
    }
    

}