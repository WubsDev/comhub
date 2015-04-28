/**=====================================================================
 * Name: AddAnotherInvoiceCtrl
 * Description: Related to AddAnotherInvoice Page
 * Created Date: Feb 04, 2015
 * Created By: Nishant Bansal (JDC)
 * 
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/
public without sharing class AddAnotherInvoiceCtrl {
	public String sourcePage{get;set;}
	public AddAnotherInvoiceCtrl(){
		if(system.currentPageReference().getParameters().get('sourcePage') != null) {
			sourcePage = System.currentPageReference().getParameters().get('sourcePage');
		}
		if(String.isEmpty(sourcePage)){
			sourcePage = 'InvoicesAndPayments';//Default is Invoice
		}	
	}
	
// To add another Invoice	
	public pagereference addAnotherInvoice() {
		pagereference pageref = new pagereference('/apex/sourcePage='+sourcePage);
		return pageRef;
	}
	
// To finish	
	public pagereference finished() {
		pagereference pageref = new pagereference('/apex/sourcePage='+sourcePage);
		return pageRef;
	}
	

}