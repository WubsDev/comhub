trigger InputAfterInsert on Input__c (after insert ,before insert ,before update) {
    
    inputTriggerHandler objHandler=new inputTriggerHandler();
    //I-148567,  Ranjeet Singh, Need to add validation for Invoice and Input - Duplicate Inputs are allowed
    if(trigger.isBefore && trigger.isUpdate) {
        objHandler.triggerHandler_BeforeUpdate(trigger.new);
    }
    
    if(trigger.isBefore && trigger.isInsert) {
        objHandler.triggerHandler_BeforeInsert(trigger.new);
        InputAutoFollowHandler.updateOwnerSharing(trigger.new);
    }   
	//April-01 : Updated By Ranjeet(Appirio) : Moved existing code to isInsert and isAfter event block 
    if(Trigger.isInsert && trigger.isAfter){
    	
    	InputAutoFollowHandler inputAuto = new InputAutoFollowHandler();
    	inputAuto.triggerHandler_AfterInsert(Trigger.new);
    	
        Set<Id>             accountIdSet               = New Set<Id>();
        Set<String>         nameSet                    = New Set<String>();
        Set<Id>             profileIdSet               = New Set<Id>();
        List<Input__Share>  inputShareList             = New List<Input__Share>();
        map<Id, List<User>> accountIdUsersMap          = New map<Id, List<User>>();
        Set<String>         inputIdSet                 = new Set<String>();
        Map<String, String> inputBeneficiaryOwnerIdByInputId    = New Map<String, String>();
        
        List<Input_Beneficiary__Share>  inputBeneShareList      = New List<Input_Beneficiary__Share>();
        
        //get all custom setting names
        for (Input_Configuration__c cs : Input_Configuration__c.getall().values())
        {
            nameSet.add(cs.Name);
        }
        system.debug('name set Values: ' + nameSet);
        //get all profiles ids
        for (Profile p : [select Id from Profile where Name in: nameSet])
        {
            profileIdSet.add(p.Id);
        }
        system.debug('profile ids Values: ' + profileIdSet);
        
        
        /* START: Test Section
        List<String> inputId = new List<String>();
        for (Input__c input : Trigger.new) {
            inputId.add(input.Id);
        }
        
        InputManualSharing.shareInputRecords(inputId, Userinfo.getUserId());
        END: Test Section*/
        
    //if (!profileIdSet.contains(UserInfo.getProfileId())) {
        //get all account id for input new  
        for (Input__c input : Trigger.new) {
            if (input.Parent_Account__c != null)
            {
                accountIdSet.add(input.Parent_Account__c);
            }
            
            inputIdSet.add(input.Id);
        }
        
        /* 
         * Updated By: Bohao Chen on 19/Mar/2014
         * Description: create map for input beneficiary owner by input id
         */
        for(Input__c i : [Select i.Id, i.Input_Beneficiary__r.OwnerId From Input__c i Where i.Id IN: inputIdSet])
        {
          inputBeneficiaryOwnerIdByInputId.put(i.Id, i.Input_Beneficiary__r.OwnerId);
        }
        
        system.debug('@InputAfterInsert inputBeneficiaryOwnerIdByInputId ' + inputBeneficiaryOwnerIdByInputId);
        
        system.debug('account ids Values: ' + accountIdSet);
		//April-01 : Updated By Ranjeet(Appirio) : Added criteria "UserType <>'CspLitePortal'", as shating not allowed for comunity user
		for (User u : [Select Id, Name, ContactId, Contact.AccountId from User 
			where	Contact.AccountId in: accountIdSet 
					And Id !=: Userinfo.getUserId() 
                    and UserType NOT IN ('CspLitePortal','PowerPartner')]) {
                    	system.debug('------------u----------------'+u);
            if (!accountIdUsersMap.containsKey(u.Contact.AccountId))
                accountIdUsersMap.put(u.Contact.AccountId, new List<User>{u});
            else 
                accountIdUsersMap.get(u.Contact.AccountId).add(u);
        }
        system.debug('account ids map values: ' + accountIdUsersMap);
        system.debug('account ids map values: ' + Trigger.new);
        //generate manual sharing list
        for (Input__c input : Trigger.new) {
            if (input.Parent_Account__c != null) {
                if (accountIdUsersMap.containsKey(input.Parent_Account__c)) {
                	system.debug('------------input----------------'+input);
                    for (User u : accountIdUsersMap.get(input.Parent_Account__c)) 
                    {
                        /* 
                         * Updated By: Bohao Chen on 19/Mar/2014
                         * Description: Because we cannot share the record with the user who is the owner of record
                         */
                        system.debug('------------input----------------'+input+'------------u.id---'+u.Id);
                        if(u.Id != input.OwnerId)
                        {  
                            inputShareList.add(new Input__Share(ParentId = input.Id, UserOrGroupId = u.Id, AccessLevel = 'Edit'));
                        }
                    }
                }
            }
        }
        
        // shares the input beneficiary - added by tim.
        for (Input__c input : Trigger.new) {
            if (input.Parent_Account__c != null) {
                if (accountIdUsersMap.containsKey(input.Parent_Account__c)) {
                    if (input.Input_Beneficiary__c != null) {
                        for (User u : accountIdUsersMap.get(input.Parent_Account__c)) 
                        {
                            /* 
                             * Updated By: Bohao Chen on 19/Mar/2014
                             * Description: Because we cannot share the record with the user who is the owner of record
                             */                         
                            if(inputBeneficiaryOwnerIdByInputId.containsKey(input.Id) && u.Id != inputBeneficiaryOwnerIdByInputId.get(input.Id))
                            {
                                inputBeneShareList.add(new Input_Beneficiary__Share(ParentId = input.Input_Beneficiary__c, UserOrGroupId = u.Id, AccessLevel = 'Edit'));
                            }
                        }
                    }
                }
            }
        }
        system.debug('inputBeneShareList ids map values: ' + inputBeneShareList);
        system.debug('inputShareList ids map values: ' + inputShareList);
        insert inputBeneShareList;
        if(inputShareList.size() > 0){
        insert inputShareList;
    }
        
    }
}