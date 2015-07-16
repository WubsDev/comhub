/**=====================================================================
 * Name: ManageCashInputsCtl
 * 	Copy code from FX Management tool to view all Inputs
 * Created Date: March 03, 2015
 * Created By: Ranjeet Singh (JDC)
 *  
 * Date Modified                Modified By                  Description of the update
 
 =====================================================================*/
public without sharing class ManageCashInputsCtl {
    //******Attributes****////
    public Input__c Record {get; set;}
    
    public LIST<Input__c> inputSOQL {get; set;}
    public MAP<Id,Input__c> inputMap;
    public List<selectoption> options 	{get; set;}//dynamic list of available currencies
    public List<selectoption> benes 	{get; set;}//dynamic list of available currencies
    public Input_Beneficiary__c ib 	{get; set;}
    public MAP<String, Double> mrMap;//Map of Market Rates
    public String lastUpdatedString {get; set;}
	public String selectedCurrency{get;set;}
    public Input__c input{get;set;}
    
    public string currentContact 	{get; set;}
    public string message 		{get; set;}//Used to deliver messages to the screen
    public string Mode 			{get; set;} // sets rendering on the page
    public string lineId 		{get; set;} // used for deleting and editing records
    public boolean ShowInput 	{get; set;} // rendering on page
    public boolean newDisabled 	{get; set;} // rendering on page
    
    public boolean newBene 		{get; set;} // rendering on page
    public boolean disableBene 	{get;set;}
    
    public User UserAccount 	{get; set;} // holds the user account information ready for use
    
    public String soql 	{get;set;}
    public String soql2 {get;set;}
    
    public Double optionProtection 	{get;set;}//used as a temporary storage for currency when option is selected
    public Double optionObligation 	{get;set;}//used as a temporary storage for currency when option is selected

    public String userLanguageKey	{get;set;}
    
    public CustomPaginationController incomingPgCtl{get;set;}
    //public PaginationController outgoingPgCtl{get;set;}
    public CustomPaginationController hedgingPgCtl{get;set;}
    //public PaginationController invoicePgCtl{get;set;}
    //New pagenator controller
    public CustomPaginationController outgoingPgCtlCTM{get;set;}
    
    public List<inputWpr> outgoingPgCtlCTM_genericList{
    	get{
    		return (List<inputWpr>)outgoingPgCtlCTM.genericList;
    	}
    	set;
    }
    public List<inputWpr> hedgingPgCtl_genericList{
    	get{
    		return (List<inputWpr>)hedgingPgCtl.genericList;
    	}
    	set;
    }
    public List<inputWpr> incomingPgCtl_genericList{
    	get{
    		return (List<inputWpr>)incomingPgCtl.genericList;
    	}
    	set;
    }
    public String userCurrency{
    	get{
    		if(String.isEmpty(userCurrency)){
    			userCurrency = Utility.userCurrency;
    		}
    		return userCurrency;
    	}
    	set;
    }
    
    public ManageCashInputsCtl() {
    	try{
    		input = new Input__c();
    		selectedCurrency = '';
	        currentContact = Utility.loggedInUser.ContactId;
	        newBene = false;
	        message ='';
	        newDisabled = true;
	        disableBene = false;
	        Record = new Input__c();
//	        Outgoing = new List<inputWpr>();
	        //Invoices = new List<inputWpr>();
	        Mode = '';
	        ShowInput = false;
	        UserAccount =  [    Select  Id, Name, ContactId, Contact.AccountId 
	                            from    User 
	                            where   ContactId =: currentContact Limit 1];
	        System.debug('The userAccount variable is: ' + UserAccount);
	        System.debug('The userAccount contact account to be used in variable is: ' + UserAccount.Contact.AccountId);
	        Record.User__c = Utility.loggedInUser.id;
	        userLanguageKey = Utility.loggedInUser.LanguageLocaleKey;
	        System.debug('@Input CONSTRUCTOR userLanguageKey: ' + userLanguageKey);
	
			system.debug('*******Error 1:');
		    incomingPgCtl		= new CustomPaginationController(Integer.valueOf(System.Label.InputViewPagesize), new List<inputWpr>(), new List<List<inputWpr>>() );
		    hedgingPgCtl		= new CustomPaginationController(Integer.valueOf(System.Label.InputViewPagesize), new List<inputWpr>(), new List<List<inputWpr>>());
		    outgoingPgCtlCTM 	= new CustomPaginationController(Integer.valueOf(System.Label.InputViewPagesize), new List<inputWpr>(), new List<List<inputWpr>>());
			system.debug('*******Error 2:');
			
	        updateMarketRate();
	        PopulateLists();
    	}catch(Exception Ex){
    		//ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Unable to load input page. Error Detail :'+ex.getMessage()));
    		message = 'Unable to load input page. Error Detail :'+ex.getMessage();
    	}
    }
    
    public String getTranslatedText() {
    	Schema.DescribeFieldResult F = Input__c.Input_Type__c.getDescribe(); 
		List<Schema.PicklistEntry> P = F.getPicklistValues(); 
		Map<String, String> mapMyFieldTranslation = new Map<String, String>(); 

		for (Schema.PicklistEntry e : P) {
		    mapMyFieldTranslation.put(e.value, e.label); 
		}

		String result = mapMyFieldTranslation.get(record.Input_Type__c);
		return result;
    }

    public string findContact()
    {
        String cc = 'notFound';
        cc = apexpages.currentPage().getParameters().get('cId');
        system.debug('THE CONTACT THAT HAS BEEN DRAGGED FROM = '+cc);
        if(cc == null) {
            cc = Utility.loggedInUser.ContactId;
            system.debug('THE CONTACT THAT HAS BEEN DRAGGED FROM = '+cc);
        }
        return cc.left(15);
    }
    
    
   
    /*  Checks to see if the input record is a 'WUBS' type.
        Will default the beneficiary to WUBS if record matches  */
    private void checkWUBSRecord() {
        if(Record.Input_Type__c.containsIgnoreCase('wubs')) {
            disableBene = true;
            LIST<Input_Beneficiary__c> ibs = new LIST<Input_Beneficiary__c>();
            ibs = [SELECT Id, Name FROM Input_Beneficiary__c WHERE Name = 'WUBS' limit 990];//Ranjeet added limit Beneficiary, SFDC dropdown limit
            if(ibs.size()>0) {
                Boolean beneFound = false;
                for(selectOption so : benes) {
                    if(so.getLabel() == 'WUBS')
                        beneFound = true;
                }
                if(!beneFound)
                    benes.add(new selectOption(ibs[0].Id, ibs[0].Name));
                Record.Input_Beneficiary__c = ibs[0].Id;
            } else {
                Input_Beneficiary__c wubsIB = new Input_Beneficiary__c(Name = 'WUBS');
                insert wubsIB;
                benes.add(new selectOption(wubsIB.Id, wubsIB.Name));
            }
        }
    }

    public void NewRecord() {
        // Check if the record input type is WUBS based
        checkWUBSRecord();
        
        ShowInput = true;
        if(Record.Input_Type__c == 'Forecast Inflow')
            Mode='Incoming';
        else if(Record.Input_Type__c == 'Option - Other'||Record.Input_Type__c == 'Option - WUBS')
        {
            optionProtection = 0;
            optionObligation = 0;
            Mode = 'Option';
            
        }else if(Record.Input_Type__c == 'Window Forward Contract - Other'||Record.Input_Type__c == 'Window Forward Contract - WUBS')
        {
            optionProtection = 0;
            optionObligation = 0;
            Mode = 'Forward Window';    
        } else if(Record.Input_Type__c == 'Fixed Forward Contract - Other'||Record.Input_Type__c == 'Fixed Forward Contract - WUBS') {
            optionProtection = 0;
            optionObligation = 0;
            Mode = 'Forward Fixed'; 
        } else
            Mode='Outgoing';
         
        if(Record.Input_Type__c == '') {
            Mode='';
            ShowInput = false;
        }
    }
    
  /*  public void Save() {
              if(Record.Input_Type__c=='Window Forward Contract - WUBS')
	            {
	                Record.Transaction_Date__c = Record.Window_Start_Date__c;
	                Record.Type__c = 'Forward Contract - WUBS';
	            }
	            else if(Record.Input_Type__c=='Window Forward Contract - Other') // was missing 'Window'
	            {
	                Record.Transaction_Date__c = Record.Window_Start_Date__c;
	                Record.Type__c = 'Forward Contract - Other';
	            }
	            else if(Record.Input_Type__c == 'Invoice')
	            {
	                Record.Type__c='Invoice';
	            }
	            else if(Record.Input_Type__c == 'Purchase Order')
	            {
	                Record.Type__c='Purchase Order';
	            }else if(Record.Input_Type__c == 'Forecast Order')
	            {
	                Record.Type__c='Forecast Order';
	            }else if(Record.Input_Type__c == 'Forecast Inflow')
	            {
	                Record.Type__c='Forecast Inflow';
	            }else if(Record.Input_Type__c == 'Fixed Forward Contract - WUBS')
	            {
	                Record.Type__c = 'Forward Contract - WUBS';
	            }else if(Record.Input_Type__c == 'Fixed Forward Contract - Other')
	            {
	                Record.Type__c = 'Forward Contract - Other';
	            }
    }
*/    
    //This function will populate the Settings records for this user with the latest currency values
    public void updateMarketRate() {
        options= new LIST<selectoption>();
        mrMap = new MAP<String, Double>();
        for(Market_Rate__c mr:[SELECT   Id, Currency_Code__c, Currency_Name__c, Currency_Value__c, Name
                                FROM    Market_Rate__c
                                ORDER BY Currency_Code__c ASC ])
        {
            if(!mrMap.containsKey(mr.Currency_Code__c)) {
                mrMap.put(mr.Currency_Code__c, mr.Currency_Value__c);
                options.add(new selectOption(mr.Currency_Code__c, mr.Currency_Code__c));//Build out the select list on the New panel. 
            }
        }

    }
    
    //returns the currency options
    public list<selectoption> getitems()
    {
        return options;
    }
    
    private void populateBeneficiaries() {
        benes= new LIST<selectoption>();
        benes.add(new selectOption('', ''));
        benes.add(new selectOption('a1Kn00000004DvA', '['+System.label.Add_New+']'));//Add first option to create a new Beneficiary
        for(Input_Beneficiary__c i : [SELECT Name, Id FROM Input_Beneficiary__c ORDER BY Name ASC limit 990]) {//Ranjeet added limit Beneficiary, SFDC limit on selectList
            benes.add(new selectOption(i.id, i.Name));//Build out the select list on the New panel.
        }
    }
    
    //returns the currency options
    public list<selectoption> getbeneficiaries() {
        return benes;
    }
    
    //quicksave across all existing lines
    public void quickSave() {
        try {
        	system.debug('*******Error:@@');
        	message='';
        	List<Input__c>outsObjs = new List<Input__c>(); 
        	List<Invoice__c>ouInvoicesObjs = new List<Invoice__c>(); 
        	for(inputWpr input : (List<inputWpr>)outgoingPgCtlCTM.genericList){
        		if(input.input!=null){
        			input.input.Parent_Account__c = Utility.currentAccount;
                	input.input.User__c = Utility.loggedInUser.id;
        			outsObjs.add(input.input);
        		}
        		if(input.invoice!=null){
        			ouInvoicesObjs.add(input.invoice);
        		}
        	}
        	for(inputWpr input : (List<inputWpr>)incomingPgCtl.genericList){
    			input.input.Parent_Account__c = Utility.currentAccount;
            	input.input.User__c = Utility.loggedInUser.id;
        		outsObjs.add(input.input);
        	}
        	for(inputWpr input : (List<inputWpr>)hedgingPgCtl.genericList	){
    			input.input.Parent_Account__c = Utility.currentAccount;
            	input.input.User__c = Utility.loggedInUser.id;
        		outsObjs.add(input.input);
        	}
        	if(outsObjs.size()>0){
	        	update(outsObjs);
        	}
        	if(ouInvoicesObjs.size()>0){
        		system.debug('---ashishssssss--------'+ouInvoicesObjs);
        		update ouInvoicesObjs;
        	}
	        /*
	        //Invoice breaking some functionaliy for update
	        List<Invoice__c>invoiceObjs = new List<Invoice__c>();
        	for(inputWpr input : Invoices){
        		invoiceObjs.add(input.invoice);
        	}
	        update(invoiceObjs);*/
	    } catch(DMLException e) {
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Exception_Message_Update_Record + ' ' + e.getDmlMessage(0)));
			message=System.Label.Exception_Message_Update_Record + ' ' + e.getDmlMessage(0);
			system.debug('*******Error:'+e);
	    } finally {
	    	system.debug('*******Error:!');
	        //PopulateLists(!String.isEmpty(message));
	        system.debug('*******Error:@');
	        ShowInput = false;
	        newDisabled = true;
	        disableBene = false;
	    }
    }
    
    public void Cancel() {
        Record = new Input__c();
        newBene = false;
        ShowInput = false;
        disableBene = false;
        Mode='';        
    }
    public void cancelInputs(){    	
    	//PopulateLists();
    }
    /*
    public Set<Id>owerns {
    	get{
    		if(owerns==null){
    			owerns = Utility.getCurrentUsers();
    		}
    		return owerns;
    	}
    	set;
    }*/
    //Populates the Incoming and Outgoing list filtered with the records which belog to the same account                
    public void PopulateLists() {
    	PopulateLists(true);
    }
    public void PopulateLists(boolean isResetMessage) {
    	if(isResetMessage){
    		message = '';
    	}
        if(input!=null && input.Window_Start_Date__c!=null && input.Window_End_Date__c!=null){
        	if(input.Window_Start_Date__c > input.Window_End_Date__c){
        		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '"START DATE" should be earlier than "End Date".'));
        		message = 'Start date must be before the End date.';
        		return;
        	}	
        
        }    	
        populateBeneficiaries();
        // SELECT
        soql = 'SELECT id, Input_Beneficiary__c, Input_Type__c, Window_Start_Date__c, Window_End_Date__c, Counter_Party__c,Rate__c,';
        soql += 'LastModifiedDate, LastModifiedBy.Name, Input_Beneficiary__r.Name, Name, Custom_Currency__c, Amount__c, Show_Input__c, ';
        soql += 'ShowAlert__c, Beneficiary_Customer__c, Description__c, Paid__c, Invoice_Number__c, Payment_Date__c, PO_Number__c, Sort_Order__c, ';
        soql += 'Transaction_Date__c, Type__c, Reference_Number__c, Option_Protection_Obligation__c, Option_Protection_Obligation__r.Id, ';
        soql += 'Option_Protection_Obligation__r.Amount__c, CreatedDate, Parent_Account__c, OwnerId, Currency_Code__c,Sell_Currency__c, Buy_Currency__c';
        // FROM
        soql += ' FROM Input__c WHERE ';
        // WHERE
        //soql += ' Show_Input__c = true '; 
        soql +=  ' Input_Type__c != \'Invoice\' AND Parent_account__c=\''+Utility.currentAccount+'\'  AND Input_Type__c NOT IN (\'' + 'Fixed Forward Contract - WUBS' + '\') ';
        soql +=	 getCurrencyDatetimeFilter('input', selectedCurrency, input.Window_Start_Date__c, input.Window_End_Date__c);
        //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, '********soql : '+soql));
        /*
        if(input.Window_End_Date__c!=null){
        	soql +=	 ' AND Transaction_Date__c<=: input.Window_End_Date__c ';
        }*/
       
        //For Input
        incomingPgCtl.loadData(
        	getInputData(incomingPgCtl.sortField, incomingPgCtl.sortDir,
        	runQuery(incomingPgCtl.sortField, incomingPgCtl.sortDir, soql + ' AND Input_Type__c IN '+Utility.getCriteriaFromValues(Utility.inputIncoming))));
        
        //For Hedging
        hedgingPgCtl.loadData(
        	getInputData(hedgingPgCtl.sortField, hedgingPgCtl.sortDir, (runQuery(hedgingPgCtl.sortField, hedgingPgCtl.sortDir,
        	soql + ' AND ( Input_Type__c IN '+Utility.getCriteriaFromValues(Utility.inputHedging)+' or '+
        				' Type__c IN '+Utility.getCriteriaFromValues(Utility.inputHedging)+') '
        	))));
        //For Output
        //outgoingPgCtl.generateData(runQuery(soql + ' AND Type__c NOT IN '+Utility.getCriteriaFromValues(Utility.inputNOT_Outgoing)+'  AND Input_Type__c NOT IN '+Utility.getCriteriaFromValues(Utility.inputNOT_Outgoing)));
        
        List<inputWpr>outputs = getInputData(outgoingPgCtlCTM.sortField, outgoingPgCtlCTM.sortDir, 
            runQuery(outgoingPgCtlCTM.sortField, outgoingPgCtlCTM.sortDir, soql + ' AND ( Type__c IN '+Utility.getCriteriaFromValues(Utility.input_Outgoing)+'  OR Input_Type__c IN '+Utility.getCriteriaFromValues(Utility.input_Outgoing)+' ) '));
        outputs.addAll(getInvoiceData(selectedCurrency, input.Window_Start_Date__c, input.Window_End_Date__c));
        outputs.sort();
        outgoingPgCtlCTM.loadData(outputs);
    }
	private string getCurrencyDatetimeFilter(String objType, String selectedCurrency, Date startDate, Date endDate){
        String soqlFilter ='';
        
        if(!String.isEmpty(selectedCurrency)){
        	soqlFilter +=	 ' AND Custom_Currency__c = \''+selectedCurrency+'\'';
        }
        String objTypeField = (objType=='input')? 'Transaction_Date__c': 'Due_Date__c';
        if(input.Window_Start_Date__c!=null){
        	String startDateL = startDate+'' ;//'yyyy-MM-dd\'T\'hh:mm:ss\'Z\''
        	startDateL = startDateL.replace('00:00:00', '');
        	soqlFilter +=	 ' AND '+objTypeField+'>='+startDateL;
        }
        if(input.Window_End_Date__c!=null){
        	String endDateL = endDate+'';
        	endDateL = endDateL.replace('00:00:00', '');
        	soqlFilter +=	 ' AND '+objTypeField+'<='+endDateL;
        }
		return soqlFilter;
	}
    private List<inputWpr> getInvoiceData( String selectedCurrency, Date startDate, Date endDate){
    	List<Invoice__c>invoices = new List<Invoice__c>();
    	String invoiceSoql = 'select Name, Account__c, Settlement_Amount__c, Input_Beneficiary__c, Input_Beneficiary__r.Name, Due_Date__c, Amount__c, Status__c,Custom_Currency__c,OwnerId from invoice__c where account__c=\''+Utility.currentAccount+'\' ';
    	invoiceSoql +=	 getCurrencyDatetimeFilter('invoice', selectedCurrency, startDate, endDate);
    	system.debug('************::'+invoiceSoql);
    	return getInvoiceData(Database.query(invoiceSoql));
    	
    }
    private List<inputWpr> getInputData(String sortField, String sortDir, List<input__c>inputs){
    	List<inputWpr> wprs = new List<inputWpr>();
        
    	for(input__c input: inputs){
            inputWpr inputWprL = new inputWpr(sortField, sortDir,  input); 
            wprs.add(inputWprL);
    	}
    	return wprs;
    }
    private List<inputWpr> getInvoiceData(List<Invoice__c>invoices){
    	List<inputWpr> wprs = new List<inputWpr>();
            
    	for(invoice__c invoice: invoices){
            inputWpr inputWprL = new inputWpr(outgoingPgCtlCTM.sortField, outgoingPgCtlCTM.sortDir, invoice);
            wprs.add(inputWprL);
            //For dealar profile, don't show view detail link
           // system.debug('****!permissionSet.contains(invoice.id):'+permissionSet+' >> '+' :: '+invoice.id+'!!'+permissionSet.contains(invoice.id));
    	}
    	return wprs;
    }
    boolean isCCTuser{
        get{
            if(isCCTuser==null){
                Id profileId=userinfo.getProfileId();
                String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
                isCCTuser = profileName.containsIgnoreCase('CCT');
            }
            return isCCTuser;
        }
        set;
    }
	/*
    private void processInput(LIST<Input__c> inputs) {
    	system.debug('******inputs : '+inputs);
        date parsedDate = date.parse('1/1/2013');
        DateTime lastUpdated = datetime.newInstance(parsedDate.year(), parsedDate.month(), parsedDate.day());
        string lastUpdatedBy = '';
        
        for (Input__c inp : inputs) {
            if(inp.Input_Type__c == 'Forecast Inflow' || inp.Input_Type__c == 'Inflow - Other')
                Incoming.add(new inputWpr(inp));
            else if(inp.Type__c == 'Option Protection - Other' || inp.Input_Type__c == 'Window Forward Contract - WUBS' 
            		|| inp.Type__c == 'Option Obligation - Other' || inp.Type__c == 'Option Obligation - WUBS'
            		|| inp.Type__c == 'Option Protection - WUBS'  || inp.Input_Type__c == 'Window Forward Contract - Other' 
            		|| inp.Input_Type__c == 'Fixed Forward Contract - Other') {
                Hedging.add(new inputWpr(inp));   
            } else {
                if(inp.Input_Type__c != 'Fixed Forward Contract - WUBS') {
                    Outgoing.add(new inputWpr(inp));
                }
            }
            
            if (!inputMap.containsKey(inp.id)) {
                inputMap.put(inp.Id,inp);
            }
            
            if (inp.LastModifiedDate > lastUpdated) {
                lastUpdatedBy = inp.LastModifiedBy.Name;
                lastUpdatedString = System.Label.Update_Time_Input_Page + ' ';
                lastUpdatedString += inp.LastModifiedDate.format('dd/MM/yyyy');
                lastUpdatedString += ' at ';
                lastUpdatedString += inp.LastModifiedDate.format('h:mm a z');
                lastUpdatedString += '. ' + System.Label.Update_User_Input_Page + ' ';
                lastUpdatedString += lastUpdatedBy;
                
                lastUpdated = inp.LastModifiedDate;
            }
        }
    }
    /*
    //change a line to a state of paid
    public void linePaid() {
        if(inputMap.containsKey(lineId)) {
            Record = inputMap.get(lineId);
            Record.Paid__c = true;
            save();                         
        }
    }
    
    public void editLine() {
    	try{
        //LIST<Input__c> editInput = new LIST<Input__c>();
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'WE BE IN EDIT MODE'));
        //lineId = apexPages.currentPage().getParameters().get('lineId');
        if(inputMap.containsKey(lineId)) {
            Record = inputMap.get(lineId);
            Input__c record2 = inputMap.get(Record.Option_Protection_Obligation__c);
            checkWUBSRecord();
            ShowInput = true;
            
            if(Record.Input_Type__c == 'Forecast Inflow')
                Mode='Incoming';
            else if(Record.Input_Type__c == 'Option - Other'||Record.Input_Type__c == 'Option - WUBS') {
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'IN THE CORRECT AREA : ' + record2));
                Mode = 'Option';
                if(Record.Option_Protection_Obligation__c == record2.Id) {
                    if(Record.Type__c == 'Option Protection - WUBS' || Record.Type__c == 'Option Protection - Other') {
                        optionProtection = double.valueOf(Record.Amount__c);
                        optionObligation = record2.Amount__c;
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'IN THE CORRECT AREA : protection'));
                    }
                    else if(Record.Type__c == 'Option Obligation - WUBS' || Record.Type__c == 'Option Obligation - Other') {
                        optionProtection = double.valueOf(record2.Amount__c);
                        optionObligation = double.valueOf(Record.Amount__c);
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'IN THE CORRECT AREA : obligation'));
                    }
                }
                System.debug('MODE IS : ' + Mode);
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'MODE IS : ' + Mode));       
            }
            else if(Record.Input_Type__c == 'Window Forward Contract - Other'||Record.Input_Type__c == 'Window Forward Contract - WUBS') {
                Mode = 'Forward Window';    
            }
            else if(Record.Input_Type__c == 'Fixed Forward Contract - Other'||Record.Input_Type__c == 'Fixed Forward Contract - WUBS') {
                Mode = 'Forward Fixed'; 
            } else
                Mode='Outgoing';                            
        }
    	}catch(Exception Ex){
             //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.CM_Alert_ErrorOccurredWhileEditingRecord + ' ' + Record.Input_Type__ c + ' ' + System.Label.CM_Alert_UnableToSaveErrorDetail + Ex));
    		 message = 'Error occured while editing the '+Record.Input_Type__c+'. Error Detail :'+Ex.getMessage();
    	}
    }
    
    public void deleteLine() {
        //lineId = apexPages.currentPage().getParameters().get('lineId');
        if(inputMap.containsKey(lineId))
        {
            Record = inputMap.get(lineId);
            Input__c record2;
            
            try {           
            	if(Record.OwnerId != null && Record.OwnerId != UserInfo.getUserId()) {
                    Record.OwnerId = UserInfo.getUserId();
                }
                update(Record);
                
                if(Record.Input_Type__c == 'Option - Other'||Record.Input_Type__c == 'Option - WUBS') {
                    record2 = inputMap.get(Record.Option_Protection_Obligation__c);
                    
                    if(record2.OwnerId != null && record2.OwnerId != UserInfo.getUserId()) {
                        record2.OwnerId = UserInfo.getUserId();
                    }
                    update(record2);
                    delete(record2);
                }
				delete(Record);
            } catch (DMLexception e) {
                String error;
                if(String.valueOf(e).containsIgnoreCase('INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY'))
                    error = System.Label.Exception_Message_Locked_Record_Delete; //'This record was created by an WUBS Internal User. Please notify a System Administrator if you wish to delete this record.';
                else if(String.valueOf(e).containsIgnoreCase('ENTITY_IS_DELETED'))
                    error = System.Label.Exception_Message_Record_Already_Deleted; //'This record has already been deleted.';
                else
                    error = String.valueOf(e.getDmlMessage(0));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Exception_Message_Delete_Record + ' ' + error));
            } catch (Exception e) {
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            	
            }
            
            PopulateLists();
            // clear out the local record copy. Defaults the 'Create a new record:' picklist to '--None--'
            Record = new Input__c();
            ShowInput = false;
            Mode = '';                      
        }
    }
    
    public void checkApp() {
        
        if(Record.Input_Type__c != '--None--') {
            NewRecord();
            newDisabled = false;
        }
    }*/
    

      // the current field to sort by. defaults to last name
    
	// toggles the sorting of query from asc<-->desc
	public void toggleIncomingSort() {
		system.debug('***********>>'+incomingPgCtl.sortDir+incomingPgCtl.sortField);
        // simply toggle the direction
        incomingPgCtl.toggle();
        // run the query again
        PopulateLists(false); 
	}
	// toggles the sorting of query from asc<-->desc
	public void togglehedgingSort() {
        // simply toggle the direction
        hedgingPgCtl.sortDir = hedgingPgCtl.sortDir.equals('asc') ? 'desc' : 'asc';
        // run the query again
        PopulateLists(false);
	}
	// toggles the sorting of query from asc<-->desc
	public void toggleoutgoingSort() {
        // simply toggle the direction
        outgoingPgCtlCTM.sortDir = outgoingPgCtlCTM.sortDir.equals('asc') ? 'desc' : 'asc';
        // run the query again
        PopulateLists(false);
	}     
	// runs the actual query
	public LIST<Input__c> runQuery(String sortField, String sortDir, String queryText) {
		date sdate = Date.Today().addDays(-60);		
		string soql3 = (queryText +' ORDER BY ' + sortField +' '+sortDir + ', CreatedDate desc limit 40000');
		LIST<Input__c> inputs = new LIST<Input__c>();
        try {
			inputs = Database.query(soql3);
		} catch (System.Queryexception e) {
			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Exception_Message_Query_Database + ' ' + e.getMessage()));
			message = System.Label.Exception_Message_Query_Database + ' ' + e.getMessage();
		}
		return inputs;
	}
    
    public void newBeneficiary() {
        ib = new Input_Beneficiary__c();
        ib.Account__c = UserAccount.Contact.AccountId;
        newBene = true;
    }
    
     //Getting data from exising record I-149395
    public List<SelectOption> getaccountTradedCurrency(){
    	list<Selectoption> lstCurrency = new list<Selectoption>();
        lstCurrency.add(new Selectoption('', Label.CM_Community_Text_FieldFilter_Currency_Item_ShowAll));
        lstCurrency.addAll(Utility.getaccountTradedCurrency());
		return lstCurrency;
    }

    public List<SelectOption> getaccountTableCurrency(){
    	list<Selectoption> lstCurrency = new list<Selectoption>();
        lstCurrency.addAll(Utility.getaccountTradedCurrency());
		return lstCurrency;
    }
    
    
    public List<SelectOption> getbuyAndSellCurrency(){
    	list<Selectoption> lstCurrency = new list<Selectoption>();
    	// lstCurrency.add(new Selectoption('Select','Select'));
    	lstCurrency.addAll(Utility.picklistValues('Input__c', 'Buy_Currency__c'));
		return lstCurrency;
    }
    
    
    public void saveBeneficiary() {
        if(ib.Name != '['+System.Label.Add_New+']') {
            insert ib;
			benes.add(new selectOption(ib.Id, ib.Name));//Add One Last option to create a new Beneficiary
            Record.Input_Beneficiary__c = ib.Id;
            newBene = false;
        }
    }
    
    public void deleteInputs(){
    	try{
	    	List<input__c>inputs = new List<input__c>();
	    	Set<Id>inputOptions = new Set<Id>();
	    	List<invoice__c>invoices = new List<invoice__c>();
	    	if(outgoingPgCtlCTM.genericList!=null){
		    	inputs.addAll(getDeleteSelected((List<inputWpr>)outgoingPgCtlCTM.genericList));
		    	invoices.addAll(getDeleteSelectedInvoice((List<inputWpr>)outgoingPgCtlCTM.genericList));
	    	}
	    	if(incomingPgCtl.genericList!=null){
	    		inputs.addAll(getDeleteSelected((List<inputWpr>)incomingPgCtl.genericList));
	    	}
	    	if(hedgingPgCtl.genericList!=null){
	    		inputs.addAll(getDeleteSelected((List<inputWpr>)hedgingPgCtl.genericList));
	    		for(Input__c wpr : inputs){
	    			if(wpr.Option_Protection_Obligation__c!=null){
	    				if(!inputOptions.contains(wpr.id)){
	    					inputOptions.add(wpr.Option_Protection_Obligation__c);
	    				}else{
	    					inputOptions.remove(wpr.Id);
	    				}
	    				// new Input__c(id=wpr.input.Option_Protection_Obligation__c)
	    			}
	    		}
	    		for(Id inputId : inputOptions){
	    			inputs.add(new Input__c(id=inputId));
	    		}
	    	}
	    	
	    	if(inputs.size()>0){
	    		delete inputs;
	    	}
	    	if(invoices.size()>0){
	    		delete invoices;
	    	}
		}catch(Exception Ex){
    		 //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error occured while editing the '+Record.Input_Type__c+'. Error Detail :'+Ex));
    		 message = 'Error occured deleting selected inputs. Error Detail :'+Ex.getMessage();
    	}    	
    	finally{
    		PopulateLists();
    	}
    }

    private List<Invoice__c> getDeleteSelectedInvoice(List<inputWpr> inputsWpr){
    	List<invoice__c>invoices = new List<invoice__c>();
    	if(inputsWpr!=null){
	    	for(inputWpr inputWp : inputsWpr){
	    		system.debug('*****:'+inputWp);
	    		if(inputWp.isSelected==true && inputWp.invoice!=null){
	    			invoices.add(inputWp.invoice);
	    		}
	    	}
    	}
    	return invoices;
    }

    private List<Input__c> getDeleteSelected(List<inputWpr> inputsWpr){
    	List<input__c>inputs = new List<input__c>();
    	if(inputsWpr!=null){
	    	for(inputWpr inputWp : inputsWpr){
	    		system.debug('*****:'+inputWp);
	    		if(inputWp.isSelected==true && inputWp.input!=null){
	    			inputs.add(inputWp.input);
	    		}
	    	}
    	}
    	return inputs;
    }
    
    public void cancelBeneficiary() {
        newBene = false;
        disableBene = false; // not needed
    }
    /*
    public pageReference disclaimerLink() {
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
    }*/
    public String checkBoxOutgoingHtml{
    	get{
    		return '<div><input type="checkbox" id="outputChk" onclick="doToggleDelete(this,\'deleteInputOutgoingChk\');"/>Action</div>';
    	}
    }
    public String checkBoxIncomingHtml{
    	get{
    		return '<div><input type="checkbox" id="incomingChk" onclick="doToggleDelete(this,\'deleteInputIncomingChk\');"/>Action</div>';
    	}
    }
    public String checkBoxHedgingHtml{
    	get{
    		return '<div><input type="checkbox" id="hedgingChk" onclick="doToggleDelete(this,\'deleteInputHedgingChk\');"/>Action</div>';
    	}
    }
    
    public String checkBoxOutgoingPaidHtml{
    	get{
    		return '<div>Status&#47;<input type="checkbox" id="outputChk"/>Paid</div>';
    	}
    }
}