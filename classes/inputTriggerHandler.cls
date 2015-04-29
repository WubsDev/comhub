/**=====================================================================
 * Name: inputTriggerHandler
 * Description: Related to invoive autofollow and validation rule for duplicate invoice and input beneficiary
 * Created Date: Feb 02, 2015
 * Created By: Nishant Bansal (JDC)
 * 
 * Date Modified                Created By                  Description of the update
 *2/12/2015                     Ranjeet Singh             Validation rule for duplicate input and input beneficiary
 =====================================================================*/
public class inputTriggerHandler{
// Validation to find duplicate before update
    public void triggerHandler_BeforeUpdate(list<Input__c> listInvoice){
        system.debug('****:insert');
        validateUniqueInvoiceAndBenificiary(listInvoice, false);
    }
    
// Validation to find duplicate before insert    
    public void triggerHandler_BeforeInsert(list<Input__c> listInvoice){
        system.debug('****:update');
        updateCurrencyAndSettlementDate(listInvoice);
        validateUniqueInvoiceAndBenificiary(listInvoice, true);
    }
    
    map<string, map<string, string>>mapLabelNames = new map<string, map<string, string>>();
// Validation to find the Duplicate Invoice Name and Input Beneficiary      
    public void validateUniqueInvoiceAndBenificiary(list<Input__c> listInvoice, boolean isInsert) {
        
        Map<String,Set<String>> invoiceBenificiary = new Map<String,Set<String>>(); 
        Map<String,List<Input__c>> mapInvoice = new Map<String,List<Input__c>>(); 
        Set<String> setAllBenificiary = new Set<String>();
        Set<String> setAllReferences = new Set<String>();
        Set<id>invoiceIds = new  Set<id>();

        map<id, id>ownerAccountId = new map<id, id>();
        //[Select Name,contactId, contact.AccountId FROM User WHERE id =:
        Set<id>ownerIds = new set<id>();
        for(Input__c invoice : listInvoice) {
            ownerIds.add(invoice.ownerId);
            if(!mapLabelNames.containsKey(invoice.Input_Type__c) && !String.isEmpty(invoice.Input_Type__c)){
                map<string, string> labelMap = Utility.getFieldLabel('input__c', invoice.Input_Type__c);
                mapLabelNames.put(invoice.Input_Type__c, labelMap);
            }
        }
        for(User u : [SELECT Id, Contact.AccountId FROM User WHERE  id in :ownerIds and ContactId!=null]){
            if(u.Contact.AccountId!=null){
                ownerAccountId.put(u.id, u.Contact.AccountId);
            }
        }
        for(Input__c invoice : listInvoice) {
            if(!isInsert){
                invoiceIds.add(invoice.id);
            }           
            if(!String.isEmpty(invoice.Reference_Number__c)&& ownerAccountId.containsKey(invoice.ownerId)){
                String key = invoice.Reference_Number__c+'-'+ownerAccountId.get(invoice.ownerId);
                
                if(!mapInvoice.containsKey(key)){
                    mapInvoice.put(key, new List<Input__c>());
                }
                mapInvoice.get(key).add(invoice);
                setAllReferences.add(invoice.Reference_Number__c);
                if(!invoiceBenificiary.containsKey(key)) {
                    invoiceBenificiary.put(key,new Set<String>());
                }
                //Handle duplicate for new inputs 
                if(invoice.Input_Beneficiary__c != null) {
                    setAllBenificiary.add(invoice.Input_Beneficiary__c);
                    if(invoiceBenificiary.get(key).contains(invoice.Input_Beneficiary__c)) {
                        //Already dups in incomming list - Ranjeet Review
                        addInvoiceDupsError(mapInvoice.get(key));
                    }else{  
                        invoiceBenificiary.get(key).add(invoice.Input_Beneficiary__c);
                    }
                }
            }
        }
        if(invoiceBenificiary.keySet().size()==0){
            return;
        }
        system.debug('****:'+invoiceBenificiary);
        for(Input__c invoice : [SELECT Reference_Number__c ,ownerId, Input_Beneficiary__c, Input_Type__c FROM Input__c
                                                                     WHERE Reference_Number__c in:setAllReferences and id not in :invoiceIds]) {
            if(ownerAccountId.containsKey(invoice.ownerId)){
                String key = invoice.Reference_Number__c+'-'+ownerAccountId.get(invoice.ownerId);
                if(invoiceBenificiary.containsKey(key) && 
                   invoiceBenificiary.get(key).contains(invoice.Input_Beneficiary__c)) {
                    system.debug('****contains 0:'+mapLabelNames.containsKey(invoice.Input_Type__c));
                    addInvoiceDupsError(mapInvoice.get(key));                           
                }               
            }
        }
    } 
    
    public void addInvoiceDupsError(List<Input__c> inputs){
        //system.debug('****contains 0:'+mapLabelNames.containsKey(invoice.Input_Type__c));
        String lblBeneficiary = 'Beneficiary';
        for(Input__c input: inputs){
        	if(input.Input_Type__c!='Option - Other' && input.Input_Type__c!='Option - WUBS'){
	            if(mapLabelNames.containsKey(input.Input_Type__c)){
	                system.debug('****contains 1:'+mapLabelNames.get(input.Input_Type__c));                               
	                map<string, string>maplables = mapLabelNames.get(input.Input_Type__c);
	                if(maplables!=null && maplables.containsKey('Input_Beneficiary__c')){
	                    system.debug('****contains 2:'+maplables.get('Input_Beneficiary__c') );
	                    lblBeneficiary = maplables.get('Input_Beneficiary__c');
	                }
	            }
	            input.addError('Duplicate Reference Number and '+lblBeneficiary+' Found');
        	}
            //mapInvoice.get(invoice.Name)
        }
    }
    
    
    
    // Start By :  @Ashish Goyal
    // method Name : updateCurrencyAndSettlementDate
    // Desc : To update the value of Currency for Option Other type
    //			And Settlement Date for WFCO Type
    
    
    public void updateCurrencyAndSettlementDate(List<Input__c> inputList){
    	for(Input__c input : inputList){
    		if(input.Input_Type__c == 'Option - Other' || input.Input_Type__c == 'Option - WUBS'
    				|| input.Input_Type__c == 'Window Forward Contract - Other' || input.Input_Type__c == 'Fixed Forward Contract - Other'){
    			if(input.Buy_Currency__c != null){
    				input.CurrencyIsoCode = input.Buy_Currency__c;
    			}
    		}
    		if(input.Input_Type__c == 'Window Forward Contract - Other'){
    			if(input.Window_End_Date__c != null){
    				input.Transaction_Date__c = input.Window_End_Date__c;
    			}    			
    		}
    	}
    }
    
}