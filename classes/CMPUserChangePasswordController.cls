public with sharing class CMPUserChangePasswordController {
    
    public String password {get; set;}
    public String rePassword {get; set;}
    public String returnURL {get; set;}
    
    public CMPUserChangePasswordController(){
        returnURL = ApexPages.currentPage().getParameters().get('retURL');
    }
    
    public PageReference changePassword(){
        boolean isvalidate = false;
        if(String.isEmpty(password)){
            isvalidate = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.CM_Validation_User_PleaseEnterValueForPassword));
        }
        if(String.isEmpty(rePassword)){
            isvalidate = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.CM_Validation_User_PleaseEnterValueForConfirmPassword));
        }
        if(password.length() < 8){
            isvalidate = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.CM_Alert_User_PasswordInvalid));
        }
        if(isvalidate){
            return null;
        }
        else{
            if(password.equals(rePassword)){
                try{                    
                    System.setPassword(UserInfo.getUserId(), password);
                    if(returnURL != null) {
                        return new Pagereference(returnURL);
                    }
                    return Page.CMPUserDetail;
                }
                catch(Exception ex){
                    ApexPages.addMessages(ex);
                    return null;
                }   
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.CM_Alert_User_PasswordsDoNotMatch));
                return null;
            }    
        }   
    }
    
    
    public PageReference passwordCancel(){
        if(returnURL != null) {
            return new Pagereference(returnURL);
        }
        return null;
    }

}