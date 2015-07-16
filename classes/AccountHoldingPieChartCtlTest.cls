/**=====================================================================
 * Name		    : AccountHoldingPieChartCtlTest
 * Description  : Apex unit test for AccountHoldingPieChartCtl.cls
 * Created Date : 24th March 2015
 * Created By   : Shailendra Singh (JDC)
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/
@isTest
private class AccountHoldingPieChartCtlTest { 

    static testMethod void myUnitTest() {
        User portalUser = test_Utility.createTestUser(true);
        System.runAs(portalUser){
        	createTestData();
	        AccountHoldingPieChartCtl ctrl = new AccountHoldingPieChartCtl();   
	        ctrl.getPieData();
	        
	        List<AccountHoldingPieChartCtl.PieWedgeData> result = ctrl.getBarChartData();
	        
	        System.assertEquals(result.size(), 1);
	        
	        ctrl.getPieData1();    
	        
	        System.debug('ctrl.ForwardBalanceColor =>' + ctrl.ForwardBalanceColor);
	        System.debug('ctrl.isNonCCTuser =>' + ctrl.isNonCCTuser);
	        
	   }
   }
   
   private static void createTestData() {
        List<Historical_Payments__c> hPayments = new List<Historical_Payments__c>();
    	User userLoggedIn = [Select Name,contactId, contact.AccountId FROM User WHERE id =: UserInfo.getUserId()];
   		ID accId = userLoggedIn.Contact.AccountId;
		Market_Rate__c mRate = new Market_Rate__c(Currency_Code__c = 'CAD', Currency_Name__c = 'Canadian Doller', Currency_Value__c = 1.68, Last_Updated__c = System.today());
		insert mRate;     	   		
   		        
        hPayments.add(test_Utility.createHistoricalPayments(accId, false));
        hPayments.add(test_Utility.createHistoricalPayments(accId, false));
        hPayments.add(test_Utility.createHistoricalPayments(accId, false));
        hPayments.get(2).Date__c = System.today().year() + '' + System.today().month();
        
        hPayments.get(0).MarketRate__c = mRate.id;
        hPayments.get(1).MarketRate__c = mRate.id;
        hPayments.get(2).MarketRate__c = mRate.id;
        
        
        insert hPayments;
        
        Holding_Balance__c hb = test_Utility.createHoldingBalance(accID, true);
        
    	
    	Forward_Contracts__c forwardContracts = new  Forward_Contracts__c();
        forwardContracts.Account_ID__c = accId;
        forwardContracts.Settlement_Amount__c = 20; 
        forwardContracts.Maturity_Date__c =  Date.today().addDays(5);
        forwardContracts.Start_Date__c = Date.today();
        forwardContracts.Transaction_Number__c = 25;
        insert forwardContracts;     	   	
   }   
}