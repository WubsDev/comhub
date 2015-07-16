@isTest
private class InsightsAndInputTabCtrl_test {

  private static User testUser; 
   
    static testMethod void testInsightsAndInputTabCtrl() {
       
       testUser = test_Utility.createTestUser(true);
       System.runAs(testUser){
           createTestData();
           
           Test.startTest();
           
           System.currentPageReference().getParameters().put('currency', 'INR');
           InsightsAndInputTabCtrl insight = new InsightsAndInputTabCtrl();
           insight.getfwdContractList();
           //insight.changeTransactionType();
           Input__c input = test_Utility.createInput(false);
           input.Input_Type__c = 'Option - Other';
           
           insight.input = input;
           insight.inputOther = test_Utility.createInput(false);
           insight.fieldset = 'Option_Other';
           Boolean testValidation = Utility.fieldSetValidation(input, 'Option_Other', 'Option_Other', true);
           insight.changeTransactionType();
           insight.fieldSet = 'Option_Other';
           insight.saveInput();
           
           System.assertEquals(insight.hasError, true);
           
           insight.cancel();
           insight.generateForwardContractReportData();
            insight.getHoldingBalanceReportData();
            //insight.findUser();
            insight.changeTransactionType();
            insight.getInputCurrency();
            insight.getForwardContractCurrency();
            insight.first();
            insight.last();
            insight.previous();
            insight.next();
            // insight.getTransactionTypes();
            System.debug('insight.selectedCurrencyHolding =>' + insight.selectedCurrencyHolding);
            System.debug('insight.historicalPaymentsList =>' + insight.historicalPaymentsList);
            System.debug('insight.lastupdate =>' + insight.lastupdate);
            System.debug('insight.self =>' + insight.self);
           // System.debug('insight.lstTransactionType =>' + insight.lstTransactionType);
            System.debug(' insight.currentAccount =>' + insight.currentAccount);
            System.debug(' insight.LabelMaps =>' + insight.LabelMaps);
            
            InsightsAndInputTabCtrl.loadOpps('USD', System.today().month()); 
             
            
            insight.getHistoricalPaymentReportData();
            
            System.debug(' insight.hasNext =>' + insight.hasNext);
            System.debug(' insight.hasPrevious =>' + insight.hasPrevious);
            System.debug(' insight.pageNumber =>' + insight.pageNumber);
            
            insight.input = new Input__c();
            insight.saveInput(); // Error
            
            Test.stopTest();
            
       }
    
    }
    
    
    public static void  createTestData(){
      
      AccountJapanInsertValues__c accJapan = new AccountJapanInsertValues__c();
      accJapan.Name = 'JapanUserID';
        accJapan.ID__c = testUser.id;
      //Contact.AccountId = testUser.Id;
      insert accJapan;
      
      User userLoggedIn = [Select Name,contactId, contact.AccountId FROM User WHERE id =: UserInfo.getUserId()];
       ID accId = userLoggedIn.Contact.AccountId;
      
      test_Utility.createHistoricalPayments(accId, true);
      test_Utility.createHoldingBalance(accId, true);
      
      Account acc1 = new Account();
      acc1.Name = 'testname';
      acc1.OwnerId = testUser.Id;
      insert acc1;       
      
      Forward_Contracts__c forwardContracts = new  Forward_Contracts__c();
        forwardContracts.Account_ID__c = acc1.id;
        forwardContracts.Settlement_Amount__c = 20; 
        forwardContracts.Maturity_Date__c =  Date.today().addDays(5);
        forwardContracts.Start_Date__c = Date.today();
        forwardContracts.Transaction_Number__c = 25;
        insert forwardContracts;            
        
        
    }
}