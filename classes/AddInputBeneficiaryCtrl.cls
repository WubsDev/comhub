/**=====================================================================
 * Name: AddInputBeneficiaryCtrl
 * Description: Related to AddInputBeneficiary in InvoicedandPaymentsTab Page
 * Created Date: Feb 06, 2015
 * Created By: Nishant Bansal (JDC)
 * 
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/
public without sharing class AddInputBeneficiaryCtrl {
	
	public Input_Beneficiary__c inputBene{get;set;}
	public String benefComId{get;set;}
	public AddInputBeneficiaryCtrl(){		
		inputBene = new Input_Beneficiary__c();
	}

// To save the input beneficiary record	
	public PageReference save(){
		try{
			User userLoggedIn = Utility.loggedInUser;
        	Id accId = Utility.currentAccount; 			
			
			Integer count = [SELECT Count() FROM Input_Beneficiary__c WHERE Name =: inputBene.Name AND Account__c =: accId];
			if (count > 0) {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There is already exist beneficiary with the same name'));
				return null;
			}
			
			inputBene.Account__c = accId;
			insert inputBene;
			benefComId = ApexPages.CurrentPage().getParameters().get('benefId') == null ? '' : ApexPages.CurrentPage().getParameters().get('benefId');
			//ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Input Saved :'));
            //pagereference pageref = new pagereference('/apex/InvoicesAndPayments); 
            //return pageRef;			
		} catch (exception ex) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Unable to save Input Beneficiary. Error Detail :'+ex.getMessage()));
            //return null;
		}
		return null;
	}
	
// to cancel the creation of save record
	public PageReference cancel(){
		pagereference pageref = new pagereference('/apex/InvoicesAndPayments');  
        return pageRef;	
	}

}