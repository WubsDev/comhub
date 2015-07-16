/**
 * Appirio, Inc
 * Name             : portalCashflowReportCloneTest
 * Created Date     : 1 May 2015 
 * Created By       : Piyush Bansal (Appirio)
 * Description      : Test class for portalCashflowReportClone
 */
@isTest
private class portalCashflowReportCloneTest {
	static testMethod void testportalCashflowReportClone(){
		
        //starting  test execution	        
        Test.startTest();
        
        //create Test data below
        User testUser = test_Utility.createTestUser(true);
        System.runAs(testUser){
            
			Account acc = [select id,name from Account limit 1];
            Contact con = [select id,name from Contact limit 1];
            apexpages.currentPage().getParameters().put('aId',acc.Id);
            apexpages.currentPage().getParameters().put('cId',con.Id);
            apexpages.currentPage().getParameters().put('currency','USD');
            apexPages.currentPage().getParameters().put('theCurrency','USD');
            apexpages.currentPage().getParameters().put('dateRange','5');
            
            portalCashflowReportClone obj = new portalCashflowReportClone();
            obj.findAccount();
            obj.findContact();
            obj.findUser();
            obj.getUserName();
            obj.getUserCurrency();
            obj.getTabbedView();
            obj.queryLatestInput(acc.Id+'');
            Datetime dt = datetime.now();
            //obj.formatDate(dt);
            obj.currentCurrency();
            obj.disclaimerLink();
            obj.exportToCSV();
            apexpages.currentPage().getParameters().put('aId',null);
            obj.exportToCSV();
            apexpages.currentPage().getParameters().put('cId',null);
            obj.findContact();
            apexpages.currentPage().getParameters().put('dateRange',null);
            apexpages.currentPage().getParameters().put('currency',null);
            obj = new portalCashflowReportClone();
        }
         //stop test execution	        
        Test.stopTest();
    }
}