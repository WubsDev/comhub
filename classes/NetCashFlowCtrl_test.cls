/**=====================================================================
 * Name: NetCashFlowCtrl_test
 * Description: Test class for NetCashFlowCtrl.cls
 * Created Date: Mar 16, 2015
 * Created By: Aashita Sharma 
 =====================================================================*/

@isTest
private class NetCashFlowCtrl_test {
    
    // creating test user
    private static User testUser; 
    
    // method  to cover NetCashFlowCtrl class
    static testMethod void testNetCashFlowCtrl() {
       
        createTestData();
        
        System.runAs(testUser){
            Test.startTest();
            NetCashFlowCtrl netController = new NetCashFlowCtrl();
            netController.Search();
            netController.getaccountTradedCurrency();
            NetCashFlowCtrl.loadAllTimeData();
           // to verify aggResult size should be 0
            System.assertEquals(NetCashFlowCtrl.aggResult.size(), 0);
            Test.stopTest();
        }
    }
     
     // creating test data for coverage
    public static void  createTestData(){ 
        testUser = test_Utility.createTestUser(true);
        System.runAs(testUser){
            Invoice__c invoice = test_Utility.createInvoice(true);
            Input__c input = test_Utility.createInput(false);
            input.Type__c = 'Forecast Inflow';
            input.Type__c = 'Purchase Order';
            insert input;
        }
    }
}