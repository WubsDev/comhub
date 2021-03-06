/**=====================================================================
 * Name: InvoicesAndPayments
 * Description: Related to InvoicesAndPayments Page
 * Created Date: Jan 31, 2015
 * Created By: Nishant Bansal (JDC)
 * 
 * Date Modified                Modified By                  Description of the update
 * Updated T-358322, By Ranjeet Singh, Please make Default Invoice Status = Open in Type drop down in "My Invoices" table
 * Updates I-148135,I-148271, By Vivek Ojha , Currency__c --> CurrencyIsoCode
* Updated T-415633 , By Megha Agarwal , searchInvoice
 =====================================================================*/

public without sharing class InvoicesAndPayments {
    
    public boolean hasError {get;set;}
    public Invoice__c invoice{get;set;}
    public List<inputWpr> invoiceList{get;set;}
    public String selectedStatus{get;set;}
    public static String sortOrder{get; set;}
    public string compareField{get;set;}
    public String strQuery {get;set;}
    public Id accId {get;set;}
    public Integer approveMsgCount {get;set;}
    public Set<String> selectedStatusSet;
    public String selectedCurrency{get;set;}
    public String finishedCollapse{get;set;}
    private User userLoggedIn;    
    public Decimal aggregateTotal{get;set;}
    public Decimal hedgedTotal{get;set;}
    public Decimal unHedgedTotal {get;set;}
    public Decimal totalInHomeCurrency {get;set;}
    public String invoiceImageBody{get;set;}
    public String invoiceImageName{get;set;}
    public CustomPaginationController invoicePgCtl{get;set;}
    public String currentUserLocale{
        get{
            String currentUserLocaleVal = UserInfo.getLocale();
            if(currentUserLocaleVal.contains('_')){
                currentUserLocaleVal = currentUserLocaleVal.substring(0, currentUserLocaleVal.indexOf('_'));
            }
            return currentUserLocaleVal;
        }
        set;
    }
    
    public String aggregateTotalFormat{
        get{
            String aggregateTotalVal = aggregateTotal.format();
            if(!aggregateTotalVal.contains(Utility.getDecimalChar)){
                aggregateTotalVal = aggregateTotal.format() + Utility.getDecimalChar+'00';
            }
            return aggregateTotalVal;
        }
        set;
    }
    
    public String hedgedTotalFormat{
        get{
            String hedgedTotalVal = hedgedTotal.format();
            if(!hedgedTotalVal.contains(Utility.getDecimalChar)){
                hedgedTotalVal = hedgedTotal.format() + Utility.getDecimalChar+'00';
            }
            return hedgedTotalVal;
        }
        set;
    }
    
    public String unHedgedTotalFormat{
        get{
            String unHedgedTotalVal = unHedgedTotal.format();
            if(!unHedgedTotalVal.contains(Utility.getDecimalChar)){
                unHedgedTotalVal = unHedgedTotal.format() + Utility.getDecimalChar+'00';
            }
            return unHedgedTotalVal;
        }
        set;
    }
    
    public String unHedgedTotalSettlementFormat{
        get{
            String unHedgedTotalSettlementVal = unHedgedTotalSettlement.format();
            if(!unHedgedTotalSettlementVal.contains(Utility.getDecimalChar)){
                unHedgedTotalSettlementVal = unHedgedTotalSettlement.format() + Utility.getDecimalChar+'00';
            }
            return unHedgedTotalSettlementVal;
        }
        set;
    }
    
    //MAP
    public String userLanguage{get;set;}
    
    public List<inputWpr> invoicePgCtl_genericList{
    	get{
    		return (List<inputWpr>)invoicePgCtl.genericList;
    	}
    	set;
    }
    public Decimal aggregateTotalSettlement{
        get{
            return Utility.getSettlementCurrencyAmount(aggregateTotal, selectedCurrency, Utility.userCurrency);
        }
    }
    public String aggregateTotalSettlementFormat{
        get{
            String aggregateTotalSettlementVal = aggregateTotalSettlement.format();
            if(!aggregateTotalSettlementVal.contains(Utility.getDecimalChar)){
                aggregateTotalSettlementVal = aggregateTotalSettlement.format() + Utility.getDecimalChar+'00';
            }
            return aggregateTotalSettlementVal;
        }
        set;
    }
    public Decimal hedgedTotalSettlement{
        get{
            return Utility.getSettlementCurrencyAmount(hedgedTotal, selectedCurrency, Utility.userCurrency);
        }
    }
    public Decimal unHedgedTotalSettlement {
        get{
            return Utility.getSettlementCurrencyAmount(unHedgedTotal, selectedCurrency, Utility.userCurrency);
        }
    }    
    public DateTime getlastUpdated() {
    	return Utility.lastUpdateMarketDatetime;
    }    
    //added by Vivek for I-148271
    public List<Selectoption> statusForFilter{get;set;}
    
    private string beneficaryId{get;set;}
    public String selectedForwardContractCurrency{get;set;}
    public String userCurrency{get;set;}
    public Decimal conversionRate{get;set;}
    
    public InvoicesAndPayments() { 
                
        //MAP
        userLanguage = UserInfo.getLanguage();
        if(userLanguage.trim() == 'fr'|| userLanguage.trim() == 'it'){
            userLanguage = '_'+userLanguage;
        }
        else{
            userLanguage = '';
        }
                
        invoice = new Invoice__c();
    //    searchInvoice = new Invoice__c(Status__c = 'All');
        invoiceImageBody = '';
        invoiceImageName = '';
        conversionRate = 0.0;       
        beneficaryId = ApexPages.currentPage().getParameters().get('beneficaryId');
        finishedCollapse = null;
        finishedCollapse = ApexPages.currentPage().getParameters().get('fin');
        if (beneficaryId != null) {
            invoice.Beneficiary_Contact__c = beneficaryId;
        }
        
        statusForFilter = getPicklistValues('Invoice__c','Status__c');
        compareField = ApexPages.currentPage().getParameters().get('compare');
        sortOrder = ApexPages.currentPage().getParameters().get('orderType');
        
        //Updated T-358322, By Ranjeet Singh, Please make Default Invoice Status = Open in Type drop down in "My Invoices" table
        selectedStatus = 'All';
        selectedCurrency = 'ShowAll';
        
        // To get the AccountId of logged in user
        userLoggedIn = Utility.loggedInUser;
        accId = Utility.currentAccount;    
        userCurrency = Utility.userCurrency;
    //    Market_Rate__c lastUpdated = Utility.lastUpdatedMarketRate();
        invoicePgCtl = new CustomPaginationController(Integer.valueOf(System.Label.InvoiceViewPagesize), new List<inputWpr>(), new List<List<inputWpr>>() );
        invoicePgCtl.sortField = 'Name';
        sortList();
    }
    
// Get the Currency List From Current LoggedIn User Account    
    public list<Selectoption> getCurrencyList() {
        
        list<Selectoption> lstCurrency = new list<Selectoption>();
        lstCurrency.add(new Selectoption('ShowAll',Label.CM_Community_Text_FieldFilter_Currency_Item_ShowAll));
        Set<String> currencySet = new Set<String>();
        for(AggregateResult invoiceRec: [SELECT count(Id), Custom_Currency__c 
                                         FROM Invoice__c 
                                         WHERE Account__c  =:accId
                                         group by  Custom_Currency__c]) {
            String currencyCode = (String) invoiceRec.get('Custom_Currency__c');
            //Fix currencyCode should not be null: Fixed Error.
            if(!String.isEmpty(currencyCode)&& !currencySet.contains(currencyCode)) {
            currencySet.add(currencyCode);
            lstCurrency.add(new Selectoption(currencyCode,currencyCode));
            }
          }
          return lstCurrency;
    }
    
  
    private List<inputWpr> getInvoiceData(String sortField, String sortDir, List<invoice__c>invoices){
    	List<inputWpr> wprs = new List<inputWpr>();
    	for(invoice__c invoice: invoices){
    		wprs.add(new inputWpr(sortField, sortDir,  invoice));
    	}
    	return wprs;
    }
    
    public void searchInvoice(){
        String selectCurrency = '';
        selectedStatusSet = new Set<String>();
        
        strQuery = 'Select id,Name, Due_Date__c, Status__c,Amount__c,Beneficiary_Contact__c,Custom_Currency__c, OwnerId, Input_Beneficiary__c,Input_Beneficiary__r.name FROM Invoice__c' ;
       
        if (selectedStatus == 'All') {
            selectedStatusSet.add('Pending Approval (Open)');
            selectedStatusSet.add('Approved');
            selectedStatusSet.add('Void');
            selectedStatusSet.add('Paid');
        } else {
            selectedStatusSet.add(selectedStatus);
        }
                
        if( String.isBlank(compareField)) { 
          compareField = 'Name';
        }
                
        if( String.isBlank(sortOrder)) {
          sortOrder = 'desc';
        }
        if(selectedCurrency != 'ShowAll'){
            selectCurrency = ' AND Custom_Currency__c =: selectedCurrency ';
        }
        
        strQuery +=' WHERE Status__c In :selectedStatusSet AND Account__c = :accId '+selectCurrency+' limit 40000';//+ ' order By '+compareField + ' ' + sortOrder; 
        List<inputWpr> lstsort = getInvoiceData(invoicePgCtl.SortField, invoicePgCtl.sortDir,Database.query(strQuery));
        lstsort.sort();
        invoicePgCtl.loadData( lstsort);
    }
    
    public void toggleSort() {
		system.debug('***********>>'+invoicePgCtl.sortDir+invoicePgCtl.sortField);
        // simply toggle the direction
        invoicePgCtl.toggle();
        // run the query again
        searchInvoice(); 
        populateAmountField();
	}
    
// To search according to the filter and sort the list of record in "MY INVOICES" Section
    public void sortList(){ 
    	searchInvoice();
        populateAmountField();
    }  
    
    
// Desc : To populate Aggregate, Hedged & Un-Hedged Total In Insights Section    
    public Pagereference populateAmountField() {
        aggregateTotal = 0.0; 
        hedgedTotal = 0.0; 
        unHedgedTotal = 0.0; 
        totalInHomeCurrency = 0.0;
        Decimal hedgeAccount = 0.0;
        Decimal marketRate = 0.0;
        Decimal holdingBalance = 0.0;
        conversionRate = 0.0;
        if(selectedCurrency == null ||  selectedCurrency == '' ||  selectedCurrency == 'ShowAll') {
            return null;
        } 
        //conversionRate = [SELECT conversionrate FROM currencytype WHERE isocode =: selectedCurrency LIMIT 1].conversionRate;
        // Get Market rates for the selected currency
        for(Market_Rate__c rate : [SELECT Id, Currency_Code__c, Currency_Value__c 
                                   FROM Market_Rate__c
                                   WHERE Currency_Code__c =:selectedCurrency]) {
            conversionRate = rate.Currency_Value__c;
        }
        for(AggregateResult aggregateResult : [SELECT sum(FX_Balance__c) settlementAmount,
                                               avg(Base_USD__c) marketRate
                                               FROM Forward_Contracts__c 
                                               WHERE Account_ID__c =: accId
                                               AND Custom_Currency__c =: selectedCurrency]) {
                                                
            if(aggregateResult.get('settlementAmount') != null)
            hedgeAccount = (Decimal)    aggregateResult.get('settlementAmount');
            if(aggregateResult.get('marketRate') != null)
            marketRate = (Decimal)    aggregateResult.get('marketRate');
            
        } 
        //conversionRate = marketRate;
        for(AggregateResult aggregateResult : [SELECT sum(Amount__c) holdingBalance 
                                               FROM Holding_Balance__c 
                                               WHERE Account__c =: accId
                                               AND Custom_Currency__c =: selectedCurrency]) {
                                                    
           if(aggregateResult.get('holdingBalance') != null)
           holdingBalance = (Decimal)   aggregateResult.get('holdingBalance');                                                                  
         }
         hedgedTotal = hedgeAccount + holdingBalance;
         for(List<inputWpr> lstWpr: (List<List<inputWpr>>)invoicePgCtl.fullGenericList){
	         for(inputWpr invoiceRec: lstWpr){
	            if(invoiceRec.invoice.Custom_Currency__c == selectedCurrency && invoiceRec.invoice.Amount__c != null) {
	                aggregateTotal += invoiceRec.invoice.Amount__c;
	            }
	         }
         }
         if(conversionRate==0 || conversionRate<0){
         	//Conversion market not found for selected currency. 
         	totalInHomeCurrency = aggregateTotal;
         }else{
         	totalInHomeCurrency = aggregateTotal / conversionRate;
         }
         unHedgedTotal = aggregateTotal - hedgedTotal;
         return null;
    }    
    
// Update the status to Approved by clicking of button "Approve For Payment" 
    public void approvePayment(){  
        List<Invoice__c> approvedInvoiceList = new List<Invoice__c>();      
        List<Id> invoiceIdList = new List<Id>();
        approveMsgCount = 0 ;
        for(inputWpr invWrap : invoiceList) {
            if(invWrap.isSelected == true){
                invoiceIdList.add(invWrap.invoice.Id);
            }
        }
        system.debug('invoiceIdList+++++++++++++++++++'+invoiceIdList);
        for(Invoice__c inv : [Select id, Status__c FROM Invoice__c WHERE id in: invoiceIdList]) {
            inv.Status__c = 'Approved';
            approveMsgCount++;
            approvedInvoiceList.add(inv);
        }
        if(approvedInvoiceList.size()>0) {
            try{
                update approvedInvoiceList;
                //sortList();
            } catch(Exception Ex) {
                approveMsgCount = 0;
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CM_Alert_UnableToUpdateInvoice + ' ' + Ex));
            }
        }
        else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select the records'));
        }
    }
    
