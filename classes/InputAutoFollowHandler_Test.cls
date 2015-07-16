// 
// (c) 2014 Appirio, Inc.
//
// InputAutoFollowHandler_Test
// Test class for InputAutoFollowHandler
//
// 07 Apr, 2015    Ashish Goyal  Original (Ref. T-375827)
//
@isTest
private class InputAutoFollowHandler_Test {
	
	static Input__c input;
    
    static testMethod void testInputDetailController() {
		input = new Input__c();
        input.name =  'Testinput';
        input.Input_Type__c = 'Forecast Inflow';
        
        Test.startTest();
        insert input;
		System.assertNotEquals(input, null);
		Test.stopTest();
    }
}