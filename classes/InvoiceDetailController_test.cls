/**=====================================================================
 * Name: InvoiceDetailController_test
 * Description: Test class for InvoiceDetailController.cls
 * Created Date: Mar 12, 2015
 * Created By: Aashita Sharma 
 =====================================================================*/

@isTest
private class InvoiceDetailController_test {
    static Invoice__c invoice;
    static Attachment attachment;
    
    static testMethod void testInvoiceDetailController() {
       createTestData();
       // initializing standard controller 
       PageReference pageRef = Page.InvoiceEdit;
       pageRef.getParameters().put('id', String.valueOf(invoice.Id));
       Test.setCurrentPage(pageRef);
       // ApexPages.StandardController stdCtrl =  new ApexPages.StandardController( invoice);
       ApexPages.currentPage().getParameters().put('Id', invoice.Id);
       InvoiceDetailController testCtrl = new InvoiceDetailController();
       PageReference pg = testCtrl.createNewAttachment();
       // to verify createNewAttachment() method should not return null value
       System.assertNotEquals(pg, null);
       testCtrl.attachmentIdToDelete = attachment.id;
       testCtrl.delAttachment();
       testCtrl.customDelete();
       testCtrl.customCancel();
       testCtrl.save();
       testCtrl.cancel();
       Map<String, string> labelMap = testCtrl.LabelDetailMaps;
       labelMap = testCtrl.LabelMaps;
       List<SelectOption> sOptList = testCtrl.CurrencyOptions;
        }
    
   
   //creating test data
    private static void createTestData(){
    
        invoice = new Invoice__c();
        invoice.name =  'TestInvoice';
        insert invoice;
        
        attachment = new Attachment();
        attachment.ParentId =  invoice.id;
        attachment.Name = 'testAttachment';
        attachment.body = blob.valueof('testBody');
        insert attachment;
    }
}