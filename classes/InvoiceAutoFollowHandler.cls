/**=====================================================================
 * Name: InvoiceAutoFollowHandler
 * Description: Related to invoive autofollow and validation rule for duplicate invoice and input beneficiary
 * Created Date: Feb 02, 2015
 * Created By: Nishant Bansal (JDC)
 * 
 * Date Modified                Modified By                  Description of the update
 *2/6/2015                      Pankaj Mehra             Validation rule for duplicate invoice and input beneficiary
 =====================================================================*/
public class InvoiceAutoFollowHandler{
	
// AutoFollow the invoice records after insert    
    public void triggerHandler_AfterInsert(list<Invoice__c> listInvoice){
        set<Id> invoiceIdToFollow=new set<Id>();
        try{
            // looping thru all Invoices
            for(Invoice__c inv :listInvoice){
                    invoiceIdToFollow.add(inv.Id);
                }
            
            if(invoiceIdToFollow != null && invoiceIdToFollow.size()>0){
            	ID contactId = [Select contactid from User where id =: Userinfo.getUserid()].contactId;
				ID AccOwnerID  = null;
				if(contactId!=null){
					AccOwnerID = [Select AccountID, Account.OwnerId from Contact where id =: contactId and AccountID!=null].Account.OwnerId;
	            	System.debug('----------> Userinfo.getUserid() '+ Userinfo.getUserid());
					//System.debug('----------> contactId '+contactId);
					//System.debug('----------> AccID '+AccOwnerID);
	                //AutoFollowTheRecords.followRecords(invoiceIdToFollow,UserInfo.getUserId());
	                AutoFollowTheRecords.followRecords(invoiceIdToFollow,AccOwnerID);
				}
            }
        }
        catch(exception ex){
            system.debug('Exception occur->'+ex);
        }
    }
    
// Validation to find duplicate before update
    public void triggerHandler_BeforeUpdate(list<Invoice__c> listInvoice){
    	validateUniqueInvoiceAndBenificiary(listInvoice, false);
    }
    
// Validation to find duplicate before insert    
    public void triggerHandler_BeforeInsert(list<Invoice__c> listInvoice){
    	validateUniqueInvoiceAndBenificiary(listInvoice, true);
    }
    
    
// Validation to find the Duplicate Invoice Name and Input Beneficiary      
    public void validateUniqueInvoiceAndBenificiary(list<Invoice__c> listInvoice, boolean isInsert) {
    	
    	//Track Benificiary for a invoice
    	Map<String,Set<String>> invoiceBenificiary = new Map<String,Set<String>>(); 
    	//Track invoices with same Name
    	Map<String,List<Invoice__c>> mapInvoice = new Map<String,List<Invoice__c>>(); 
    	Set<String> setAllBenificiary = new Set<String>(); 
    	Set<String> setAllReference = new Set<String>(); 
    	Set<id>invoiceIds = new Set<id>();
    	for(Invoice__c invoice : listInvoice) {
			if(invoice.Account__c!=null){
    			String key = invoice.Name +'-'+invoice.Account__c;
	    		if(!mapInvoice.containsKey(key)) {
	    			if(invoice.Account__c!=null){
	    				mapInvoice.put(key, new List<Invoice__c>());
	    			}
	    		}
	    		mapInvoice.get(key).add(invoice);
	    		if(!invoiceBenificiary.containsKey(key)) {
	    			invoiceBenificiary.put(key, new Set<String>());
	    			setAllReference.add(invoice.Name);
	    		}
	    		if(invoice.Input_Beneficiary__c != null) {
	    			setAllBenificiary.add(invoice.Input_Beneficiary__c);
	    			if(invoiceBenificiary.get(key).contains(invoice.Input_Beneficiary__c)) {
	    		   		//Already dups in incomming list - Ranjeet Review
	    		   		addInvoiceDupsError(mapInvoice.get(key));
	    		   	}else{    			
	    				invoiceBenificiary.get(key).add(invoice.Input_Beneficiary__c);
	    			}
	    		}
	    		if(!isInsert){
	    			invoiceIds.add(invoice.id);
	    		}
			}
    	}    	
    	for(Invoice__c invoice : [SELECT Name , account__c, Input_Beneficiary__c FROM Invoice__c
    		WHERE Name in:setAllReference and Input_Beneficiary__c in: setAllBenificiary and id not in:invoiceIds and account__c!=null]) {
    		String key = invoice.Name +'-'+invoice.Account__c;
    		if(invoiceBenificiary.containsKey(key) && 
    		   invoiceBenificiary.get(key).contains(invoice.Input_Beneficiary__c)) {
    		   	addInvoiceDupsError(mapInvoice.get(key));
    		   }
    		}
    }
    public void addInvoiceDupsError(List<Invoice__c> invoices){
    	for(Invoice__c invoice: invoices){
    		invoice.addError('Duplicate Invoice Number And Beneficiary Found. Invoice Number : '+invoice.Name);
    		//mapInvoice.get(invoice.Name)
    	}
    }
      
}