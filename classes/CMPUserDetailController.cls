public with sharing class CMPUserDetailController {
	
	public User commUser {get; set;}
	public String returnURL {get; set;}
	
	public CMPUserDetailController(){
		String userId = ApexPages.currentPage().getParameters().get('Id');
		returnURL = ApexPages.currentPage().getParameters().get('retURL');
		if(!String.isEmpty(userId)){
			commUser = [SELECT Id, FirstName, LastName,Email, Username, Alias, IsActive, ProfileId, ContactId,
 							Phone, Extension, CommunityNickname, Fax, Title, MobilePhone, CompanyName,
 							EmailEncodingKey, Department, Street, LanguageLocaleKey, State, PostalCode, Country,
 							FederationIdentifier, TimeZoneSidKey, LocaleSidKey, City, CurrencyIsoCode 
 							FROM User WHERE Id =:userId];
		}
	}
	
	
	public PageReference custUpdate(){
		try{
			update commUser;
			if(returnURL != null) {
	 			return new Pagereference(returnURL);
	 		}
			return Page.CMPUserDetail;
		}catch(Exception ex){
			ApexPages.addMessages(ex);
			return null;
		}		
	}
	
	
	public PageReference custCancel(){
		if(returnURL != null) {
 			return new Pagereference(returnURL);
 		}
 		return null;
	}
}