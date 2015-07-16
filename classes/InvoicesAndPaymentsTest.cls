/**
 * Appirio, Inc
 * Name             : InvoicesAndPaymentsTest
 * Created Date     : 1 May 2015 
 * Created By       : Piyush Bansal (Appirio)
 * Description      : Test class for InvoicesAndPayments
 */
@isTest
private class InvoicesAndPaymentsTest {
	static testMethod void testInvoicesAndPayments(){
		
        //starting  test execution	        
        Test.startTest();
        
        //create Test data below
        Account acc = test_Utility.createAccount(true);
    	Contact con = New Contact(AccountId = acc.Id, LastName = 'Test', FirstName = 'Test');
    	insert con;
    	User tUser = test_Utility.createCommUser(con.Id, true);
        System.runAs(tUser){
            
            Beneficiary_Contact__c ben = new Beneficiary_Contact__c(name ='Test Ben');
            
            ApexPages.currentPage().getParameters().put('fin','test');
            ApexPages.currentPage().getParameters().put('beneficaryId',ben.Id);
            
            Invoice__c inv = new Invoice__c(Name='Test',Status__c='Void',Due_Date__c = Date.today(),Amount__c=100,Account__c=acc.Id,Input_Beneficiary__c=ben.Id, Custom_Currency__c = 'USD');
            insert inv;
            
            InvoicesAndPayments obj = new InvoicesAndPayments();
            obj.selectedCurrency = 'ShowAll';
            obj.selectedStatus = 'All';
            obj.getCurrencyList();
            obj.toggleSort();         
            obj.selectedCurrency = 'USD';   
            obj.populateAmountField();
            obj.invoiceList = new List<inputWpr>();
            obj.approvePayment();
            obj.AddInputBeneficiary();
            obj.saveInvoice();
			obj.invoice = inv;
            obj.saveInvoice();
            obj.cancel();
            obj.getForwardContractCurrency();
            obj.invoice = null;
            obj.saveInvoice();
            String tmpString = obj.currentUserLocale;
            tmpString = obj.unHedgedTotalFormat;
            tmpString = obj.hedgedTotalFormat;
            tmpString = obj.aggregateTotalFormat;
            tmpString = obj.unHedgedTotalSettlementFormat;
            tmpString = obj.aggregateTotalSettlementFormat;
            
            List<inputWpr> tmp = obj.invoicePgCtl_genericList;
            Decimal dec = obj.aggregateTotalSettlement;
            dec = obj.hedgedTotalSettlement;
            dec = obj.unHedgedTotalSettlement;
            Datetime dt = obj.getlastUpdated();
            
            String str = obj.inputLink;
        }
         //stop test execution	        
        Test.stopTest();
    }
}