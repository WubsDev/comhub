/**
 * Appirio, Inc
 * Name             : AttachmentUploadTest
 * Created Date     : 25 March 2015 
 * Created By       : Shailendra Singh (Appirio)
 * Description      : Test class for AttachmentUpload
 */
@isTest
private class AttachmentUploadTest {

    static testMethod void myUnitTest() {
       Input__c input = test_Utility.createInput(true);
       System.currentPageReference().getParameters().put('pid', input.id);
        System.currentPageReference().getParameters().put('retURL', '/' + input.id);
       ApexPages.StandardController stdController = new ApexPages.StandardController(input);
       AttachmentUpload ctrl = new AttachmentUpload(stdController);
       ctrl.attach.Body = Blob.valueOf('My Testing.........');
       ctrl.save();
       
       ctrl.attach.Name = 'TestName';
       ctrl.save();
       
       ctrl.saveUptoFive();
       System.currentPageReference().getParameters().put('id', ctrl.attach.id);
       ctrl = new AttachmentUpload(stdController);
       
       ctrl.cancel();
    }
}