// 
// (c) 2014 Appirio, Inc.
//
// CMPFeedbackTriggerManager_Test
// Test class for CMPFeedbackTriggerManager
//
// May 28, 2015    Ashish Goyal             Original (Ref. T-399983)
@isTest
private class CMPFeedbackTriggerManager_Test {
    @isTest         
    static void test_trigger() {
        CMP_Feedback__c cmp = new CMP_Feedback__c();        
        Test.startTest();
        cmp.Voice__c = 'Customer';
        cmp.Request__c = 'Request';
        cmp.Objective__c = 'resolved';
        cmp.Priority__c = 'P1';
        cmp.Category__c = 'Bug Fix/Issue'; 
        cmp.Title__c = 'Test class Demo';
        // cmp.Approval_Status__c = 'Submitted';
        insert cmp;
        System.assertNotEquals(cmp.Id, null);
        System.assertEquals(cmp.Submit_for_Approval__c, false);
        cmp.Approval_Status__c = 'Promoted to Idea';
        update cmp;
        Test.stopTest();
    }
}