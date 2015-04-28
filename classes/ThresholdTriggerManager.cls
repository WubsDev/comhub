// 
// (c) 2014 Appirio, Inc.
//
// ThresholdTriggerManager
// User as trigger handler class
//
// 17 Apr, 2015    Ashish Goyal  Original (Ref. T-377904)
//
public with sharing class ThresholdTriggerManager {
	
	public static Map<String, List<Alert_Threshold__c>> inputInvIdThresholdListMap = new Map<String, List<Alert_Threshold__c>>();
	
	public static void updateMarketValue(List<Alert_Threshold__c> newThresholdList){
		Map<String, List<Id>> inputInvIdCurrencyCodeMap = new Map<String, List<Id>>();
		
		Set<Id> inputIdSet = new Set<Id>();
		Set<Id> invoiceIdSet = new Set<Id>();
		
		// Creating Map of Input or Invoice Id and Threshold Object List
		for(Alert_Threshold__c alert : newThresholdList){
			if(alert.Input__c != null){
				inputIdSet.add(alert.Input__c);
				if(!inputInvIdThresholdListMap.containsKey(alert.Input__c)){
					inputInvIdThresholdListMap.put(alert.Input__c, new List<Alert_Threshold__c>());
				}
				inputInvIdThresholdListMap.get(alert.Input__c).add(alert);
			}
			else
			if(alert.Invoice__c != null){
				invoiceIdSet.add(alert.Invoice__c);
				if(!inputInvIdThresholdListMap.containsKey(alert.Input__c)){
					inputInvIdThresholdListMap.put(alert.Invoice__c, new List<Alert_Threshold__c>());
				}
				inputInvIdThresholdListMap.get(alert.Invoice__c).add(alert);
			}
		}
		
		// Creating Map of Input or Invoice Id and Currency Code
		if(inputIdSet.size() > 0){
			for(Input__c input : [SELECT Id, CurrencyIsoCode from Input__c WHERE Id IN : inputIdSet]){
				if(!inputInvIdCurrencyCodeMap.containsKey(input.CurrencyIsoCode)){
					inputInvIdCurrencyCodeMap.put(input.CurrencyIsoCode, new List<Id>());
				}
				inputInvIdCurrencyCodeMap.get(input.CurrencyIsoCode).add(input.Id);
			}
		}
		if(invoiceIdSet.size() > 0){
			for(Invoice__c invoice : [SELECT Id, CurrencyIsoCode from Invoice__c WHERE Id IN : invoiceIdSet]){
				if(!inputInvIdCurrencyCodeMap.containsKey(invoice.CurrencyIsoCode)){
					inputInvIdCurrencyCodeMap.put(invoice.CurrencyIsoCode, new List<Id>());
				}
				inputInvIdCurrencyCodeMap.get(invoice.CurrencyIsoCode).add(invoice.Id);
			}
		}
		
		if(inputInvIdCurrencyCodeMap.size() > 0){
			setMarketCurrency(inputInvIdCurrencyCodeMap);
		}
	}
	
	
	
	private static void setMarketCurrency(Map<String, List<Id>> inputInvIdCurrencyCodeMap){
		for(Market_Rate__c rate : [SELECT Id, Currency_Code__c, Currency_Value__c FROM Market_Rate__c
										WHERE Currency_Code__c IN : inputInvIdCurrencyCodeMap.keySet()]){
			
			if(inputInvIdCurrencyCodeMap.containsKey(rate.Currency_Code__c)){
				for(Id objId : inputInvIdCurrencyCodeMap.get(rate.Currency_Code__c)){
					if(inputInvIdThresholdListMap.containsKey(objId)){
						for(Alert_Threshold__c alertThreshold : inputInvIdThresholdListMap.get(objId)){
							alertThreshold.Market_Rate_at_Save__c = rate.Currency_Value__c;
						}
					}
				}
			}
		}
	}

}