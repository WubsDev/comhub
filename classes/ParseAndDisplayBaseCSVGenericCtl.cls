public virtual without sharing class ParseAndDisplayBaseCSVGenericCtl {
    public list<GenericBaseCsvWrapper> inputList {get; set;}
    public String attachmentid{get;set;}
    public list<GenericBaseCsvWrapper> parsedInput{get;set;}
    public String csvString; 
    private Attachment attach = new Attachment();
    public string transtype;
    public Boolean doSave{get;set;}
    public boolean isValidCsv{get;set;}
    public boolean hasError{get;set;}
    public String sourcePage{get;set;}
    public String fieldSetName{get;set;}
    public String defaultSourcePage {get;set;}
    public Boolean isNext {get; set;}
    public Integer isStartLocation {get; set;}
    public List<SelectOption> CurrencyOptions{get; set;}
    // public List<SelectOption> StatusOptions{get; set;}
    public ParseAndDisplayBaseCSVGenericCtl self{
    	get{
    		return this;
    	}
    	set;
    }
    public List<SelectOption> StatusOptions{
        get{
            if(StatusOptions==null || StatusOptions.size()==0){
                StatusOptions= Utility.picklistValues(getsObjectName(),'Status__c', true);
            }
            return StatusOptions;
        }
        set;
    }
    public virtual GenericBaseCsvWrapper getGenericCsvWrapper(String[] tempFields, String transtype){ return null;}
    public map<String, String> fieldLabels{
    	get{
    		return Utility.getFieldLabel(getsObjectName(), transtype);
    	}
    }
    public virtual void OnSaveUpdate(GenericBaseCsvWrapper inv) {}
    public ParseAndDisplayBaseCSVGenericCtl(){
        if(CurrencyOptions==null || CurrencyOptions.size()==0){
            CurrencyOptions= Utility.picklistValues(getsObjectName(),'Custom_Currency__c', true);
        }/*
        if(StatusOptions==null || StatusOptions.size()==0){
            //StatusOptions= Utility.picklistValues(getsObjectName(),'Status__c', true);
        }*/
    }
	public virtual PageReference Init(){
        try{
            
            isNext = false;
            isStartLocation = -1;
        	isValidCsv = true;
        	hasError = false;
        	doSave = false;
            
            // GET THE ATTACHMENT ID FOR PARSING
			if(system.currentPageReference().getParameters().get('sourcePage') != null) {
	    		sourcePage = System.currentPageReference().getParameters().get('sourcePage');
	    	}
	    	if(String.isEmpty(sourcePage)){
	    		sourcePage = defaultSourcePage;//Default is input
	    	}            
            attachmentid = apexpages.currentpage().getparameters().get('attid');
            transtype = apexpages.currentpage().getparameters().get('type');
            fieldSetName = Utility.changeTransactionType(transtype);
            system.debug('*****>> transtype::'+transtype);
            if(!String.isEmpty(attachmentid)&& attachmentid.length()>14){
                attach = [Select id,Body,Name,Description From Attachment Where id =:attachmentid ];
                if(!String.isEmpty(attach.Description)){    
                    isStartLocation = Integer.valueOf(attach.Description);
                }
                system.debug('----------'+attach);
                parseAttachment(attach.Body,attach.Name);
                system.debug('----------parsedInput------inputList---'+inputList.size());
               /* if(inputList.size() > 100){
                    list<GenericBaseCsvWrapper> inputList2 = inputList;
                    inputList.clear();
                    for(Integer iCount = 0; iCount < 100; iCount++){
                        inputList.add(inputList2.get(iCount));
                    }
                }*/
            }
            else{
                //***** Custom Label for Error Message: CM_Alert_AttachmentNotFoundPleaseReloadFile
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.CM_Alert_AttachmentNotFoundPleaseReloadFile));
                hasError = true;
                isValidCsv = false;
            }
            if(String.isEmpty(transtype)){
                //***** Custom Label for Error Message: CM_Alert_TransactionTypeNotFoundPleaseReloadFile
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.CM_Alert_TransactionTypeNotFoundPleaseReloadFile));
            	hasError = true;
            	isValidCsv = false;            	
            }
        }catch(Exception Ex){
            //***** Custom Label for Error Message: CM_Alert_UnableToLoadPageErrorDetail
            if(isValidCsv){
                if((Ex.getMessage()).contains('BLOB is not a valid')){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.CM_Alert_PleaseUploadAValidFormOfData));
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.CM_Alert_System_UnableToLoadPage + ' ' + Ex.getMessage()));
                }
            }
            hasError = true;
            isValidCsv = false;
        }    
        return null;	
	}
    
    public virtual String getsObjectName(){return '';}
    public virtual List<Schema.FieldSetMember> getFieldSet(){
    	String fieldsetApiName = Utility.changeTransactionType(transtype);
    	return  Schema.getGlobalDescribe().get(getsObjectName()).getDescribe().FieldSets.getMap().get(fieldsetApiName).getFields();
    }
    
