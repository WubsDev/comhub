/**
 * Appirio, Inc
 * Name             : ForwardContractTriggerHandlerTest
 * Created Date     : 30 April 2015 
 * Created By       : Piyush Bansal (Appirio)
 * Description      : Test class for ForwardContractTriggerHandler
 */
@isTest
private class ForwardContractTriggerHandlerTest {
    static testMethod void testForwardContractTriggerHandler(){
		
        //starting  test execution	        
        Test.startTest();
        
        //create Test data below
        
        Account acc = test_Utility.createAccount(true);
        
        Market_Rate__c mRate = new Market_Rate__c(Currency_Code__c = 'USD', Currency_Name__c = 'USD', Currency_Value__c = 60, Last_Updated__c = System.today());
        insert mRate;
        
        System.assertEquals(mRate.Currency_Code__c, 'USD');
        
        List<Forward_Contracts__c> fcList = new List<Forward_Contracts__c>();
        Forward_Contracts__c fc1 = test_Utility.createForwardContracts(acc.Id, false);
        Forward_Contracts__c fc2 = test_Utility.createForwardContracts(acc.Id, false);
        fcList.add(fc1);    
        fcList.add(fc2);
        
        insert fcList;
        
        System.assertEquals(fcList.size(), 2);
        
        fc1.Settlement_Amount__c = 10;
        fc2.Settlement_Amount__c = 10;
        
        fcList.clear();
        fcList.add(fc1);    
        fcList.add(fc2);
        
        update fcList;

        system.assertEquals(fc1.Settlement_Amount__c, 10);
        
        //stop test execution	        
        Test.stopTest();
    }
}