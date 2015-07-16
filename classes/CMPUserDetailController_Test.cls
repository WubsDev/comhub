// 
// (c) 2014 Appirio, Inc.
//
// CMPUserDetailController_Test
// Test class for CMPUserDetailController
//
// July 13, 2015    Ashish Goyal             Original ()
@isTest
private class CMPUserDetailController_Test {
	
	@isTest         
    static void testUserDetail(){
    	PageReference pageRef = Page.CMPUserDetail;
        Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('retURL','testPage');
		ApexPages.currentPage().getParameters().put('Id',UserInfo.getUserId());
		CMPUserDetailController controller = new CMPUserDetailController();
		controller.custUpdate();
		controller.custCancel();
		controller.commUser.Id = null;
		controller.custUpdate();
    }
}