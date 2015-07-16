// 
// (c) 2014 Appirio, Inc.
//
// SendLogInNoticationToContactBatch_Test
// Test class for SendLogInNoticationToContactBatch
//
// July 13, 2015    Ashish Goyal             Original ()
@isTest
private class SendLogInNoticationToContactBatch_Test {
	@isTest         
    static void testBatch(){
    	Account acc = test_Utility.createAccount(true);
    	Contact con = New Contact(AccountId = acc.Id, LastName = 'Test', FirstName = 'Test');
    	insert con;
    	User tUser = test_Utility.createCommUser(con.Id, true);
    	Test.startTest();
    	SendLogInNoticationToContactBatch conBatch = new SendLogInNoticationToContactBatch();
    	Database.executeBatch(conBatch, 10);
    	Test.stopTest();
    	
    }
    
}