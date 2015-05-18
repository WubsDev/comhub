/**=====================================================================
 * Name: InsightsAndInputTabCtrl
 * Description: Related to InsightsAndInputTab Page
 * Created Date: Jan 31, 2015
 * Created By: Nishant Bansal (JDC)
 *
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/


global without sharing class InsightsAndInputTabCtrl {
  
  public String finishedCollapse{get;set;}
  public boolean hasError {get;set;}
  public String selectedTranscation{get;set;}
  public Input__c input{get;set;}
  public Input__c inputOther{get;set;}
  public String fieldset {get; set;}
  public Id accId {get;set;}
  public String selectedForwardCurrency{get;set;}
  public String selectedCurrencyHolding{get;set;}
  public String selectedCurrencyHistorical{get;set;}
  public Forward_Contracts__c fwdContract{get;set;}
  public List<Historical_Payments__c> historicalPaymentsList{get;set;}
  //HistoricalPaymentsWpr
  public List<Holding_Balance__c> holdingBalancesList{get;set;}
  public NetCashFlowCtrl  NetCashFlow{get;set;}
  public String selectTab{get;set;}
  public  DateTime lastupdate{
  	get{
  		return Utility.lastUpdateMarketDatetime;
  	}
  }
  public InsightsAndInputTabCtrl self{
  	get{
  		return this;
  	}
  	set;
  }
  public String invoiceImageBody{get;set;}
  public String invoiceImageName{get;set;}
  
  public list<SelectOption> lstTransactionType {
  	get{
  		return getTransactionTypes();
  	}
  }

  public List<Forward_Contracts__c> getfwdContractList(){
    if(setCon != null && setCon.getResultSize() > 0){
      return (List<Forward_Contracts__c>) setCon.getRecords();
    }   
    return new List<Forward_Contracts__c>();
  }
  
	public Id currentAccount{
		get{
			return Utility.currentAccount;
		}
	}

  global InsightsAndInputTabCtrl() {
    invoiceImageBody = '';
    invoiceImageName = '';  
    NetCashFlow = new NetCashFlowCtrl();
    if(system.currentPageReference().getParameters().get('currency') != null) {
    	NetCashFlowCtrl.selectedCurrency = System.currentPageReference().getParameters().get('currency');
    }
    input = new Input__c();
    inputOther = new Input__c();
    fwdContract = new Forward_Contracts__c();
    hasError =false;
    selectedForwardCurrency = '';
    finishedCollapse = null;
    //selectedCurrencyHolding = 'All';
    selectedCurrencyHistorical = 'All';
    selectTab=ApexPages.currentPage().getParameters().get('dtab');
    finishedCollapse = ApexPages.currentPage().getParameters().get('fin');
    

    // Get the AccountId of Current LoggedIn User
    User userLoggedIn = Utility.loggedInUser;
    accId = utility.currentAccount;

    // to dispaly the reports
    //generateHistoricalPaymentReportData();
    generateHoldingBalanceReportData();
    generateForwardContractReportData();
	if(ApexPages.hasMessages(ApexPages.Severity.Error)){
		hasError = true;
	}

  }


  public ApexPages.StandardSetController setCon {
    get {
        if(setCon == null) {
            setCon = new ApexPages.StandardSetController(new List<Forward_Contracts__c>());
        }
        return setCon;
    }set;
  }
	//map<String, string> getFieldLabel(String sObjectApiName, String selectedTranscation)
  	// To show the correct field set according to the selected transaction type in "Add Manual Input" Section
  	public map<String, string> LabelMaps{
  		get{
  			//String apiName = Utility.changeTransactionType(selectedTranscation);
  			if(!String.isEmpty(fieldset)){
  				try{
  				return Utility.getFieldLabel('input__c', selectedTranscation);
  				}catch(Exception Ex){
  					
  				}
  			}
  			return new map<String, string>();
  		}
  	}
	public void changeTransactionType() {
    	fieldset = Utility.changeTransactionType(selectedTranscation);
  	}
    @RemoteAction
    global static List<NetCashFlowCtrl.wrapperInvoice> loadOppsWithAcc(String selectedCurrency1, Integer selectedMonth1, Id accId ) {
    	system.debug('************loadOpps : >> '+Utility.currentAccount);
        return NetCashFlowCtrl.loadOpps(selectedCurrency1, selectedMonth1 , accId); 
    }

    @RemoteAction
    global static List<NetCashFlowCtrl.wrapperInvoice> loadOpps(String selectedCurrency1, Integer selectedMonth1 ) {
    	system.debug('************loadOpps : >> '+Utility.currentAccount);
        return NetCashFlowCtrl.loadOpps(selectedCurrency1, selectedMonth1 );
    }

// To create the New Input Record with validation of Transaction Date, Currency Code and Amount
// fields are mandatory
  public void saveInput() {
    try{
            system.debug('save input if:::: '+input);
            hasError = Utility.fieldSetValidation(input,inputOther,fieldset, selectedTranscation, true); 
			
            /*
            if(fieldset != 'Window_Forward_Contract_Other' && fieldset !='Window_Forward_Contract_Other'){
                if(input.Transaction_Date__c == null  ) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Transaction Date Should Not be Blank '));
                    hasError = true;
                }
            }
            if(!Utility.isValidSfdcId(input.Input_Beneficiary__c) ) {
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Supplier/Buyer Should not be Blank'));
                 hasError= true;
            }
            
            /*if(input.Currency_Code__c == null || input.Currency_Code__c == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Currency Should Not be Blank '));
            }* /
            if(input.Amount__c == null || String.valueof(input.Amount__c) == ' ') {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Amount Should Not be Blank '));
                hasError = true;
            }
            */
           
            if(!hasError) {
		    	if(ApexPages.hasMessages(ApexPages.Severity.Error)){
		    		hasError = true;
		    	}
            }            	
            if(!hasError) {
            	List<input__c>inputs = new List<input__c>();
                input.Type__c = selectedTranscation;
                input.input_Type__c = selectedTranscation;
                input.Parent_Account__c = Utility.currentAccount;
                input.User__c = Utility.loggedInUser.id;
                if(fieldSet=='Option_Other'){
					Utility.updateOptionInput(input, inputOther, selectedTranscation, fieldSet);
                	inputs.add(inputOther);
                } 
                inputs.add(input);
                system.debug('*******input:'+input);
                insert inputs;
                if(Utility.updateRefOptionInput(input, inputOther, fieldSet)){
                	//Update the references for inputs. 
                	update inputs;
                }
                
                if(!String.isBlank(invoiceImageName) && !String.isBlank(invoiceImageBody)) {
                    Attachment att = new Attachment();
                    att.ParentId = input.Id;
                                    att.Body = Encodingutil.base64Decode(invoiceImageBody);
                                    att.Name = invoiceImageName;
                    insert att;
                }
                input__c input1 = new input__c();
                input1.Input_Beneficiary__c = input.Input_Beneficiary__c;
                input =input1; 
                if(fieldSet=='Option_Other'){
                	inputOther = new input__c();
                	inputOther.Input_Beneficiary__c = input.Input_Beneficiary__c;
                }
                system.debug('*******input11:'+input);
            }
    }catch(Exception ex) {
        hasError = true;
        if(!ex.getMessage().contains('Duplicate Reference Number and Beneficiar')){
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Unable to save Input. Error Detail :'+ex.getMessage()));
        }else{
                if(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                    //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
                }else{
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Unable to save Input. Error Detail :'+ex.getMessage()));
                }           
        }
        system.debug('exception message:::: '+ ex.getMessage());
    }finally{
    	//There are some error didn't caught by catch
    	if(ApexPages.hasMessages(ApexPages.Severity.Error)){
    		hasError = true;
    	}
        invoiceImageBody = '';
        invoiceImageName = '';    	
    }
  }

