// 
// (c) 2014 Appirio, Inc.
//
// InputInvoiceSharingManager_Test
// Test class for InputInvoiceSharingManager
//
// July 13, 2015    Ashish Goyal             Original ()
@isTest
private class InputInvoiceSharingManager_Test {
	@isTest         
    static void testUserDetail(){
    	Input__c input;
    	Invoice__c inv;
    	Account acc = test_Utility.createAccount(true);
    	Contact con = New Contact(AccountId = acc.Id, LastName = 'Test', FirstName = 'Test');
    	insert con;
    	User tUser = test_Utility.createCommUser(con.Id, true);
    	System.runAs(tUser){
    		Test.startTest();
    		input = test_Utility.createInput(false);
    		input.Parent_Account__c = acc.Id;
    		inv = test_Utility.createInvoice(false);
    		inv.Account__c = acc.Id;
    		insert input;
    		insert inv;    
    		tUser.Share_Records__c = true;
    		update tUser;	
    		tUser.Share_Records__c = false;
    		update tUser;
    		Test.stopTest();	
    	}
    	
    	
    	
    	
    }
}