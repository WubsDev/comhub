/**=====================================================================
 * Name: TopPendingInvoicesCtrl_test 
 * Description: Test class for TopPendingInvoicesCtrl.cls
 * Created Date: Mar 13, 2015
 * Created By: Aashita Sharma 
 =====================================================================*/


@isTest
private class TopPendingInvoicesCtrl_test {

    static testMethod void testTopPendingInvoicesCtrl() {
        
        createTestData();
        //initializing constructor
        TopPendingInvoicesCtrl testConstructor = new TopPendingInvoicesCtrl();
        // checking properties
        System.assertEquals(testConstructor.dataAvailable, true);
        
    }
    
    public static void createTestData(){
    
        // creating test data
        Invoice__c invoice = test_Utility.createInvoice(true);
    
    }
    
    
}