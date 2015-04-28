/**=====================================================================
 * Name: HistoricalPaymentTriggerHandler
 * Description: Related to ForwardContractTrigger to Populate Market Rate on Historical Payments
 * Created Date: Feb 10, 2015
 * Created By: Nishant Bansal (JDC)
 * 
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/
 
public with sharing class HistoricalPaymentTriggerHandler { 
	
	// Before Insert of Historical Payments Record
	public static void beforeInsert(list<Historical_Payments__c> historicalPaymentsList){ 
		updateMarketRate(historicalPaymentsList,null);
	}
	
	// Before Update of Historical Payments Record
	public static void beforeUpdate(list<Historical_Payments__c> historicalPaymentsList, Map<Id,Historical_Payments__c> oldMap){
		updateMarketRate(historicalPaymentsList,oldMap);
	}
	
	// Update the Market Rate in Forward Contracts 
	public static void updateMarketRate(list<Historical_Payments__c> historicalPaymentsList, Map<Id,Historical_Payments__c> oldMap){
		
		// set of currency ISO codes associated with forward contacts passed in
		Set<String> currencyIsoCodes = new Set<String>();
		for(Historical_Payments__c newHP : historicalPaymentsList ) {
			if(oldMap == null || newHP.CurrencyIsoCode != oldMap.get(newHP.id).CurrencyIsoCode) {
				currencyIsoCodes.add(newHP.CurrencyIsoCode);
			}
		}	
		
		// Market rate associated with above added currency ISO codes
		Map<String, Market_Rate__c>	marketRateMap = new Map<String, Market_Rate__c>();
    	for(Market_Rate__c marketRate : [Select Id, Currency_Code__c FROM Market_Rate__c
    																 WHERE Currency_Code__c 
    																 IN : currencyIsoCodes]) {
			marketRateMap.put(marketRate.Currency_Code__c, marketRate);
    	}

		for(Historical_Payments__c newHP : historicalPaymentsList ) {
			if(marketRateMap.containsKey(newHP.CurrencyIsoCode)) {
				newHP.MarketRate__c = marketRateMap.get(newHP.CurrencyIsoCode).Id;
			}
		}    	
    	
	}
	
}