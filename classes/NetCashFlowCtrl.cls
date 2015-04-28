/**=====================================================================
 * Name: NetCashFlowCtrl
 * Description: Related to NetCashFlow Page
 * Created Date: Jan 28, 2015
 * Created By: Nishant Bansal (JDC)
 * 
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/
global without sharing class NetCashFlowCtrl {
 //without sharing 
    public static Integer selectedMonth{get;set;} 
    public static String selectedCurrency{get;set;} 
    public List<wrapperInvoice> wrapperList{get;set;}
    public static AggregateResult[] aggResult;
    public static AggregateResult[] aggResultInvoice;
    //public static String colorSet{get;set;}
    public String PickListValues { get; set; }
    public Id accId{get;set;}
    
    private static String TRADING_RECEIPTS = 'Forecast Inflow';
    private static String INFLOW_OTHER ='Inflow - Other';
    private static String PURCHASE_ORDER = 'Purchase Order';
    private static String FORECAST_ORDER = 'Forecast Order';
    private static String OUTFLOW_OTHER = 'Outflow - Other';
    
    
    public NetCashFlowCtrl(){
        selectedMonth = 6;
        selectedCurrency = 'Total';//UserInfo.getDefaultCurrency();UserInfo.getDefaultCurrency();
        wrapperList = loadOpps(selectedCurrency, selectedMonth );
        User userLoggedIn = Utility.loggedInUser;
        accId = Utility.currentAccount;    
    }

    //Getting data from exising record only for netcashFlow.
    public List<SelectOption> getaccountNetcashCurrency(){ 
    	list<Selectoption> lstCurrency = new list<Selectoption>();
        lstCurrency.add(new Selectoption('Total','Total in ' + Utility.userCurrency));
    	lstCurrency.addAll(Utility.getaccountNetcashCurrency());
		return lstCurrency;
    }

    
    //Getting data from exising record I-149395, This select netcashFlow+Summary Report currency.
    public List<SelectOption> getaccountTradedCurrency(){ 
    	list<Selectoption> lstCurrency = new list<Selectoption>();
        lstCurrency.add(new Selectoption('Total','Total in ' + Utility.userCurrency));
    	lstCurrency.addAll(Utility.getaccountTradedCurrency());
		return lstCurrency;
    }
    

    public void search() {
        String selectedCur = selectedCurrency;
                
    }
    
    public static List<wrapperInvoice> loadOpps(String selectedCurrency1, Integer selectedMonth1, Id accId ) {
        //set<Id> owners = Utility.getCurrentUsers();
        User userLoggedIn = Utility.loggedInUser;
        List<wrapperInvoice> wrapperList = new List<wrapperInvoice>();
        map<String, wrapperInvoice>mapWpr = new map<String, wrapperInvoice>();
        try{
        	if(accId==null){
        		accId = Utility.currentAccount;
        	}
        	system.debug('************aid :'+ accId);
	        selectedCurrency = selectedCurrency1; 
	        wrapperInvoice wrapInv;
	        String inputMonth;
	        Double inputAmount;
	        set<string>mthYear = new set<string>();
	        Double maxAmt = 0;	        
	        Date startdt = Date.today().toStartOfMonth();
	        //Date lastdt = startdt.addMonths(selectedMonth1-1);
	        Date lastdt = startdt.addMonths(selectedMonth1).addDays(-1);
	        String queryStr = 'SELECT CALENDAR_MONTH({0}) m,CALENDAR_YEAR({1}) y, SUM(Amount__c) s, CurrencyIsoCode code' 
	                      + ' FROM {2} Where {3} {4} {5}';
	        if(selectedCurrency != 'Total') { // All currency
	        	queryStr = queryStr + ' AND CurrencyIsoCode = :selectedCurrency ';
	        }
	        queryStr = queryStr + ' GROUP BY {6} '
	                    + 'ORDER BY {7}';
	        aggResult = Database.query(String.format(queryStr , new List<String>{
											'Transaction_Date__c',
											'Transaction_Date__c',
											'Input__c',
											'Parent_account__c=\''+accId+'\' ',
											'AND (Type__c in (\'Forecast Inflow\', \'Inflow - Other\') or Input_Type__c in (\'Forecast Inflow\', \'Inflow - Other\'))',
											'AND (Transaction_Date__c >= :startdt AND Transaction_Date__c <= :lastdt)',
											'CALENDAR_MONTH(Transaction_Date__c),CALENDAR_YEAR(Transaction_Date__c), CurrencyIsoCode',
											'CALENDAR_YEAR(Transaction_Date__c),CALENDAR_MONTH(Transaction_Date__c)'
										})); 
	        getUpdateAmount(mapWpr, true);
	        aggResult = Database.query(String.format(queryStr , new List<String>{
											'Transaction_Date__c',
											'Transaction_Date__c',
											'Input__c',
											'Parent_account__c=\''+accId+'\' ',
											'AND (Type__c in (\'Purchase Order\',\'Forecast Order\',\'Outflow - Other\', \'Forecast Outflow\') or Input_Type__c in (\'Purchase Order\',\'Forecast Order\',\'Outflow - Other\', \'Forecast Outflow\'))',
											'AND (Transaction_Date__c >= :startdt AND Transaction_Date__c <= :lastdt)',
											'CALENDAR_MONTH(Transaction_Date__c),CALENDAR_YEAR(Transaction_Date__c), CurrencyIsoCode',
											'CALENDAR_YEAR(Transaction_Date__c),CALENDAR_MONTH(Transaction_Date__c)'
										})); 	        
	        getUpdateAmount(mapWpr, false); 
	        //,'Option - Other' --> Need to add at Report Also
	        
	        aggResult = Database.query(String.format(queryStr , new List<String>{
											'Due_Date__c',
											'Due_Date__c',
											'Invoice__c',
											'Account__c =: accId',
											'AND (Due_Date__c >= :startdt AND Due_Date__c <= :lastdt)',
											'And Status__c not in (\'Void\', \'Paid\')',
											'CALENDAR_MONTH(Due_Date__c),CALENDAR_YEAR(Due_Date__c), CurrencyIsoCode',
											'CALENDAR_YEAR(Due_Date__c),CALENDAR_MONTH(Due_Date__c)'
										})); 	        
	        getUpdateAmount(mapWpr, false); 	   
	        mthYear =  New Set<String>( mapWpr.keySet());
	        wrapperList =  mapWpr.values();
            //Fix the missing month data
            if(wrapperList.size()>0){
	             while(startdt<=lastdt){
	                Decimal amt =0;
	  /*               
	                 //commented negative values.
	                 if(maxAmt>0){
	                    amt = (maxAmt-(2*maxAmt))/2;
	                 }
	*/    			
	                wrapInv = new wrapperInvoice(amt, startdt.month(), startdt.year(), '');
	                if(!mthYear.contains(wrapInv.invoiceMonth)){
	                    mthYear.add(wrapInv.invoiceMonth);
	                    wrapperList.add(wrapInv);
	                    wrapInv.init();
	                }
	                startdt = startdt.addMonths(1);
	            }
            }
            //Build color map
            wrapperList.sort();

	        
        }catch(Exception Ex){
           system.debug('******Ex::'+Ex.getMessage());
        }
        System.debug('---------> wrapperList : '  + wrapperList);
        return wrapperList;
    }
    @RemoteAction  
    global static List<wrapperInvoice> loadOpps(String selectedCurrency1, Integer selectedMonth1 ) {
    	return loadOpps(selectedCurrency1, selectedMonth1, null );
    }
    
    @RemoteAction  
    global static List<InvoicByCurrencyWrap> loadAllTimeData() {
        Id accId = Utility.currentAccount;
        User userLoggedIn = Utility.loggedInUser;
        Map<String, InvoicByCurrencyWrap> invoiceMap = new map<String, InvoicByCurrencyWrap>();
        try{
        	for(AggregateResult agResult : [SELECT SUM(Amount__c) s, CurrencyIsoCode c FROM Input__c WHERE Parent_Account__c =: accId and (Type__c in (:TRADING_RECEIPTS, :INFLOW_OTHER) or Input_Type__c in (:TRADING_RECEIPTS, :INFLOW_OTHER)) GROUP BY CurrencyIsoCode]) {
	        	addRecordToInvoiceCurrencyMap(agResult, invoiceMap, true);
	        }
        	for(AggregateResult agResult : [SELECT SUM(Amount__c) s, CurrencyIsoCode c FROM Input__c WHERE Parent_Account__c =: accId and (Type__c in (:PURCHASE_ORDER, :FORECAST_ORDER, :OUTFLOW_OTHER) or Input_Type__c in (:PURCHASE_ORDER, :FORECAST_ORDER, :OUTFLOW_OTHER)) GROUP BY CurrencyIsoCode]) {
	        	addRecordToInvoiceCurrencyMap(agResult, invoiceMap, false);
  			    
	        }
        	for(AggregateResult agResult : [SELECT SUM(Amount__c) s, CurrencyIsoCode c From Invoice__c WHERE Account__c =: accId GROUP BY CurrencyIsoCode]) {
				addRecordToInvoiceCurrencyMap(agResult, invoiceMap, false);
	        }	
        }catch(Exception Ex){
           system.debug('******Ex::'+Ex.getMessage());
        }
        return invoiceMap.values();
    }
    
    // Add record to map based on ifFlow or outflow type
    public static void addRecordToInvoiceCurrencyMap(AggregateResult agResult, Map<String, InvoicByCurrencyWrap> invoiceMap, boolean inFlow) {
		   InvoicByCurrencyWrap wrap = new InvoicByCurrencyWrap((Decimal)agResult.get('s') , String.valueof(agResult.get('c')));
		   if(!inFlow){
		    	wrap.amount = (wrap.amount - (2*wrap.amount));
		    	wrap.init();
		   }
  			if(!invoiceMap.containsKey(wrap.currencyCode)){
		       	invoiceMap.put(wrap.currencyCode, wrap);
		    }else{
		       	InvoicByCurrencyWrap wrapInv = invoiceMap.get(wrap.currencyCode);
		       	wrapInv.amount = wrapInv.amount + wrap.amount;
		       	wrapInv.init();
		    }
		    
    }
    
    public static void getUpdateAmount(Map<String, wrapperInvoice>mapWpr, boolean inFlow){
		if(aggResult != null && aggResult.size()>0){
		    for(AggregateResult  ar : aggResult) {
		        wrapperInvoice newWrapInv = new wrapperInvoice((Decimal)ar.get('s') , Integer.valueof(ar.get('m')), Integer.valueof(ar.get('y')), String.valueof(ar.get('code')));
		        if(selectedCurrency == 'Total') {
		        	newWrapInv.amount = Utility.getSettlementCurrencyAmount(newWrapInv.amount, newWrapInv.currencyCode, Utility.userCurrency);
		        }
		        if(!inFlow){
		        	newWrapInv.amount = (- newWrapInv.amount);
		        }
		        //mthYear.add(wrapInv.invoiceMonth);
		        if(!mapWpr.containsKey( newWrapInv.invoiceMonth)){
		        	mapWpr.put(newWrapInv.invoiceMonth, newWrapInv);
		        	newWrapInv.init();
		        }else{
		        	wrapperInvoice wrapInv = mapWpr.get(newWrapInv.invoiceMonth);
		        	wrapInv.amount = wrapInv.amount + newWrapInv.amount;
		        	wrapInv.init();
		        }
		        //wrapperList.add(wrapInv);
		    }
		}    	
    }
    
    global class wrapperInvoice implements Comparable {
        
        public Decimal amount{get;set;}            
        public String invoiceMonth{get;set;}
        private Integer invMonth{get;set;}
        private Integer invYear{get;set;}
        public string colorSet{get;set;}
    	public String toolTipAmount{get;set;}
    	public String currencyCode{get;set;}
        
        public Integer compareTo(Object compareTo) {
            wrapperInvoice compareToEmp = (wrapperInvoice)compareTo;
            if (invYear > compareToEmp.invYear) return 1;
            if (invYear == compareToEmp.invYear)
            {
                if (invMonth == compareToEmp.invMonth) return 0;
                if (invMonth > compareToEmp.invMonth) return 1;
                return -1;
            }
            return -1;        
        }
        public wrapperInvoice(Decimal amountP, Integer invMonthP, Integer invYearP, String currencyCode){
            invYear =invYearP;
            invMonth= invMonthP;
            amount = amountP;
            this.currencyCode = currencyCode;
            init();
            initColor();
        }
        public void initColor(){
            if(colorSet == null) colorSet = '';
            if(amount == null){
                colorSet = colorSet + '#000';
            }
            if(amount!=null){
                if(String.isEmpty(colorSet)){
                    if(amount>=0){
                        colorSet = colorSet + '#15BB87';
                    }else{
                        colorSet = colorSet + '#C9626E';
                    }
                }
            }
        }
        public void init(){
            if(amount==null){
                amount = 0;
            }
			List<String> args = new String[]{'0','number','###,###,##0.00'};
			toolTipAmount = String.format( amount.divide(1000, 0, System.RoundingMode.HALF_UP).format(), args);  
			          
            string inputMonth ='';
            if(invMonth == 1) 
                inputMonth = 'Jan ';
            else if(invMonth == 2)
                inputMonth = 'Feb ';
            else if(invMonth == 3)
                inputMonth = 'Mar ' ;
            else if(invMonth == 4)
                inputMonth = 'Apr ';
            else if(invMonth == 5)
                inputMonth = 'May ';
            else if(invMonth == 6)
                inputMonth = 'June ';
            else if(invMonth == 7)
                inputMonth = 'July ' ;
            else if(invMonth == 8)
                inputMonth = 'Aug ' ;
            else if(invMonth == 9)
                inputMonth = 'Sept ' ;
            else if(invMonth == 10)
                inputMonth = 'Oct ' ;
            else if(invMonth == 11)
                inputMonth = 'Nov ' ;
            else if(invMonth == 12)
                inputMonth = 'Dec ' ;
            invoiceMonth = inputMonth+ invYear;
        }

    }
    
    global class InvoicByCurrencyWrap{
    	public Decimal amount{get;set;} 
    	public String toolTipAmount{get;set;}
    	public String currencyCode{get;set;}
    	
    	public InvoicByCurrencyWrap(Decimal amount, String currencyCode) {
    		this.amount = amount;
    		this.currencyCode = currencyCode;
    		init();
    	}
         public void init(){
            if(amount==null){
                amount = 0;
            }
			List<String> args = new String[]{'0','number','###,###,##0.00'};
			toolTipAmount = String.format( amount.divide(1000, 0, System.RoundingMode.HALF_UP).format(), args);  
         }   	
    }
    
}