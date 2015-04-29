// 
// (c) 2014 Appirio, Inc.
//
// InputDetailController
// Used as Page Controller to show the details of Input object record and add attachment to record
//
// 02 Apr, 2015    Ashish Goyal  			Original (Ref. T-375814)
// 23 Apr, 2015	   Pratibha Chhimpa			Modified(I-156475)
public without sharing class InputDetailController {
	
	public Input__c inputRecord {get;set;}
	public Input__c inputOptionRecord {get;set;}
	transient public List<Attachment> listChildAttachments {get;set;}
	public String attachmentIdToDelete {get;set;}
	public Boolean isForcast {get; set;}
	public Boolean isOption {get; set;}
	public Boolean isFixed {get; set;}
	public Boolean isWindow {get; set;}
	public String selectedTranscation{get;set;}
	public String fieldset ;
	 //added line for test edit permissions
    public boolean canEdit{get;set;}

	  // Constructor
	 public InputDetailController(){
	 	isForcast = false;
		isOption = false;
		isFixed = false;
		isWindow = false;
		inputOptionRecord = new Input__c();
		if(ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != ''){
		 	for(Input__C tempInput : [SELECT id, Input_Type__c, Type__c, Option_Protection_Obligation__c from Input__c WHERE Id =: ApexPages.currentPage().getParameters().get('id')]){
		 		inputRecord = tempInput;
		 		selectedTranscation = tempInput.Input_Type__c;
		 	}
		 	if(inputRecord.Input_Type__c == 'Forecast Outflow' || inputRecord.Input_Type__c == 'Purchase Order' ||
		    	inputRecord.Input_Type__c == 'Outflow - Other' || inputRecord.Input_Type__c == 'Forecast Inflow' ||
		    	inputRecord.Input_Type__c == 'Inflow - Other'){
	    		isForcast = true;
	    		fieldset = 'InputDetailFS3';
	    	}
	    	else if(inputRecord.Input_Type__c == 'Option - Other' || inputRecord.Input_Type__c == 'Option - WUBS'){
	    		isOption = true;
	    		fieldset = 'InputDetailFS2';
	    		if(inputRecord.Option_Protection_Obligation__c!=null){
			 		for(Input__C tempInput : [SELECT id, Input_Type__c, Type__c, Option_Protection_Obligation__c from Input__c WHERE Id =: inputRecord.Option_Protection_Obligation__c]){
			 			if(inputRecord.Type__c.contains('Protection')){			 				
			 				inputOptionRecord = tempInput;
			 			}else{
			 				inputOptionRecord = inputRecord;
			 				inputRecord = tempInput;
			 			}
			 		}
	    		}
	    	}
			else if(inputRecord.Input_Type__c == 'Fixed Forward Contract - Other'){
	    		isFixed = true;    		
	    		fieldset = 'Fixed_Forward_Contract_Other';
	    	}
	    	else if(inputRecord.Input_Type__c == 'Window Forward Contract - Other'){
	    		isWindow = true;
	    		fieldset = 'Window_Forward_Contract_Other';
	    	} 
	    	system.debug('@@@@@ ' + inputRecord.Input_Type__c);
	    	inputRecord =  getInput(inputRecord.id);
	    	if(inputOptionRecord.Id != null){
	    		inputOptionRecord = getInput(inputOptionRecord.id);
	    	}
	    	canEdit = false;
         	canEdit = [SELECT RecordId, HasEditAccess FROM UserRecordAccess 
                            WHERE UserId = :userInfo.getuserId() AND RecordId = :inputRecord.id LIMIT 1].HasEditAccess ;
            listChildAttachments = findAttachments();

		 }

	 }
	 
	 //create new attachment record
	 public PageReference createNewAttachment(){
	    return new PageReference ('/apex/AttachmentUpload?pid='+inputRecord.id+'&retURL=%2Fapex%2FInputDetail?id='+inputRecord.id);
	 }
	 
	 //get all the child attachment records
	 private List<Attachment> findAttachments(){
	     return [SELECT Id, Name, LastModifiedById, CreatedById, ContentType FROM Attachment 
	             WHERE ParentId = :this.inputRecord.id];
	 }
	 
	 public PageReference delAttachment(){
	 	system.debug('$$$' + attachmentIdToDelete);
	   Attachment att = new Attachment(Id=attachmentIdToDelete);
	   delete att;
	   attachmentIdToDelete = '';
	   listChildAttachments = findAttachments();
	   return null;
	 }
	 
	 public Pagereference customDelete() {
	 	try{
	 		delete inputRecord;
	 		if(inputOptionRecord.Id != null){
	 			delete inputOptionRecord;
	 		}
	 		if(system.currentPageReference().getParameters().get('retURL') != null) {
	 			return new Pagereference(system.currentPageReference().getParameters().get('retURL'));
	 		}
	 		return Page.ManageCashInput;
	 	} catch(Exception ex) {
			return null;	 		
	 	}
	 }
	 public Pagereference customCancel() {
	 	try{
	 		if(system.currentPageReference().getParameters().get('retURL') != null) {
	 			return new Pagereference(system.currentPageReference().getParameters().get('retURL'));
	 		}
	 		return Page.ManageCashInput;
	 	} catch(Exception ex) {
			return null;	 		
	 	}
	 }
	 
	 public List<SelectOption> CurrencyOptions{
    	get{
    		if(CurrencyOptions==null || CurrencyOptions.size()==0){
        		CurrencyOptions= Utility.picklistValues('Input__c','CurrencyIsoCode', true);
    		}
    		return CurrencyOptions;
    	}
    	set;
    }
	 
	 public map<String, string> LabelMaps{
  		get{
  			//String apiName = Utility.changeTransactionType(selectedTranscation);
  			if(!String.isEmpty(fieldset)){
  				try{
  				return Utility.getFieldLabel('input__c', selectedTranscation);
  				}catch(Exception Ex){
  					
  				}
  			}
  			return new map<String, string>();
  		}
  	}

  	// Get fields from fieldset
	public List<Schema.FieldSetMember> getFields() {

        return Schema.SObjectType.Input__c.fieldSets.getMap().get(fieldset).getFields();
    }
    // GetInvoice with all the fields in the fieldset
    private Input__c getInput(String id) {
        String query = 'SELECT ';
        system.debug('#####' + this.getFields());
        for(Schema.FieldSetMember f : this.getFields()) {
            query += f.getFieldPath() + ', ';
        }
        query += 'Id,Input_Type__c,Type__c,CreatedById,OwnerId,LastModifiedById,Option_Protection_Obligation__c FROM Input__c Where Id =: id LIMIT 1';
        system.debug('#####' + query);
        return Database.query(query);
    }
    
    
    public PageReference save(){
    	try{
	    	if(inputRecord.Input_Type__c == 'Option - Other' || inputRecord.Input_Type__c == 'Option - WUBS'){
	    		inputOptionRecord.Transaction_Date__c = inputRecord.Transaction_Date__c;
	    		inputOptionRecord.Buy_Currency__c = inputRecord.Buy_Currency__c;
	    		inputOptionRecord.Sell_Currency__c = inputRecord.Sell_Currency__c;
	    		inputOptionRecord.Reference_Number__c = inputRecord.Reference_Number__c;
	    		inputOptionRecord.Counter_Party__c = inputRecord.Counter_Party__c;
	    		update inputOptionRecord;
	    	}
	    	update inputRecord;
	    	
	    	if(system.currentPageReference().getParameters().get('retURL') != null) {
	 			return new Pagereference(system.currentPageReference().getParameters().get('retURL'));
	 		}
	 		return Page.ManageCashInput;
    	}
    	catch(DMLException dmlEx){
    		ApexPages.addMessages(dmlEx);
    		return null;
    	}
    	
    }

}