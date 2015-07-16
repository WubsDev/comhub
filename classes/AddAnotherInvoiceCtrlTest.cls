/**
 * Appirio, Inc
 * Name             : AddAnotherInvoiceCtrlTest
 * Created Date     : 23 March 2015 
 * Created By       : Shailendra Singh (Appirio)
 * Description      : Test class for AddAnotherInvoiceCtrl
 */
@isTest
private class AddAnotherInvoiceCtrlTest {

    static testMethod void myUnitTest() {
        System.currentPageReference().getParameters().put('sourcePage', 'InvoicesAndPayments');
        AddAnotherInvoiceCtrl ctrl = new AddAnotherInvoiceCtrl();
        ctrl.addAnotherInvoice();
        Pagereference ref = ctrl.finished();
        System.assertEquals(ref.getUrl(), '/apex/sourcePage=InvoicesAndPayments');
        
        System.currentPageReference().getParameters().put('sourcePage', null);
        ctrl = new AddAnotherInvoiceCtrl();
    }
}