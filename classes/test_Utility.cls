/**=====================================================================
 * Name: test_Utility 
 * Description: utility class for for test data creation
 * Created Date: Mar 13, 2015
 * Created By: Aashita Sharma 
 =====================================================================*/

public with sharing class test_Utility {
            
   // method to create invoice record
    public static Invoice__c createInvoice(boolean isInsert){       
        Invoice__c invoice = new Invoice__c();
        invoice.CurrencyIsoCode = 'USD';
        if(isInsert)
        insert invoice;
        return invoice;
    }
    
    
    public static Input__c createInputWithType(boolean isInsert, String inputType, String accId){
      Input__c input = new Input__c(Input_Type__c = inputType);
      input.Amount__c = 11;
      input.Parent_Account__c = accId;
      input.CurrencyIsoCode = 'INR';
      input.Custom_Currency__c = 'INR';
      input.Transaction_Date__c = date.today().addDays(2);
      
      if(isInsert) 
      insert input;
      return input;
    }
    
    public static Input__c createInput(boolean isInsert){
      Input__c input = new Input__c(Input_Type__c = 'Purchase Order');
      input.Amount__c = 11;
      input.CurrencyIsoCode = 'INR';
      input.Custom_Currency__c = 'INR';
      input.Transaction_Date__c = date.today().addDays(2);
      
      if(isInsert) 
      insert input;
      return input;
    }
	public static Attachment addAttachmentToParent(Id parentId, String attName, String testData) {  
	    Blob b = Blob.valueOf(testData);  
	      
	    Attachment attachment = new Attachment();  
	    attachment.ParentId = parentId;  
	    attachment.Name = attName;  
	    attachment.Body = b;  
	      
	    insert(attachment);  
	    return attachment;
	}  
    public static User createTestUser(boolean isInsert){
       Campaign camp = new Campaign(Name= 'Bronze Trigger Emails');
        insert camp; 
      
      Account acc = new Account();
      acc.Name = 'testname';
      insert acc;
      
      Contact contact = new Contact();
      contact.AccountId =  acc.Id;
      contact.LastName = 'testlastname';
      insert contact;
      
      User testUser = new User();
      //testUser = new User();
      testUser.alias = 'testuser';
      testUser.Email = 'testuser@test123.com';
      testUser.EmailEncodingKey = 'ISO-8859-1';
      testUser.LanguageLocaleKey = 'en_US';
      testUser.LastName = 'Test User567';
      testUser.LocaleSidKey = 'en_AU';
      testUser.Account_Administrator__c = false;
      testUser.ProfileId = [SELECT Id FROM Profile WHERE Name LIKE 'Partner community - FX management tool' LIMIT 1].Id;
      testUser.TimeZoneSidKey = 'Australia/Sydney';
      testUser.UserName = 'testuser@travelex.com.au';
      testUser.ContactId = contact.Id;
      testUser.DefaultCurrencyIsoCode = 'INR';
      if(isInsert)
      insert testUser;
      return testUser;
    }   
    
    
    public static Historical_Payments__c createHistoricalPayments(ID accID ,Boolean isInsert) {
    	Historical_Payments__c payment = new Historical_Payments__c(Account_ID__c = accID, Amount__c = 14, Date__c = '201411', CurrencyISOCode = 'INR');
    	if(isInsert) {
    		insert payment;
    	} 
    	return payment;
    }
    
    public static Holding_Balance__c createHoldingBalance(ID accID ,Boolean isInsert) {
    	Market_Rate__c mRate = new Market_Rate__c(Currency_Code__c = 'INR', Currency_Name__c = 'INR', Currency_Value__c = 60, Last_Updated__c = System.today());
    	insert mRate;
    	Holding_Balance__c holdingBal = new Holding_Balance__c(Account__c = accID, Amount__c = 10000, Custom_Currency__c = 'INR', External_id__c = (datetime.now()+''));
    	holdingBal.Market_Rate__c = mRate.id;
    	if(isInsert) {
    		insert holdingBal;
    	} 
    	return holdingBal;
    } 
    
    public static Account createAccount(Boolean isInsert) {
      Account acc = new Account();
      acc.Name = 'testname';
      if(isInsert) {
      	insert acc;
      } 
      return acc;
    }   
    
    public static Beneficiary__c createBeneficiary(String name, ID accID, Boolean isInsert) {
    	Bene_Enrollment_Campaign__c beneEnrollment = new Bene_Enrollment_Campaign__c(Account__c = accID, Campaign_Start_Date__c = System.today(), Campaign_End_Date__c = System.today().addDays(30), Campaign_Status__c = 'Planned');
    	insert beneEnrollment;
    	Beneficiary__c beneficiary = new Beneficiary__c(Name = name, Account_Name__c = accID, Enrollment_Campaign__c = beneEnrollment.id);
    	if(isInsert) {
    		insert beneficiary;
    	}
    	return beneficiary;
    }
    
    public static Forward_Contracts__c createForwardContracts(ID accID, Boolean isInsert) {
         Forward_Contracts__c forwardContracts = new  Forward_Contracts__c();
         forwardContracts.Account_ID__c = accID;

         forwardContracts.Settlement_Amount__c = 20; 
         forwardContracts.Maturity_Date__c =  Date.today().addDays(5);
         forwardContracts.Start_Date__c = Date.today();
         forwardContracts.Transaction_Number__c = 25;
         forwardContracts.Custom_Currency__c = 'USD';
         if(isInsert) {
         	insert forwardContracts;
         } 
         return forwardContracts;    
    }          
     
     
    public static User createCommUser(Id conId, Boolean isInsert){
    	User testUser = new User();
      	testUser.alias = 'testuder';
      	testUser.Email = 'testuser@test1233.com';
      	testUser.EmailEncodingKey = 'ISO-8859-1';
      	testUser.LanguageLocaleKey = 'en_US';
      	testUser.LastName = 'Test User5627';
      	testUser.LocaleSidKey = 'fr';
      	testUser.Account_Administrator__c = false;
      	testUser.ProfileId = [SELECT Id FROM Profile WHERE Name LIKE '%CCT%' LIMIT 1].Id;
      	testUser.TimeZoneSidKey = 'Australia/Sydney';
      	testUser.UserName = 'testuser@travelex.com.auc';
      	testUser.ContactId = conId;
      	testUser.DefaultCurrencyIsoCode = 'INR';
      	if(isInsert)
      		insert testUser;
      	return testUser;
	}
}