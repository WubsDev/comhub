public without sharing class CustomLookupCtrl {
	public String fieldName {get;set;}   
    public String objName {get;set;}
    public String selectedId {get;set;}
    public SObject currentRecord{get;set;}
    public String selectedRecordName {get;set;}
    public String fieldPopulatingId {get;set;}
    public String fieldSetNameAPI {get;set;}
                  
    public CustomLookupCtrl(){
    	fieldName = '';
    	objName = '';
    	currentRecord = null;
    }
     
    public PageReference getSelectedRecord(){
    	if(!String.isEmpty(selectedId)){
    		if(String.isEmpty(selectedRecordName)){                 
    		string currentRecordId = this.selectedId;  
    		String currentAccount =Utility.currentAccount;   	
    		if(currentRecordId <> null){
		    	List<Sobject> sobjectList = Database.query('SELECT Id, ' + this.fieldName + ' FROM ' + this.objName + ' WHERE ID = : currentRecordId AND Account__c =: currentAccount');
		    	system.debug('**********:sobjectList:'+sobjectList+'>'+currentRecordId+' []'+Utility.currentAccount);
		    	if(!sobjectList.isEmpty()){
		    		this.currentRecord = sobjectList[0];
		    		selectedRecordName = (String) this.currentRecord.get(this.fieldName);
		    	}
    		}
    		}else{
    			Schema.SObjectType targetType = Schema.getGlobalDescribe().get(this.objName);
    			this.currentRecord = targetType.newSObject();
				this.currentRecord.put('Id', selectedId);
    			this.currentRecord.put(this.fieldName, selectedRecordName);
    		}
    	}
   		system.debug('**********:selectedRecordName:'+selectedRecordName);
    	return null;
    }   
}