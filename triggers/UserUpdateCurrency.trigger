trigger UserUpdateCurrency on User (before insert, before update, after insert) {

    
    
    
    // Updated By : 05th May 2015   @Ashish Goyal   
    // Ref : T-392409
    // Desc : To update the FederationId with the username of user 
    //          Before update and before insert event
    
    if(Trigger.isInsert){
        if(Trigger.isBefore){
            for (User newUser: Trigger.new) {
                newUser.Currency_Custom_Field__c = newUser.DefaultCurrencyIsoCode;
            }
            UserManager.updateFederationIdBI(Trigger.new);
    		UserManager.updateDisclaimer(Trigger.new);
        }
        
        // Updated By : 05th May 2015   @Ashish Goyal   
        // Ref : T-392431
        // Desc : To send email to Account owner when new community user is created
        /*
        if(Trigger.isAfter){
            UserManager.sendAccountOwnerEmail(Trigger.new, Trigger.newMap);
        }*/
    }
    
    if(Trigger.isUpdate){
        for (User newUser: Trigger.new) {
            newUser.Currency_Custom_Field__c = newUser.DefaultCurrencyIsoCode;
        }
        //Updated Disabled FederationId On Sushant Request for update 10 May-2015
        UserManager.updateFederationIdBU(Trigger.new, Trigger.oldMap);
    }
    
    // End @Ashish Goyal
    
}