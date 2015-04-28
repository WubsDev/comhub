public without sharing class portalCashflowReportClone {
  public static Integer selectedMonth{get;set;}     
  public DateTime dt       {get;set;}
  public String reportingDate {get;set;}
  public MAP<String,MAP<Integer,double>> reportMap  {get;set;}
  public MAP<String,MAP<Integer,double>> USDreportMap  {get;set;} 
  public MAP<Integer, String> monthMap     {get;set;}
  public MAP<String, Integer> currencyMap   {get;set;}
  public LIST<String> cMap     {get;set;}
  public boolean showTabs      {get;set;}
  public boolean contactFound    {get;set;}
  public boolean accountFound    {get;set;}
  public boolean noCurrencies    {get;set;}
  public boolean isSuperUser     {get;set;}
  public boolean isAccountPage  {get;set;}
  
  public User u{get;set;}
  
  public date td;
  
  public String currentReport    {get;set;}
  public String currentContact  {get;set;}
  public String currentAccount  {get;set;}
  public String currency2      {get;set;}
  public String theCurrency    {get;set;}

  public String latestUpdatedFromWarehouse  {get;set;}

  
  //constructor
  public portalCashflowReportClone()
  {
  	try{
	    isAccountPage = false;
	    isSuperUser = false;
	    noCurrencies = false;
	    currency2 = 'Total';
	    
	    currentContact = findContact();
	    if(currentContact == 'notFound')
	    {
	      contactFound = false;
	    }else
	    {
	      contactFound = true;
	    }
	    system.debug('THE CONTACT THAT HAS BEEN FOUND = '+currentContact);
	    showTabs=false;
	
	    reportingDate = System.now().format('dd/MM/yyyy h:mm:ssa z');//tz.getDisplayName() + tz.getID() + tz.toString();
	    currentAccount = apexpages.currentPage().getParameters().get('aId');
	    theCurrency = apexpages.currentPage().getParameters().get('currency');
	    if(apexpages.currentPage().getParameters().get('dateRange')!=null){
	    	selectedMonth = Integer.valueof(apexpages.currentPage().getParameters().get('dateRange'));
	    }
	    system.debug(apexpages.currentPage().getParameters()+'theCurrency >>> above >>> '+theCurrency);
	    if(theCurrency == null && theCurrency == '') {
	    	theCurrency = 'Total';
	    }
	    system.debug('theCurrency >>> here >>> '+theCurrency);
	    if(currentAccount == null)
	    {
	      accountFound = false;
	      isAccountPage = false;
	    }
	      
	    else
	    {
	      isAccountPage = true;
	      accountFound = true;
	      currentAccount = currentAccount.left(15);
	    }
	      
	    dt = system.now().addYears(1);//dateTime.now();
	    populateCurrencies();
	    
	    String errorMessage = '';
	    if(!accountFound){
    		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Unable to load report as Associated account not found.'));
    		showTabs = false;
    	}
    	if(String.isEmpty(theCurrency)){
    		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Unable to load report as Currency not selected.'));
    		showTabs = false;
    	}
    	if(selectedMonth==null || selectedMonth<1 ){
    		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Unable to load report as Month-Range not selected.'));
    		showTabs = false;
    	}
		/*
		//Commented by Ranjeet as no reference found on report page
	    User user = findUser2(currentContact);
	    if (user!=null && user.Contact!=null && user.Contact.AccountId != null) {
	      latestUpdatedFromWarehouse = formatDate(queryLatestInput(user.Contact.AccountId));
	    } else if (currentAccount != null) {
	      latestUpdatedFromWarehouse = formatDate(queryLatestInput(currentAccount));
	    }*/
  	}catch(Exception ex){
  		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Unable to load report. Error Detail : '+ex.getmessage() ));
  	}
  }
  
  
  
  public string findContact()
  {
    
    String cc = 'notFound';
    cc = apexpages.currentPage().getParameters().get('cId');
    system.debug('THE CONTACT THAT HAS BEEN DRAGGED FROM = '+cc);
    if(cc == null)
    {
      User u = findUser();
      cc = u.ContactId;
      system.debug('cc>>>> ' + cc);
      //cc = '003S000000ryEqN';
      system.debug('THE CONTACT THAT HAS BEEN DRAGGED FROM = '+cc);
    }
    if(cc == null) 
       return cc;
    
    return cc.left(15);
  }
  
  public User loggedInUser;
  public User findUser()
  {
    if(loggedInUser == null){
	    loggedInUser = [Select   Id, ContactId, DefaultCurrencyIsoCode, Name, Contact.AccountId, IsPrmSuperUser
	          FROM  User
	          WHERE  Id =: UserInfo.getUserId() LIMIT 1];
    }
    return loggedInUser;
    
  }
  
  
  
  public User findUser2(String con)
  {
    User u = [Select   Id, ContactId, DefaultCurrencyIsoCode, Name, Contact.AccountId, IsPrmSuperUser 
          FROM  User
          WHERE  ContactId =: con LIMIT 1];
    
    return u;
  }
  
  public Account findAccount()
  {
    Account a = [Select   Id, Name
           FROM    Account
           WHERE    Id =: currentAccount LIMIT 1];
    
    return a;
  }
  
  /* Queries the account if it exists */
  /*public Account findAccount(Account account)
  {
    Account a = [Select   Id, Name
          FROM  Account
          WHERE  Id =: account LIMIT 1];
    
    return a;
  }*/
  
  public String getUserCurrency()
  {
    User u2;
    if(currentAccount == null)
      u2 = findUser2(currentContact);//findUser();
    else
      u2 = findUser();
    return u2.DefaultCurrencyIsoCode;
  }
  
  // TO DO: Revise this method call
  public String getUserName()
  {
    User u3 = findUser();
    String conId = apexpages.currentPage().getParameters().get('cId');
    System.Debug('@ getUSERNAME Method. currentAccount variable is : ' + currentAccount);
    if(currentAccount == null && conId == null)
      return u3.Name;
    else if(conId != null)
    {
      conId = conId.left(15);
      return findUser2(conId).Name;
    }
    else if(!isAccountPage && isSuperUser)
      return u3.Name;
    return findAccount().Name;
  }

  // find the latest input record loaded by WUBS Data Warehouse.
  public DateTime queryLatestInput(String accountId) {
    Input__c input;
    try {
      //ar = [Select MAX(CreatedDate) From Input__c Where Parent_Account__c =: accountId Group BY CreatedDate LIMIT 1];
      system.debug('accountId >>> '+accountId);
      input = [Select LastModifiedDate From Input__c 
           Where Parent_Account__c =: accountId 
           AND (Input_Type__c = 'Fixed Forward Contract - WUBS' OR Type__c = 'Forward Contract - WUBS') 
           ORDER BY LastModifiedDate DESC Limit 1 ];
      return input.LastModifiedDate;
    } catch (Exception e) {
      System.debug('Error getting the latest updated record = '+ e.getMessage());
    }
    return null;
  }

  private String formatDate(DateTime dt) {
    String formattedDate = '';
    if (dt != null) {
          formattedDate = dt.format('dd/MM/yyyy');
          formattedDate += ' at ';
          formattedDate += dt.format('h:mm a z');
        }

        return formattedDate;
  }
  
  //Find out what currencies need to be 
  public void populateCurrencies()
  {
    currencyMap = new MAP<String,Integer>();
    cMap = new LIST<String>();
    LIST<Input__c> qList = new LIST<Input__c>();
    Integer t = 2;
    cMap.add('Total');
    User u4 = findUser2(currentContact);
    if (u4.IsPrmSuperUser)
    {
      isSuperUser = true;
      currentAccount = u4.Contact.AccountId;
      accountFound = true;
    }
    /*
    //Commented by ranjeet for poputaion now hapning only at currency level.
    if(contactFound && !accountFound)
    {  //modified query as variable 'dt' not being assigned
      qList = [SELECT   Id, Name, Amount__c, Type__c, Transaction_Date__c, CurrencyIsoCode, Paid__c,
            ContactId__c, AccountId__c, Parent_Account__c, Currency_Code__c 
            FROM   Input__c 
            WHERE  Parent_Account__c =: u4.Contact.AccountId 
            AND ((Transaction_Date__c <: date.valueOf(dt) AND Transaction_Date__c >: date.valueOf(system.now())) OR (Paid__c = false AND Transaction_Date__c <: date.valueOf(dt))) // AND Parent_Account__c =: u4.Contact.AccountId]; changed from 'AND' to 'OR'
            ORDER BY CurrencyIsoCode ASC];
    }
    
    if(accountFound)
    {
      qList = [SELECT   Id, Name, Amount__c, Type__c, Transaction_Date__c, CurrencyIsoCode, Paid__c, 
            ContactId__c, AccountId__c, Parent_Account__c, Currency_Code__c
            FROM   Input__c 
            WHERE  Parent_Account__c =: currentAccount
            AND ((Transaction_Date__c <: date.valueOf(dt) AND Transaction_Date__c >: date.valueOf(system.now())) OR (Paid__c = false AND Transaction_Date__c <: date.valueOf(dt))) // AND Parent_Account__c =: u4.Contact.AccountId]; changed from 'AND' to 'OR'
            ORDER BY CurrencyIsoCode ASC];
    }
    if(qList.isEmpty())
      noCurrencies = true;
    else
      noCurrencies = false;
    system.debug('****noCurrencies, accountFound:'+noCurrencies+','+accountFound+'  >> '+qList);
    
    for(Input__c ci:qList)
    {
      if(!currencyMap.containsKey(ci.CurrencyIsoCode))
      {
        currencyMap.put(ci.CurrencyIsoCode, t);
        cMap.add(ci.CurrencyIsoCode);
        t=t+1;
      }
      showTabs=true;
    }
    */
	//added condition by Ranjeet
    if(accountFound)
    {
    	showTabs=true;
    	noCurrencies = false;
    }
    system.debug('****showTabs:'+showTabs+' >> '+cMap );
    currentReport = cMap[0];
  }

  
  //gets the current currency from the page and sets it to be used by the component
  public void currentCurrency()
  {
    currency2 = apexPages.currentPage().getParameters().get('theCurrency');
    reportingDate = System.now().format('dd/MM/yyyy h:mm:ssa z');
    system.debug('THIS IS THE CALLED CURRENCY: '+currency2);
  }
  
  public Component.Apex.TabPanel getTabbedView()
  {
    Component.Apex.TabPanel panel = new Component.Apex.TabPanel(
    switchType = 'client',
    title = 'Summary Reports');
    
    //Add New Tab
    Component.Apex.Tab acctTab = new Component.Apex.Tab();
    acctTab.label = System.Label.Total;  //'TOTAL';
    panel.childComponents.add(acctTab);
    Component.Apex.OutputText oppText = new Component.Apex.OutputText(escape = false);
    oppText.value = '<c:portalCashFlowReport inTitle="Total" con="003n000000289kE"/>';
    panel.childComponents.get(panel.childComponents.size() -1 ).childComponents.add(oppText);
  
    /*
    //Add New Tab
    acctTab = new Component.Apex.Tab();
    acctTab.label = 'AUD';
    panel.childComponents.add(acctTab);
    Component.Apex.pageBlock oppTextt = new Component.Apex.pageBlock();
    oppTextt.title = 'My Content';
    oppTextt.mode='edit';
    panel.childComponents.get(panel.childComponents.size() -1 ).childComponents.add(oppTextt);
    */

    return panel;
  }
  
  public pageReference disclaimerLink()
  {
    String host = ApexPages.currentPage().getHeaders().get('Host');
    //String host = Site.getCurrentSiteUrl();
    System.debug(ApexPages.currentPage().getHeaders().get('Host'));
    System.debug(Site.getCurrentSiteUrl());
    String siteHost = Site.getCurrentSiteUrl();
    pageReference pr;
    if(siteHost == null)
      pr = new pageReference('https://' + host + '/apex/Disclaimer');
    else
      pr = new pageReference(siteHost + 'apex/Tradeforecaster_home');
    pr.setRedirect(true);
    return pr;
  }
  
  public pageReference exportToCSV()
  {
    String host = ApexPages.currentPage().getHeaders().get('Host');
    //String host = Site.getCurrentSiteUrl();
    System.debug(ApexPages.currentPage().getHeaders().get('Host'));
    System.debug(Site.getCurrentSiteUrl());
    String siteHost = Site.getCurrentSiteUrl();
    pageReference pr;
    String accountIdExcel = apexpages.currentPage().getParameters().get('aId');
    String contactIdExcel = apexpages.currentPage().getParameters().get('cId');
    if(siteHost == null)
    {
      if(accountIdExcel != null)
      {
        pr = new pageReference('https://' + host + '/apex/portalCSVReport');
        pr.getParameters().put('aId',accountIdExcel);
      }
      else
      {
        pr = new pageReference('https://' + host + '/apex/portalCSVReport');
        pr.getParameters().put('cId',contactIdExcel);
      }  
    }
    else
      pr = new pageReference(siteHost + 'apex/portalCSVReport');
    pr.setRedirect(true);
    return pr;
  }

}