// To add the new Input Beneficiary     
    public Pagereference AddInputBeneficiary(){
    	String SitePath = Site.getPathPrefix();
        //Pagereference pgRef = new Pagereference('/cashmanagement/apex/AddInputBeneficiary?sfdc.tabName=01rS000000095lA');
        Pagereference pgRef = new Pagereference(SitePath+'/apex/AddInputBeneficiary');
        pgRef.setRedirect(true);
        return pgRef;
    }


// To create the New Invoice Record with validation that all fields are mandatory    
    public pagereference saveInvoice() {
        try{
            hasError = false;
            invoice.Custom_Currency__c = selectedForwardContractCurrency;
            if(invoice.Name == null || invoice.Name == '') {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CM_Validation_Input_InvoiceNumberShouldNotBeBlank));
                hasError = true;                
            }   
            if(invoice.Status__c == null || invoice.Status__c == ''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CM_Validation_Input_FieldStatusShouldNotBeBlank));
                hasError = true;                
            }       
            /*if(invoice.Custom_Currency__c == null) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Currency Should Not be Blank '));
                hasError = true;
            }*/
            if(invoice.Due_Date__c == null) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CM_Validation_Input_FieldPaymentDateShouldNotBeBlank));
                hasError = true;
            }
            if(invoice.Amount__c == null ) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CM_Validation_Input_FieldAmountShouldNotBeBlank));
                hasError = true;
            }           
            if(invoice.Input_Beneficiary__c== null ) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CM_Validation_Input_FieldSupplierShouldNotBeBlank));
                hasError = true;
            }    
            if(!hasError) {
                invoice.Account__c= accId;
                insert invoice;
                system.debug('invoiceImagename >>> '+invoiceImageName);
                system.debug('invoiceImageBody >>> '+invoiceImageBody);
                // insert invoice attachments 
                if(!String.isBlank(invoiceImageName) && !String.isBlank(invoiceImageBody)) {
                    Attachment att = new Attachment();
                    att.ParentId = invoice.Id;
                                    att.Body = Encodingutil.base64Decode(invoiceImageBody);
                                    att.Name = invoiceImageName;
                    insert att;
                }
                
                //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Invoice record has been saved successfully.'));
                //pagereference pageref = new pagereference('/apex/AddAnotherInvoice'); 
                //return pageRef;
                
                invoice = new Invoice__c();
        
                        if (beneficaryId != null) {
                            invoice.Beneficiary_Contact__c = beneficaryId;
                        }
            }
            //else{
                return null;
            //}
        } catch(Exception ex){
            hasError = true;
            if(ex.getMessage().contains('Duplicate Invoice Number and Beneficiary Found')){
                //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Unable to save Invoice. Duplicate Invoice Number and Beneficiary Found'));
            } else{
                if(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                    //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
                }else{
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Unable to save Invoice. Error Detail :'+ex.getMessage()));
                }
            }
            return null;
        }
        finally {   
            invoiceImageBody = '';
            invoiceImageName = '';
        }
    }
       
