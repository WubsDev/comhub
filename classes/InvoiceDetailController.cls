/**=====================================================================
 * Appirio, Inc
 * Name: InvoiceDetailController
 * Description: Controller with business logic for InvoiceDetail VF page - T-361755
 * Created Date: 14 Feb' 2014
 * Created By: Jinesh Goyal (Appirio)
 * 
 * Date Modified                Modified By                  Description of the update
 *02 March 2015					Ranjeet Singh				Code Review - Should used standard fieldSet binding instead of describe
 															Fixed.
 *23 April 2015					Pratibha Chhimpa			I-156475													
 =====================================================================*/
 public without sharing class InvoiceDetailController{
	 
	 //class level member variables
	 public Invoice__c invoiceRecord {get;set;}
	 transient public List<Attachment> listChildAttachments {get;set;}
	 public String invoiceId {get;set;}
	 public String invoiceName {get;set;}
     public String attachmentIdToDelete {get;set;}
	 public Decimal settlementCurrency {get;set;}
     public String userDefaultCurrency{get;set;}
     public String settlementCurrencyDecimalVal{get;set;}
     //added line for test edit permissions
     public boolean canEdit{get;set;}
     public String returnURL{get; set;}
	 /*
	 public InvoiceDetailController(ApexPages.StandardController stdController) {
	     //get value from query string parameter
		 this.invoiceRecord = (Invoice__c)stdController.getRecord();
	     Schema.FieldSet fieldSet = Schema.SObjectType.Invoice__c.fieldSets.getMap().get('Detail');
	     Invoice__c tmpInv = [SELECT Name, Amount__c, Currency_Code__c FROM Invoice__c WHERE Id = :this.invoiceRecord.id and Account__c=:Utility.currentAccount LIMIT 1];
	     invoiceRecord.Settlement_Amount__c = Utility.getSettlementCurrencyAmount(tmpInv.Amount__c, tmpInv.Currency_Code__c, Utility.userCurrency );//UserInfo.getDefaultCurrency()
	     listChildAttachments = findAttachments();


	   
	 }//END OF CONSTRUCTOR */

	// Constructor
	public InvoiceDetailController() {
		returnURL = ApexPages.currentPage().getParameters().get('retURL');
	 	if(ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != ''){
	 		for(Invoice__c tmpInv : getInvoice(ApexPages.currentPage().getParameters().get('id')) ){
	 		    this.invoiceRecord = tmpInv;
	        }
            //invoiceRecord.Settlement_Amount__c = Utility.getSettlementCurrencyAmount(invoiceRecord.Amount__c, invoiceRecord.Currency_Code__c, Utility.userCurrency );//UserInfo.getDefaultCurrency()
	     	listChildAttachments = findAttachments();
	     	invoiceid=invoiceRecord.id;
	     	invoiceName = invoiceRecord.Name;
	     	canEdit = false;
            // canEdit = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :userInfo.getuserId() AND RecordId = :invoiceRecord.id LIMIT 1].HasEditAccess ;
            
            if(invoiceRecord.OwnerId == UserInfo.getUserId() || invoiceRecord.OwnerId == Utility.currentAccountOwner){
                canEdit = true;
            }
            
            userDefaultCurrency = UserInfo.getDefaultCurrency();
            settlementCurrency = Utility.getSettlementCurrencyAmount(invoiceRecord.Amount__c, invoiceRecord.Custom_Currency__c, userDefaultCurrency);      
            settlementCurrencyDecimalVal = settlementCurrency.format();
			
			if(!settlementCurrencyDecimalVal.contains(Utility.getDecimalChar)){
				settlementCurrencyDecimalVal = settlementCurrency.format() + Utility.getDecimalChar+'00';
			}
	 	}
	 	
	 }
	 
	 //create new attachment record
	 public PageReference createNewAttachment(){
	    return new PageReference ('/apex/AttachmentUpload?pid='+invoiceRecord.id+'&retURL=%2Fapex%2FInvoiceDetail?id='+invoiceRecord.id);
	 }
	 
	 //get all the child attachment records
	 private List<Attachment> findAttachments(){
	     return [SELECT Id, Name, LastModifiedById, CreatedById, ContentType FROM Attachment 
	             WHERE ParentId = :this.invoiceRecord.id];
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
	 		delete invoiceRecord;
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
	 		if(returnURL != null) {
	 			return new Pagereference(returnURL);
	 		}
	 		return Page.ManageCashInput;
	 	} catch(Exception ex) {
			return null;	 		
	 	}
	 }
	 /*
	 public PageReference alertEdit(){
	 	PageReference pgAlert = Page.NewThresholdAlertPage;
	 	pgAlert.getParameters().put('retURL', 'Invoice');
	 	pgAlert.getParameters().put('recId', this.invoiceRecord.id);
	 	pgAlert.getParameters().put('objectType', 'Invoice');
	 	//{!IF($Site.Prefix != null, URLFOR($Site.BaseCustomUrl+'/'+SUBSTITUTE($Site.Prefix, '/', '')), '')}/apex/NewThresholdAlertPage?objectType=Invoice&recId={!Invoice__c.id}
	 	pgAlert.setRedirect(true);
	 	return pgAlert;
	 }*/
	
	public List<SelectOption> CurrencyOptions{
    	get{
    		if(CurrencyOptions==null || CurrencyOptions.size()==0){
        		CurrencyOptions= Utility.picklistValues('Invoice__c','Custom_Currency__c', true);
    		}
    		return CurrencyOptions;
    	}
    	set;
    }
    
  	public map<String, string> LabelMaps{
  		get{
  			//String apiName = Utility.changeTransactionType(selectedTranscation);
  				try{
	  				return Utility.getFieldLabel('Invoice__c', 'Community Invoice Edit');
  				}catch(Exception Ex){
  					
  				}
  			return new map<String, string>();
  		}
  	}

  	public map<String, string> LabelDetailMaps{
  		get{
  			//String apiName = Utility.changeTransactionType(selectedTranscation);
  				try{
	  				return Utility.getFieldLabel('Invoice__c', 'Detail');
  				}catch(Exception Ex){
  					
  				}
  			return new map<String, string>();
  		}
  	}
	
	
	// Get fields from fieldset
	public List<Schema.FieldSetMember> getFields() {
        return SObjectType.Invoice__c.FieldSets.Detail.getFields();
    }
    // GetInvoice with all the fields in the fieldset
    private List<Invoice__c> getInvoice(String id) {
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : this.getFields()) {
            query += f.getFieldPath() + ', ';
        }
        String account = Utility.currentAccount;
        query += 'Id, Currency_Code__c FROM Invoice__c Where Id =: id and Account__c=:account LIMIT 1';
        return Database.query(query);
    }
    
    
    public PageReference save(){
    	Boolean hasError = false;
    	try{
	    	if(invoiceRecord.Name == null || invoiceRecord.Name == '') {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CM_Validation_Input_InvoiceNumberShouldNotBeBlank));
	            hasError = true;                
	        }   
	        if(invoiceRecord.Status__c == null || invoiceRecord.Status__c == ''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CM_Validation_Input_FieldStatusShouldNotBeBlank));
	            hasError = true;                
	        }       
	        if(invoiceRecord.Due_Date__c == null) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CM_Validation_Input_FieldPaymentDateShouldNotBeBlank));
	            hasError = true;
	        }
	        if(invoiceRecord.Amount__c == null ) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CM_Validation_Input_FieldAmountShouldNotBeBlank));
	            hasError = true;
	        }   
	        if(!Utility.isValidSfdcId(invoiceRecord.Input_Beneficiary__c)) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CM_Validation_Input_FieldSupplierShouldNotBeBlank));
	            hasError = true;
	        }   
	        if(invoiceRecord.Custom_Currency__c == '' || invoiceRecord.Custom_Currency__c == 'Select' || invoiceRecord.Custom_Currency__c == null) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CM_Validation_Input_FieldSelectedCurrencyIsNotValid));
	            hasError = true;
	        }   
	        if(!hasError) {
	        	update invoiceRecord;
				return new PageReference(returnURL);
	        }
	        return ApexPages.currentPage();
	    }catch(Exception ex){
    		ApexPages.addMessages(ex);
    		return ApexPages.currentPage();
    	}
	 }
	 
	 public PageReference cancel(){
	    return new PageReference ('/apex/InvoiceDetail?id='+invoiceRecord.id);
	 }
	 
 }//END OF CLASS