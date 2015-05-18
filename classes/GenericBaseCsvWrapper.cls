/**=====================================================================
 * Name: GenericBaseCsvWrapper
 * Description: Related to CSV Parser
 * Created Date: 29 March, 2015
 * Created By: Ranjeet Singh (JDC)
 *
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/
public virtual class GenericBaseCsvWrapper {
	public sObject input {get;set;}
    public sObject inputOther{get;set;}
	//public member
	public String CurrencyVal{
		get{
			return mapPicklistSelect.get('Custom_Currency__c');
		}
		set{
			mapPicklistSelect.put('Custom_Currency__c', value);
		}
	}
	public String Status{
		get{
			return mapPicklistSelect.get('Status__c');
		}
		set{
			mapPicklistSelect.put('Status__c', value);
		}
	}
	
	public String BuyCurrency{
		get{
			return mapPicklistSelect.get('Buy_Currency__c');
		}
		set{
			mapPicklistSelect.put('Buy_Currency__c', value);
		}
	}
	
	public String SellCurrency{
		get{
			return mapPicklistSelect.get('Sell_Currency__c');
		}
		set{
			mapPicklistSelect.put('Sell_Currency__c', value);
		}
	}
	
	public map<string, string>mapPicklistSelect{get;set;}
    public map<string, string>mapCSVvalues{get;set;}
	public boolean isValid{get;set;}
	public string transtype{get;set;}
	public string selectedCurrency {get;set;}
	public string fieldSetName{get;set;}
	
	public map<String, String> fieldLabels {
		get{
			if(fieldLabels==null){ 
				fieldLabels = Utility.getFieldLabel(getsObjectName(), transtype);
			}
			return fieldLabels;
		}	
		set;	
	}
	public virtual String errorMsgPart(String srcText){return '';}
	public virtual String getsObjectName(){return '';}
	
	public GenericBaseCsvWrapper(){
		
	}
	public virtual void OnSaveUpdate(GenericBaseCsvWrapper inv) {
		
	}
	
	public GenericBaseCsvWrapper(String[] tempFields, string transtype){
		parseRecInit();
    	mapPicklistSelect = new map<string, string>();
    	mapPicklistSelect.put('Custom_Currency__c', '');
    	mapPicklistSelect.put('Status__c', '');
    	mapPicklistSelect.put('Buy_Currency__c', '');
    	mapPicklistSelect.put('Sell_Currency__c', '');
		InitWrapper(transtype);
		parseCsvLine(tempFields);
	}
	public virtual void InitWrapper(string transtype){
    	isValid=true;
    	this.transtype = transtype;
    	fieldSetName = Utility.changeTransactionType(transtype);
    	mapCSVvalues = new map<string, string>();
	}
	public virtual Integer getParsedRec(Schema.FieldSetMember f, String[] tempFields, Integer indexCount){
		return indexCount;
	}
	
	public virtual void parseRecInit(){	}

	boolean isHasPickValue(string objName, string fieldname, string value){
		if(picklistMap==null){
			picklistMap = new map<String, Set<String>>();
		}
		if(picklistMap.get(objName)==null){
			picklistMap.put(objName+fieldname, Utility.picklistValueSet(objName, fieldname));
		}
		if(picklistMap.containsKey(objName+fieldname)){
			return picklistMap.get(objName+fieldname).contains(value.toUpperCase());
		}
		return false;
	}
    public static map<String, Set<String>> picklistMap{get;set;}
	
    public virtual void parseCsvLine(String[] tempFields){
    	Integer indexCount = 0;
    	parseRecInit();
    	mapPicklistSelect.put('Custom_Currency__c', '');
    	mapPicklistSelect.put('Buy_Currency__c', '');
    	mapPicklistSelect.put('Sell_Currency__c', '');
    	
        if(tempFields!=null && tempFields.size()>0){
        	system.debug('*****tempFields>'+Schema.getGlobalDescribe().get(getsObjectName()).getDescribe().fieldSets.getMap().get(fieldSetName));
        	if(Schema.getGlobalDescribe().get(getsObjectName()).getDescribe().fieldSets.getMap().get(fieldSetName)!=null){
	        	for(Schema.FieldSetMember f : Schema.getGlobalDescribe().get(getsObjectName()).getDescribe().fieldSets.getMap().get(fieldSetName).getFields()){
					//Parse fields from Field Set
					this.mapCSVvalues.put(f.FieldPath, Utility.getValidText(tempFields, indexCount));
				    //Set values for sObject(Input).
				    if(f.getType()==Schema.DisplayType.DATE){
				    	this.input.put(f.FieldPath, Utility.getDate(this.mapCSVvalues.get(f.FieldPath)));				    	
				    }else
			        if(f.getType()==Schema.DisplayType.DOUBLE){
			        	this.input.put(f.FieldPath, Utility.getDecimal(this.mapCSVvalues.get(f.FieldPath)));
			        }else
			        if(f.getType()==Schema.DisplayType.BOOLEAN){
			        	this.input.put(f.FieldPath, Utility.getBoolean(this.mapCSVvalues.get(f.FieldPath)));
			        }else
			        if(f.getType()==Schema.DisplayType.PICKLIST){
			        	system.debug('******this.mapPicklistSelect:'+this.mapPicklistSelect);
			        	// this.input.put(f.FieldPath, this.mapCSVvalues.get(f.FieldPath));
			        	//Set default to blank
			        	this.mapPicklistSelect.put(f.FieldPath, '');
		        		if(!String.isEmpty(this.mapCSVvalues.get(f.FieldPath))){
		        			//validate picklist value from CSV, exist in possible value.
		        			if(isHasPickValue(getsObjectName() ,f.FieldPath, this.mapCSVvalues.get(f.FieldPath))){
		        				this.mapPicklistSelect.put(f.FieldPath, this.mapCSVvalues.get(f.FieldPath));
		        				this.input.put(f.FieldPath, this.mapCSVvalues.get(f.FieldPath));
							}
		        		}	                		
			        }else
			        if(f.getType()==Schema.DisplayType.REFERENCE){
			        	//Reference need, cutom code -> Beneficary lookup.
			        }else{
			        	//Default field type values handle.	                	
			        	this.input.put(f.FieldPath, this.mapCSVvalues.get(f.FieldPath));
			        }	                
			        system.debug('#######################         '+this.mapCSVvalues.get(f.FieldPath));
					indexCount = getParsedRec(f, tempFields, indexCount);	
					indexCount++;				
	        	}
        	}
        }
        system.debug('-------------this.input----------------'+this.input);
    }	
    
	public virtual boolean isValidData(Schema.FieldSetMember f,  boolean logPageMessage){
		return isValid;
	}
	

	//Also validate lookup values
	public virtual boolean isValidData(boolean logPageMessage, boolean isFullValidate){
		this.isValid = true;
       	String fieldSetName = Utility.changeTransactionType(this.transtype);
		
       	if(Schema.getGlobalDescribe().get(getsObjectName()).getDescribe().fieldSets.getMap().get(fieldSetName)!=null){
        	for(Schema.FieldSetMember f : Schema.getGlobalDescribe().get(getsObjectName()).getDescribe().fieldSets.getMap().get(fieldSetName).getFields()){
        		if(f.dbrequired || f.required){
        			//custom Validate Custom_Currency__c.
			        if(f.getType()==Schema.DisplayType.PICKLIST){
			        	system.debug('**********mapPicklistSelect:>>'+this.mapPicklistSelect.get(f.FieldPath));
				        if (!Utility.isValidText(this.mapPicklistSelect.get(f.FieldPath)) || !this.mapPicklistSelect.containsKey(f.FieldPath) ) {//invoice.Custom_Currency__c
				             this.isValid = false;
							 if(logPageMessage) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,fieldLabels.get(f.FieldPath)+Utility.getValidationTextByFieldType(f)+errorMsgPart(this.mapCSVvalues.get(f.FieldPath))));
							 if(this.mapPicklistSelect.containsKey(f.FieldPath)){
							 	this.input.put(f.FieldPath, this.mapPicklistSelect.get(f.FieldPath));
							 }
				        }else{
				        	this.input.put(f.FieldPath, this.mapPicklistSelect.get(f.FieldPath));
				        }
					}else{   
						//Generic Validation.     			
	        			if(this.input.get(f.fieldPath)==null || String.IsEmpty((this.input.get(f.fieldPath)+''))){
				        	if(f.getType()==Schema.DisplayType.REFERENCE ){
					        	if(isFullValidate==true){
									if(logPageMessage) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,fieldLabels.get(f.FieldPath)+Utility.getValidationTextByFieldType(f)+errorMsgPart(this.mapCSVvalues.get(f.FieldPath))));
									this.isValid = false;
					        	}
					        }else{
								if(logPageMessage) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,fieldLabels.get(f.FieldPath)+Utility.getValidationTextByFieldType(f)+errorMsgPart(this.mapCSVvalues.get(f.FieldPath))));
								this.isValid = false;
				        	}
	        			}
        			}
        			//child validation
        			if(this.isValid==true){
	        			this.isValid = isValidData(f, logPageMessage);
        			}
    			}
    			else
    			if(f.getType()==Schema.DisplayType.PICKLIST){
			        system.debug('**********mapPicklistSelect:>>'+this.mapPicklistSelect.get(f.FieldPath));
			        //!Utility.isValidText(this.mapPicklistSelect.get(f.FieldPath)) ||
			        //its not required, so picklist can be blank.
			        if ( !this.mapPicklistSelect.containsKey(f.FieldPath) ) {//invoice.Custom_Currency__c
			             this.isValid = false;
						 if(logPageMessage) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,fieldLabels.get(f.FieldPath)+Utility.getValidationTextByFieldType(f)+errorMsgPart(this.mapCSVvalues.get(f.FieldPath))));
						 if(this.mapPicklistSelect.containsKey(f.FieldPath)){
						 	this.input.put(f.FieldPath, this.mapPicklistSelect.get(f.FieldPath));
						 }
			        }else{
			        	this.input.put(f.FieldPath, this.mapPicklistSelect.get(f.FieldPath));
			        }
				}
   			}
		}
    	return this.isValid;
		
	}    
	public virtual boolean isValidData(boolean logPageMessage){
		// validate without lookups
		return isValidData(logPageMessage, false);
	}
}