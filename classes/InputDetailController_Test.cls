// 
// (c) 2014 Appirio, Inc.
//
// InputDetailController_Test
// Test class for InputDetailController
//
// 06 Apr, 2015    Ashish Goyal  Original (Ref. T-375814)
//
@isTest
private class InputDetailController_Test {
    static Input__c input;
    static Attachment attachment;
    
    static testMethod void testInputDetailController() {
       createTestData();
       // initializing standard controller 
       PageReference pageRef = Page.InputEdit;
       pageRef.getParameters().put('id', String.valueOf(input.Id));
       Test.setCurrentPage(pageRef);
       //ApexPages.StandardController stdCtrl =  new ApexPages.StandardController( input);
       ApexPages.currentPage().getParameters().put('Id', input.Id);
       InputDetailController testCtrl = new InputDetailController();
       PageReference pg = testCtrl.createNewAttachment();
       // to verify createNewAttachment() method should not return null value
       System.assertNotEquals(pg, null);
       testCtrl.attachmentIdToDelete = attachment.id;
       testCtrl.customCancel();
       testCtrl.delAttachment();

       List<SelectOption> lstSelOptn = testCtrl.CurrencyOptions;
       Map<String, string> mapLabelMaps = testCtrl.LabelMaps;

       input.Input_Type__c = 'Fixed Forward Contract - Other';
       update input;
       ApexPages.currentPage().getParameters().put('Id', input.Id);
       InputDetailController testCtrl1 = new InputDetailController();
       
       input.Input_Type__c = 'Window Forward Contract - Other';
       update input;
       ApexPages.currentPage().getParameters().put('Id', input.Id);
       InputDetailController testCtrl2 = new InputDetailController();

       Input_Beneficiary__c ib = new Input_Beneficiary__c(Name = 'Test 1');
       insert ib;
       
       Account acc = new Account();
       acc.Name = 'testname';
       insert acc;

       //User u = Utility.createTestUser(true);
       //System.runAs(u) {
         Test.startTest();
         Input__c input1 = new Input__c();
         input1.name =  'Testinput1';
         input1.Input_Type__c = 'Option - WUBS';
         input1.Type__c = 'test type';
         input1.Option_Protection_Obligation__c = input.Id;
         input1.Window_Start_Date__c = Date.today();
         input1.Window_End_Date__c = Date.today().addDays(5);
         input1.Reference_Number__c = '12334';
         input1.Transaction_Date__c = Date.today().addDays(-5);
         input1.Buy_Currency__c = 'USD';
         input1.Sell_Currency__c = 'USD';
         input1.Amount__c = 53435.50;
         input1.Input_Beneficiary__c = ib.Id;
         input1.Parent_Account__c = acc.Id;
         insert input1;

         ApexPages.currentPage().getParameters().put('Id', input1.Id);
         InputDetailController testCtrl3 = new InputDetailController();
         testCtrl3.inputRecord = input1;
         testCtrl3.save();
         testCtrl3.customDelete();
         Test.stopTest();
       //}
    }
    
   
   //creating test data
    private static void createTestData(){
    
        input = new Input__c();
        input.name =  'Testinput';
        input.Input_Type__c = 'Forecast Inflow';
        input.Window_Start_Date__c = Date.today();
        input.Window_End_Date__c = Date.today().addDays(5);
        insert input;
        
        attachment = new Attachment();
        attachment.ParentId =  input.id;
        attachment.Name = 'testAttachment';
        attachment.body = blob.valueof('testBody');
        insert attachment;
    }
}