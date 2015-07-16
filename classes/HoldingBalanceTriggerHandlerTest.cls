/**
 * Appirio, Inc
 * Name             : HoldingBalanceTriggerHandlerTest
 * Created Date     : 30 April 2015 
 * Created By       : Piyush Bansal (Appirio)
 * Description      : Test class for HoldingBalanceTriggerHandler
 */
@isTest
private class HoldingBalanceTriggerHandlerTest {
	static testMethod void testHoldingBalanceTriggerHandler(){
         //starting  test execution	        
        Test.startTest();
        
        //create Test data below
        
        Account acc = test_Utility.createAccount(true);
        
        Market_Rate__c mRate = new Market_Rate__c(Currency_Code__c = 'USD', Currency_Name__c = 'USD', Currency_Value__c = 60, Last_Updated__c = System.today());
        insert mRate;
        
        System.assertEquals(mRate.Currency_Code__c, 'USD');
        
        List<Holding_Balance__c> lst = new List<Holding_Balance__c>();
        Holding_Balance__c hp1 = test_Utility.createHoldingBalance(acc.Id, false);
        lst.add(hp1);
        insert lst;
        
        hp1.CurrencyIsoCode = 'USD';
        
        lst.clear();
        lst.add(hp1);
        update lst;
        System.assertEquals(hp1.CurrencyIsoCode, 'USD');
        
        //stop test execution
        Test.stopTest();
    }
}