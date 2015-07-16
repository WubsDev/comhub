/**=====================================================================
 * Name: ParseAndDisplayCSVGenericCtlTest
 * Description: Test class for ParseAndDisplayCSVGenericCtl controller.
 * Created Date: 24 March, 2015
 * Created By: Ranjeet Singh (JDC)
 *
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/
 
@isTest
private class ParseAndDisplayCSVGenericCtlTest {
//!! 
//

    static User testUser = null;
    static testMethod void unitTestController() {
        PageReference pgGenericCsv = Page.ParseAndDisplayCSVGeneric;
        testUser = test_Utility.createTestUser(true);
        pgGenericCsv.getParameters().put('sourcePage', 'InsightsAndInputTab');
        System.runAs(testUser){
            Input__c input = test_Utility.createInput(true);
            Attachment att = test_Utility.addAttachmentToParent(input.id, 'test2.csv', '01/13/2015,USD,5,2,test 8822,123\n01/13/2015,USD,5,2,test 8822,123');
            system.debug('*****input>>'+input.id+'..att :'+att.id);
            String attachmentid = '';//pgGenericCsv.getparameters().put('attid', att.id);
            String transtype = pgGenericCsv.getparameters().put('type', 'Option - WUBS');
            Test.setCurrentPage(pgGenericCsv);
            ParseAndDisplayCSVGenericCtl ctl =new ParseAndDisplayCSVGenericCtl();
            ctl.Init();
            ctl.parseCsv('123344,1234,han,12-05-2015,IN,Approved');
            ctl.parseAttachment(att.Body, 'Test');
            
       		String[] tmpFields =  new List<String> { '123344','1234','han','12-05-2015','IN','Approved' };
            ctl.getGenericCsvWrapper(tmpFields, 'Option - Other');
            
            Account acc = new Account(name='Test Account');
            Utility.currentAccount = acc.Id;
            User usr = [Select   Id, Profile.Name, ContactId, DefaultCurrencyIsoCode, Name, IsPrmSuperUser,
                	CurrencyIsoCode, Contact.AccountId, Contact.Account.CurrencyIsoCode, LanguageLocaleKey FROM  User
                  	WHERE  Id = :UserInfo.getUserId() LIMIT 1];
            Utility.loggedInUser.id = usr.Id;
            //GenericBaseCsvWrapper inv = new GenericBaseCsvWrapper(tmpFields, 'Option - Other');
            //ctl.OnSaveUpdate(inv);
        }
        
    }

}