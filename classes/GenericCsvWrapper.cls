/**=====================================================================
 * Name: GenericCsvWrapper
 * Description: Related to ParseAndDisplayCSVGeneric Page
 * Created Date: 29 March, 2015
 * Created By: Ranjeet Singh (JDC)
 *
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/ 
public class GenericCsvWrapper extends GenericBaseCsvWrapper {


	public override String getsObjectName(){
		return 'input__c';
	}

    public GenericCsvWrapper(String[] tempFields, string transtype){
    	super(tempFields, transtype);
    } 
    public override void parseRecInit(){ 
		this.input =new input__c();
		this.inputOther =new input__c(); 

	   	this.input.put('Type__c', transtype);
	   	this.input.put('input_Type__c', transtype);
    }
    public override Integer getParsedRec(Schema.FieldSetMember f, String[] tempFields, Integer indexCount){
		//Handle Option_Other input type.
		if(f.FieldPath.equalsIgnoreCase('Amount__c')){
          	if(fieldSetName=='Option_Other'){
          		indexCount++;
                if(indexCount>=tempFields.size()){
                	return indexCount;
                }
				this.mapCSVvalues.put('Option_'+f.FieldPath, Utility.getValidText(tempFields[indexCount]));
              	this.inputOther.put(f.FieldPath, Utility.getDecimal(this.mapCSVvalues.get('Option_'+f.FieldPath)));			              		
          	}
        }
        return indexCount;
    } 
	public override boolean isValidData(Schema.FieldSetMember f, boolean logPageMessage){
		//Valided DateRange.
		if(f.FieldPath.equalsIgnoreCase('Window_End_Date__c')){
			Date Window_End_Date = Date.valueOf(this.input.get('Window_End_Date__c'));
			Date Window_Start_Date = Date.valueOf(this.input.get('Window_Start_Date__c'));
			if(this.input.get('Window_Start_Date__c')!=null && Window_End_Date<Window_Start_Date){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CM_Validation_Input_DateShouldBeGreaterOrEqual));
				isValid = false;
			}
		}

		//validate "Obligation Amount", need custom validation.
		if(f.FieldPath.equalsIgnoreCase('Amount__c')){
		    if(fieldSetName=='Option_Other'){
		    	if (this.inputOther!=null && this.inputOther.get('Amount__c')==null) {						    	 
                    if(logPageMessage) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.CM_FieldLabel_Input_ObligationAmount + ' ' + System.Label.CM_Validation_Input_FieldShouldBeAValidNumber + ' '+errorMsgPart(this.mapCSVvalues.get('Option_'+f.FieldPath))));
		    	 	isValid = false;
		    	 }
			}
		}
    	return isValid;
	}
   
    public override String errorMsgPart(String srcText){
		if(Utility.isValidText(srcText)){
            return ' : ' + System.Label.CM_Validation_Input_FieldForInput + ' ' + Utility.getValidText(String.valueOf(this.input.get('Reference_Number__c'))) + ', ' + System.Label.CM_Validation_Input_FieldCsvValue + ' ' + srcText+'\' )';
		}
		return '';
	}
}