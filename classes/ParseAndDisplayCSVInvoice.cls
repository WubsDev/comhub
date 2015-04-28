/**=====================================================================
 * Name: ParseAndDisplayCSVInvoice
 * Description: Related to ParseAndDisplayCSVInvoicePage Page
 * Created Date: Jan 13, 2015
 * Created By: Nishant Bansal (JDC)
 *
 * Date Modified  Feb 11,2015              Modified By   Vivek Ojha               Description of the update I-148135
 * Updates I-148135, By Vivek Ojha , Currency__c --> CurrencyIsoCode
 * Feb 12,2015							   Piyush Bansal						I-148263 : makiing all fields as required
 =====================================================================*/

public without sharing class ParseAndDisplayCSVInvoice extends ParseAndDisplayBaseCSVGenericCtl {
	public override String getsObjectName(){return 'invoice__c';} 
   	public ParseAndDisplayCSVInvoice(){
   		defaultSourcePage = 'InvoicesAndPayments';
   	}
   	public override list<GenericBaseCsvWrapper> parseCsv(String content){
   		parsedInput = new list<InvoiceCsvWrapper>();
   		return super.parseCsv(content);
   	}
   	public override void parseAttachment(Blob body, String name){
   		parsedInput = new list<InvoiceCsvWrapper>();
   		super.parseAttachment(body, name);
   	} 
   	public override GenericBaseCsvWrapper getGenericCsvWrapper(String[] tempFields, String transtype){
   		return new InvoiceCsvWrapper(tempFields, transtype);
   	}
   	public override void OnSaveUpdate(GenericBaseCsvWrapper inv) {
		inv.input.put('Account__c', Utility.currentAccount);
	}   	
}