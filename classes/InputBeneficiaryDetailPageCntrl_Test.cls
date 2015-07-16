// 
// (c) 2014 Appirio, Inc.
//
// InputBeneficiaryDetailPageCntrl_Test
// Test class for InputBeneficiaryDetailPageController
//
// 07 Apr, 2015    Ashish Goyal  Original (Ref. T-375697)
//
@isTest
private class InputBeneficiaryDetailPageCntrl_Test {
    
    static testMethod void testInputDetailController() {
        Input_Beneficiary__c inputBen = new Input_Beneficiary__c();
        inputBen.Name = 'Test Beneficiary';
        inputBen.Beneficiary_Email__c = 'Test@test12.com';
        insert inputBen;
        
        Input__c input = new Input__c();
        input.name =  'Testinput';
        input.Input_Type__c = 'Forecast Inflow';
        input.Input_Beneficiary__c = inputBen.Id;
        input.Window_Start_Date__c = Date.today();
        input.Window_End_Date__c = Date.today().addDays(5);
        insert input;
        
        Invoice__c invoice = new Invoice__c();
        invoice.name =  'TestInvoice';
        invoice.Input_Beneficiary__c = inputBen.Id;
        insert invoice;
        
        Test.startTest();
        PageReference pageRef = Page.InputBeneficiaryDetailPage;
        pageRef.getParameters().put('id', String.valueOf(inputBen.Id));
        Test.setCurrentPage(pageRef);
        InputBeneficiaryDetailPageController testCtrl = new InputBeneficiaryDetailPageController();
        System.assertNotEquals(testCtrl, null);
        testCtrl.customDelete();
        testCtrl.customCancel();
        testCtrl.doRedirect();
        Test.stopTest();
    }

}