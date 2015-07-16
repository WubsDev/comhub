// 
// (c) 2014 Appirio, Inc.
//
// CMPUserChangePasswordController_Test
// Test class for CMPUserChangePasswordController
//
// July 13, 2015    Ashish Goyal             Original ()
@isTest
private class CMPUserChangePasswordController_Test {
	
	@isTest         
	static void test_changePassword() {
		
		PageReference pageRef = Page.CMPUserChangePassword;
        Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('retURL','testPage');
		CMPUserChangePasswordController controller = new CMPUserChangePasswordController();
		
		Test.startTest();
		
		controller.password = '';
		controller.rePassword = '';
		controller.changePassword();
		
		controller.password = 'hello';
		controller.rePassword = 'hello';
		controller.changePassword();
		
		controller.password = 'helloash';
		controller.rePassword = 'helloash';
		controller.changePassword();
		
		controller.password = 'helloash';
		controller.rePassword = 'helloasi';
		controller.changePassword();
		
		controller.passwordCancel();
		Test.stopTest();
	}
}