// To Cancel the record    
	public void cancel() {
	    if(invoice.id != null)
	    delete invoice;
	}
    
     public  list<Selectoption> getPicklistValues(String ObjectApi_name,String Field_name){ 

        list<Selectoption> lstStatus = new list<Selectoption>();
        lstStatus.add(new Selectoption('All', Label.CM_Community_Text_FieldFilter_Status_Item_All));
        
        List<String> lstPickvals=new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
             //  T-415633
            lstStatus.add(new Selectoption(a.getValue(),a.getLabel()));
        }
        
          return lstStatus;
    }
    
    public List<SelectOption> getForwardContractCurrency(){
        selectedForwardContractCurrency = '';
       List<SelectOption> currList =  picklistValues('Invoice__c','Custom_Currency__c');
       if(currList.size() > 0){
        selectedForwardContractCurrency = currList[0].getValue();
       }
       return currList;
    }
  
	public List<SelectOption> picklistValues(String ObjectAPI , String fieldName){
	    List<SelectOption> lstPickvals=new List<SelectOption>();
	    Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectAPI);
	    Sobject Object_name = targetType.newSObject();
	    Schema.sObjectType sobject_type = Object_name.getSObjectType();
	    Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
	    Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); 
	    List<Schema.PicklistEntry> pick_list_values = field_map.get(fieldName).getDescribe().getPickListValues(); 
        
	    for (Schema.PicklistEntry a : pick_list_values) {
	        lstPickvals.add(new SelectOption(a.getValue(),a.getValue()));
	    }
	    return lstPickvals;
	}

	public String inputLink{
		get{
			return Utility.inputLink;
		}
	}    
  
}