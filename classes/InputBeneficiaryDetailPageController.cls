// 
// (c) 2014 Appirio, Inc.
//
// InputBeneficiaryDetailPageController
// Used as Page Controller to show the details of Input Beneficiary object record
//
// 07 Apr, 2015    Ashish Goyal  Original (Ref. T-375697)
//
public without sharing class InputBeneficiaryDetailPageController {
	
	public Input_Beneficiary__c inputRecord {get;set;}	
	public boolean escapeAssociation = false;
	public InputBeneficiaryDetailPageController(ApexPages.StandardController stdController) {	
	    
		this.inputRecord = (Input_Beneficiary__c)stdController.getRecord();
	}
	
	public InputBeneficiaryDetailPageController(){
		if(ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != ''){
	 		for(Input_Beneficiary__c tmpInv : getInputBene(ApexPages.currentPage().getParameters().get('id')) ){
	 		    this.inputRecord = tmpInv;
	        }
		}
	}
	
	
	public Pagereference customDelete() {
		try{
	 		boolean foundAssociation =false;
	 		//Check existing association with Invoice.Inpts.
	 		String associationMsg = '';
	 		List<Invoice__c>invoices = [select id, Name from Invoice__c where Input_Beneficiary__c =:this.inputRecord.id];
	 		if(invoices.size()>0){
	 			associationMsg = 'Invoices ( '+invoices.size()+')';
	 			foundAssociation = true;
	 		}
	 		List<Input__c>inputs = [select id, Name from Input__c where Input_Beneficiary__c =:this.inputRecord.id AND Input_Type__c != 'Invoice'];
	 		if(inputs.size()>0){
	 			if(!String.isEmpty(associationMsg)){
	 				associationMsg = ' and ';
	 			}
	 			associationMsg = 'Inputs ( '+inputs.size()+')';
	 			foundAssociation = true;
	 		}
	 		if(foundAssociation && !escapeAssociation){
	 			escapeAssociation = true;	 			 
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Please press Delete to continue. Found associated '+associationMsg));
	 		}else{
		 		delete inputRecord;
		 		if(system.currentPageReference().getParameters().get('retURL') != null) {
		 			return new Pagereference(system.currentPageReference().getParameters().get('retURL'));
		 		}
		 		return Page.ManageCashInput;
	 		}
	 	} catch(Exception er) {	
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,er.getDmlMessage(0)); 
            ApexPages.addMessage(myMsg);				 		
	 	}
	 	return ApexPages.currentPage();
	 }
	 
	 
	 public PageReference doRedirect(){
	 	String sitePath = Site.getPathPrefix();
	 	if(String.isEmpty(sitePath)){
	 		return new Pagereference('/'+inputRecord.Id+'?nooverride=1');
	 	}
	 	return null;
	 }
	 
	 
	 // GetInvoice with all the fields in the fieldset
    private List<Input_Beneficiary__c> getInputBene(String id) {
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : this.getFields()) {
            query += f.getFieldPath() + ', ';
        }
        String account = Utility.currentAccount;
        query += 'Id, OwnerId FROM Input_Beneficiary__c Where Id =: id LIMIT 1';
        return Database.query(query);
    }
    
    
    // Get fields from fieldset
	public List<Schema.FieldSetMember> getFields() {
        return SObjectType.Input_Beneficiary__c.FieldSets.Detail.getFields();
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
	 
	 public map<String, string> LabelDetailMaps{
  		get{
  			//String apiName = Utility.changeTransactionType(selectedTranscation);
  				try{
	  				return Utility.getFieldLabel('Input_Beneficiary__c', 'Detail');
  				}catch(Exception Ex){
  					
  				}
  			return new map<String, string>();
  		}
  	}

}