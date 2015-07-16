global class CommunityLoginController {
 
	public String username{get; set;}
	public String password {get; set;}
	public String selectedLanguage{get;set;}
	public List<SelectOption> languageOptions{get;set;}	
	 
	

	public pageReference doLogin()
	{  
		pageReference pgRef = null;
		try{	
			if(UserInfo.getUserType()!=null){		
				if ( UserInfo.getUserType().equalsIgnoreCase('Guest')) {					
					pgRef = Site.login(username,password,null);
				}	//pgRef = Page.CommunityLogin;
				if(!UserInfo.getUserType().equalsIgnoreCase('Guest')){
					String profileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
					if(profileName.containsIgnoreCase('cct')){
					pgRef = Page.wuDashboard;
				}
				}
				if(pgRef!=null){
		    		pgRef.setredirect(true);
				}
			}
		}
		catch(Exception exc){
			ApexPages.addMessages(exc);
		}
		return pgRef;
	}
	//Require the Init on page, as need to redirect the user if already logged in.
	//Senario 1. Login from SFDC internal
	//Senario 2. Login from button from Email.
 	public CommunityLoginController(){

		languageOptions = new List<SelectOption>();
		for(CashManagementLanguageConfiguration__c cmLang : [Select id, Name, Label__c, ISO_Code__c from CashManagementLanguageConfiguration__c where Active__c = true]){
			languageOptions.add(new SelectOption(cmLang.ISO_Code__c, cmLang.Name));
		}
		system.debug('Cookie :'+retriveCookie());
		selectedLanguage = retriveCookie();

		selectedLanguage =  selectedLanguage.trim().length() > 0 ? selectedLanguage : 'en';
	}

	public PageReference changeLanguage(){
		Cookie selLanguage = new Cookie('selLang', selectedLanguage,null,-1,false);
		ApexPages.currentPage().setCookies(new Cookie[]{selLanguage});
		PageReference pg = Page.CommunityLogin;
		pg.setRedirect(true);
		return pg;
	}

	public 	pageReference Init(){
		pageReference pgRef = null;
		try{	
			if(!UserInfo.getUserType().equalsIgnoreCase('Guest')){
				String profileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
				if(profileName.containsIgnoreCase('cct')){
					pgRef = Page.wuDashboard;
				}
			}
				if(pgRef!=null){
		    		pgRef.setredirect(true);
				}
			}
		catch(Exception exc){
			ApexPages.addMessages(exc);
		}
		return pgRef;
	}

	private string retriveCookie(){
		Cookie selLanguage = ApexPages.currentPage().getCookies().get('selLang');
		if(selLanguage != null)
			return selLanguage.getValue();
		return '';
	}
}