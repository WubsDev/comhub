/**
 * Appirio, Inc
 * Name             : ManageCashInputsCtlTest
 * Created Date     : 30 April 2015 
 * Created By       : Nikhil Sharma (Appirio)
 * Description      : Test class for ManageCashInputsCtl
 */
@isTest
private class ManageCashInputsCtlTest {
	static Account acc;
    static testMethod void myUnitTest() {
       // System.currentPageReference().getParameters().put('sourcePage', 'InvoicesAndPayments');
        createTestData();
        ApexPages.currentPage().getParameters().put('aId', acc.Id);
        apexpages.currentPage().getParameters().put('cId','test12341234test');
        ManageCashInputsCtl ctrl = new ManageCashInputsCtl();
        ctrl.record.Input_Type__c ='Option - WUBS';
        ctrl.selectedCurrency = 'usd';
        ctrl.input.Window_Start_Date__c = Date.Today() ;
        ctrl.input.Window_End_Date__c = Date.Today().addDays(2);
        String str = ctrl.getTranslatedText();
        ctrl.NewRecord();
        ctrl.toggleIncomingSort();
        ctrl.togglehedgingSort();
        ctrl.toggleoutgoingSort();
        ctrl.PopulateLists();
        String contact = ctrl.findContact();
        ctrl.Cancel();
        ctrl.quickSave();
    }
    
    private static void createTestData() {
    	Market_Rate__c mktRate = new Market_Rate__c(Currency_Code__c = 'USD', Currency_Name__c='test', Currency_Value__c=5.0);
    	insert mktRate;
    	Input_Beneficiary__c inputBeneficiary = new Input_Beneficiary__c(Name = 'WUBS');
    	insert inputBeneficiary;    	
    	acc = new Account(name = 'acc');
    	insert acc;
    	Invoice__c invoice = new Invoice__c(account__c = acc.Id);
    	insert invoice;
    //	mktRate.Currency
    }
}