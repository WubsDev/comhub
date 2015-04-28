/**=====================================================================
 * Name: ParseAndDisplayCSVGenericCtl
 * Description: Related to ParseAndDisplayCSVGeneric Page
 * Created Date: 05 March, 2015
 * Created By: Ranjeet Singh (JDC)
 *
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/
 
public without sharing class ParseAndDisplayCSVGenericCtl extends ParseAndDisplayBaseCSVGenericCtl{
	public override String getsObjectName(){return 'input__c';} 
   	public ParseAndDisplayCSVGenericCtl(){
   		defaultSourcePage = 'InsightsAndInputTab';
   	}
   	public override list<GenericBaseCsvWrapper> parseCsv(String content){
   		parsedInput = new list<GenericCsvWrapper>();
   		return super.parseCsv(content);
   	}
   	public override void parseAttachment(Blob body, String name){
   		parsedInput = new list<GenericCsvWrapper>();
   		super.parseAttachment(body, name);
   	} 
   	public override GenericBaseCsvWrapper getGenericCsvWrapper(String[] tempFields, String transtype){
   		return new GenericCsvWrapper(tempFields, transtype);
   	}
   	public override void OnSaveUpdate(GenericBaseCsvWrapper inv) {
   		inv.input.put('Parent_Account__c', Utility.currentAccount);
        inv.input.put('User__c', Utility.loggedInUser.id);
		Utility.updateOptionInput(inv.input, inv.inputOther, transtype, inv.fieldSetName);
	}
}