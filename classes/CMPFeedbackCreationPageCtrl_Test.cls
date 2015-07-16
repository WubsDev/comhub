// 
// (c) 2014 Appirio, Inc.
//
// CMPFeedbackCreationPageCtrl_Test
// Test class for CMPFeedbackCreationPageCtrl
//
// May 26, 2015    Ashish Goyal             Original (Ref. T-398557)
@isTest
private class CMPFeedbackCreationPageCtrl_Test {
    
    @isTest         
    static void test_method_one() {
        CMP_Feedback__c cmp = new CMP_Feedback__c();        
        Test.startTest();
        CMPFeedbackCreationPageCtrl cntrl2 = new CMPFeedbackCreationPageCtrl();
        ApexPages.StandardController std = new ApexPages.StandardController(cmp);
        CMPFeedbackCreationPageCtrl cntrl = new CMPFeedbackCreationPageCtrl(std);
        cntrl.cmp.Voice__c = 'a Customer';
        cntrl.cmp.Request__c = 'Request';
        cntrl.cmp.Objective__c = 'resolved';
        cntrl.cmp.Priority__c = 'P1';
        cntrl.attach.Name = 'Test.txt';
        cntrl.attach.Body = Blob.valueOf('ashishs shiweeovch');
        cntrl.custCancel(); 
        cntrl.saveCMP();    
        cntrl.showDiv();
        System.assertEquals(cntrl.cmp.Id, null);
        Test.stopTest();
    }

}