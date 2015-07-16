// 
// (c) 2014 Appirio, Inc.
//
// InputInvoiceSharingManager
// User as trigger handler class for User Trigger
//
// 18 June, 2015    Ashish Goyal  Original (Ref. T-410586)
//
public class InputInvoiceSharingManager {
	
	// @desc : update the owner of input/invoice record with the related account owner
	// @param : Set of user id 
	// @return : void

	public static void updateSharingPermission(Set<Id> userIdSet){
		List<Input__c> inputList = new List<Input__c>();
		List<Invoice__c> invoiceList = new List<Invoice__c>();
		
		for(Input__c input : [SELECT Id, OwnerId, Parent_Account__c, Parent_Account__r.OwnerId, 
									Original_Owner__c FROM Input__c WHERE OwnerId IN :userIdSet LIMIT 999]){
			if(String.IsEmpty(input.Original_Owner__c)){
				input.Original_Owner__c = input.OwnerId;
			}
			if(input.Parent_Account__c != null){
				input.OwnerId = input.Parent_Account__r.OwnerId;
				inputList.add(input);
			}
		}
		
		for(Invoice__c invoice : [SELECT Id, OwnerId, Account__c, Account__r.OwnerId, 
									Original_Owner__c FROM Invoice__c WHERE OwnerId IN :userIdSet LIMIT 999]){
			if(String.IsEmpty(invoice.Original_Owner__c)){
				invoice.Original_Owner__c = invoice.OwnerId;
			}
			if(invoice.Account__c != null){
				invoice.OwnerId = invoice.Account__r.OwnerId;
				invoiceList.add(invoice);
			}
		}

		if(inputList.size() > 0){
			update inputList;
		}
		
		if(invoiceList.size() > 0){
			update invoiceList;
		}
	}
	
	// @desc : update the owner of input/invoice record with the original owner
	// @param : Set of user id 
	// @return : void
	
	public static void resetSharingPermission(Set<Id> userIdSet){
		List<Input__c> inputList = new List<Input__c>();
		List<Invoice__c> invoiceList = new List<Invoice__c>();
		
		for(Input__c input : [SELECT Id, OwnerId,  
									Original_Owner__c FROM Input__c WHERE Original_Owner__c IN :userIdSet LIMIT 999]){
			if(!String.IsEmpty(input.Original_Owner__c)){
				input.OwnerId = input.Original_Owner__c;
				inputList.add(input);
			}
		}
		
		for(Invoice__c invoice : [SELECT Id, OwnerId,
									Original_Owner__c FROM Invoice__c WHERE Original_Owner__c IN :userIdSet LIMIT 999]){			
			if(!String.IsEmpty(invoice.Original_Owner__c)){
				invoice.OwnerId = invoice.Original_Owner__c;
				invoiceList.add(invoice);
			}
		}
		
		if(inputList.size() > 0){
			update inputList;
		}
		
		if(invoiceList.size() > 0){
			update invoiceList;
		}
	}

}