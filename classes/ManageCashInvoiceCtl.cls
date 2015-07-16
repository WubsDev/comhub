global without sharing class ManageCashInvoiceCtl {

    public boolean hasError {get;set;}
    public Invoice__c invoice{get;set;}
    public String invoiceImageBody{get;set;}
    public String invoiceImageName{get;set;}
    public String selectedForwardContractCurrency{get;set;}
    public list<SelectOption> lstTransactionType {get;set;}
    public InsightsAndInputTabCtrl InsightsAndInputCtl{get;set;}
    
    private string beneficaryId{get;set;}
    public Id AccId{
    	get{
    		return Utility.currentAccount;
    	}
    }
    public String finishedCollapse{get;set;}
    
    // This method used for get Transaction Type picklist value from custom setting (I-148624)
    public List<SelectOption> getTransactionTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Select','Select'));
        for(Transaction_Type__c tt : [SELECT id, name, Option_Index__c From Transaction_Type__c order by Option_Index__c ]){
            options.add(new SelectOption(tt.Name,tt.Name));
        }
        return options;
    }
    
    public String inputLink{
    	get{
    		return Utility.inputLink;
    	}
    }    
    public ManageCashInvoiceCtl(){
        invoice = new Invoice__c();
        invoiceImageBody = '';
        invoiceImageName = '';
        beneficaryId = ApexPages.currentPage().getParameters().get('beneficaryId');
        if (beneficaryId != null) {
            invoice.Beneficiary_Contact__c = beneficaryId;
        }
        finishedCollapse = null;
        finishedCollapse = ApexPages.currentPage().getParameters().get('fin');
        lstTransactionType = getTransactionTypes();
    }
    public List<SelectOption> getForwardContractCurrency(){
        selectedForwardContractCurrency = '';
       List<SelectOption> currList =  Utility.picklistValues('Invoice__c','Custom_Currency__c', true);
       if(currList.size() > 0){
        selectedForwardContractCurrency = currList[0].getValue();
       }
       return currList;
    }
	// To Cancel the record    
    public void cancel2() {
    	if(InsightsAndInputCtl!=null){
    		//InsightsAndInputCtl.selectedTranscation = '';
    	}
        if(invoice.id != null)
        delete invoice;
        else{
        	invoice = new Invoice__c();
        }
    }
    
    
// To create the New Invoice Record with validation that all fields are mandatory    
    public pagereference saveInvoice() {
        try{
            hasError = false;
            invoice.Custom_Currency__c = selectedForwardContractCurrency;
            if(invoice.Name == null || invoice.Name == '') {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CM_Validation_Input_InvoiceNumberShouldNotBeBlank));
                hasError = true;                
            }   
            if(invoice.Status__c == null || invoice.Status__c == ''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CM_Validation_Input_FieldStatusShouldNotBeBlank));
                hasError = true;                
            }       
            /*if(invoice.Custom_Currency__c == null) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Currency Should Not be Blank '));
                hasError = true;
            }*/
            if(invoice.Due_Date__c == null) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CM_Validation_Input_FieldPaymentDateShouldNotBeBlank));
                hasError = true;
            }
            if(invoice.Amount__c == null ) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CM_Validation_Input_FieldAmountShouldNotBeBlank));
                hasError = true;
            }   
            if(!Utility.isValidSfdcId(invoice.Input_Beneficiary__c)) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CM_Validation_Input_FieldSupplierShouldNotBeBlank));
                hasError = true;
            }   
            if(invoice.Custom_Currency__c == '' || invoice.Custom_Currency__c == 'Select' || invoice.Custom_Currency__c == null) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CM_Validation_Input_FieldSelectedCurrencyIsNotValid));
                hasError = true;
            }   
            if(!hasError) {
                invoice.Account__c= Utility.currentAccount;
                insert invoice;
                system.debug('invoiceImagename >>> '+invoiceImageName);
                system.debug('invoiceImageBody >>> '+invoiceImageBody);
                // insert invoice attachments 
                if(!String.isBlank(invoiceImageName) && !String.isBlank(invoiceImageBody)) {
                    Attachment att = new Attachment();
                    att.ParentId = invoice.Id;
                                    att.Body = Encodingutil.base64Decode(invoiceImageBody);
                                    att.Name = invoiceImageName;
                    insert att;
                }
                invoice = new Invoice__c();
        
	            if (beneficaryId != null) {
	                invoice.Beneficiary_Contact__c = beneficaryId;
	            }
            }
            //else{
                return null;
            //}
        } catch(Exception ex){
            hasError = true;
            if(ex.getMessage().contains('Duplicate Invoice Number and Beneficiary Found')){
                //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Unable to save Invoice. Duplicate Invoice Number and Beneficiary Found'));
            } else{
                if(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                    //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
                }else{
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CM_Alert_UnableToSaveInvoice + ex.getMessage()));
                }
            }
            return null;
        }
        finally {   
	    	if(ApexPages.hasMessages(ApexPages.Severity.Error)){
	    		hasError = true;
	    	}
            invoiceImageBody = '';
            invoiceImageName = '';
        }
    }

    
}