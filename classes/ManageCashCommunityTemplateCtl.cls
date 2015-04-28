/**=====================================================================
 * Name: AccountHoldingPieChartCtl
 * Description: Related to AccountHoldingPieChartCtl Page
 * Created Date: Feb 19 2015
 * Created By: Ranjeet Singh (JDC)
 *
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/
global without sharing class ManageCashCommunityTemplateCtl {
	public boolean isSidebarCollapsed{
		get{
			List<Sidebar_Status_By_User__c> setval = [select id, isSidebarCollapsed__c from Sidebar_Status_By_User__c where OwnerId = :Utility.loggedInUser.id limit 1];
			if(setval.size()>0){
				return setval[0].isSidebarCollapsed__c ;
			}else{
				return false;
			}
		}
	}
	
	public pageReference init()
	{  
		pageReference pgRef = null;
		try{	
			if(UserInfo.getUserType()!=null){		
				if ( UserInfo.getUserType().equals('Guest')) {
					pgRef = Page.CommunityLogin;
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
	
	public ManageCashCommunityTemplateCtl(){
		
	}
	//Remote action to save the user preference on SidebarCollapsedStatus. 
	@RemoteAction
	global static boolean setSidebarCollapsedStatus(boolean isSidebarCollapsed){
		//
		List<Sidebar_Status_By_User__c> setval = [select id, isSidebarCollapsed__c from Sidebar_Status_By_User__c where OwnerId = :Utility.loggedInUser.id limit 1];
		if(setval.size()>0){
			setval[0].isSidebarCollapsed__c = isSidebarCollapsed;
			update setval[0];
		}else{
			Sidebar_Status_By_User__c Sidebar_Status_By_User = new Sidebar_Status_By_User__c();
			Sidebar_Status_By_User.OwnerId = Utility.loggedInUser.id; 
			Sidebar_Status_By_User.isSidebarCollapsed__c = isSidebarCollapsed;
			insert Sidebar_Status_By_User;
		}
		return isSidebarCollapsed;
	}

}