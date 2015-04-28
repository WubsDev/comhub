public without sharing class BeneficiaryLookupDetailCntrl {
	
	public Input_Beneficiary__c inputRecord {get;set;}
	
	public BeneficiaryLookupDetailCntrl(){
		if(ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != ''){
			String beneId = ApexPages.currentPage().getParameters().get('id');
	 		for(Input_Beneficiary__c tmpInv : [SELECT Id, Name, OwnerId FROM Input_Beneficiary__c WHERE ID =:beneId]){
	 		    inputRecord = tmpInv;
	        }
		}
	}

}