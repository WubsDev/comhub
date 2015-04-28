/**=====================================================================
 * Name: ForwardContractTriggerHandler
 * Description: Related to ForwardContractTrigger
 * Created Date: Feb 09, 2015
 * Created By: Nishant Bansal (JDC)
 * 
 * Date Modified                Modified By                  Description of the update
 	March/17/2015				Ranjeet Singh					I-150167	: Currency Feed not being uploaded to SFDC
 =====================================================================*/
 
public with sharing class ForwardContractTriggerHandler {
	
	// Before Insert of Forward Contracts Record
	public static void beforeInsert(list<Forward_Contracts__c> forwardContractList){ 
		updateMarketRate(forwardContractList,null);
	}
	
	// Before Update of Forward Contracts Record
	public static void beforeUpdate(list<Forward_Contracts__c> forwardContractList, Map<Id,Forward_Contracts__c> oldMap){
		updateMarketRate(forwardContractList,oldMap);
	}
	
	// Update the Market Rate in Forward Contracts 
	public static void updateMarketRate(list<Forward_Contracts__c> forwardContractList, Map<Id,Forward_Contracts__c> oldMap){
		//I-150167	: Currency Feed not being uploaded to SFDC
		// set of currency ISO codes associated with forward contacts passed in
		Set<String> currencyIsoCodes = new Set<String>();
		for(Forward_Contracts__c newfc : forwardContractList ) {
			if(oldMap == null || newfc.Custom_Currency__c != oldMap.get(newfc.id).Custom_Currency__c /*|| newfc.FX_Amount__c != oldMap.get(newfc.id).FX_Amount__c
				|| newfc.Account_ID__c != oldMap.get(newfc.id).Account_ID__c || newfc.Converted_Amount__c != oldMap.get(newfc.id).Converted_Amount__c
				|| newfc.FX_Balance__c != oldMap.get(newfc.id).FX_Balance__c || newfc.FX_Currency__c != oldMap.get(newfc.id).FX_Currency__c
				|| newfc.Maturity_Date__c != oldMap.get(newfc.id).Maturity_Date__c || newfc.Maturity_Date__c != oldMap.get(newfc.id).Maturity_Date__c
				|| newfc.Settlement_Amount__c != oldMap.get(newfc.id).Settlement_Amount__c || newfc.Settlement_Amount__c != oldMap.get(newfc.id).Settlement_Amount__c
				|| newfc.Settlement_Balance__c != oldMap.get(newfc.id).Settlement_Balance__c || newfc.Start_Date__c != oldMap.get(newfc.id).Start_Date__c
				|| newfc.Transaction_Number__c != oldMap.get(newfc.id).Transaction_Number__c*/) {
				currencyIsoCodes.add(newfc.Custom_Currency__c);
			}
		}	
		
		// Market rate associated with above added currency ISO codes
		Map<String, Market_Rate__c>	marketRateMap = new Map<String, Market_Rate__c>();
    	for(Market_Rate__c marketRate : [Select Id, Currency_Code__c FROM Market_Rate__c WHERE Currency_Code__c IN : currencyIsoCodes]) {
			marketRateMap.put(marketRate.Currency_Code__c, marketRate);
    	}

		for(Forward_Contracts__c newfc : forwardContractList ) {
			if(marketRateMap.containsKey(newfc.Custom_Currency__c)) {
				newfc.Market_Rate__c = marketRateMap.get(newfc.Custom_Currency__c).Id;
			}
		}    	
    	
	}
	
}