// To Cancel the record
  public void cancel() {
    if(input!=null && input.id != null){
    	delete input;
    }else{
	    input = new Input__c();
	    inputOther = new Input__c();
    }
    
  }

// Display the Forward Contract Report Data in Forward Contract Subtab
// Under Insights and Inputs Tab and filter by Currency
  public void generateForwardContractReportData(){
    try{
    	Date todayDate = Datetime.now().date();
        string strQuery = 'SELECT Transaction_Number__c, Start_Date__c, Maturity_Date__c, Settlement_Amount__c, Settlement_Balance__c, Settlement_currency__c';
        strQuery = strQuery + ' ,market_rate__r.Ratio_to_USD__c,Custom_Currency__c, FX_Currency__c, FX_Amount__c, FX_Balance__c FROM Forward_Contracts__c  ';
        if(String.isEmpty(selectedForwardCurrency)){
            strQuery += 'WHERE Maturity_Date__c>=:todayDate AND Account_ID__c =: accId order by Custom_Currency__c';
        }else {
            strQuery += 'WHERE Maturity_Date__c>=:todayDate AND Custom_Currency__c =: selectedForwardCurrency AND Account_ID__c =: accId';
        }        
        setCon = new ApexPages.StandardSetController(Database.query(strQuery));
        setCon.setpagesize(100);
    }catch(Exception Ex){
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error Detail '+Ex.getMessage()));
    }
  }
  public boolean isNonCCTuser{
  	get{
  		return Utility.isNonCCTuser;
  	}
  }