// TO Check that the File is CSV and to convert the file from BLOB to String for parsing   
    public virtual void parseAttachment(Blob body, String name){        
        if(name.endsWith('.csv')) {
        	system.debug('********Blob z:'+body);
            csvString = body.toString();
            system.debug('********Blob zing:'+csvString);
            inputList = parseCsv(csvString);
        }else {
            //***** Custom Label for Error Message: CM_Alert_InvalidFileFormat
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.CM_Alert_File_InvalidFileFormat));
            isValidCsv = false;
        }
    }   

	public virtual void updateBeneficiaries(){
		system.debug('********updateBeneficiaries');
		Set<string>InputBeneficiary = new Set<string>();
		for(GenericBaseCsvWrapper incWpr : parsedInput){
			String beneName = incWpr.mapCSVvalues.get('Input_Beneficiary__c');
			if(!String.isEmpty(beneName)){
        		InputBeneficiary.add(beneName.toUpperCase());
			}
        }        
        map<string,id>inputBeneficiaryId = new map<string,id>();
        if(InputBeneficiary.size()>0){
		    for(Input_Beneficiary__c beneficiary : [Select ID,Name from Input_Beneficiary__c where Name in: InputBeneficiary and account__c=:Utility.currentAccount]){
		    	inputBeneficiaryId.put(beneficiary.Name.toUpperCase(), beneficiary.id);
		    }
        }
        List<Input_Beneficiary__c> newInput_Beneficiary = new List<Input_Beneficiary__c>();
        //Create new Input_Beneficiary if not exist in system.
        for(GenericBaseCsvWrapper incWpr : parsedInput){
			String beneName = incWpr.mapCSVvalues.get('Input_Beneficiary__c');
			if(!String.isEmpty(beneName)){
        		beneName = beneName.toUpperCase();
        		if(!inputBeneficiaryId.containsKey(beneName)){
        			// Create InputBeneficiary
        			Input_Beneficiary__c bene = new Input_Beneficiary__c();
        			bene.Account__c = Utility.currentAccount;
        			bene.name = incWpr.mapCSVvalues.get('Input_Beneficiary__c');
        			newInput_Beneficiary.add(bene);
				}
			}
        }
        system.debug('********updateBeneficiaries:'+newInput_Beneficiary);
        //Insert new Bene
        if(newInput_Beneficiary.size()>0){
        	insert newInput_Beneficiary;
        	for(Input_Beneficiary__c newBene : newInput_Beneficiary){
        		inputBeneficiaryId.put(newBene.Name.toUpperCase(), newBene.id);
        	}
        }
        system.debug('********this.inputBeneficiaryId >> '+inputBeneficiaryId);
		for(GenericBaseCsvWrapper incWpr : parsedInput){
			String beneName = incWpr.mapCSVvalues.get('Input_Beneficiary__c');
			if(!String.isEmpty(beneName)){
				beneName = beneName.toUpperCase();
                incWpr.beneName = beneName;
				if(inputBeneficiaryId.containsKey(beneName)){
			        incWpr.input.put('Input_Beneficiary__c', inputBeneficiaryId.get(beneName));		        
				}
			}
			system.debug('********incWpr.input >> '+incWpr.input);
	    }
	}
    
	// Parse the CSV file and add it to the parsedInput list
    public virtual list<GenericBaseCsvWrapper> parseCsv(String content){
    	List<ApexPages.Message> invalidInCsvMsgs = new List<ApexPages.Message>();
    	this.isValidCsv = true;
        
        system.debug('----------isStartLocation-----'+isStartLocation);
        List<String>inputbenNames = new List<String>();
        if(content != null) {
            Integer invalidRowCount = isStartLocation;
            invalidRowCount = 0 ;
            List<String> contentString = content.split('\n'); 
            for(Integer indexCSV = isStartLocation+1; indexCSV < contentString.size() && indexCSV <= isStartLocation+52; indexCSV++){
                String str =  contentString.get(indexCSV);
                system.debug('-------------------str-------------'+str);
            	if(Utility.isValidText(str)){
	                for(String str1 : str.split('\r')) {
                    	system.debug('-------------------str1-------------'+str1);
	                	if(Utility.isValidCsvRow(str1)){
	                		invalidRowCount++;
	                		//Skip Header
	                		if(invalidRowCount>1){
                            	List<String> tempFields;
                           		tempFields = str1.split(Utility.CSVRowDeliminator);
			                    //Verify the Length of array, check for trim/empty line.
			                    GenericBaseCsvWrapper inv = getGenericCsvWrapper(tempFields, transtype);
			                    inv.isValidData(true);
		                    	parsedInput.add(inv);
	                		}
	                	}
	                }
	            }
                if(parsedInput.size() > 50){
                    isNext = true;
                    parsedInput.remove(50);
                     break;
                }

            }
        }
        // parsedInput.remove(101);
        system.debug('----------parsedInput---------'+parsedInput.size());
        if(parsedInput.size()==0 ){             // || parsedInput.size()>100){
        	this.isValidCsv = false;
        }
        if(this.isValidCsv){
            //T-411078 : CMP Upload Fix.
            updateBeneficiaries();
        	for(GenericBaseCsvWrapper incWpr : parsedInput){
        		incWpr.isValidData(true, true);        		
        	}
        }else{
        	system.debug('********this.isValidCsv >> '+this.isValidCsv);
            //***** Custom Label for Error Message: CM_Alert_InvalidEmptyCSVPleaseFixAndTryAgain         
           /* if(parsedInput.size()>100){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CM_Community_Max_CSV_ErrorMsg));
            }else{*/            
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CM_Alert_InvalidEmptyCSVPleaseFixAndTryAgain));
           // }
        	parsedInput = new list<GenericBaseCsvWrapper>();        	
        }
        system.debug('********parsedInput >> '+parsedInput);
        return parsedInput;
    }
    
    public virtual PageReference cancel(){
        PageReference page = new Pagereference('/apex/'+sourcePage);
        page.setRedirect(true);
        delete attach;
        return page;
    }
    
   
	// Save the CSV file records
    public virtual PageReference save() {
    	system.debug('********this.isValidCsv >-0-> ');
        saveAndSubmit();
        return null;
    }
    
    
    
    public virtual PageReference showNextRecordToInsert(){
        saveAndSubmit();
        hasError = false;
        doSave = false;
        isNext = false;
        isStartLocation += 50;
        attach.Description = isStartLocation+'';
        update attach;
        system.debug('---------------------------attach---------------------------------------'+attach);
        parsedInput.clear();
        inputList.clear();
        parseAttachment(attach.Body,attach.Name);
        return null;
    }
    
    
    public virtual void saveAndSubmit(){
        doSave = true;
        hasError= false;
        try{
	        if(this.isValidCsv){
	        	for(GenericBaseCsvWrapper incWpr : parsedInput){
	        		if(!incWpr.isValidData(true, true)){
	        			hasError = true;
	        		}        		
	        	}
	        }
	        system.debug('********this.isValidCsv >-1-> '+hasError);
	        if(hasError){
	        	doSave = false;
                return;
	        }
	        system.debug('********this.isValidCsv >-2-> ');
            //Added by Vivek
            // To get the AccountId of logged in user
            User userLoggedIn = Utility.loggedInUser;
            Id accId = Utility.currentAccount;

            List<sObject> inputListInsert = new List<sObject>();
			system.debug('********this.isValidCsv >-3-> ');
            for(GenericBaseCsvWrapper inv : parsedInput){
                inv.input.put('CurrencyIsoCode', inv.mapPicklistSelect.get('Custom_Currency__c'));
                system.debug('Invoice:' + inv.input);
                OnSaveUpdate(inv);
                system.debug('********this.isValidCsv >-33-> '+inv.input);
                if(inv.fieldSetName=='Option_Other'){
                	system.debug('********this.isValidCsv >-34-> '+inv.inputOther);
                	inputListInsert.add(inv.inputOther);
                }
                inputListInsert.add(inv.input);
            }
            //Added by Piyush To prevent Save if any field is blank
            if(doSave){
            	system.debug('********this.isValidCsv >-5-> '+inputListInsert.size());
            	if(inputListInsert.size()>0){ 
            		system.debug('********this.isValidCsv >-77-> '+inputListInsert.size());
	            	if(inputListInsert[0].id!=null){
	            		Database.upsert(inputListInsert, true);
	            	}else{
	            		Database.insert(inputListInsert, true);
	            	}
            	}
            	//Update the ref for option inputs.
            	List<sobject>optionUpdate = new List<sobject>();
            	for(GenericBaseCsvWrapper inv : parsedInput){
	                if(Utility.updateRefOptionInput(inv.input, inv.inputOther, inv.fieldSetName)){
	                	optionUpdate.add(inv.input);
	                	optionUpdate.add(inv.inputOther);
	                }
            	}
            	if(optionUpdate.size()>0){
            		Database.update(optionUpdate, true);
            	}
                //upsert invoiceListInsert;
                hasError = false;
                doSave = true;
                system.debug('********this.isValidCsv >-6-> ');
            }
        }
        catch(exception ex){
        	system.debug('********this.isValidCsv >-7-> ');
            hasError = true;
            doSave=false;
            //FIELD_CUSTOM_VALIDATION_EXCEPTION
            if(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CM_Alert_UnableToSaveInvoice));
            } else{
                //***** Custom Label for Error Message: CM_Alert_UnableToSaveErrorDetail
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CM_Alert_UnableToSaveErrorDetail + ' ' + ex.getMessage()));
            }           
        }
    }
}