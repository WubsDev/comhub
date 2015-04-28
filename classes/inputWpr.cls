/**=====================================================================
 * Name: ManageCashInputsCtl
 * 	Copy code from FX Management tool to view all Inputs
 * Created Date: March 28, 2015
 * Created By: Ranjeet Singh (JDC)
 *  
 * Date Modified                Modified By                  Description of the update
 
 =====================================================================*/ 
 public class inputWpr implements Comparable {
	public boolean isSelected {get;set;}
	public boolean isOwner {get;set;}
	public Input__c input{get;set;}
	public Invoice__c invoice{get;set;}
	public String sortField {get;set;}
	public String dir {get;set;}
	public Decimal settlementCurrency{
		get{
			if(invoice!=null){
				return Utility.getSettlementCurrencyAmount(invoice.Amount__c, invoice.CurrencyIsoCode, Utility.userCurrency);
			}
			if(input!=null){
				return Utility.getSettlementCurrencyAmount(input.Amount__c, input.CurrencyIsoCode, Utility.userCurrency);
			}
			return 0;
		}
		set;
	}	
	
	public inputWpr(String sortField, String dir, input__c input){
		this.input = input;
		this.sortField = sortField;
		this.dir = dir;
		if(this.input.OwnerId == UserInfo.getUserId()){
			isOwner = true;
		}
		else{
			isOwner = false;
		}

	}
	public inputWpr(String sortField, String dir, Invoice__c invoice){
		this.invoice = invoice;
		this.sortField = sortField;
		this.dir = dir;
		if(this.invoice.OwnerId == UserInfo.getUserId()){
			isOwner = true;
		}
		else{
			isOwner = false;
		}
	}

    public Decimal amount{
        get{                
            if(invoice==null || invoice.Amount__c==null){
                return 0;
            }
            return invoice.Amount__c;
        }
    }

	//Methods for sorting
    static map<string, string> fieldMappingForInvoice = new map<string, string>{
	    	'Transaction_Date__c'=>'Due_Date__c',
	    	'CurrencyIsoCode'=> 'CurrencyIsoCode',
	    	'Amount__c' => 'Amount__c', 
	    	'Input_Beneficiary__r.Name'=> 'Input_Beneficiary__r.Name',
	    	'Reference_Number__c' => 'Name'}; 
	
    // Compare inputWpr.
    public Integer compareTo(Object compareTo) {
    	Integer ascDir = 1;
    	Integer descDir = -1;
    	if(this.dir!='asc'){
    		descDir = 1;
    		ascDir = -1;
    	}
        Integer returnValue = 0;
        // Cast argument to inputWpr
        inputWpr aHW = (inputWpr)compareTo;
        // The return value of 0 indicates that both elements are equal.
        String invoiceField = fieldMappingForInvoice.get(sortField);
        if(sortField=='Transaction_Date__c' || sortField=='Due_Date__c'){
        	Date Transaction_Date = null;
        	Date Transaction_DateArg = null;
        	if(input!=null){
        		Transaction_Date = input.Transaction_Date__c;
        	}else{
        		Transaction_Date = invoice.Due_Date__c; 
        	}
        	if(aHW.input!=null){
        		Transaction_DateArg = aHW.input.Transaction_Date__c;
        	}else{
        		Transaction_DateArg = aHW.invoice.Due_Date__c; 
        	}
        	//compare date
	        if (Transaction_Date > Transaction_DateArg) {
	            // Set return value to a positive value.
	            returnValue = ascDir;
	        } else if (Transaction_Date < Transaction_DateArg) {
	            // Set return value to a negative value.
	            returnValue = descDir;
	        }
        }
        if(sortField=='Amount__c' ){
        	Decimal Transaction_Date = null;
        	Decimal Transaction_DateArg = null;
        	if(input!=null){
        		Transaction_Date = input.Amount__c;
        	}else{
        		Transaction_Date = invoice.Amount__c; 
        	}
        	if(aHW.input!=null){
        		Transaction_DateArg = aHW.input.Amount__c;
        	}else{
        		Transaction_DateArg = aHW.invoice.Amount__c; 
        	}
        	//compare date
	        if (Transaction_Date > Transaction_DateArg) {
	            // Set return value to a positive value.
	            returnValue = ascDir;
	        } else if (Transaction_Date < Transaction_DateArg) {
	            // Set return value to a negative value.
	            returnValue = descDir;
	        }	        	
        }
        if(sortField=='Input_Beneficiary__r.Name'){
        	String Transaction_Date = null;
        	String Transaction_DateArg = null;
        	if(input!=null){
        		Transaction_Date = input.Input_Beneficiary__r.Name;
        	}else{
        		Transaction_Date = invoice.Input_Beneficiary__r.Name; 
        	}
        	if(aHW.input!=null){
        		Transaction_DateArg = aHW.input.Input_Beneficiary__r.Name;
        	}else{
        		Transaction_DateArg = aHW.invoice.Input_Beneficiary__r.Name; 
        	}
        	//compare date
	        if (Transaction_Date > Transaction_DateArg) {
	            // Set return value to a positive value.
	            returnValue = ascDir;
	        } else if (Transaction_Date < Transaction_DateArg) {
	            // Set return value to a negative value.
	            returnValue = descDir;
	        }	        	
        }
        if(sortField=='Reference_Number__c'|| sortField=='Name'){
        	String Transaction_Date = null;
        	String Transaction_DateArg = null;
        	if(input!=null){
        		Transaction_Date = input.Reference_Number__c;
        	}else{
        		Transaction_Date = invoice.Name; 
        	}
        	if(aHW.input!=null){
        		Transaction_DateArg = aHW.input.Reference_Number__c;
        	}else{
        		Transaction_DateArg = aHW.invoice.Name; 
        	}
        	//compare date
	        if (Transaction_Date > Transaction_DateArg) {
	            // Set return value to a positive value.
	            returnValue = ascDir;
	        } else if (Transaction_Date < Transaction_DateArg) {
	            // Set return value to a negative value.
	            returnValue = descDir;
	        }	        	
        }
        if(sortField=='Type__c'){
        	String Transaction_Date = null;
        	String Transaction_DateArg = null;
        	if(input!=null){
        		Transaction_Date = input.Type__c;
        	}else{
        		Transaction_Date = 'Invoice'; 
        	}
        	if(aHW.input!=null){
        		Transaction_DateArg = aHW.input.Type__c;
        	}else{
        		Transaction_DateArg = 'Invoice'; 
        	}
        	//compare date
	        if (Transaction_Date > Transaction_DateArg) {
	            // Set return value to a positive value.
	            returnValue = ascDir;
	        } else if (Transaction_Date < Transaction_DateArg) {
	            // Set return value to a negative value.
	            returnValue = descDir;
	        }	        	
        }
        if(sortField=='Status__c'){
        	String Transaction_Date = null;
        	String Transaction_DateArg = null;
        	if(input!=null){
        		//Transaction_Date = input.Type__c;
        	}else{
        		Transaction_Date = invoice.Status__c; 
        	}
        	if(aHW.input!=null){
        		//Transaction_DateArg = aHW.input.Type__c;
        	}else{
        		Transaction_DateArg = aHW.invoice.Status__c; 
        	}
        	//compare date
	        if (Transaction_Date > Transaction_DateArg) {
	            // Set return value to a positive value.
	            returnValue = ascDir;
	        } else if (Transaction_Date < Transaction_DateArg) {
	            // Set return value to a negative value.
	            returnValue = descDir;
	        }	        	
        }
        if(sortField=='settlementCurrency'){
        	Double Transaction_Date = null;
        	Double Transaction_DateArg = null;
        	if(input!=null){
        		//Transaction_Date = input.Type__c;
        	}else{
        		Transaction_Date = settlementCurrency; 
        	}
        	if(aHW.input!=null){
        		//Transaction_DateArg = aHW.input.Type__c;
        	}else{
        		Transaction_DateArg = aHW.settlementCurrency; 
        	}
        	//compare date
	        if (Transaction_Date > Transaction_DateArg) {
	            // Set return value to a positive value.
	            returnValue = ascDir;
	        } else if (Transaction_Date < Transaction_DateArg) {
	            // Set return value to a negative value.
	            returnValue = descDir;
	        }	        	
        }
        
      
        return returnValue;     
    }   	
	
}