/**=====================================================================
 * Name: AddAnotherInvoiceCtrl
 * Description: Related to AddAnotherInvoice Page
 * Created Date: Feb 05, 2015
 * Created By: Nishant Bansal (JDC)
 * 
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/
public without sharing class AddAnotherInputCtrl {
	public string sourcePage{get;set;}
	public AddAnotherInputCtrl(){
		if(system.currentPageReference().getParameters().get('sourcePage') != null) {
    		sourcePage = System.currentPageReference().getParameters().get('sourcePage');
    	}
    	if(String.isEmpty(sourcePage)){
    		sourcePage = 'InsightsAndInputTab';//Default is input
    	}
	}
// To add another Invoice	
	public pagereference addAnotherInput() {
		pagereference pageref = new pagereference('/apex/'+sourcePage);
		return pageRef;
	}
	
// To finish		
	public pagereference finished() {
		pagereference pageref = new pagereference('/apex/'+sourcePage);
		return pageRef;
	}
	

}