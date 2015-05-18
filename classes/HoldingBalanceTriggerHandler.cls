/**=====================================================================
 * Name: HoldingBalanceTriggerHandler
 * Description: Related to HoldingBalanceTrigger
 * Created Date: Feb 09, 2015
 * Created By: Nishant Bansal (JDC)
 * 
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/
 
public with sharing class HoldingBalanceTriggerHandler {
	
	// Before Insert of Holding Balance Record
	public static void beforeInsert(list<Holding_Balance__c> holdingBalanceList){ 
		updateMarketRate(holdingBalanceList,null);
	}
	
	// Before Update of Holding Balance Record
	public static void beforeUpdate(list<Holding_Balance__c> holdingBalanceList, Map<Id,Holding_Balance__c> oldMap){
		updateMarketRate(holdingBalanceList,oldMap);
	}
	
	// Update the Market Rate in Forward Contracts 
	public static void updateMarketRate(list<Holding_Balance__c> holdingBalanceList, Map<Id,Holding_Balance__c> oldMap){
				
		// set of currency associated with forward contacts passed in
		Set<String> currencySet = new Set<String>();
		for(Holding_Balance__c newHB : holdingBalanceList ) {
			if(oldMap == null || (newHB.Market_Rate__c==null || newHB.Custom_Currency__c != oldMap.get(newHB.id).Custom_Currency__c)) {
				currencySet.add(newHB.Custom_Currency__c);
			}
		}	
		// Market rate associated with above added currency 
		Map<String, Market_Rate__c>	marketRateMap = new Map<String, Market_Rate__c>();
    	for(Market_Rate__c marketRate : [Select Id, Currency_Code__c FROM Market_Rate__c 
    																 WHERE Currency_Code__c 
    																 IN : currencySet]) {
			marketRateMap.put(marketRate.Currency_Code__c, marketRate);
    	}

		for(Holding_Balance__c newHB : holdingBalanceList ) {
			if(marketRateMap.containsKey(newHB.Custom_Currency__c)) {
				newHB.Market_Rate__c = marketRateMap.get(newHB.Custom_Currency__c).Id;
			}
		}
	}
	
}