public class CommunityLoginController {
 
	public String username{get; set;}
	public String password {get; set;}
	 
	public pageReference init()
	{  
		pageReference pgRef = null;
		try{	
			if(UserInfo.getUserType()!=null){		
				if ( !UserInfo.getUserType().equals('Guest')) {
					//if(ApexPages.currentPage()!=Page.CommunityLogin){					
					//	pgRef = Page.CommunityLogin;
					//}
					pgRef = Page.wuDashboard;
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
	public pageReference doLogin()
	{  
		pageReference pgRef = null;
		try{	
			if(UserInfo.getUserType()!=null){		
				if ( UserInfo.getUserType().equals('Guest')) {					
					pgRef = Site.login(username,password,Page.wuDashboard+'');
				}	//pgRef = Page.CommunityLogin;
				if(!UserInfo.getUserType().equals('Guest')){
					pgRef = Page.wuDashboard;
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

}