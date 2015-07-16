/**=====================================================================
 * Name: GenericCsvWrapper
 * Description: Related to ParseAndDisplayCSVGeneric Page
 * Created Date: 29 March, 2015
 * Created By: Ranjeet Singh (JDC)
 *
 * Date Modified                Modified By                  Description of the update
 	29 March, 2015				Ranjeet Singh				  Review : Code refactor.
 =====================================================================*/ 
public with sharing class InvoiceCsvWrapper extends GenericBaseCsvWrapper {
	public override String getsObjectName(){
		return 'invoice__c';
	}

    public InvoiceCsvWrapper(String[] tempFields, string transtype){
    	super(tempFields, transtype);
    } 
    public override void parseRecInit(){ 
		this.input =new invoice__c();
		this.inputOther =new invoice__c();
    }
    public override String errorMsgPart(String srcText){
		if(Utility.isValidText(srcText)){
            return ' : ' + System.Label.CM_Validation_Input_FieldForInput + Utility.getValidText(String.valueOf(this.input.get('Name'))) + ', ' + System.Label.CM_Validation_Input_FieldCsvValue + ' '+srcText+'\' )';
		}
		return '';
	}    
}