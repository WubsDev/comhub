public with sharing class CMPUserCreationPageExtenision {
    public Contact contactRecord {get; set;}
    public User commUser {get; set;}
    public List<SelectOption> profileList {get; set;}
    public String userLicense {get; set;}
    
    public CMPUserCreationPageExtenision(ApexPages.StandardController stdController){
        String contactId = ApexPages.currentPage().getParameters().get('contactId');
        String userId = ApexPages.currentPage().getParameters().get('Id');
        profileList = new List<SelectOption>();
        if(String.isEmpty(userId)){
            commUser = new User();
            if(!String.isEmpty(contactId)){
                // Updated : 07/02/2015 - T-412820 - Megha Agarwal - pre-populate value from contact  
                contactRecord = [SELECT FirstName, LastName, Name, Email from Contact where Id =: contactId];
                commUser = new User(FirstName = contactRecord.FirstName, LastName = contactRecord.LastName, ContactId = contactRecord.Id, Email = contactRecord.Email , username = contactRecord.Email, isActive =  true);
                if(commUser.Email != null){
                  commUser.CommunityNickname = commUser.Email.contains('@') ? commUser.Email.subString(0, commUser.Email.indexOf('@')) : commUser.Email;
                }
                if(commUser.FirstName != null){
                    commUser.alias = commUser.FirstName.subString(0,1);
                }else{
                    commUser.alias = '';
                }
                if(commUser.lastName != null){
                    commUser.alias += commUser.lastName.length() > 4 ? commUser.LastName.subString(0,4) : commUser.lastName;
                }
                commUser.alias = commUser.alias.tolowerCase();
                
                    
            }else{
                commUser = new User();
            }
            for(CMPUserFieldDefaultValue__c defaultValue : CMPUserFieldDefaultValue__c.getAll().values()){
                commUser.put(defaultValue.Name, defaultValue.default_Value__c);
            }
            commUser.emailencodingkey='UTF-8';
            commUser.languagelocalekey='en_US';
            commUser.localesidkey='en_US';
            commUser.timezonesidkey='America/Indiana/Indianapolis';
        }else{
            commUser = [SELECT Id, FirstName, LastName,Email, Username, Alias, IsActive, ProfileId, ContactId,
                            Phone, Extension, CommunityNickname, Fax, Title, MobilePhone, CompanyName,
                            EmailEncodingKey, Department, Street, LanguageLocaleKey, State, PostalCode, Country,
                            FederationIdentifier, TimeZoneSidKey, LocaleSidKey, City, CurrencyIsoCode 
                            FROM User WHERE Id =:userId];
        }
        String prof = '%'+Label.Community_Profile+'%';
        for(Profile pf : [Select Id, Name, UserLicense.Name from Profile WHERE Name LIKE :prof LIMIT 999]){
            profileList.add(new SelectOption(pf.Id, pf.Name));
            userLicense = pf.UserLicense.Name;
        }
        if(profileList.size() > 0){
            commUser.ProfileId = profileList.get(0).getValue();
        }
    }
    
    
    public PageReference custSave(){
        try{
            if(String.isEmpty(commUser.Id)){
                insert commUser;
            }else{
                update commUser;
            }
            return new PageReference('/'+commUser.ContactId);
        }
        catch(Exception ex){
            ApexPages.addMessages(ex);
            system.debug('---exception >>>>>------'+ex);
            return null;
        }
    }
    
    public PageReference custCancel(){
        if(String.isEmpty(commUser.Id)){
            return new PageReference('/'+contactRecord.Id);
        }else{
            return new PageReference('/'+commUser.ContactId);
        }
    }
}