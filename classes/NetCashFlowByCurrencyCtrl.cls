global without sharing class NetCashFlowByCurrencyCtrl {
	
	private static String TRADING_RECEIPTS = 'Forecast Inflow';
    private static String PURCHASE_ORDER = 'Purchase Order';
    private static String FORECAST_ORDER = 'Forecast Outflow';
	
	@RemoteAction  
    global static List<NetCashFlowCtrl.InvoicByCurrencyWrap> loadAllTimeData() {
        Id accId = Utility.currentAccount;
        User userLoggedIn = Utility.loggedInUser;
        Map<String, NetCashFlowCtrl.InvoicByCurrencyWrap> invoiceMap = new map<String, NetCashFlowCtrl.InvoicByCurrencyWrap>();
        try{
        	for(AggregateResult agResult : [SELECT SUM(Amount__c) s, Custom_Currency__c c FROM Input__c WHERE Input_Type__c != 'Invoice' AND Parent_Account__c =: accId and (Type__c in (:TRADING_RECEIPTS) or Input_Type__c in (:TRADING_RECEIPTS)) GROUP BY Custom_Currency__c]) {
	        	NetCashFlowCtrl.addRecordToInvoiceCurrencyMap(agResult, invoiceMap, true);
	        }
        	for(AggregateResult agResult : [SELECT SUM(Amount__c) s, Custom_Currency__c c FROM Input__c WHERE Parent_Account__c =: accId AND Input_Type__c != 'Invoice' and (Type__c in (:PURCHASE_ORDER, :FORECAST_ORDER) or Input_Type__c in (:PURCHASE_ORDER, :FORECAST_ORDER)) GROUP BY Custom_Currency__c]) {
	        	NetCashFlowCtrl.addRecordToInvoiceCurrencyMap(agResult, invoiceMap, false);
  			    
	        }
        	for(AggregateResult agResult : [SELECT SUM(Amount__c) s, Custom_Currency__c c From Invoice__c WHERE Account__c =: accId GROUP BY Custom_Currency__c]) {
				NetCashFlowCtrl.addRecordToInvoiceCurrencyMap(agResult, invoiceMap, false);
	        }	
        }catch(Exception Ex){
           system.debug('******Ex::'+Ex.getMessage());
        }
        return invoiceMap.values();
    }

}