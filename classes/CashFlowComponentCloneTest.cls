/**
 * Appirio, Inc
 * Name             : CashFlowComponentCloneTest
 * Created Date     : 26 March 2015 
 * Description      : Test class for CashFlowComponentClone
 */
@isTest
private class CashFlowComponentCloneTest {
	static User portalUser;
	
    static testMethod void myUnitTest() {
    	portalUser = test_Utility.createTestUser(true);
    	System.runAs(portalUser) {
    		createTestData();
    		
    		Test.startTest();
    		
        	CashFlowComponentClone ctrl = new CashFlowComponentClone();
        	CashFlowComponentClone.selMonth = 3;
        	ctrl.cur = 'INR';
        	System.debug('ctrl.isNonCCTuser =>' + ctrl.isNonCCTuser);
        	ctrl.getMonths();
        	ctrl.getSpacer();
        	ctrl.firstMonthToDisplay(portalUser.ContactId, portalUser.Contact.AccountId);
        	ctrl.monthSearch(System.today());
        	
        	
        	
        	ctrl = new CashFlowComponentClone();
        	ctrl.cur = 'Total';
        	CashFlowComponentClone.selMonth = 3;
        	System.debug('ctrl.isNonCCTuser =>' + ctrl.isNonCCTuser);
        	ctrl.getMonths();
        	ctrl.getSpacer();
        	ctrl.firstMonthToDisplay(portalUser.ContactId, portalUser.Contact.AccountId);
        	ctrl.monthSearch(System.today());        
        	ctrl.getUserCurrency();	
        	
        	Test.stopTest();
        	
        	System.assert(ctrl.outflowTotal.size() != 0);
    	}
    	User currentUser = [Select   Id, ContactId, DefaultCurrencyIsoCode, Name, Contact.AccountId, IsPrmSuperUser, CurrencyIsoCode FROM  User WHERE  Id =: UserInfo.getUserId() LIMIT 1];
    	CashFlowComponentClone ctrl = new CashFlowComponentClone();
    	CashFlowComponentClone.selMonth = 3;
    	ctrl.cur = 'INR';
    	ctrl.getMonths();
    	ctrl.getSpacer();
    	ctrl.firstMonthToDisplay(currentUser.ContactId, currentUser.Contact.AccountId);
    	ctrl.monthSearch(System.today());
        	    	
    	ctrl = new CashFlowComponentClone();
    	ctrl.cur = 'Total';
    	CashFlowComponentClone.selMonth = 3;
    	ctrl.getMonths();
    	ctrl.getSpacer();
    	ctrl.firstMonthToDisplay(currentUser.ContactId, currentUser.Contact.AccountId);
    	ctrl.monthSearch(System.today());      
    	
    	List<Input__c> inputList = new List<Input__c>();
    	Forward_Contracts__c frwd = new Forward_Contracts__c();
    	frwd.FX_Balance__c = 28334;
    	frwd.Maturity_Date__c = system.today();
    	frwd.Account_ID__c = portalUser.Contact.AccountId;
    	insert frwd;
    	inputList.add(test_Utility.createInput(false));    	
    	ctrl.addToTradingReceipts(inputList.get(0));
    	ctrl.addToInflowOther(inputList.get(0));
    	ctrl.addToPurchaseOrder(inputList.get(0));
    	ctrl.addToForecastOrder(inputList.get(0));
    	ctrl.addToOutflowOther(inputList.get(0));
    	ctrl.addToForwardWUBS(frwd);
    	ctrl.addToForwardOther(inputList.get(0));
    	
    	ctrl.addToOptionsWUBSProtection(inputList.get(0));
    	ctrl.addToOptionsWUBSObligation(inputList.get(0));
    	ctrl.addToOptionsOtherProtection(inputList.get(0));
    	ctrl.addToOptionsOtherObligation(inputList.get(0));
    }
    
    static void createTestData() {
    	portalUser = [Select   Id, ContactId, DefaultCurrencyIsoCode, Name, Contact.AccountId, IsPrmSuperUser, CurrencyIsoCode FROM  User WHERE  Id =: UserInfo.getUserId() LIMIT 1];
    	List<Input__c> inputList = new List<Input__c>();
    	inputList.add(test_Utility.createInput(false));
    	inputList.add(test_Utility.createInput(false));
    	inputList.add(test_Utility.createInput(false));
    	inputList.add(test_Utility.createInput(false));
    	inputList.add(test_Utility.createInput(false));
    	inputList.add(test_Utility.createInput(false));
    	inputList.add(test_Utility.createInput(false));
    	inputList.add(test_Utility.createInput(false));
    	inputList.add(test_Utility.createInput(false));
    	inputList.add(test_Utility.createInput(false));
    	
    	inputList.get(1).Input_Type__c = 'Forecast Outgoing';
    	inputList.get(2).Input_Type__c = 'Forecast Outflow';
    	inputList.get(3).Input_Type__c = 'Option - Other';
    	inputList.get(4).Input_Type__c = 'Forecast Inflow';
    	
    	
    	insert inputList;
    	
    	Invoice__c invoice = test_Utility.createInvoice(true);
    	
    	
    	
    	
    	test_Utility.createHoldingBalance(portalUser.Contact.AccountId, true);
    	test_Utility.createForwardContracts(portalUser.Contact.AccountId, true);
    }
}