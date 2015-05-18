public without sharing class CashFlowComponentClone {
    public static Integer selMonth{get;set;}    
    public              string          currentContact{get;set;}//used to understand who the query is against.
    public              string          currentAccount{get;set;}//used to understand who the query is against.
    public              string          cur {get;set;}
    public              Date            oldestDate{get;set;}//used to determine the starting month 
    public              DateTime        dt{get;set;}//Used for the time stamp on the page
    public              Integer         totalCol;//Used to recognise the final total column
    public              Boolean         showAdvanced{get;set;}
    public              Double         currentBalance{get;private set;}
    public              Double          currentRate{get;private set;} //current exchange rate
    public              Double          conversionRate {get;private set;} //inverse of the currentRate
    
    public              MAP<String, Double>     mrMap;//Map of Market Rates
    public              MAP<Integer, String>    monthMap{get;set;}
    public              User            classUser;
    public              Account         classAccount;
    public              String          defaultCode{get;set;}
    public User loggedInUser;
    
    //Declare the lists used to display totals
    transient   public  LIST<String>    months;//Used to create the month columns in the report page.
    transient   public  LIST<Double>   outflowTotal{get;private set;}
    transient   public  LIST<Double>   inflowTotal{get;private set;}
    transient   public  LIST<Double>   hedgeTotalObligation{get;private set;}
    transient   public  LIST<Double>   hedgeTotalProtection{get;private set;}
    transient   public  LIST<Double>   hedgeTotal{get;private set;}
    transient   public  LIST<Double>   netHedgeTotal{get;private set;}
    transient   public  LIST<Double>   netFXPositionProtection{get;private set;}
    transient   public  LIST<Double>   netFXPositionObligation{get;private set;}
    transient   public  LIST<Double>   netOperatingFXCashFlow{get;private set;}
    transient   public  LIST<Double>   Invoices{get;private set;}
    transient   public  LIST<Double>   PurchaseOrders{get;private set;}
    transient   public  LIST<Double>   ForecastOrders{get;private set;}
    transient   public  LIST<Double>   OutflowOther{get;private set;}
    transient   public  LIST<Double>   TradingReceipts{get;private set;}
    transient   public  LIST<Double>   InflowOther{get;private set;}
    transient   public  LIST<Double>   ForwardContractsWUBS{get;private set;}
    transient   public  LIST<Double>   ForwardContractsOther{get;private set;}
    transient   public  LIST<Double>   OptionsWUBSProtection{get;private set;}
    transient   public  LIST<Double>   OptionsWUBSObligation{get;private set;}
    transient   public  LIST<Double>   OptionsOtherProtection{get;private set;}
    transient   public  LIST<Double>   OptionsOtherObligation{get;private set;}
    transient   public  LIST<Double>   convertedRate{get;private set;}
    transient   public  LIST<Double>   convertedProtectionRate{get;private set;}
    transient   public  LIST<Double>   convertedObligationRate{get;private set;}
    
    //Booleans for empty lists
    public Boolean noInvoices                   {get;private set;}
    public Boolean noPurchaseOrders             {get;private set;}
    public Boolean noForecastOrders             {get;private set;}
    public Boolean noOutflowOther               {get;private set;}
    public Boolean noTradingReceipts            {get;private set;}
    public Boolean noInflowOther                {get;private set;}
    public Boolean noForwardContractsWUBS       {get;private set;}
    public Boolean noForwardContractsOther      {get;private set;}
    
    public Boolean noOptionsWUBSProtection      {get;private set;}
    public Boolean noOptionsWUBSObligation      {get;private set;}
    public Boolean noOptionsOtherProtection     {get;private set;}
    public Boolean noOptionsOtherObligation     {get;private set;}
    
    public Boolean nohedgeTotalProtection       {get;private set;}
    public Boolean nohedgeTotalObligation       {get;private set;}
    public Boolean nonetFXPositionProtection    {get;private set;}
    public Boolean nonetFXPositionObligation    {get;private set;}
    public Boolean noCurrentBalance             {get;private set;}
    
    public Boolean isTotal                      {get;private set;}
    public Decimal holdingBalance {get; set;}
    
    //public set<Id> owners {get; set;}

    //  Constructor - not really used. 
    /*** Unreliable constructor since this is a controller for a component page. Use getMonths() ***/
    public CashFlowComponentClone()
    {
        //This section returns null and reverts to the default user. 
        classUser = Utility.loggedInUser;//findUser(currentContact);
        System.debug('THE current CONTACT IS THIS: ' + currentContact);
        System.debug('THE RETURNED USER IS THIS: ' + classUser);
        defaultCode = classUser.DefaultCurrencyIsoCode; // was DefaultCurrencyIsoCode
        
        
        System.debug('THE RETURNED USER IS THIS: ' + selMonth);
        updateMarketRate();
        dt = datetime.now();
        initialiseLists();
        
        //getOwnersId();
        showAdvanced=false;
    }
    /*
    private User findUser(String con)
    {
        User u = [SELECT    Id, Name, ContactId, CurrencyIsoCode, DefaultCurrencyIsoCode, contact.AccountId 
                    FROM    User
                    WHERE   ContactId =: con
                    LIMIT   1];
                    
        System.debug('THE QUERIED USER IS THIS: ' + u);
        return u;
    }*/
	/*
    private void getOwnersId(){
        /*Id accId = Utility.currentAccount;
        for(User u : [SELECT Id FROM User WHERE Contact.AccountId = :accId]){
            owners.add(u.Id);
        }* /
        if(owners==null || owners.size()==0){
        	owners = Utility.getCurrentUsers();
        }
    }*/
    private Account findAccount(String acc)
    {
        Account[] a = [SELECT   Id, Name, CurrencyIsoCode 
                    FROM    Account
                    WHERE   id =: acc
                    LIMIT   1];
                    
        //System.debug('THE QUERIED ACCOUNT IS THIS: ' + a);
        if(a.size() > 0)
            return a[0];
        return null;
    }
    
    public boolean isNonCCTuser{
        get{
            return Utility.isNonCCTuser;
        }
    }

    
    private void initialiseLists()
    {
        mrMap = new MAP<String, Double>();
        months = new LIST<String>();
        outflowTotal = new LIST<Double>();
        inflowTotal = new LIST<Double>();
        hedgeTotalObligation = new LIST<Double>();
        hedgeTotalProtection = new LIST<Double>();
        netFXPositionProtection = new LIST<Double>();
        netFXPositionObligation = new LIST<Double>();
        netOperatingFXCashFlow = new LIST<Double>();
        Invoices = new LIST<Double>();
        PurchaseOrders = new LIST<Double>();
        ForecastOrders = new LIST<Double>();
        OutflowOther = new LIST<Double>();
        TradingReceipts = new LIST<Double>();
        InflowOther = new LIST<Double>();
        ForwardContractsWUBS = new LIST<Double>();
        ForwardContractsOther = new LIST<Double>();
        OptionsWUBSProtection = new LIST<Double>();
        OptionsWUBSObligation = new LIST<Double>();
        OptionsOtherProtection = new LIST<Double>();
        OptionsOtherObligation = new LIST<Double>();
        hedgeTotal = new LIST<Double>();
        netHedgeTotal = new LIST<Double>();
        convertedRate = new LIST<Double>();
        convertedObligationRate = new LIST<Double>();
        convertedProtectionRate = new LIST<Double>();
        //owners = new set<Id>();
    }

    //return the list of months. PSEUDO-CONSTRUCTOR
    /*** This function acts as the constructor for portalCashFlowReport.component ***/
    /*** All initialisation functions should occur here. ***/
    public LIST<String> getMonths()
    {
        if(currentAccount == null) {
            currentAccount = Utility.currentAccount;
        }
        if(currentAccount != null || currentAccount != '')
            classAccount = findAccount(currentAccount);
        /*if(classAccount == null)
            classUser = findUser(currentContact);
        else
            classUser = loggedInUser;
        */
        classUser = Utility.loggedInUser;
        System.debug('THE current CONTACT IS THIS: ' + currentContact);
        System.debug('THE current Account IS THIS: ' + currentAccount);
        System.debug('THE RETURNED USER IS THIS: ' + classUser);
        System.debug('THE RETURNED ACCOUNT IS THIS: ' + classAccount);
        System.debug('***(selMonth:'+selMonth);
        defaultCode = classUser.DefaultCurrencyIsoCode; // was DefaultCurrencyIsoCode
        /*Date lastdt = Date.today();
        Date startdt = lastdt.addMonths((1-selMonth)).toStartOfMonth();*/
        Date startdt = Date.today().toStartOfMonth();
        Date lastdt = startdt.addMonths(selMonth).addDays(-1);
        System.debug('$$$$' + startdt);
        initialiseLists();
        //getOwnersId();
        updateMarketRate();
        //oldestDate = firstMonthToDisplay(currentContact, currentAccount);
        monthSearch(startdt);
        settingsValues();
        System.debug('For populateValues <Contact>: ' + currentContact);
        System.debug('For populateValues <Date>: ' + oldestDate);
        System.debug('For populateValues <Currency>: ' + cur);
        populateInvoiceValues(currentContact, startdt, lastdt, cur, currentAccount);
        populateFWContractValues(currentContact, startdt,lastdt, cur, currentAccount);
        populateValues(currentContact, startdt, lastdt, cur, currentAccount);
        
        //populateInvoiceValues(currentContact, startdt, lastdt, cur, currentAccount);
        
        populateHoldingBalance(cur, currentAccount);
        return(months);
    }
    
    public LIST<String> getSpacer()
    {
        LIST<String> sp = new LIST<String>();
        for(integer ig=0; ig<totalCol; ig++)
        {
            sp.add('');
        }
        return sp;
    }
    
    //Find the oldest month, assuming it's older than this month
    public Date firstMonthToDisplay(String con, String acc)
    {
        date td = date.Today().toStartOfMonth();
        //date td1 = date.newinstance(td.year(), 1, 1);
        
        if(acc != null)
        {
            system.debug('Searching for INPUT__c based on account');
            for(Input__c inp:[SELECT    Id, Transaction_Date__c, Paid__c, OwnerId, ContactId__c, Parent_Account__c, CreatedDate
                                FROM    Input__c
                                WHERE   Paid__c = false 
                                AND Parent_account__c=:Utility.currentAccount
                                AND Transaction_Date__c <: td.addYears(1)
                                AND Transaction_Date__c >= :td])
            {
                if(td > inp.Transaction_Date__c)
                {
                    td = inp.Transaction_Date__c;
                }
            }
        }
        else
        {
            system.debug('Searching for INPUT__c based on contact');
            for(Input__c inp:[SELECT    Id, Transaction_Date__c, Paid__c, OwnerId, ContactId__c, Parent_Account__c, CreatedDate
                            FROM    Input__c
                            WHERE   Paid__c = false AND ContactId__c =: con
                            AND Transaction_Date__c <: td.addYears(1)
                            AND Transaction_Date__c >= :td])
            {
                if(td > inp.Transaction_Date__c)
                {
                    td = inp.Transaction_Date__c;
                }
            }   
        }
        
        return td;
    }
    
    
    //this function returns the List of Month Name to be displayed in the table. It is fired by a single number which is the month of the oldest date 
    public void monthSearch(Date m)
    {
        months = new LIST<String>();
        Integer lmonth;
        Integer lYear;
        for(Integer i = 0; i < selMonth; i++){
            lYear= m.addmonths(i).year();
            lmonth = m.month()+i;
            if(lmonth >12)
            {
                lmonth = lmonth-12;
            }
            months.add(String.valueOf(Utility.getMonthName(lmonth)+' '+(String.valueOf(lYear).right(2))));
            outflowTotal.add(0);
            inflowTotal.add(0);
            hedgeTotalObligation.add(0);
            hedgeTotalProtection.add(0);
            netFXPositionProtection.add(0);
            netFXPositionObligation.add(0);
            netOperatingFXCashFlow.add(0);
            Invoices.add(0);
            PurchaseOrders.add(0);
            ForecastOrders.add(0);
            OutflowOther.add(0);
            TradingReceipts.add(0);
            InflowOther.add(0);
            hedgeTotal.add(0);
            netHedgeTotal.add(0);
            ForwardContractsWUBS.add(0);
            ForwardContractsOther.add(0);
            OptionsWUBSProtection.add(0);
            OptionsWUBSObligation.add(0);
            OptionsOtherProtection.add(0);
            OptionsOtherObligation.add(0);
            convertedRate.add(0);
            convertedProtectionRate.add(0);
            convertedObligationRate.add(0);
        }
        
        months.add(System.Label.Total); // George Sarkis 24/03/2014
        outflowTotal.add(0);
        inflowTotal.add(0);
        hedgeTotalObligation.add(0);
        hedgeTotalProtection.add(0);
        netFXPositionProtection.add(0);
        netFXPositionObligation.add(0);
        netOperatingFXCashFlow.add(0);
        Invoices.add(0);
        PurchaseOrders.add(0);
        ForecastOrders.add(0);
        OutflowOther.add(0);
        TradingReceipts.add(0);
        InflowOther.add(0);
        hedgeTotal.add(0);
        netHedgeTotal.add(0);
        ForwardContractsWUBS.add(0);
        ForwardContractsOther.add(0);
        OptionsWUBSProtection.add(0);
        OptionsWUBSObligation.add(0);
        OptionsOtherProtection.add(0);
        OptionsOtherObligation.add(0);
        convertedRate.add(0);
        convertedProtectionRate.add(0);
        convertedObligationRate.add(0);
        
        totalCol = selMonth;
    }
    
    
    //This function will populate the Settings records for this user with the latest currency values
    public void updateMarketRate()
    {
        mrMap = new MAP<String, Double>();
        system.debug('Populating the map');
        for(Market_Rate__c mr:[SELECT   Id, CurrencyIsoCode, Currency_Name__c, Currency_Value__c, Name, Currency_Code__c
                                FROM    Market_Rate__c])
        {
            if(!mrMap.containsKey(mr.Currency_Code__c))
            {
                mrMap.put(mr.Currency_Code__c, mr.Currency_Value__c);
                system.debug('CURRENCY CODE:' + mr.Currency_Code__c);
                system.debug('CURRENCY VALUE:' + mr.Currency_Value__c);
            }
        }
        if(mrMap.isEmpty())
            system.debug('map is empty in updateMarketRate');
    }
    
    //grab the bank balance and base rate
    public void settingsValues()
    {
        string cur2;
        if(cur.containsIgnoreCase('Total'))
        {
            cur2 = Utility.userCurrency; //classUser.DefaultCurrencyIsoCode; // was DefaultCurrencyIsoCode
            isTotal = true;
            
        }
        else
        {
            cur2=cur;
            isTotal = false;
        }
        currentBalance = 0;
        currentRate = 0;
        conversionRate = 0;
        Portal_Settings__c ps;
        //system.debug('THE ISOCURRENCYCODE BEING USED HERE IS: '+ classUser.CurrencyIsoCode);
        //system.debug('THE DEFAULT ISOCURRENCY BEING USED HERE IS: '+classUser.DefaultCurrencyIsoCode);
        system.debug('THE CURRENCY BEING USED HERE IS: '+cur);
        String accountId;
        //System.debug('@settingsvalues() classAccount: ' + classAccount);
        /*if (classAccount != null) {
            accountId = classAccount.Id;
        } else {
            accountId = classUser.Contact.AccountId;
        }*/
        accountId = Utility.currentAccount;

        LIST<Portal_Settings__c> psl = [    Select  id, Name, Currency__c, Current_Balance__c
                                    From    Portal_Settings__c
                                    Where   Currency__c =: cur2 
                                    And Account__c =: accountId Limit 1];
        //System.debug('@settingsvalues() classAccount: ' + classAccount);
        //System.debug('@settingsvalues() classUser.Contact.AccountId: ' + classUser.Contact.AccountId);
        System.debug('@settingsvalues() psl: ' + psl);
        if(psl.size()>0)
        {
            ps = psl[0];
            currentBalance = Double.valueOf(ps.Current_Balance__c);
        }
        
        // find the currency selected.
        system.debug('THE CURRENCY2 BEING USED HERE IS: '+cur2);
        if(mrMap.containsKey(cur2) && mrMap.containsKey(defaultCode)){
            currentRate = double.valueOf(mrMap.get(defaultCode)/mrMap.get(cur2));   //mrMap.get(cur2); (mrMap.get(cur2)/mrMap.get(defaultCode));
            conversionRate = 1/currentRate;
            system.debug('THE CURRENT RATE BEING USED HERE IS: '+ currentRate + 'CONVERSION RATE'+ conversionRate);
        }
        
        if(cur=='Total')
        {
            currentRate = 1;
            conversionRate = 1;
        }
        else if(cur.containsIgnoreCase(Utility.userCurrency)) // was classUser.DefaultCurrencyIsoCode
        {
            currentRate = 1;
            conversionRate = 1;
        }
    }
    
    public void populateHoldingBalance(String theCurrency, String acc) {
        LIST<Holding_Balance__c> holdBalList = new LIST<Holding_Balance__c>();
        holdingBalance = 0;
         if(theCurrency != 'Total')
         {
           holdBalList =  [SELECT Amount__c 
                              FROM Holding_Balance__c
                              WHERE Account__c =: acc
                              AND Custom_Currency__c =: theCurrency];
         }else {
            holdBalList =  [SELECT Amount__c
                              FROM Holding_Balance__c
                              WHERE Account__c =: acc];
         }
         system.debug('holdBalList >>> '+ holdBalList);
         for(Holding_Balance__c h:holdBalList) {
            holdingBalance = holdingBalance + h.Amount__c;
         }
    }
    // Method created to display the data from Invoice__c
    // Created : Poonam Varyani
    // task: T-355017
    public void populateInvoiceValues(String con,  Date startDate, Date endDate, String theCurrency, String acc) {
        system.debug('test invoice:');
        date td = date.Today();
        LIST<Invoice__c> invList = new LIST<Invoice__c>();//used as a temporary storage list to process the value into their own lists
        if(theCurrency != 'Total')
        {
            system.debug('Searching based on the account. Account has been passed in Invoice.');
            invList = [Select Id, Name, Account__c, Amount__c, Custom_Currency__c, Due_Date__c, 
                        Status__c, Seller__c, Product__c
                        From Invoice__c where Account__c =: acc
                        And Status__c not in ('Void', 'Paid')
                        And Due_Date__c >=: startDate
                        And Due_Date__c <=: endDate
                        And Custom_Currency__c = :theCurrency ];
            
        }else
        {
            invList = [Select Id, Name, Account__c, Amount__c, Custom_Currency__c, Due_Date__c, 
                        Status__c, Seller__c, Product__c
                        From Invoice__c where Account__c =: acc
                        And Status__c not in ('Void', 'Paid')
                        And Due_Date__c >=: startDate
                        And Due_Date__c <=: endDate];
        }
         
         system.debug('invList >>>> '+invList);
         //Loop through the incList and separate the values out into their respective lists and placements
        for(Invoice__c i:invList)
        {
            addToInvoice(i, startDate);
        }
        isListEmpty();
    }
    public void populateFWContractValues(String con,  Date startDate, Date endDate, String theCurrency, String acc) {
        system.debug('test invoice:');
        date td = date.Today();
        LIST<Forward_Contracts__c> fxList = new LIST<Forward_Contracts__c>();//used as a temporary storage list to process the value into their own lists
        if(theCurrency != 'Total')
        {
            system.debug('Searching based on the account. Account has been passed in.');
            fxList = [SELECT Transaction_Number__c, Start_Date__c, Maturity_Date__c, Settlement_Amount__c, 
                        Custom_Currency__c, FX_Currency__c, FX_Amount__c, FX_Balance__c, CurrencyIsoCode FROM Forward_Contracts__c where Account_ID__c =: acc
                        And Custom_Currency__c = :theCurrency 
                        AND(
                        	/*(
	                         	Start_Date__c >=: startDate
	                        	And Start_Date__c <=: endDate
	                        	)
	                        OR(*/
	                        	Maturity_Date__c >=: startDate
	                        	AND Maturity_Date__c <=: endDate
	                        	
	                        	//)
	                        )
                        ];
            
        }else
        {
            fxList = [SELECT Transaction_Number__c, Start_Date__c, Maturity_Date__c, Settlement_Amount__c,
                        Custom_Currency__c, FX_Currency__c, FX_Amount__c, FX_Balance__c, CurrencyIsoCode FROM Forward_Contracts__c where Account_ID__c =: acc
                        AND(
                        	/*(
	                         	Start_Date__c >=: startDate
	                        	And Start_Date__c <=: endDate
	                        	)
	                        OR(*/
	                        	Maturity_Date__c >=: startDate
	                        	AND Maturity_Date__c <=: endDate
	                        	
	                        	//)
	                        )
                        ];
        }
         
         system.debug('fxList >>>> '+fxList);
         //Loop through the incList and separate the values out into their respective lists and placements
        for(Forward_Contracts__c i:fxList)
        {
            addToForwardWUBS(i, startDate);
        }
        isListEmpty();
    }
    public void populateValues(String con, Date startDate, Date endDate, String theCurrency, String acc)
    {
        //system.debug('test1:' +owners);
        //date td = date.Today();
        LIST<Input__c> incList = new LIST<Input__c>();//used as a temporary storage list to process the value into their own lists
        User u2 = Utility.loggedInUser;//findUser(con);
        system.debug('theCurrency >>> ' + theCurrency);
        if(acc != null)
        {
            if(theCurrency != 'Total')
            {
                 System.debug('startdt =>' + startDate + ' lastdt =>' + endDate);
                system.debug('Searching based on the account. Account has been passed in.');
                incList = [SELECT   Id, Amount__c, Type__c, Transaction_Date__c, Custom_Currency__c, Paid__c,ContactId__c,
                                        User__c, Sort_Order__c, Input_Type__c, Parent_Account__c
                                FROM    Input__c
                                WHERE   Transaction_Date__c != null 
                                        AND Transaction_Date__c >= : startDate 
                                        //AND Parent_Account__c =: acc
                                        //AND Paid__c = false
                                        AND Parent_account__c=:Utility.currentAccount
                                        AND (Custom_Currency__c =: theCurrency )  //CurrencyIsoCode =: theCurrency
                                        AND Transaction_Date__c <=: endDate
                                        ORDER BY Sort_Order__c ASC];
            }else
            {
                system.debug('query in else 1 ??? ');
                incList = [SELECT   Id, Amount__c, Type__c, Transaction_Date__c, Custom_Currency__c, Paid__c,ContactId__c,
                                        User__c, Sort_Order__c, Input_Type__c, Parent_Account__c
                                FROM    Input__c
                                WHERE   Transaction_Date__c != null 
                                        AND Transaction_Date__c >= : startDate 
                                        //AND Parent_Account__c =: acc
                                        //AND Paid__c = false
                                        AND Parent_account__c=:Utility.currentAccount
                                        AND Transaction_Date__c <=: endDate
                                        ORDER BY Sort_Order__c ASC];
            }
        }
        else
        {
            if(theCurrency != 'Total')
            {
                incList = [SELECT   Id, Amount__c, Type__c, Transaction_Date__c, Custom_Currency__c, Paid__c,ContactId__c,
                                        User__c, Sort_Order__c, Input_Type__c, Parent_Account__c, CreatedDate
                                FROM    Input__c
                                WHERE   Transaction_Date__c != null 
                                        AND Transaction_Date__c >= : startDate 
                                        //AND Parent_Account__c =: u2.contact.AccountId
                                        AND Parent_account__c=:Utility.currentAccount
                                        //AND Paid__c = false
                                        AND (Custom_Currency__c =: theCurrency ) //CurrencyIsoCode =: theCurrency
                                        AND Transaction_Date__c <=: endDate
                                        ORDER BY Sort_Order__c ASC];
            }else
            {
                system.debug('query in else 2 ??? ');
                incList = [SELECT   Id, Amount__c, Type__c, Transaction_Date__c, Custom_Currency__c, Paid__c,ContactId__c,
                                        User__c, Sort_Order__c, Input_Type__c
                                FROM    Input__c
                                WHERE   Transaction_Date__c != null 
                                        AND Transaction_Date__c >= : startDate 
                                        //AND Parent_Account__c =: u2.contact.AccountId
                                        //AND Paid__c = false
                                        AND Parent_account__c=:Utility.currentAccount
                                        AND Transaction_Date__c <=: endDate
                                        ORDER BY Sort_Order__c ASC];
            }
        }
        system.debug('incList >>>> '+incList);
        //Loop through the incList and separate the values out into their respective lists and placements
        for(Input__c i:incList)
        {
            /*if(i.Type__c == 'Invoice')
            {
                addToInvoice(i, oldest);
            }else*/ if(i.Type__c == 'Purchase Order' || i.Input_Type__c == 'Purchase Order')
            {
                addToPurchaseOrder(i, startDate);
            }
            else if(i.Type__c == 'Forecast Outflow' || i.Input_Type__c == 'Forecast Outflow')
            {
                addToForecastOrder(i, startDate);
            }
            else if(i.Type__c == 'Outflow - Other' || i.Input_Type__c == 'Outflow - Other')
            {
                addToOutflowOther(i, startDate);
            }
            else if(//(i.Type__c == 'Option - Other' || i.Input_Type__c == 'Option - Other') || 
                (i.Type__c == 'Fixed Forward Contract - Other' || i.Input_Type__c == 'Fixed Forward Contract - Other') ||
                ( i.Type__c == 'Window Forward Contract - Other' || i.Input_Type__c == 'Window Forward Contract - Other')
             ) {
                addToForwardOther(i, startDate);
            }/*else if(i.Type__c == 'Forward Contract - WUBS')
            {
                system.debug('type ::: Forward Contract - WUBS' + i);
                addToForwardWUBS(i, startDate);
            }*/else if(i.Type__c == 'Option Protection - WUBS')
            {
                addToOptionsWUBSProtection(i, startDate);
                showAdvanced = true;
            }
            else if(i.Type__c == 'Option Obligation - WUBS')
            {
                addToOptionsWUBSObligation(i, startDate);
                showAdvanced = true;
            }
            else if(i.Type__c == 'Option Protection - Other')
            {
                addToOptionsOtherProtection(i, startDate);
                showAdvanced = true;
            }else if(i.Type__c == 'Option Obligation - Other')
            {
                addToOptionsOtherObligation(i, startDate);
                showAdvanced = true;
            }
            else if(i.Type__c == 'Inflow - Other' || i.Input_Type__c == 'Inflow - Other')
            {
                addToInflowOther(i, startDate);
            }
            else if(i.Type__c == 'Forecast Inflow' || i.Input_Type__c == 'Forecast Inflow')
            {
                addToTradingReceipts(i, startDate);
            }
        }
        
        for(Integer i=0; i<(totalCol+1); i++)
        {
            if(cur == 'Total')
            {
                cur = defaultCode;
            }
            system.debug('THE CURRENT RATE IS '+cur+'  '+defaultCode);
            system.debug('CRASH OCCURS MAYBE HERE 1');
            system.debug('CRASH OCCURS MAYBE HERE 1: "' + defaultCode+'"');
            system.debug('CRASH OCCURS MAYBE HERE 1: "' + cur+'"');
            system.debug('CRASH OCCURS MAYBE HERE 1: "' + mrMap.get(cur)+'"');
            system.debug('CRASH OCCURS MAYBE HERE 1: "' + mrMap.get(defaultCode)+'"');
            double defaulConRate = 1.0;
            double conRate = 1.0;
            if(mrMap.isEmpty()){
                system.debug('The map is entirely empty. This is a cause of the crash.');
                
            }else if(mrMap.containsKey(defaultCode)){
                //system.debug('defaultCode could not be found in the map.');
                defaulConRate = mrMap.get(defaultCode);
            }
            if(mrMap.containsKey(cur)){
                conRate = mrMap.get(cur);
                //system.debug('currency could not be found in the map.');
            }
                
            Double ccr = 1/double.valueOf(defaulConRate/conRate);   // Updated by Harshit Jain March 30, 2015 [I-153292]
            system.debug('CRASH OCCURS MAYBE HERE 2');
            system.debug('VALUES USED FOR CONVERSION RATE IS: '+mrMap.get(defaultCode)+'-Default '+mrMap.get(cur)+'-the Currency');
            system.debug('CRASH OCCURS MAYBE HERE 3');
            system.debug('THE CURRENT RATE IS: '+netHedgeTotal[i]+' / '+ccr);
            convertedRate[i] = Double.valueOf((netHedgeTotal[i]/ccr));
            convertedProtectionRate[i] = Double.valueOf((netFXPositionProtection[i]/ccr));
            convertedObligationRate[i] = Double.valueOf((netFXPositionObligation[i]/ccr));
        }

        system.debug('test1:');
        system.debug('test2:' + Invoices);
        isListEmpty();
        
        
    }
    
    private void isListEmpty()
    {
        /* BEGIN: Section to check if lists are empty   */
        Double num = 0;
        for(Double i: Invoices) {  
            system.debug('>>>> i >>> '+i);
            num += i;   
        }
        noInvoices = num > 0 || num < 0 ? false : true;
        
        num = 0;
        for(Double i: PurchaseOrders) {    
            num += i;   
        }
        noPurchaseOrders = num > 0 || num < 0 ? false : true;
        
        num = 0;
        for(Double i: ForecastOrders) {    
            num += i;   
        }
        noForecastOrders = num > 0 || num < 0 ? false : true;
        
        num = 0;
        for(Double i: OutflowOther) {  
            num += i;   
        }
        noOutflowOther = num > 0 || num < 0 ? false : true;
        
        num = 0;
        for(Double i: TradingReceipts) {   
            num += i;   
        }
        noTradingReceipts = num > 0 || num < 0 ? false : true;
        
        num = 0;
        for(Double i: InflowOther) {   
            num += i;   
        }
        noInflowOther = num > 0 || num < 0 ? false : true;
        
        num = 0;
        for(Double i: ForwardContractsWUBS) {  
            num += i;   
        }
        noForwardContractsWUBS = num > 0 || num < 0 ? false : true;
        
        num = 0;
        for(Double i: ForwardContractsOther) { 
            num += i;   
        }
        noForwardContractsOther = num > 0 || num < 0 ? false : true;
        
        // OPTIONS
        num = 0;
        for(Double i: OptionsWUBSProtection) { 
            num += i;   
        }
        noOptionsWUBSProtection = num > 0 || num < 0 ? false : true;
        
        num = 0;
        for(Double i: OptionsWUBSObligation) { 
            num += i;   
        }
        noOptionsWUBSObligation = num > 0 || num < 0 ? false : true;
        
        num = 0;
        for(Double i: OptionsOtherProtection) {    
            num += i;   
        }
        noOptionsOtherProtection = num > 0 || num < 0 ? false : true;
        
        num = 0;
        for(Double i: OptionsOtherObligation) {    
            num += i;   
        }
        noOptionsOtherObligation = num > 0 || num < 0 ? false : true;
        
        // hedging
        num = 0;
        for(Double i: hedgeTotalProtection) {  
            num += i;   
        }
        nohedgeTotalProtection = num > 0 || num < 0 ? false : true;
        
        num = 0;
        for(Double i: hedgeTotalObligation) {  
            num += i;   
        }
        nohedgeTotalObligation = num > 0 || num < 0 ? false : true;
        
        num = 0;
        for(Double i: netFXPositionProtection) {   
            num += i;   
        }
        nonetFXPositionProtection = num > 0 || num < 0 ? false : true;
        
        num = 0;
        for(Double i: netFXPositionObligation) {   
            num += i;   
        }
        nonetFXPositionObligation = num > 0 || num < 0 ? false : true;
        
        noCurrentBalance = currentBalance > 0 ? false : true;
        /* END: Section to check if lists are empty     */
    }
    
    // Method created to display the data from Invoice__c
    // Earlier it was using object Input__c
    // Modified : Poonam Varyani
    // task: T-355017
    public void addToInvoice(Invoice__c i)
    {
        addToInvoice(i, system.Today());
    }
    
    //add input to the invoice list and add to the appropriate lists
    // Method created to display the data from Invoice__c
    // Earlier it was using object Input__c
    // Modified : Poonam Varyani
    // task: T-355017
    private void addToInvoice(Invoice__c i, Date od)
    {
        Double c;
        integer mi;
        if(currentAccount != null)
        {
            User uc = Utility.loggedInUser;//classUser;
            system.debug('Adding Invoices based on the current account details');
            c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));
            mi = od.monthsBetween(i.Due_Date__c);
        }
        else
        {
            User uc = Utility.loggedInUser;//classUser;
            system.debug('Adding Invoices based on the current contact details');
            c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));
            mi = od.monthsBetween(i.Due_Date__c);   
        }
        Invoices[mi] += c; 
        outflowTotal[mi] += c; 
        netHedgeTotal[mi] -= c;
        netOperatingFXCashFlow[mi] -= c;
        netFXPositionProtection[mi] -= c;
        netFXPositionObligation[mi] -= c;
        
        //add to total
        Invoices[totalCol] += c;
        outflowTotal[totalCol] += c;
        netHedgeTotal[totalCol] -= c;
        netOperatingFXCashFlow[totalCol] -= c;
        netFXPositionProtection[totalCol] -= c;
        netFXPositionObligation[totalCol] -= c;
    }

    public void addToPurchaseOrder(Input__c i)
    {
        addToPurchaseOrder(i, system.Today());
    }
    
    //add input to the purchase order list and add to the appropriate lists
    private void addToPurchaseOrder(Input__c i, Date od)
    {
        Double c;
        integer mo;
        if(currentAccount != null || currentAccount != '')
        {
            User uc = classUser;
            if(i.Custom_Currency__c!= null) {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));  
            }else {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));
            }
            
            mo = od.monthsBetween(i.Transaction_Date__c);
        }
        else
        {
            User uc = classUser;
            if(i.Custom_Currency__c!= null) {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));  
            }else {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));
            }
            mo = od.monthsBetween(i.Transaction_Date__c);
        }
        
        PurchaseOrders[mo] += c;
        outflowTotal[mo] += c;
        netHedgeTotal[mo] -= c;
        netOperatingFXCashFlow[mo] -= c;
        netFXPositionProtection[mo] -= c;
        netFXPositionObligation[mo] -= c;
        
        //add to total
        PurchaseOrders[totalCol] += c;
        outflowTotal[totalCol] += c;
        netHedgeTotal[totalCol] -= c;
        netOperatingFXCashFlow[totalCol] -= c;
        netFXPositionProtection[totalCol] -= c;
        netFXPositionObligation[totalCol] -= c;
    }
    
    public void addToForecastOrder(Input__c i)
    {
        addToForecastOrder(i, system.Today());
    }
    
    //add input to the purchase order list and add to the appropriate lists
    private void addToForecastOrder(Input__c i, Date od)
    {
        Double c;
        integer mo;
        User uc = Utility.loggedInUser;//classUser;
        if(currentAccount != null || currentAccount != '')
        {            
            if(i.Custom_Currency__c!= null) {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));  
            }else {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));
            }
            
            mo = od.monthsBetween(i.Transaction_Date__c);
        }
        else
        {
            if(i.Custom_Currency__c!= null) {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));  
            }else {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));
            }
            mo = od.monthsBetween(i.Transaction_Date__c);
        }
        
        ForecastOrders[mo] += c;
        outflowTotal[mo] += c;
        netHedgeTotal[mo] -= c;
        netOperatingFXCashFlow[mo] -= c;
        netFXPositionProtection[mo] -= c;
        netFXPositionObligation[mo] -= c;
        
        //add to total
        ForecastOrders[totalCol] += c;
        outflowTotal[totalCol] += c;
        netHedgeTotal[totalCol] -= c;
        netOperatingFXCashFlow[totalCol] -= c;
        netFXPositionProtection[totalCol] -= c;
        netFXPositionObligation[totalCol] -= c;
    }
    
    public void addToOutflowOther(Input__c i)
    {
        addToOutflowOther(i, system.Today());
    }
    
    //add input to the purchase order list and add to the appropriate lists
    private void addToOutflowOther(Input__c i, Date od)
    {
        Double c;
        integer mo;
        if(currentAccount != null || currentAccount != '')
        {
            User uc = Utility.loggedInUser;//classUser;
            if(i.Custom_Currency__c!= null) {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));  
            }else {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));
            }
            mo = od.monthsBetween(i.Transaction_Date__c);
        }
        else
        {
            User uc = Utility.loggedInUser;//classUser;
            c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));
            mo = od.monthsBetween(i.Transaction_Date__c);
        }
        
        OutflowOther[mo] += c;
        outflowTotal[mo] += c;
        netHedgeTotal[mo] -= c;
        netOperatingFXCashFlow[mo] -= c;
        netFXPositionProtection[mo] -= c;
        netFXPositionObligation[mo] -= c;
        
        //add to total
        OutflowOther[totalCol] += c;
        outflowTotal[totalCol] += c;
        netHedgeTotal[totalCol] -= c;
        netOperatingFXCashFlow[totalCol] -= c;
        netFXPositionProtection[totalCol] -= c;
        netFXPositionObligation[totalCol] -= c;
    }
    
    public void addToTradingReceipts(Input__c i)
    {
        addToTradingReceipts(i, system.Today());
    }
    
    //add input to the purchase order list and add to the appropriate lists
    private void addToTradingReceipts(Input__c i, Date od)
    {
        Double c;
        integer mo;
        if(currentAccount != null || currentAccount != '')
        {
            User uc = Utility.loggedInUser;//classUser;
            if(i.Custom_Currency__c!= null) {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));  
            }else {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));
            }
            mo = od.monthsBetween(i.Transaction_Date__c);
        }
        else
        {
            User uc = Utility.loggedInUser;//classUser;
            if(i.Custom_Currency__c!= null) {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));  
            }else {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));
            }
            mo = od.monthsBetween(i.Transaction_Date__c);
        }
        
        TradingReceipts[mo] += c;
        inflowTotal[mo] += c;
        netHedgeTotal[mo] += c;
        netOperatingFXCashFlow[mo] += c;
        netFXPositionProtection[mo] += c;
        netFXPositionObligation[mo] += c;
        
        //add tot total
        TradingReceipts[totalCol] += c;
        inflowTotal[totalCol] += c;
        netHedgeTotal[totalCol] += c;
        netOperatingFXCashFlow[totalCol] += c;
        netFXPositionProtection[totalCol] += c;
        netFXPositionObligation[totalCol] += c;
    }

    public void addToInflowOther(Input__c i)
    {
        addToInflowOther(i, system.Today());
    }
    
    //add input to the purchase order list and add to the appropriate lists
    private void addToInflowOther(Input__c i, Date od)
    {
        Double c;
        integer mo;
        system.debug('****i.Amount__c>>'+i.Amount__c);
        if(currentAccount != null || currentAccount != '')
        {
            User uc = Utility.loggedInUser;//classUser;
            if(i.Custom_Currency__c!= null) {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));  
            }else {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));
            }
            mo = od.monthsBetween(i.Transaction_Date__c);
        }
        else
        {
            User uc = Utility.loggedInUser;//classUser;
            if(i.Custom_Currency__c!= null) {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));  
            }else {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));
            }
            mo = od.monthsBetween(i.Transaction_Date__c);
        }
        system.debug('****j.Amount__c>>'+c);
        InflowOther[mo] += c;
        inflowTotal[mo] += c;
        netHedgeTotal[mo] += c;
        netOperatingFXCashFlow[mo] += c;
        netFXPositionProtection[mo] += c;
        netFXPositionObligation[mo] += c;
        
        //add to total
        InflowOther[totalCol] += c;
        inflowTotal[totalCol] += c;
        netHedgeTotal[totalCol] += c;
        netOperatingFXCashFlow[totalCol] += c;
        netFXPositionProtection[totalCol] += c;
        netFXPositionObligation[totalCol] += c;
    }

    public void addToForwardWUBS(Forward_Contracts__c i)
    {
        addToForwardWUBS(i, system.Today());
    }
    
    //add input to the purchase order list and add to the appropriate lists
    private void addToForwardWUBS(Forward_Contracts__c i, Date od)
    {
        Double c;
        integer mo;
        if(currentAccount != null || currentAccount != '')
        {
            User uc = Utility.loggedInUser;//classUser;
            if(i.CurrencyIsoCode!= null) {
                c = Double.valueOf(convert(double.valueOf(i.FX_Balance__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));  
            }else {
                c = Double.valueOf(convert(double.valueOf(i.FX_Balance__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));
            }
                mo = od.monthsBetween(i.Maturity_Date__c);
            }
        else
        {
            User uc = Utility.loggedInUser;//classUser;
            if(i.CurrencyIsoCode!= null) {
                c = Double.valueOf(convert(double.valueOf(i.FX_Balance__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));  
            }else {
                c = Double.valueOf(convert(double.valueOf(i.FX_Balance__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));
            }
                mo = od.monthsBetween(i.Maturity_Date__c);
            }
        system.debug('*****Maturity_Date__c 3: '+mo+' > '+i.Maturity_Date__c+'@'+c);
        ForwardContractsWUBS[mo] += c;
        hedgeTotalProtection[mo] += c;
        hedgeTotalObligation[mo] += c;
        hedgeTotal[mo]+=c;
        netHedgeTotal[mo] += c;
        netFXPositionProtection[mo] += c;
        netFXPositionObligation[mo] += c;
        
        //add to total
        ForwardContractsWUBS[totalCol] += c;
        hedgeTotalProtection[totalCol] += c;
        hedgeTotalObligation[totalCol] += c;
        hedgeTotal[totalCol]+=c;
        netHedgeTotal[totalCol] += c;
        netFXPositionProtection[totalCol] += c;
        netFXPositionObligation[totalCol] += c;
    }

    public void addToForwardOther(Input__c i)
    {
        addToForwardOther(i, system.Today());
    }
    
    //add input to the purchase order list and add to the appropriate lists
    private void addToForwardOther(Input__c i, Date od)
    {
        Double c;
        integer mo;
        if(currentAccount != null || currentAccount != '')
        {
            User uc = classUser;
            if(i.Custom_Currency__c!= null) {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));  
            }else {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));
            }
            mo = od.monthsBetween(i.Transaction_Date__c);
        }
        else
        {
            User uc = classUser;
            if(i.Custom_Currency__c!= null) {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));  
            }else {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));
            }
            mo = od.monthsBetween(i.Transaction_Date__c);
        }
        
        ForwardContractsOther[mo] += c;
        hedgeTotalProtection[mo] += c;
        hedgeTotalObligation[mo] += c;
        hedgeTotal[mo]+=c;
        netHedgeTotal[mo] += c;
        netFXPositionProtection[mo] += c;
        netFXPositionObligation[mo] += c;
        
        //add to total
        ForwardContractsOther[totalCol] += c;
        hedgeTotalProtection[totalCol] += c;
        hedgeTotalObligation[totalCol] += c;
        hedgeTotal[totalCol]+=c;
        netHedgeTotal[totalCol] += c;
        netFXPositionProtection[totalCol] += c;
        netFXPositionObligation[totalCol] += c;
    }

    public void addToOptionsWUBSProtection(Input__c i)
    {
        addToOptionsWUBSProtection(i, system.Today());
    }
    
    //add input to the purchase order list and add to the appropriate lists
    private void addToOptionsWUBSProtection(Input__c i, Date od)
    {
        Double c;
        integer mo;
        if(currentAccount != null || currentAccount != '')
        {
            User uc = classUser;
            if(i.Custom_Currency__c!= null) {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));  
            }else {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));
            }
            mo = od.monthsBetween(i.Transaction_Date__c);
        }
        else
        {
            User uc = classUser;
            if(i.Custom_Currency__c!= null) {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));  
            }else {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));
            }
            mo = od.monthsBetween(i.Transaction_Date__c);
        }
        
        OptionsWUBSProtection[mo] += c;
        hedgeTotalProtection[mo] += c;
        netFXPositionProtection[mo] += c;
        hedgeTotal[mo]+=c;
        netHedgeTotal[mo] += c;
        
        //add to total
        OptionsWUBSProtection[totalCol] += c;
        hedgeTotalProtection[totalCol] += c;
        netFXPositionProtection[totalCol] += c;
        hedgeTotal[totalCol]+=c;
        netHedgeTotal[totalCol] += c;
    }

    public void addToOptionsWUBSObligation(Input__c i)
    {
        addToOptionsWUBSObligation(i, system.Today());
    }
    
    //add input to the purchase order list and add to the appropriate lists
    private void addToOptionsWUBSObligation(Input__c i, Date od)
    {
        Double c;
        integer mo;
        if(currentAccount != null || currentAccount != '')
        {
            User uc = classUser;
            if(i.Custom_Currency__c!= null) {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));  
            }else {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));
            }
            mo = od.monthsBetween(i.Transaction_Date__c);
        }
        else
        {
            User uc = classUser;
            if(i.Custom_Currency__c!= null) {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));  
            }else {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));
            }
            mo = od.monthsBetween(i.Transaction_Date__c);
        }
        
        OptionsWUBSObligation[mo] += c;
        hedgeTotalObligation[mo] += c;
        hedgeTotal[mo]+=c;
        netHedgeTotal[mo] += c;
        netFXPositionObligation[mo] += c;
        
        //add to total
        OptionsWUBSObligation[totalCol] += c;
        hedgeTotalObligation[totalCol] += c;
        hedgeTotal[totalCol]+=c;
        netHedgeTotal[totalCol] += c;
        netFXPositionObligation[totalCol] += c;
    }

    public void addToOptionsOtherProtection(Input__c i)
    {
        addToOptionsOtherProtection(i, system.Today());
    }
    
    //add input to the purchase order list and add to the appropriate lists
    private void addToOptionsOtherProtection(Input__c i, Date od)
    {
        Double c;
        integer mo;
        if(currentAccount != null || currentAccount != '')
        {
            User uc = classUser;
            if(i.Custom_Currency__c!= null) {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));  
            }else {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));
            }
            mo = od.monthsBetween(i.Transaction_Date__c);
        }
        else
        {
            User uc = classUser;
            if(i.Custom_Currency__c!= null) {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));  
            }else {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));
            }
            mo = od.monthsBetween(i.Transaction_Date__c);
        }
        
        OptionsOtherProtection[mo] += c;
        hedgeTotalProtection[mo] += c;
        hedgeTotal[mo]+=c;
        netHedgeTotal[mo] += c;
        netFXPositionProtection[mo] += c;
        
        //add to total
        OptionsOtherProtection[totalCol] += c;
        hedgeTotalProtection[totalCol] += c;
        hedgeTotal[totalCol]+=c;
        netHedgeTotal[totalCol] += c;
        netFXPositionProtection[totalCol] += c;
    }

    public void addToOptionsOtherObligation(Input__c i)
    {
        addToOptionsOtherObligation(i, system.Today());
    }
    
    //add input to the purchase order list and add to the appropriate lists
    private void addToOptionsOtherObligation(Input__c i, Date od)
    {
        Double c;
        integer mo;
        if(currentAccount != null || currentAccount != '')
        {
            User uc = classUser;
            if(i.Custom_Currency__c!= null) {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));  
            }else {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));
            }
            mo = od.monthsBetween(i.Transaction_Date__c);
        }
        else
        {
            User uc = classUser;
            if(i.Custom_Currency__c!= null) {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));  
            }else {
                c = Double.valueOf(convert(double.valueOf(i.Amount__c), i.Custom_Currency__c, uc.DefaultCurrencyIsoCode ));
            }
            mo = od.monthsBetween(i.Transaction_Date__c);
        }
        
        OptionsOtherObligation[mo] += c;
        hedgeTotalObligation[mo] += c;
        hedgeTotal[mo]+=c;
        netHedgeTotal[mo] += c;
        netFXPositionObligation[mo] += c;
        
        //add to total
        OptionsOtherObligation[totalCol] += c;
        hedgeTotalObligation[totalCol] += c;
        hedgeTotal[totalCol]+=c;
        netHedgeTotal[totalCol] += c;
        netFXPositionObligation[totalCol] += c;
    }   
    
    private double convert(Double d, String c, String ic)
    {
        if(cur=='Total' &&  c != Utility.userCurrency ){//Userinfo.getDefaultCurrency()
            d = Utility.getSettlementCurrencyAmount(d, c, ic);
        }
        return d;
    }
    
    /* Potentially dangerous. Please review before using. */
    public String getUserCurrency()
    {
    	return Utility.userCurrency;
    	/*
        User u = findUser(currentContact);
        if(classAccount != null)
            return findAccount(currentAccount).CurrencyIsoCode;
        return u.DefaultCurrencyIsoCode;
        */
    }

}