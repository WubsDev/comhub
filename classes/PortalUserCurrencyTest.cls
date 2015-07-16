/**
 * Appirio, Inc
 * Name             : PortalUserCurrencyTest
 * Created Date     : 1 May 2015 
 * Created By       : Piyush Bansal (Appirio)
 * Description      : Test class for PortalUserCurrency
 */
@isTest
private class PortalUserCurrencyTest {
	static testMethod void testPortalUserCurrency(){
		
        //starting  test execution	        
        Test.startTest();
        
        //create Test data below
        User testUser = test_Utility.createTestUser(true);
        System.runAs(testUser){
            PortalUserCurrency obj = new PortalUserCurrency();
            obj.getCurrencyList();
            obj.updateRecord();
            obj.cancel();
            obj.updateSharingPemissionOnRecord();
        }
        //stop test execution	        
        Test.stopTest();
    }
}