// 
// (c) 2014 Appirio, Inc.
//
// FeedBackTabComponentController_Test
// Test class for FeedBackTabComponentController
//
// July 13, 2015    Ashish Goyal             Original ()
@isTest
private class FeedBackTabComponentController_Test {
	@isTest         
    static void testFeedBackComp(){
    	PageReference pageRef = Page.CMPFeedbackCreationPage;
        Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('tab','profile');
    	FeedBackTabComponentController controller = new FeedBackTabComponentController();
    	controller.refreshDashboard();
    }
}