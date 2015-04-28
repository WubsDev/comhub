global without sharing class NetCashFlowByCurrencyCtrl {
	
	private static String TRADING_RECEIPTS = 'Forecast Inflow';
    private static String INFLOW_OTHER ='Inflow - Other';
    private static String PURCHASE_ORDER = 'Purchase Order';
    private static String FORECAST_ORDER = 'Forecast Outflow';
    private static String OUTFLOW_OTHER = 'Outflow - Other';
	
	@RemoteAction  
    global static List<NetCashFlowCtrl.InvoicByCurrencyWrap> loadAllTimeData() {
        Id accId = Utility.currentAccount;
        User userLoggedIn = Utility.loggedInUser;
        Map<String, NetCashFlowCtrl.InvoicByCurrencyWrap> invoiceMap = new map<String, NetCashFlowCtrl.InvoicByCurrencyWrap>();
        try{
        	for(AggregateResult agResult : [SELECT SUM(Amount__c) s, CurrencyIsoCode c FROM Input__c WHERE Parent_Account__c =: accId and (Type__c in (:TRADING_RECEIPTS, :INFLOW_OTHER) or Input_Type__c in (:TRADING_RECEIPTS, :INFLOW_OTHER)) GROUP BY CurrencyIsoCode]) {
	        	NetCashFlowCtrl.addRecordToInvoiceCurrencyMap(agResult, invoiceMap, true);
	        }
        	for(AggregateResult agResult : [SELECT SUM(Amount__c) s, CurrencyIsoCode c FROM Input__c WHERE Parent_Account__c =: accId and (Type__c in (:PURCHASE_ORDER, :FORECAST_ORDER, :OUTFLOW_OTHER) or Input_Type__c in (:PURCHASE_ORDER, :FORECAST_ORDER, :OUTFLOW_OTHER)) GROUP BY CurrencyIsoCode]) {
	        	NetCashFlowCtrl.addRecordToInvoiceCurrencyMap(agResult, invoiceMap, false);
  			    
	        }
        	for(AggregateResult agResult : [SELECT SUM(Amount__c) s, CurrencyIsoCode c From Invoice__c WHERE Account__c =: accId GROUP BY CurrencyIsoCode]) {
				NetCashFlowCtrl.addRecordToInvoiceCurrencyMap(agResult, invoiceMap, false);
	        }	
        }catch(Exception Ex){
           system.debug('******Ex::'+Ex.getMessage());
        }
        return invoiceMap.values();
    }

}