/**

 */

@isTest
private class DragnDropFileUploadControllerTest{

    static testMethod void uploadTest() {
        //Split string 'file' in to two chunks, first chunk must be divisible by 3 for base64 encode with no padding
        Blob part1 = Blob.valueOf('This text re'); //length is 12 
        Blob part2 = Blob.valueOf('presents a dummy file');
                
        String part1base64 = EncodingUtil.base64Encode(part1);
        String part2base64 = EncodingUtil.base64Encode(part2);
        
        //Create a test accound the 'file' can be attached to.
        Account acct = new Account(Name = 'test');
        insert acct;
         
        //Start the test
        Test.startTest();
        
        Test.setCurrentPage(new Pagereference('/apex/testPage')); 
        
        //Send first part of the file to be uploaded
        String attachmentId = DragnDropFileUploadController.uploadFile(acct.Id,'','fileName','text',part1base64);
        
        DragnDropFileUploadController ctrl = new DragnDropFileUploadController();
        ctrl.parentId = acct.id;
        ctrl.upload1();

        ctrl.uploadInput();
        //Send the second piece of the file to be uploaded
        DragnDropFileUploadController.uploadFile(acct.Id,attachmentId,'fileName','text',part2base64);
        Test.stopTest();
        
        //Assert one file has been attached to the test account
        List<Attachment> attachments = [select Id, Body from Attachment where ParentId = :acct.Id];
        system.assert(attachments.size() == 1);
        
        //Assert the contents of the split file were recontructed correctly
        system.assert(attachments[0].Body.toString() == 'This text represents a dummy file');
        
        ctrl.attachment.name = 'test';
        ctrl.attachment.Body = Blob.valueOf('Test'); 
        ctrl.typeInput = 'Purchase Order';
        ctrl.uploadInput();
        
        
        ctrl.attachment = new Attachment();
        ctrl.attachment.name = 'test';
        ctrl.attachment.Body = Blob.valueOf('Test');         
        ctrl.typeInput = 'Forecast Inflow';
        ctrl.uploadInput();
        
        
        ctrl.attachment = new Attachment();
        ctrl.attachment.name = 'test';
        ctrl.attachment.Body = Blob.valueOf('Test');         
        ctrl.typeInput = 'Invoice';        
        ctrl.uploadInput();
    }
    
    static testmethod void testIEFallback(){
    	 Account acct = new Account(Name = 'test');
         insert acct;	
         
         Blob part1 = Blob.valueOf('This text re');
         
         DragnDropFileUploadController c= new DragnDropFileUploadController();
         c.parentId=acct.Id;
         
         c.attachment.Body = part1;
         c.attachment.Name='test.txt';
         
         c.uploadFile();
         
    }
}