/**=====================================================================
 * Name: AccountHoldingPieChartCtl
 * Description: Related to AccountHoldingPieChartCtl Page
 * Created Date: Jan 31, 2015
 * Created By: Nishant Bansal (JDC)
 *
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/


public without sharing class AccountHoldingPieChartCtl
{  
    public static String accId;
    public AccountHoldingPieChartCtl(){
        User userLoggedIn = Utility.loggedInUser;
        accId = Utility.currentAccount; 
        dataMap =  getChartData();
        colorOrder = new list<String>();
        forwardColorCurrencyMap= new map<String, string>();
    
    }
    list<String> colorOrder{get;set;}
    public String HoldingBalanceColor{
        get;set;
    }
    public String ForwardBalanceColor{
        get;set;
    }
    public String HistoryBalanceColor{
        get;set;
    }
    public boolean isNonCCTuser{
    	get{
    		return Utility.isNonCCTuser;
    	}
    }
    
    //static
    static List<String> colorCode =  '#FFB100,#F15D15,#359A2C,#009BBD,#17C3B5,#9E62B7,#A2D760,#8DD7E8'.split(',');
    public static map<String, string>colorCurrencyMap{get;set;}
    public static map<String, string>forwardColorCurrencyMap{get;set;}
    public static map<String, string>holdingColorCurrencyMap{get;set;}
    public static map<String, string>historyColorCurrencyMap{get;set;}

    public String getColorNextCodeForCurrency(String currencyCode, map<String, string> chartColorCurrencyMap, boolean assignNewColor){
        if(colorCurrencyMap==null){
            colorCurrencyMap =new map<String, String>();
            system.debug('*****Init colorCurrencyMap>>:'+colorCurrencyMap);
        }
        String colorForCurrency = colorCurrencyMap.get(currencyCode);
        Integer modVal = math.mod(colorCurrencyMap.size(), colorCode.size());
        //If currency not yet mapped to any currency
        system.debug('****currencyCode >>::'+currencyCode+':'+colorForCurrency);
        if(String.isEmpty(colorForCurrency) && assignNewColor){
            //Check dups in chart, is possible select
            String colorByMod = colorCode.get(modVal);
            Set<String>colorSetChart = new Set<String>(chartColorCurrencyMap.values());
            system.debug('*****colorSetChart>>:'+currencyCode+' : '+colorForCurrency+':'+colorByMod+' >'+colorSetChart);
            if(colorSetChart.contains(colorByMod)){
                system.debug('*****colorCode.size()>>:'+colorCode.size()+' >'+chartColorCurrencyMap.size());
                if(colorCode.size()>chartColorCurrencyMap.size()){
                    //There is possibility of non-dups
                    system.debug('***** Get One');
                    for(String colorCodeL: colorCode){
                        system.debug('***** Get One : '+colorCodeL);
                        if(!chartColorCurrencyMap.containsKey(colorCodeL)){
                            system.debug('***** Get One FOND: '+currencyCode+' > '+colorCodeL);
                            //found non-used color on chart
                            colorByMod = colorCodeL;
                        }
                    }
                }
            }
            colorCurrencyMap.put(currencyCode, colorByMod);
        }
        if(colorCurrencyMap.containskey(currencyCode)){
            chartColorCurrencyMap.put(currencyCode, colorCurrencyMap.get(currencyCode));
        }
        return colorCurrencyMap.get(currencyCode);
    }
    
    //Code masked, no need to conver rate, We already have values in table. 
    /*
    public static map<String, Decimal> getMarketRateCode(List<sObject> holdbalance){
        Set<String>MarketRateset = new Set<String>();
        //get Currency
        for(sObject temp:holdbalance){
            String MarketRate = (String)temp.get('MarketRate');
            if(!String.isEmpty(MarketRate)){
                MarketRateset.add(MarketRate);
            }
        }
        system.debug('****>>'+MarketRateset);
        map<String, Decimal>MarketRateMap = new map<String, Decimal>();
        if(MarketRateset.size()>0){
            for(Market_Rate__c Market_Rate : [select id, Currency_Value__c, Currency_Code__c  from Market_Rate__c where id in: MarketRateset]){
                MarketRateMap.put(Market_Rate.Currency_Code__c, Market_Rate.Currency_Value__c);
            }
        }
        system.debug('*******MarketRateMap'+MarketRateMap);
        return MarketRateMap;
    } 
    */
    //public static String HoldingColor{get;set;}
    //Outstanding Forward
    //....
    //map<String, String>currencyMap -> colorCode
    public List<PieWedgeData> getPieData() {
        system.debug('****colorOrder!!!!:');
        holdingColorCurrencyMap= new map<String, string>();
        map<string, PieWedgeData>mapPieWedgeData = new map<string, PieWedgeData>();
        List<PieWedgeData> dataList = new List<PieWedgeData>();
        //Holding data not avalianble for  NonCCTuser
        if(Utility.isNonCCTuser){
        	return dataList;
        }
        List<sObject> holdbalance= new List<sObject>();  
        //Amount__c = Converted_Amount__c * Market_rate
        String sql = 'select Custom_Currency__c, SUM(Converted_Amount__c)total, SUM(Amount__c) MarketRate FROM Holding_Balance__c where Converted_Amount__c>0 and Account__c =: accId group by Custom_Currency__c ';
        //String sql = 'SELECT CurrencyIsoCode, Converted_Amount__c FROM Holding_Balance__c where Account__c =: accId ';
        holdbalance = Database.Query(sql);
        Decimal total=0;
        for(sObject temp:holdbalance){
            total+=(Decimal)temp.get('total');
        }        

        //map<String, Decimal> MarketRateMap= getMarketRateCode(holdbalance);


        //build map for color
        Set<String>colorOrderset = new Set<String>(colorOrder);
        System.debug('****Building holdingColorCurrencyMap !!');
        Set<String>newColor4Currency = new Set<String>();
        for(sObject temp:holdbalance)
        {
            String CurrencyIsoCode = (String)temp.get('Custom_Currency__c');            
            if(!String.isEmpty(CurrencyIsoCode) && !colorOrderset.contains(CurrencyIsoCode)){
                colorOrder.add(CurrencyIsoCode);
            }
           // dataList.add(new PieWedgeData(temp.CurrencyIsoCode,(((temp.Converted_Amount__c)/total)*100)));
            mapPieWedgeData.put(CurrencyIsoCode, new PieWedgeData((String)temp.get('Custom_Currency__c'),((Decimal)temp.get('total') ),
            ((Decimal)temp.get('MarketRate')))) ;
            if(String.isEmpty(getColorNextCodeForCurrency(CurrencyIsoCode, holdingColorCurrencyMap, false))){
                newColor4Currency.add(CurrencyIsoCode);
            }
        }
        system.debug('****Building holdingColorCurrencyMap newColor4Currency!!'+newColor4Currency);
        
        for(String newColorcurrency : newColor4Currency){
            
            getColorNextCodeForCurrency(newColorcurrency, holdingColorCurrencyMap, true);
        }
        for(String colorOrderL : colorOrder){
            dataList.add(mapPieWedgeData.get(colorOrderL));
            HoldingBalanceColor  = buildColorCodes(HoldingBalanceColor, colorCurrencyMap.get(colorOrderL));
        }
        //HoldingColor ->Map color code
        system.debug('****colorOrder111:'+colorOrder);
        if(dataList.isEmpty()){
            system.debug('No data found');
        }
        system.debug('==Sam=='+dataList);
        return dataList;  
    }  
    String buildColorCodes(String orgColors, String newColor){
        if(String.isEmpty(orgColors)){
            return newColor;
        }else{
            return orgColors +','+ newColor;
        }
    }

    public List <PieWedgeData> getBarChartData(){
        List<String> lstLast5QuaterDate = new List<String>();
        Integer totalCount = 0;
        if(Math.mod(Date.today().Month(), 3) > 0){
            totalCount = 12 + Date.today().Month();
        }else{
            totalCount = 15;
        }
        for(Integer i = 0; i < totalCount; i++){
            Date todayDate = Date.today();
            Date prevDate = todayDate.addMonths((-1) * i);
            lstLast5QuaterDate.add(prevDate.Year() + '' + (prevDate.Month() <= 9 ? ('0' + prevDate.Month()) : ('' + prevDate.Month())));
        }
        
        List<PieWedgeData> dataList = new List<PieWedgeData>();
        map<string, PieWedgeData>mapPieWedgeData = new map<string, PieWedgeData>();
        Map<String, Decimal> mapQuaterToAmount = new Map<String, Decimal>();
        Map<String, String> mapQuaterToCu = new Map<String, String>();
        List<String> lstQuarters = new List<String>();
        List<String> lstYears = new List<String>();
        /*System.debug('--->' + [Select Converted_Amount__c, Year__c, Fiscal_Quarter__c,CurrencyIsoCode 
                            from Historical_Payments__c 
                            where Account_Id__c = :accId 
                            order by Year__c , Fiscal_Quarter__c]);
                            */
        for(Historical_Payments__c hp : [Select Converted_Amount__c, Year__c, Fiscal_Quarter__c,CurrencyIsoCode 
                            from Historical_Payments__c 
                            where Date__c IN :lstLast5QuaterDate
                            and Converted_Amount__c>0
                            and Account_Id__c = :accId 
                            order by Year__c , Fiscal_Quarter__c]){
            if(!mapQuaterToAmount.containsKey(hp.Fiscal_Quarter__c + ' ' + hp.Year__c)){
                mapQuaterToAmount.put(hp.Fiscal_Quarter__c + ' ' + hp.Year__c, 0.0);
                lstQuarters.add(hp.Fiscal_Quarter__c);
                lstYears.add(hp.Year__c);
            }
            mapQuaterToAmount.put(hp.Fiscal_Quarter__c + ' ' + hp.Year__c, 
                                    mapQuaterToAmount.get(hp.Fiscal_Quarter__c + ' ' + hp.Year__c) + hp.Converted_Amount__c);
        }
        for(Integer i = 0; i < lstQuarters.size(); i++){
            String key = lstQuarters.get(i) + ' ' + lstYears.get(i);
            dataList.add(new PieWedgeData(key, mapQuaterToAmount.get(key)));
        }
        return dataList;
        
    }

    // Wrapper class  
    public class PieWedgeData 
    {  
        public String name { get; set; }  
        public Decimal data { get; set; }
        public Decimal Rate{get;set;}  
        public String stack {get;set;}

        public PieWedgeData(String name, Decimal data) 
        {  
            this.name = name;  
            this.data = data;  
        }        
        public PieWedgeData(String name, Decimal data, Decimal Rate) 
        {  
            this.Rate = Rate;
            this.data = data;  
            if(this.Rate!=null){
                this.name = name;//+' - '+(Rate*data);
            }  else{
                this.name =name;
            }
        }
        public PieWedgeData(String name, Decimal data, String stack){
            this.name = name;
            this.data = data;
            this.stack = stack;
        }
    }  
    public String getQuaterNumber(Integer month){
    	if(month>0 && month<4){
    		return 'Q1';
    	}
    	if(month>3 && month<7){
    		return 'Q2';
    	}
    	if(month>6 && month<10){
    		return 'Q3';
    	}
    	if(month>9 && month<13){
    		return 'Q4';
    	}
    	return '';
    }
    /////////////////////// Javscript Array Methods /////////////////////////////
    public Map<String, Map<String,Decimal>> dataMap{get;set;}
    public String yfield{get;set;}
    public Map<String, Map<String,Decimal>> getChartData() {
        yfield = '';
      	historyColorCurrencyMap = new map<string,string>();
        dataMap = new Map<String, Map<String,Decimal>>();
        List<String> lstLast5QuaterDate = new List<String>();
        Integer totalCount = 0;
        if(Math.mod(Date.today().Month(), 3) > 0){
            totalCount = 12 + Date.today().Month();
        }else{
            totalCount = 15;
        }
        for(Integer i = 0; i < totalCount; i++){
            Date todayDate = Date.today();
            Date prevDate = todayDate.addMonths((-1) * i);
            lstLast5QuaterDate.add(prevDate.Year() + '' + (prevDate.Month() <= 9 ? ('0' + prevDate.Month()) : ('' + prevDate.Month())));
            putData(prevDate.Year() + ' ' + getQuaterNumber(prevDate.Month()), 0.0, '');
        }
        
        List<Historical_Payments__c> lstHP = [Select Converted_Amount__c, Year__c, Fiscal_Quarter__c,CurrencyIsoCode 
                                                                                    from Historical_Payments__c 
                                                                                    where Date__c IN :lstLast5QuaterDate
                                                                                    and Converted_Amount__c>0
                                                                                    and Account_Id__c = :accId
                                                                                    order by Year__c , Fiscal_Quarter__c];
                system.debug('+++++++++++++++'+lstHP);//            
        system.debug('+++++++++++++++'+accId);  
        Set<String>newColor4Currency = new Set<String>();
        //Reset dataMap if date Not exist.
		if(lstHP.size()==0){
			dataMap = new Map<String, Map<String,Decimal>>();
		}
        for(Historical_Payments__c hp : lstHP){
            if(!yfield.contains(hp.CurrencyIsoCode)) {
                yfield += hp.CurrencyIsoCode + ',';
                
                if(String.isEmpty(getColorNextCodeForCurrency(hp.CurrencyIsoCode, historyColorCurrencyMap, false))){
                    newColor4Currency.add(hp.CurrencyIsoCode);
                }
            }
        }
        system.debug('******History  Existing Currency::'+historyColorCurrencyMap+'<>'+colorCurrencyMap);
        system.debug('******History newColor4Currency::'+newColor4Currency);
        for(String newColorCurr : newColor4Currency){
            system.debug('******History newColor4Currency FINd::'+newColorCurr);
            getColorNextCodeForCurrency(newColorCurr, historyColorCurrencyMap, true);
            system.debug('******History  Existing Currency::'+historyColorCurrencyMap+'<>'+colorCurrencyMap);
        }
        if(yfield.endsWith(',')) {
                yfield = yfield.removeEnd(',') ;
        }
        if(!String.isEmpty(yfield)){
            for(String col : yfield.split(',')){
                HistoryBalanceColor  = buildColorCodes(HistoryBalanceColor, colorCurrencyMap.get(col));
                system.debug('******History  Currency HistoryBalanceColor::'+HistoryBalanceColor+ ' > ' +col);
            }
        }
        for(Historical_Payments__c hp : lstHP){
            
            for(String curr : yfield.split(',')) {
                if(curr == hp.CurrencyIsoCode) {
                    putData(hp.Year__c + ' ' + hp.Fiscal_Quarter__c, hp.Converted_Amount__c, hp.CurrencyIsoCode);       
                } else {
                    if(!dataMap.containsKey(curr)) {
                        putData(hp.Year__c + ' ' + hp.Fiscal_Quarter__c, 0.0, curr);    
                    }
                    
                }
            }
		}
        system.debug('******History  Currency HistoryBalanceColor Final::'+HistoryBalanceColor+' !! '+historyColorCurrencyMap+' <> '+colorCurrencyMap);
        //use a loop and edit the code below to putData(retrieved month name, retrieved quantity, retrieved product code);
        //for (AggregateResult  ar: HERE IS YOUR QUERY ) {
                //data.putData(monthFromInteger(monthInt), Integer.valueOf(ar.get('quantityCount')), yourProductName);
        //}
        //Create the Empty-bar on Quatar without data.
        for(String productGroupName : dataMap.keySet()){
        	Map<String,Decimal> productGroup = dataMap.get(productGroupName);
        	if(productGroup.size()==0){
	            for(String curr : yfield.split(',')) {
	            	productGroup.put(curr, 0);
	            }
        	}
        }
        return dataMap;
	}
        
	private void putData(String name, Decimal quantity, String productCode){
    	System.debug(name + '>>>>' + productCode + ' >>>' + quantity); 
        Map<String,Decimal> productGroup = new Map<String,Decimal>();
        if(!String.isEmpty(productCode)){
	        if (dataMap.containsKey(name)){
	            productGroup = dataMap.get(name);
	        }
	        Decimal quan = (productGroup.containsKey(productCode) && productGroup.get(productCode) != null) ?
	                        productGroup.get(productCode) + quantity : quantity;
	        productGroup.put(productCode, quan);
        }
        dataMap.put(name, productGroup);
	}
            
    /////////////////////// Javscript Array Methods Ends /////////////////////////////
    
    public List<PieWedgeData1> getPieData1() {
        system.debug('****colorOrder@@@:');
        forwardColorCurrencyMap= new map<String, string>();
        List<PieWedgeData1> dataList = new List<PieWedgeData1>(); 
        List<sObject> holdbalance= new List<sObject>();  
        map<string, PieWedgeData1>mapPieWedgeData = new map<string, PieWedgeData1>();
        Date todayDate = Datetime.now().date();
        
        // commented from query
        // Start_Date__c<=: todayDate and
        
        // Updated By : Ashish Goyal	20th May 2015
        // removed and Maturity_Date__c>=:todayDate condition
        // Ref : I-163726
        //
        String sql = 'SELECT Custom_Currency__c, SUM(Converted_Amount__c)total, SUM(FX_Balance__c) MarketRate FROM Forward_Contracts__c where Converted_Amount__c>0 and Account_ID__c =: accId group by Custom_Currency__c';
        
        holdbalance = Database.Query(sql);
        Decimal total=0;
        for(sObject temp:holdbalance){
            total+=(Decimal)temp.get('total');
        }
        //map<String, Decimal> MarketRateMap= getMarketRateCode(holdbalance);
        //system.debug('*****!MarketRateMap! >> '+MarketRateMap);        
        Set<string>colorOrderSet = new Set<string>(colorOrder);
        Set<String>newColor4Currency = new Set<String>();
        for(sObject temp:holdbalance)
        {           
            String CurrencyIsoCode = (String)temp.get('Custom_Currency__c');
            if(!String.isEmpty(CurrencyIsoCode) && !colorOrderSet.contains(CurrencyIsoCode)){
                colorOrder.add(CurrencyIsoCode);
            }
            mapPieWedgeData.put(CurrencyIsoCode, new PieWedgeData1((String)temp.get('Custom_Currency__c'),((Decimal)temp.get('total')),
            ((Decimal)temp.get('MarketRate')) ));            
            if(String.isEmpty(getColorNextCodeForCurrency(CurrencyIsoCode, forwardColorCurrencyMap, false))){
                newColor4Currency.add(CurrencyIsoCode);
            }
        }
        for(String newColorcurr : newColor4Currency){
            getColorNextCodeForCurrency(newColorcurr, forwardColorCurrencyMap, true);
        }        
        for(String colorOrderL : colorOrder){
            if(mapPieWedgeData.containsKey(colorOrderL)){
                dataList.add(mapPieWedgeData.get(colorOrderL));
                ForwardBalanceColor  = buildColorCodes(ForwardBalanceColor, colorCurrencyMap.get(colorOrderL));
            }
        }        
        if(dataList.isEmpty()){
            system.debug('No data found');
        }
        system.debug('==Sam=='+dataList);
        return dataList;  
    }  
    
        // Wrapper class  
    public class PieWedgeData1 
    {  
        public String name { get; set; }  
        public Decimal data { get; set; }  
        public String stack {get;set;}
        public Decimal Rate{get;set;}  
        
        public PieWedgeData1(String name, Decimal data, Decimal Rate){
            this.Rate = Rate;  
            this.name = name;  
            this.data = data;           
            if(this.Rate!=null){
                this.name = name;//+' - '+(Rate*data);
            }  else{
                this.name =name;
            }
        } 
        public PieWedgeData1(String name, Decimal data) 
        {  
            this.name = name;  
            this.data = data;  
    
    }
    }
    
}