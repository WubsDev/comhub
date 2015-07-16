/**
 * Appirio, Inc
 * Name             : ManageCashCommunityTemplateCtlTest
 * Created Date     : 1 May 2015 
 * Created By       : Nikhil Sharma (Appirio)
 * Description      : Test class for ManageCashCommunityTemplateCtl
 */
@isTest
private class ManageCashCommunityTemplateCtlTest {
	static Account acc;
    static testMethod void myUnitTest() {
    	
    	ManageCashCommunityTemplateCtl ctrl = new ManageCashCommunityTemplateCtl();
    	pageReference pr = ctrl.init();
    	boolean b = ctrl.isSidebarCollapsed;
    	ManageCashCommunityTemplateCtl.setSidebarCollapsedStatus(true);
    	createTestData();
    	ManageCashCommunityTemplateCtl.setSidebarCollapsedStatus(true);
    	b = ctrl.isSidebarCollapsed;
    }
    
    private static void createTestData(){
    	//select id, isSidebarCollapsed__c from Sidebar_Status_By_User__c where OwnerId = :Utility.loggedInUser.id limit 1
    	Sidebar_Status_By_User__c ssUser = new Sidebar_Status_By_User__c(OwnerId = Utility.loggedInUser.id);
    	insert ssUser; 	
    }
}