// Display the Holding Balance Report Data in Holding Balance
// Subtab in Insights and Inputs Tab
  public void generateHoldingBalanceReportData(){
  		//Hide data for NonCCTuser
  		if(Utility.isNonCCTuser){
  			return ;
  		}
    //if(selectedCurrencyHolding == 'All') {
        holdingBalancesList = [SELECT Name, Amount__c, CurrencyISOCode,Custom_Currency__c FROM Holding_Balance__c
                                                                       WHERE Account__c =:accId
                                                                       order by Custom_Currency__c ];
        /*}else {
            holdingBalancesList = [SELECT Name, Amount__c FROM Holding_Balance__c
                                                          WHERE Account__c =:accId
                                                          AND CurrencyISOCode =: selectedCurrencyHolding
                                                          order by CurrencyISOCode ];
        }   */
  }

    public List<HoldingBalanceWpr>  getHoldingBalanceReportData(){
        List<HoldingBalanceWpr> HoldingBalanceWprList = new List<HoldingBalanceWpr>();
  		//Hide data for NonCCTuser
  		if(Utility.isNonCCTuser){
  			return HoldingBalanceWprList;
  		}        
        String lastCurrency = '';
      for(Holding_Balance__c holdingBal: [SELECT Name, Amount__c,Custom_Currency__c, CurrencyISOCode FROM Holding_Balance__c
                                                                       WHERE Account__c =:accId
                                                                       order by Custom_Currency__c desc]){
                /*if(lastCurrency != holdingBal.CurrencyISOCode){
                    if(lastCurrency!=''){
                        HoldingBalanceWprList.add(new HoldingBalanceWpr(''));
                    }
                    lastCurrency = holdingBal.CurrencyISOCode;
                    HoldingBalanceWprList.add(new HoldingBalanceWpr(holdingBal.CurrencyISOCode));
                }*/
              HoldingBalanceWprList.add(new HoldingBalanceWpr(holdingBal));
            }
		    //public List<Historical_Payments__c> historicalPaymentsList{get;set;}
		    //HistoricalPaymentsWpr
		    return HoldingBalanceWprList;
    }

// Display the Historical Payment Report Data in Historical Payment Subtab
// Under Insights and Inputs Tab and filter by Currency
    public List<HistoricalPaymentsWpr>  getHistoricalPaymentReportData(){
        List<HistoricalPaymentsWpr> historicalPaymentsList = new List<HistoricalPaymentsWpr>();
        String lastCurrency = '';
      for(Historical_Payments__c histPayL: [SELECT Name, Amount__c, Date__c, MOnth__c, Fiscal_Quarter__c, 
                                            CurrencyISOCode, Year__c 
                                            FROM Historical_Payments__c
                                             WHERE Account_ID__c =:accId
                                             //order by Year__c asc, Fiscal_Quarter__c asc, MOnth__c asc]){
                                             order by CurrencyISOCode, Year__c desc, Fiscal_Quarter__c asc, MOnth__c asc]){
                system.debug('$$$' + histPayL.CurrencyISOCode);
                system.debug('$$$' + lastCurrency);                                 
                if(lastCurrency != histPayL.CurrencyISOCode){
                    if(lastCurrency != ''){
                       // historicalPaymentsList.add(new HistoricalPaymentsWpr(''));
                    }
                    lastCurrency = histPayL.CurrencyISOCode;
                    historicalPaymentsList.add(new HistoricalPaymentsWpr(histPayL.CurrencyISOCode));
                }
              historicalPaymentsList.add(new HistoricalPaymentsWpr(histPayL));
            }
    //public List<Historical_Payments__c> historicalPaymentsList{get;set;}
    //HistoricalPaymentsWpr
    return historicalPaymentsList;
    }

// Used To Get the Currency Code From The CurrencyIsoCode
    public List<SelectOption> getInputCurrency(){
        return Utility.picklistValues('Input__c','Custom_Currency__c', true);
    }

// Used To Get the Currency Code From The CurrencyIsoCode
    public List<SelectOption> getForwardContractCurrency(){
        return Utility.getCurrencyForFC();
    }

// Used in pagination of forward contract report
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }set;
    }

    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }set;
    }

  public Integer pageNumber {
    get {
        return setCon.getPageNumber();
    }set;
  }

  public void first() {
    setCon.first();
  }

  public void last() {
    setCon.last();
  }

    public void previous() {
        setCon.previous();
    }

    public void next() {
        setCon.next();
    }
    public class HistoricalPaymentsWpr{
        public Historical_Payments__c HistoricalWpr {get;set;}
        public String month{            
            get{
                String mon = '';
                try{
                    mon = Utility.getMonthName(Integer.valueOf(HistoricalWpr.MOnth__c));
                }catch(Exception ex){}
                return mon;
            }
        }
        public String currency1{get;set;}
        //public string isCurrencyRow{get;set;}
        public HistoricalPaymentsWpr(String cur){
            currency1 = cur;
            HistoricalWpr = null;
        }
        public HistoricalPaymentsWpr(Historical_Payments__c HistoricalWprP){
            HistoricalWpr = HistoricalWprP;
        }
    }

    public class HoldingBalanceWpr{
        public Holding_Balance__c HoldingWpr {get;set;}
        public String currency1{get;set;}
        public HoldingBalanceWpr(String cur){
            currency1=cur;
            HoldingWpr = null;

        }
        public HoldingBalanceWpr(Holding_Balance__c HoldingWprP){
            HoldingWpr = HoldingWprP;

        }
    }

    // This method used for get Transaction Type picklist value from custom setting (I-148624)
    public List<SelectOption> getTransactionTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Select','Select'));
        for(Transaction_Type__c tt : [SELECT id, name, Option_Index__c From Transaction_Type__c order by Option_Index__c ]){
            options.add(new SelectOption(tt.Name,tt.Name));
        }
        return options;
    }
    public String inputLink{
    	get{
    		return Utility.inputLink;
    	}
    }   

}