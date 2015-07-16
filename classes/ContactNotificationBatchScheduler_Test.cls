// 
// (c) 2014 Appirio, Inc.
//
// ContactNotificationBatchScheduler_Test
// Test class for ContactNotificationBatchScheduler
//
// July 13, 2015    Ashish Goyal             Original ()
@isTest
private class ContactNotificationBatchScheduler_Test {
	@isTest         
    static void testschedule() {
		Test.StartTest();
		ContactNotificationBatchScheduler sh1 = new ContactNotificationBatchScheduler();
		String sch = '0 0 23 * * ?'; 
		system.schedule('Test Territory Check', sch, sh1); 
		Test.stopTest(); 
	}
}