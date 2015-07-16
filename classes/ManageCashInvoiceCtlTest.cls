/**
 * Appirio, Inc
 * Name             : AddAnotherInvoiceCtrlTest
 * Created Date     : 23 March 2015 
 * Created By       : Shailendra Singh (Appirio)
 * Description      : Test class for AddAnotherInvoiceCtrl
 */
@isTest
private class ManageCashInvoiceCtlTest {
	static Account acc;
	static Input_Beneficiary__c ib;
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        createTestData();
        ApexPages.currentPage().getParameters().put('aId', acc.Id);
        ApexPages.currentPage().getParameters().put('beneficaryId',null);
        ApexPages.currentPage().getParameters().put('fin','test');
        ManageCashInvoiceCtl ctrl = new ManageCashInvoiceCtl();
        List<SelectOption> options = ctrl.getForwardContractCurrency();
    //    insert ctrl.invoice;
     //   ctrl.cancel();
        pagereference pr = ctrl.saveInvoice();
        ctrl.invoice.Name = 'test';
        ctrl.invoice.Status__c = 'test';
        ctrl.invoice.Due_Date__c = Date.Today();
        ctrl.invoice.Amount__c = 1.0;
        ctrl.invoice.Input_Beneficiary__c = ib.Id;
        ctrl.invoice.Custom_Currency__c = 'AED';
        ctrl.hasError = false;
        insert ctrl.invoice;
        pr = ctrl.saveInvoice();
    }
    
    private static void CreateTestData() {
    	acc = new Account(name = 'acc');
    	insert acc;
    	InsightsAndInputTabCtrl insight = new InsightsAndInputTabCtrl();
    	//Transaction_Type__c tt : [SELECT id, name, Option_Index__c From Transaction_Type__c order by Option_Index_
    	List<Transaction_Type__c> listTransactions = new List<Transaction_Type__c>();
    	Transaction_Type__c tt1 = new Transaction_Type__c(name='tt1',Option_Index__c=1);
    	listTransactions.add(tt1);
    	Transaction_Type__c tt2 = new Transaction_Type__c(name='tt2',Option_Index__c=2);
    	listTransactions.add(tt2);
    	insert listTransactions;
    	ib = new Input_Beneficiary__c(name='test');
    	insert ib;    	
    }
}