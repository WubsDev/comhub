// 
// (c) 2014 Appirio, Inc.
//
// CMPFeedbackCreationPageCtrl
// Used to create new record for CMP Feedback object record and controller for CMPFeedbackCreationPage
//
// May 26, 2015    Ashish Goyal  			Original (Ref. T-398557)
public with sharing class CMPFeedbackCreationPageCtrl {
	
	public CMP_Feedback__c cmp {get; set;}
	public Attachment attach{get;set;}
	public AccountCMPJunction__c junctionObj {get; set;}
	public boolean isSuccess {get; set;}
	public boolean isShow {get; set;}
	
	
	// @description: class controller used to initialise variables 
	// @param: ApexPages.StandardController
	// @return: none
	
	public CMPFeedbackCreationPageCtrl(ApexPages.StandardController std){
		isSuccess = false;
		isShow = false;
		cmp = new CMP_Feedback__c();
		attach = new Attachment();
		junctionObj = new AccountCMPJunction__c();
	}
	
	public CMPFeedbackCreationPageCtrl(){
		isSuccess = false;
		cmp = new CMP_Feedback__c();
		attach = new Attachment();
		junctionObj = new AccountCMPJunction__c();
	}
	
	
	public void showDiv(){
		isShow = true;
	}
	
	// @description: insert the cmp feedback and attachmant record.
	// @param: none
	// @return: pagereference
	
	public void saveCMP(){
		SavePoint sp = Database.setSavepoint();
		try{			
			insert cmp;			
			if(attach.Name != null){
				attach.ParentId = cmp.Id;
				insert attach;
			}
			if(junctionObj.Account__c != null){ 
				junctionObj.CMP_Feedback__c = cmp.Id;
				insert junctionObj;
			}
			isSuccess = true;
			PageReference pageref = new pagereference('/apex/CMPFeedbackCreationPage');
			pageref.setRedirect(true);
			isShow = false;
			cmp = new CMP_Feedback__c();
			attach = new Attachment();
			//return pageRef;
		}
		catch(Exception e){
			Database.rollback(sp);
			isSuccess = false;
			ApexPages.addMessages(e);
			//return null;
		}
	}
	
	
	// @description: reset all the variable and redirect to different page 
	// @param: none
	// @return: pagereference
	
	public PageReference custCancel(){
		//delete cmp;
		PageReference pageref = new pagereference('/apex/CMPFeedbackCreationPage');
		//pageref.setRedirect(true);
		return pageRef;
	}

}