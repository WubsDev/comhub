/**
 * Appirio, Inc
 * Name             : GenericCsvWrapperTest
 * Created Date     : 30 April 2015 
 * Created By       : Piyush Bansal (Appirio)
 * Description      : Test class for GenericCsvWrapper
 */
@isTest
private class GenericCsvWrapperTest {
	static testMethod void testGenericCsvWrapper(){
        
        //start test execution
        Test.startTest();
        
        String[] tmpFields =  new List<String> { '123344','1234','han','12-05-2015','IN','Approved' };
        GenericCsvWrapper obj = new GenericCsvWrapper(tmpFields,'Option - Other');
        
        for(Schema.FieldSetMember f : Schema.getGlobalDescribe().get('input__c').getDescribe().fieldSets.getMap().get('Option_Other').getFields())
        {
        	obj.isValidData(f, true);
            obj.isValidData(true, true);
            obj.isValidData(true);
            obj.getParsedRec(f,tmpFields,1);
        }
        obj.CurrencyVal = 'USD';
        String curr = obj.CurrencyVal;
        obj.BuyCurrency = 'USD';
        String curr2 = obj.BuyCurrency;
        obj.SellCurrency = 'USD';
        String curr3 = obj.SellCurrency;
        obj.Status='Test';
        String status = obj.Status;
        
        obj.selectedCurrency = 'USD';
        obj.errorMsgPart('Test');
        obj.getsObjectName();
        GenericBaseCsvWrapper objBase = new GenericBaseCsvWrapper();
        obj.OnSaveUpdate(objBase);
        
        PageReference pgGenericCsv = Page.ParseAndDisplayCSVGeneric;
        User testUser = test_Utility.createTestUser(true);
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
            
       		tmpFields =  new List<String> { '123344','1234','han','12-05-2015','IN','Approved' };
            ctl.getGenericCsvWrapper(tmpFields, 'Option - Other');
            
            Account acc = new Account(name='Test Account');
            Utility.currentAccount = acc.Id;
            User usr = [Select   Id, Profile.Name, ContactId, DefaultCurrencyIsoCode, Name, IsPrmSuperUser,
                	CurrencyIsoCode, Contact.AccountId, Contact.Account.CurrencyIsoCode, LanguageLocaleKey FROM  User
                  	WHERE  Id = :UserInfo.getUserId() LIMIT 1];
            Utility.loggedInUser.id = usr.Id;
            //GenericBaseCsvWrapper inv = new GenericBaseCsvWrapper(tmpFields, 'Option - Other');
            String sobjname= ctl.getsObjectName();
            objBase.input = new input__c(name='Test');
            ctl.OnSaveUpdate(objBase);
            ctl.init();
            apexpages.currentpage().getparameters().put('attid',att.Id);
            apexpages.currentpage().getparameters().put('type','');
            ctl.init();
            ctl.cancel();
            ctl.isValidCsv = null;
            ctl.save();
            ctl.isValidCsv = true;
            ctl.save();
            map<String, String> mapStr = ctl.fieldLabels;
            List<SelectOption> CurrOpt = ctl.CurrencyOptions;
            ctl.OnSaveUpdate(objBase);
            
            ParseAndDisplayBaseCSVGenericCtl tmp = ctl.self;
            system.currentPageReference().getParameters().put('sourcePage',null);
            ctl.sourcePage = null;
            ctl.init();
            ctl.transtype='Option - Other';
            ctl.getFieldSet();
            //ctl.StatusOptions= Utility.picklistValues('input__c','Status__c', true);
            //List<SelectOption> statusOpt = ctl.StatusOptions;
            
			/*ParseAndDisplayBaseCSVGenericCtl baseObj = new ParseAndDisplayBaseCSVGenericCtl();            
            baseObj.getsObjectName();
            baseObj.transtype='Option - Other';
            baseObj.getGenericCsvWrapper(tmpFields, 'Option - Other');
            */
            
            system.currentPageReference().getParameters().put('tmp','Invoice');
            ParseAndDisplayCSVGenericTmpCtl tmpObj = new ParseAndDisplayCSVGenericTmpCtl();
                
            ParseAndDisplayCSVInvoice csvInvobj = new ParseAndDisplayCSVInvoice();    
            csvInvobj.getsObjectName();
            csvInvobj.parseAttachment(att.Body, 'Test');
            csvInvobj.getGenericCsvWrapper(tmpFields, 'Option - Other');
            csvInvobj.Init();
            csvInvobj.parseCsv('Test');
            //csvInvobj.OnSaveUpdate(objBase);
        }
        //stop test execution
        Test.stopTest();
    }
}