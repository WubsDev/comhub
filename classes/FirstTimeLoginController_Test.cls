/**=======================================================================================
 * Name: FirstTimeLoginController_Test
 * Description: Test Class of FirstTimeLoginController Class
 * Created Date: Apr 29, 2015
 * Created By: Rohit B. (Appirio)
 * 
 * Date Modified                Modified By                 	Description of the update
 * [Date]						[Developer Name]				[Short Description]
 ==========================================================================================*/

@isTest
private class FirstTimeLoginController_Test {
	
	@isTest static void test_method_one() {
		FirstTimeLoginController ftlc = new FirstTimeLoginController();
		ftlc.updateUser();
		//System.assertEquals(ftlc.IsFirstTimeLogin, false);
	}	
}