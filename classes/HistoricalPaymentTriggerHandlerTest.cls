/**
 * Appirio, Inc
 * Name             : HistoricalPaymentTriggerHandlerTest
 * Created Date     : 30 April 2015 
 * Created By       : Piyush Bansal (Appirio)
 * Description      : Test class for HistoricalPaymentTriggerHandler
 */
@isTest
private class HistoricalPaymentTriggerHandlerTest {
    static testMethod void testHistoricalPaymentTriggerHandler(){
         //starting  test execution	        
        Test.startTest();
        
        //create Test data below
        
        Account acc = test_Utility.createAccount(true);
        
        Market_Rate__c mRate = new Market_Rate__c(Currency_Code__c = 'USD', Currency_Name__c = 'USD', Currency_Value__c = 60, Last_Updated__c = System.today());
        insert mRate;
        
        System.assertEquals(mRate.Currency_Code__c, 'USD');
        
        List<Historical_Payments__c> lst = new List<Historical_Payments__c>();
        Historical_Payments__c hp1 = test_Utility.createHistoricalPayments(acc.Id, false);
        Historical_Payments__c hp2 = test_Utility.createHistoricalPayments(acc.Id, false);
        lst.add(hp1);
        lst.add(hp2);
        insert lst;
        
        hp1.CurrencyIsoCode = 'USD';
        hp2.CurrencyIsoCode = 'USD';
        
        lst.clear();
        lst.add(hp1);
        lst.add(hp2);
        update lst;
        
        System.assertEquals(hp1.CurrencyIsoCode, 'USD');
        //stop test execution
        Test.stopTest();
    }
}