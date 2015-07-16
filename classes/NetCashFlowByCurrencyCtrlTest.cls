/**
 */
@isTest
private class NetCashFlowByCurrencyCtrlTest {
	
	static Account acc;
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        createTestData();
        ApexPages.currentPage().getParameters().put('aId',acc.Id);
        List<NetCashFlowCtrl.InvoicByCurrencyWrap> listwrpr = NetCashFlowByCurrencyCtrl.loadAllTimeData();
    }
    
    private static void createTestData(){
    	acc = new Account(name = 'acc');
    	insert acc;
    	List<Input__c> listInputs = new List<Input__c>();
    	Input__c input1 = new Input__c(Amount__c=20, Type__c='Forecast Inflow',Parent_Account__c=acc.Id);
    	listInputs.add(input1);
    	Input__c input2 = new Input__c(Amount__c=30, Type__c='Purchase Order',Parent_Account__c=acc.Id);
    	listInputs.add(input2);
    	Invoice__c invoice = new Invoice__c(Amount__c=30, Account__c=acc.Id);
    	insert invoice;
    	insert listInputs;
    }
}