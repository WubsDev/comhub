/**=====================================================================
 * Name: Utility
 * Description: 
 * Created Date: Feb 11, 2015
 * Created By: Nishant Bansal (JDC)
 * 
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/

public without sharing class Utility {

	
    public static List<SelectOption> getaccountNetcashCurrency(){ 
		//        return picklistValues('Account','Traded_Currencies__c');        
		// Get the Currency List From Current LoggedIn User Account    
        list<Selectoption> lstCurrency = new list<Selectoption>();
        Set<String> currencySet = new Set<String>();
        
        for(AggregateResult invoiceRec: [SELECT count(Id), Custom_Currency__c 
                                         FROM Invoice__c 
                                         WHERE Account__c  =:currentAccount
                                         group by  Custom_Currency__c]) {
            String currencyCode = (String) invoiceRec.get('Custom_Currency__c');
            if(!currencySet.contains(currencyCode)) {
            	currencySet.add(currencyCode);
            }
          }
    for(AggregateResult inputRec: [SELECT count(Id), Custom_Currency__c 
                                         FROM Input__c 
                                         WHERE Parent_account__c=:currentAccount
                                         and Custom_Currency__c not in :currencySet
                                         and (Type__c in ('Forecast Inflow', 'Purchase Order','Forecast Order', 'Forecast Outflow') 
                                            or Input_Type__c in ('Forecast Inflow', 'Purchase Order','Forecast Order', 'Forecast Outflow')
                                         	)
                                         group by  Custom_Currency__c]) {
            String currencyCode = (String) inputRec.get('Custom_Currency__c');
            if(!currencySet.contains(currencyCode)) {
            	currencySet.add(currencyCode);
			}
		}
		List<String> currencySorted = new List<String>(currencySet);
		currencySorted.sort();
		for(String currencySort: currencySorted){
            if(currencySort!=null){
				lstCurrency.add(new Selectoption(currencySort,currencySort));
            }
		}   
		return lstCurrency;
    }    

		//Getting data from exising record I-149395
    public static List<SelectOption> getaccountTradedCurrency(){ 
		//        return picklistValues('Account','Traded_Currencies__c');        
		// Get the Currency List From Current LoggedIn User Account    
        list<Selectoption> lstCurrency = new list<Selectoption>();
        Set<String> currencySet = new Set<String>();
        Date startdt = Date.today(); //.toStartOfMonth();
        for(AggregateResult invoiceRec: [SELECT count(Id), Custom_Currency__c 
                                         FROM Invoice__c 
                                         WHERE Account__c  =:currentAccount
                                         AND Due_Date__c >= :startdt
                                         group by  Custom_Currency__c]) {
            String currencyCode = (String) invoiceRec.get('Custom_Currency__c');
            if(!currencySet.contains(currencyCode)) {
            	currencySet.add(currencyCode);
            }
          }
    for(AggregateResult inputRec: [SELECT count(Id), Custom_Currency__c 
                                         FROM Input__c 
                                         WHERE Parent_account__c=:currentAccount
                                         and Custom_Currency__c not in :currencySet
                                         and Input_Type__c !='Fixed Forward Contract - WUBS'
                                         AND Input_Type__c != 'Invoice'
                                         AND Transaction_Date__c >= :startdt 
                                         group by  Custom_Currency__c]) {
            String currencyCode = (String) inputRec.get('Custom_Currency__c');
            if(!currencySet.contains(currencyCode)) {
            	currencySet.add(currencyCode);
			}
		}
		List<String> currencySorted = new List<String>(currencySet);
		currencySorted.sort();
		for(String currencySort: currencySorted){
            if(currencySort!=null){
				lstCurrency.add(new Selectoption(currencySort,currencySort));
            }
		}   
		return lstCurrency;
    }    
		//Getting data from exising record I-149395
		//Updated for I-150167 Use Forward_Contracts.Custome_Currency__c
    public static List<SelectOption> getCurrencyForFC(){ 
        list<Selectoption> lstCurrency = new list<Selectoption>();
        Set<String> currencySet = new Set<String>();
        for(AggregateResult invoiceRec: [SELECT count(Id), Custom_Currency__c 
                                         FROM Forward_Contracts__c 
                                         WHERE Account_ID__c  =:currentAccount
                                         group by  Custom_Currency__c]) {
            String currencyCode = (String) invoiceRec.get('Custom_Currency__c');
            if(!currencySet.contains(currencyCode)) {
            	currencySet.add(currencyCode);
            }
          }
		List<String> currencySorted = new List<String>(currencySet);
		currencySorted.sort();
		for(String currencySort: currencySorted){
            if(currencySort!=null){
				lstCurrency.add(new Selectoption(currencySort,currencySort));
            }
		}   
		return lstCurrency;
    }

    
    
    /*
    *
    *
    *
    *
    */
    
    public static List<SelectOption> getCurrencyForHB(){ 
        list<Selectoption> lstCurrency = new list<Selectoption>();
        Set<String> currencySet = new Set<String>();
        for(AggregateResult invoiceRec: [SELECT count(Id), Custom_Currency__c 
                                         FROM Holding_Balance__c
                                         WHERE Account__c  =:currentAccount
                                         group by  Custom_Currency__c]) {
            String currencyCode = (String) invoiceRec.get('Custom_Currency__c');
            if(!currencySet.contains(currencyCode)) {
              currencySet.add(currencyCode);
            }
          }
	    List<String> currencySorted = new List<String>(currencySet);
	    currencySorted.sort();
	    for(String currencySort: currencySorted){
	            if(currencySort!=null){
	        lstCurrency.add(new Selectoption(currencySort,currencySort));
	            }
	    }   
	    return lstCurrency;
    }

    public static List<SelectOption> picklistValues(String ObjectAPI , String fieldName){
        return picklistValues(ObjectAPI , fieldName, false);
    }
    public static List<SelectOption> picklistValues(String ObjectAPI , String fieldName, boolean addBlank){
        List<SelectOption> lstPickvals=new List<SelectOption>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectAPI);
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); 
        List<Schema.PicklistEntry> pick_list_values = field_map.get(fieldName).getDescribe().getPickListValues();
        if(addBlank){
            lstPickvals.add(new SelectOption('', System.label.CM_Community_Text_FieldFilter_TransactionTypeFilter_Item_Select));
        } 
        for (Schema.PicklistEntry a : pick_list_values) {
            lstPickvals.add(new SelectOption(a.getLabel(),a.getLabel()));
        }
        lstPickvals.sort();
        return lstPickvals;
    }
    
    
    public static Map<String, String> picklistLabelValueMap(String ObjectAPI , String fieldName){
        Map<String, String> lstPickvals=new Map<String, String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectAPI);
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); 
        List<Schema.PicklistEntry> pick_list_values = field_map.get(fieldName).getDescribe().getPickListValues();
        
        for (Schema.PicklistEntry a : pick_list_values) {
            lstPickvals.put(a.getLabel(),a.getValue());
        }
        return lstPickvals;
    }
    
    
    public static Set<String> picklistValueSet(String ObjectAPI , String fieldName){
        Set<String> lstPickvals=new Set<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectAPI);
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); 
        List<Schema.PicklistEntry> pick_list_values = field_map.get(fieldName).getDescribe().getPickListValues(); 
        for (Schema.PicklistEntry a : pick_list_values) {
            lstPickvals.add(a.getValue().toUpperCase());
            lstPickvals.add('label-'+a.getLabel().toUpperCase());
        }
        return lstPickvals;
    }
    //get remaining SOQL query rows for the current thread
    public static Integer getRemainingSOQLRows(){
        return Limits.getLimitQueryRows() - Limits.getQueryRows();
    }
    
    static map<String, Decimal> marketRates;
    public static Decimal getSettlementCurrencyAmount(Decimal amount, String invCurr, String userCurrency){
        if(amount == null || amount == 0.0){
            return 0.0;
        }
        if(invCurr == userCurrency){
            return amount;
        }
        if(marketRates == null){
            marketRates = new map<String, Decimal>();
            for(Market_Rate__c rate : [SELECT Id, Currency_Code__c, Currency_Value__c FROM Market_Rate__c limit :getRemainingSOQLRows()]){
                marketRates.put(rate.Currency_Code__c, rate.Currency_Value__c);
            }
        }
        Decimal invCurrValue = 1.0;
        Decimal userCurrValue = 1.0;
        
        if(marketRates.containsKey(invCurr)){
            invCurrValue = marketRates.get(invCurr);
        }
        if(marketRates.containsKey(userCurrency)){
            userCurrValue = marketRates.get(userCurrency);
        }
        //Decimal result = (amount * invCurrValue) * (1 / userCurrValue);
        Decimal result = (amount * userCurrValue) * (1 / invCurrValue);
        system.debug('****convert :('+amount+' *'+ userCurrValue+') * (1 / '+invCurrValue+')) ==>'+result);

        result = result.setScale(2);
        return result;
    }
    public static boolean isValidText(String srcText){
        if(srcText!=null){
            srcText = srcText.trim();
        }
        return !String.isEmpty(srcText);
    } 
    public static string getValidText(String srcText){
        if(srcText!=null){
        	if(srcText.indexOf('null')!= -1){
        		srcText = '';
        	}
            srcText = srcText.trim();
        }else{
        	srcText = '';
        }
        return srcText;
    } 

	public static String getValidText(String[]srcArray, Integer index){
        if(index>=srcArray.size()){
        	return '';
        }
        return Utility.getValidText(srcArray[index]);
	}
    
    public static boolean isValidDecimal(String srcText){
        if(Utility.isValidText(srcText)){
            try{
                Decimal.valueOf(Utility.getValidText(srcText));
                return true;
            }catch(Exception Ex){
                system.debug('****valid Decimal>>'+Ex);
            }           
        }       
        return false;
    }

    public static void getFormatDecimalString(){
        Decimal d = 1234.45;
        String s = d.format();
        String separatorCharL = s.substring(s.length()-7, s.length()-6);
        //system.debug('-----------'+s+'>>'+getDecimalSeparatorChar+'::'+getDecimalChar+'ooo');
        if(separatorCharL == ' ' || separatorCharL == ' '){
            separatorCharL = ' ';
        }
        getDecimalSeparatorChar = separatorCharL;
        getDecimalChar = s.substring(s.length()-3, s.length()-2);       
    }
    public static string getDecimalChar{
        get{
            if(String.isEmpty(getDecimalChar) ){
                getFormatDecimalString();
            }
            return getDecimalChar;
        }
        set;
    }
    public static string getDecimalSeparatorChar{
        get{
            if(String.isEmpty(getDecimalSeparatorChar)){
                getFormatDecimalString();
            }
            system.debug('----------getDecimalSeparatorChar---------'+getDecimalSeparatorChar);
            return getDecimalSeparatorChar;
        }
        set;
    }
    
    public static Decimal getDecimal(String srcText){
        if(Utility.isValidText(srcText)){
        	system.debug('****Decimal SRC 0>>'+srcText);
            try{
                srcText = Utility.getValidText(srcText);
                //system.debug('****Decimal Src>>'+Utility.getValidText(srcText));
                //For some local "." is separator
                srcText = srcText.replace(getDecimalChar, '@@');
                system.debug('****Decimal SRC 2>>'+srcText);
                srcText = srcText.replace(getDecimalSeparatorChar, '');
                system.debug('****Decimal SRC 3>>'+srcText);
                srcText = srcText.replace('@@', '.');  
                system.debug('****Decimal SRC 4>>'+srcText);
                system.debug('----------getDecimalSeparatorChar---------'+getDecimalSeparatorChar+' : '+getDecimalChar);         
                return Decimal.valueOf(srcText);
            }catch(Exception Ex){
                system.debug('****Decimal>>'+Ex+': Converted:'+srcText);
            }
        }
        return null;
    }
    
    public static Date getDate(String srcText){
        if(Utility.isValidText(srcText)){
            try{
                String[] dt = Utility.getValidText(srcText).split('/');
                if(dt.size()==3){
                		Integer m;
                		Integer d;
                		if(userInfo.getLocale().equalsIgnoreCase('en_us')) {
                			m = Integer.valueof(dt[0]);
                    	d = Integer.valueof(dt[1]);
                		} else {
                			d = Integer.valueof(dt[0]);
                    	m = Integer.valueof(dt[1]);
                		}
                    
                    if(dt[2].length()==2){
                        dt[2] = '20'+dt[2];
                    }
                    Integer y = Integer.valueof(dt[2]);
                    return Date.newInstance(y, m, d);
                }
            }catch(Exception Ex){
                system.debug('****Date>>'+Ex);
            }
        }
        return null;
    }
    /*
    public static Set<Id>getCurrentUsers(){
        set<Id> owners = new set<Id>();
        for(User u : [SELECT Id FROM User WHERE Contact.AccountId = :currentAccount]){
            owners.add(u.Id);
        }
        return owners;
    }
    */
    static list<String> monthList = new List<String>{System.Label.Jan, System.Label.Feb, System.Label.Mar, System.Label.Apr, 
        System.Label.May, System.Label.Jun, System.Label.Jul, System.Label.Aug, System.Label.Sep, System.Label.Oct, System.Label.Nov, System.Label.Dec};
    public static String getMonthName(Integer month){
        return monthList.get(month - 1);
    }
     public static boolean isValidCsvRow(String csvRow){
        if(!String.isEmpty( csvRow)){
            csvRow = csvRow.remove(',').trim();
        }
        return !String.isEmpty( csvRow);
     }
     
     
     //Check if profile name ends with CCT, to find if profile is "CCT"  profile.
     public static boolean isDealerUser{
      get{
        return (!(isCCTuser || isNonCCTuser));
      }
     }
     
     
     //Check if profile name ends with CCT, to find if profile is "CCT"  profile.
     public static boolean isCCTuser{
     	get{
     		return (!loggedInUser.Profile.Name.endsWithIgnoreCase('Non CCT') && loggedInUser.Profile.Name.endsWithIgnoreCase('CCT'));
     	}
     }
	 //Check if profile name ends with Non CCT, to find if profile is "Non CCT" profile.
     public static boolean isNonCCTuser{
     	get{
     		return loggedInUser.Profile.Name.endsWithIgnoreCase('Non CCT');
     	}
     }
     
     public static String userCurrency{
     	get{
     		if(loggedInUser != null){
            if(String.isEmpty(userCurrency)){
     			if(!String.isEmpty(loggedInUser.DefaultCurrencyIsoCode)){
                if(loggedInUser != null && loggedInUser.ContactId!=null){
                    userCurrency= loggedInUser.DefaultCurrencyIsoCode;
                    return userCurrency;
                }
                else{
                    userCurrency= [SELECT CurrencyIsoCode from Account Where Id =:currentAccount].CurrencyIsoCode;
                    return userCurrency;
                }
     			}else{
     				if(loggedInUser != null && loggedInUser.ContactId!=null && Contact.AccountId!=null){
                  userCurrency= loggedInUser.CurrencyIsoCode;
                  return userCurrency;
     				}
     			}
            }else{
            	return userCurrency;
            }
     		}
     		return '';
     	}
      set;
     }
     
     public static User loggedInUser{
        get{
            if(loggedInUser == null){
                loggedInUser = [Select   Id, Profile.Name, ContactId, DefaultCurrencyIsoCode, Name, IsPrmSuperUser,LocaleSidKey,
                  CurrencyIsoCode, Contact.AccountId, Contact.Account.CurrencyIsoCode, LanguageLocaleKey, Contact.Account.OwnerId FROM  User
                  	WHERE  Id = :UserInfo.getUserId() LIMIT 1];//'005n0000000iicr']; 
            }
            return loggedInUser;
        }
        set;
     }
     public static Market_Rate__c loggedInMarketRate{
        get{
            if(loggedInMarketRate==null){
                if(loggedInUser!=null){
                    if(loggedInUser.DefaultCurrencyIsoCode!=null){
                        List<Market_Rate__c> mrs = [Select last_updated__c, LastModifiedDate  from Market_Rate__c Where Currency_Code__c=: loggedInUser.DefaultCurrencyIsoCode];
                        if(mrs.size()>0){
                            loggedInMarketRate = mrs[0]; 
                        }
                    }
                }
            }
            return loggedInMarketRate;
        }
        set;
     }
     public static Id currentAccount{
        get{
            if(currentAccount==null){
                if(loggedInUser!=null){
                	if(loggedInUser.Contact != null){
                    	currentAccount = loggedInUser.Contact.AccountId;
                	}
                }
                if(currentAccount==null){
            		if(ApexPages.currentPage() != null){
            			String zaId = ApexPages.currentPage().getParameters().get('aId');
            			if(!String.isEmpty(zaId)){
            				currentAccount = zaId;
            			}
            		}
                }
            }
            return currentAccount;
        }
        set;
     }
     
     
     public static Id currentAccountOwner{
        get{
            if(loggedInUser != null){
                if(loggedInUser.Contact.AccountId != null){
                    currentAccountOwner = loggedInUser.Contact.Account.OwnerId;
                }else{
                    currentAccountOwner = null;
                }
            }
            return currentAccountOwner;
        }
        set;
     }
     
     
     public static Datetime lastUpdateMarketDatetime{
        get{
            if(loggedInMarketRate!=null){
            	if(loggedInMarketRate.last_updated__c!=null){
                	return loggedInMarketRate.last_updated__c;
            	}else{
            		return loggedInMarketRate.LastModifiedDate;
            	}
            }
            return null;
        }
     }

     public static Market_rate__c lastUpdatedMarketRate(){
        return loggedInMarketRate;
     }
     public static String inputIncoming{
        get{
            if(String.isEmpty(inputIncoming)){
                inputIncoming = System.Label.TypeIncoming;
            }
            return inputIncoming;
        }
        set;
     }
     
     public static String inputHedging{
        get{
            if(String.isEmpty(inputHedging)){
                inputHedging = System.Label.InputHedging;
            }
            return inputHedging;
        }
        set;
     }
    //TypeFFC_WUBS
     public static String inputTypeFfcWubs{
        get{
            if(String.isEmpty(inputTypeFfcWubs)){
                inputTypeFfcWubs = System.Label.TypeFFC_WUBS;
            }
            return inputTypeFfcWubs;
        }
        set;
     }  
     public static String input_Outgoing{
        get{            
            if(String.isEmpty(input_Outgoing)){
                //Outgoing is left from all below types
                input_Outgoing = System.Label.CM_Type_Outgoing;
            }
            return input_Outgoing;
        }
        set;
     }
     public static String getCriteriaFromValues(String valueSemicolon){
        if(!String.isEmpty(valueSemicolon)){
          List<String>values = valueSemicolon.split(',');
            return '(\''+string.join( values, '\',\'' )+'\')';
        }
        return '';
     }
     
     
     public static boolean fieldSetValidation(sObject oBjsObject, String fieldSetName, String selectedTranscation, boolean isRenderErrorMessage){
     	return fieldSetValidation(oBjsObject, null, fieldSetName, selectedTranscation, isRenderErrorMessage);
     }
     public static boolean fieldSetValidation(sObject oBjsObject, sobject oBjsAnotherObject, String fieldSetName, String selectedTranscation, boolean isRenderErrorMessage){
     	boolean hasError = false;
     	map<String, string> mapLabelNames = getFieldLabelByFieldsetAPIname('input__c', fieldSetName, selectedTranscation);
     	for(Schema.FieldSetMember f : oBjsObject.getSObjectType().getDescribe().fieldSets.getMap().get(fieldSetName).getFields()) {
     		if(f.required || f.dbrequired){
          system.debug('--------ashish---------'+f.getFieldPath()+'-----------------'+oBjsObject.get(f.getFieldPath()));
     			if(oBjsObject.get(f.getFieldPath())==null){
		     		if(isRenderErrorMessage){
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, mapLabelNames.get(f.FieldPath) + ' ' + System.Label.CM_Validation_Input_ShouldNotBeBlank));
		     		}  
		     		hasError = true;
     			}
     		}
            system.debug('*****::'+f.FieldPath+f.Type+ ' > ' +f.Label+' !! '+f.required+ '  :>>: ' + f.dbrequired);
        }
        if(oBjsAnotherObject!=null && fieldSetName=='Option_Other' && oBjsAnotherObject.get('amount__c')==null){
        	if(isRenderErrorMessage){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CM_Validation_Input_FieldObligationAmountShouldNotBeBlank));
        	}
        	hasError = true;
        }
        system.debug('***** fieldSetName ::'+fieldSetName+' >> '+oBjsObject.get('Window_Start_Date__c')+' !! '+oBjsObject.get('Window_End_Date__c'));
        if(oBjsAnotherObject!=null && fieldSetName=='Window_Forward_Contract_Other' && oBjsObject.get('Window_Start_Date__c')!=null && oBjsObject.get('Window_End_Date__c')!=null){
        	Datetime Window_Start_Date = (Datetime)oBjsObject.get('Window_Start_Date__c');
        	Datetime Window_End_Date = (Datetime)oBjsObject.get('Window_End_Date__c');
        	system.debug('*****::'+Window_Start_Date+' : '+Window_End_Date);
        	if(Window_End_Date<Window_Start_Date){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CM_Validation_Input_DateShouldBeGreaterOrEqual));
        	}
        }
        return hasError;
     }
    public static map<String, string> getFieldLabel(String sObjectApiName, String selectedTranscation){
    	String tranApiName = changeTransactionType(selectedTranscation);
    	return getFieldLabelByFieldsetAPIname(sObjectApiName, tranApiName, selectedTranscation);
    }
    public static String getBeneLabelByTransType(String TransactionType){
    	String beneName = '';
    	if(!String.isEmpty(TransactionType)){
    		if(TransactionType.equalsIgnoreCase('Outgoing')){
          beneName = Label.CM_SectionText_InvoiceManagement_MyInvoices_BuyerSupplier;
    		}else if(TransactionType.equalsIgnoreCase('Hedging')){
    			beneName = 'Counter Party';
    		}else if(TransactionType.equalsIgnoreCase('Incoming')){
          beneName = Label.CM_SectionText_InvoiceManagement_MyInvoices_BuyerSupplier;
    		}
    	}
    	return beneName;
    }
    public static map<String, string> getFieldLabelByFieldsetAPIname(String sObjectApiName, String tranApiName, String selectedTranscation){    	
    	map<String, string>labelName = new map<String, string>();
    	if(!Schema.getGlobalDescribe().get(sObjectApiName).getDescribe().fieldSets.getMap().containsKey(tranApiName)){
    		return labelName;
    	}
     	for(Schema.FieldSetMember f : Schema.getGlobalDescribe().get(sObjectApiName).getDescribe().fieldSets.getMap().get(tranApiName).getFields()) {
     		boolean isSet = false;
     		if(f.getFieldPath().equalsIgnoreCase('Input_Beneficiary__c')){
     			/*if(tranApiName.equalsIgnoreCase('Fixed_Forward_Contract_Other')
     				||tranApiName.equalsIgnoreCase('Window_Forward_Contract_Other')
     				||tranApiName.equalsIgnoreCase('Option_Other')){
     				isSet = true;
     				labelName.put(f.getFieldPath(), 'Counter Party');
     			}*/
     			isSet = true;
     			//tranApiName.equalsIgnoreCase('Outgoing_Transaction')
     			String TransactionType = getTransactionType(selectedTranscation);
     			labelName.put(f.getFieldPath(), getBeneLabelByTransType(TransactionType));
     		}
     		if(f.getFieldPath().equalsIgnoreCase('Transaction_Date__c')){
     			if(tranApiName.equalsIgnoreCase('Fixed_Forward_Contract_Other') || tranApiName.equalsIgnoreCase('Option_Other')){
     				isSet = true;
            labelName.put(f.getFieldPath(), Label.Settlement_Date);
     			}
     		}
     		
        if(f.getFieldPath().equalsIgnoreCase('Custom_Currency__c')){
     				isSet = true;
            labelName.put(f.getFieldPath(), Label.CM_Label_Currency_Code);
     		}
     		
     		if(f.getFieldPath().equalsIgnoreCase('Counter_Party__c')){
     				isSet = true;
            labelName.put(f.getFieldPath(), Label.Counter_Party);
     		}
     		
     		if(f.getFieldPath().equalsIgnoreCase('Amount__c') && tranApiName.equalsIgnoreCase('Option_Other')){
          labelName.put(f.getFieldPath(), Label.Protection_Amount);
          labelName.put(f.getFieldPath()+'_other', Label.Obligation_Amount);
     			isSet = true;
     		}
     		if(f.getFieldPath().equalsIgnoreCase('Paid__c')){
     			if(tranApiName.equalsIgnoreCase('Fixed_Forward_Contract_Other')||tranApiName.equalsIgnoreCase('Window_Forward_Contract_Other')||
     				tranApiName.equalsIgnoreCase('Option_Other')){
     				isSet = true;
            labelName.put(f.getFieldPath(), System.Label.CM_FieldInput_Input_Settled);
     			}else
     				if(tranApiName.equalsIgnoreCase('Outgoing_Transaction')){
              labelName.put(f.getFieldPath(), System.Label.CM_Community_Text_FieldFilter_InvoiceStatus_Item_Paid);
     					isSet = true;
     			}else 
     				if(tranApiName.equalsIgnoreCase('incoming_Transaction')){
              labelName.put(f.getFieldPath(), System.Label.CM_FieldInput_Input_Received);
     					isSet = true;
     			}
     		}
     		if(!isSet){
     			labelName.put(f.getFieldPath(), f.Label);
     		}

        }
        system.debug('----------'+labelName);
        return labelName;
    }

	public static string getTransactionType(String selectedTranscation) {
		String trnType = '';
      if (selectedTranscation == 'Purchase Order' || selectedTranscation == 'Forecast Outflow') {
            trnType = 'Outgoing';
       	}else if(selectedTranscation == 'Option - Other' || selectedTranscation == 'Option - WUBS'){
       		trnType = 'Hedging';
         }else if (selectedTranscation == 'Forecast Inflow') {
        	trnType = 'Incoming';
       	}else if(selectedTranscation == 'Fixed Forward Contract - Other') {
            trnType = 'Hedging';
       	}else if(selectedTranscation == 'Window Forward Contract - Other'){
        	trnType = 'Hedging';
       	}else if(selectedTranscation == 'Invoice') {
       		trnType = 'Outgoing';
       	}else if(selectedTranscation == 'Community Invoice Edit' || selectedTranscation == 'Detail') {
       		trnType = 'Outgoing';
       	}
       	return trnType;
	}

	public static string changeTransactionType(String selectedTranscation) {
    	String fieldset = '';
      if (selectedTranscation == 'Purchase Order' || selectedTranscation == 'Forecast Outflow' ) {
            fieldset = 'Outgoing_Transaction';
       	}else if(selectedTranscation == 'Option - Other' || selectedTranscation == 'Option - WUBS'){
       		fieldset = 'Option_Other';
         }else if (selectedTranscation == 'Forecast Inflow') {
        	fieldset = 'incoming_Transaction';
       	}else if(selectedTranscation == 'Fixed Forward Contract - Other') {
            fieldset = 'Fixed_Forward_Contract_Other';
       	}else if(selectedTranscation == 'Window Forward Contract - Other'){
        	fieldset = 'Window_Forward_Contract_Other';
       	}else if(selectedTranscation == 'Invoice') {
       		fieldset = 'Invoice_CSV';
       	}else if(selectedTranscation == 'Community Invoice Edit') {
       		fieldset = 'Community_Invoice_Edit';
       	}else if(selectedTranscation == 'Detail') {
       		fieldset = 'Detail';
       	}
       	return fieldset;
  }

	public static string getVFPageName()  {
		// THIS IS THE CLOSEST YOU CAN GET SO FAR
		String pageName = ApexPages.CurrentPage().getUrl();  
		// IT ALWAYS STARTS WITH /APEX/ SO REMOVE IT
		pageName = pageName.replaceFirst('/apex/','');         
		pageName = EncodingUtil.urlEncode(pageName, 'UTF-8');  
		// %3F IS THE VALUE OF THE QUESTION MARK IN UTF-8 
		string[] pageNameExtra = pageName.split('%3F',0);   
		// SO YOU MAY SPLIT THE STRING AT THAT POINT
		  // FOR THIS PURPOSE YOU ONLY NEED THE FIRST
		// IN THE RESULTING ARRAY
		pageName = pageNameExtra[0]; 
		// HERE IS YOUR PRODUCT  
		system.debug('pageName-->'+pageName);                       
		return pageName;                                        
	}
    public static String inputLink{
    	get{
        return '<a href=\'apex/ManageCashInput\'><h3 style=\'color:#222222;text-decoration:none!important;\'>'+Label.CM_Community_Link_ManageAllInputs+'</h3></a>';
    	}
    }    
    
    //After insert update the reference of option objects.
    public static boolean updateRefOptionInput(sObject input, sObject optionInput, String fieldSet){
    	if(fieldSet=='Option_Other'){
    		if(optionInput!=null && optionInput.id!=null){
    			input.put('Option_Protection_Obligation__c', optionInput.id);
    			optionInput.put('Option_Protection_Obligation__c', input.id);
    			return true; 
    		}    		
    	}
    	return false;
    }
    
    public static String CSVRowDeliminator{
    	public get{
    			if(String.isEmpty(CSVRowDeliminator)){
	    			CMPUserBasedCSVPareser__c cmpCSVParser = CMPUserBasedCSVPareser__c.getValues(Utility.loggedInUser.LocaleSidKey);
	    			if(cmpCSVParser != null){
	                	CSVRowDeliminator = cmpCSVParser.CSVRowDeliminator__c;
	            	}else{
	            		//Check if default local-set
	            		if(Utility.loggedInUser.LocaleSidKey.length()>2){
	            			String findSid = Utility.loggedInUser.LocaleSidKey.substring(0,2);
	            			
	            			for(CMPUserBasedCSVPareser__c cmpCSVParserItr : CMPUserBasedCSVPareser__c.getAll().values()){
	            				if(!String.isEmpty(cmpCSVParserItr.Name)&& cmpCSVParserItr.Name.length()==2){
	            					if(findSid.equalsIgnoreCase(cmpCSVParserItr.Name)){
	            						CSVRowDeliminator = cmpCSVParserItr.CSVRowDeliminator__c;
	            					}
	            				}
	            			}
	            		}
	    			}
    			}
	    		if(String.isEmpty(CSVRowDeliminator)){	
	            	CSVRowDeliminator= ',';
	    		}
    			return CSVRowDeliminator;
    	}
    	private set;
    }
    
    public static void updateOptionInput(sObject input, sObject optionInput, String selectedTranscation, String fieldSet){
		input.put('Type__c', selectedTranscation);
        input.put('input_Type__c', selectedTranscation);
        if(fieldSet=='Option_Other'){
        	optionInput.put('Parent_Account__c', Utility.currentAccount);
            optionInput.put('User__c', Utility.loggedInUser.id);
        	if(selectedTranscation == 'Option - Other'){
            	input.put('Type__c', 'Option Protection - Other');            	
            	optionInput.put('Type__c', 'Option Obligation - Other');
        	}
        	if(selectedTranscation == 'Option - WUBS'){
            	input.put('Type__c',  'Option Protection - WUBS');
            	optionInput.put('Type__c', 'Option Obligation - WUBS');
        	}
        	optionInput.put('Buy_Currency__c', input.get('Buy_Currency__c'));
        	optionInput.put('Sell_Currency__c', input.get('Sell_Currency__c'));
        	optionInput.put('Counter_Party__c', input.get('Counter_Party__c'));
        	optionInput.put('Transaction_Date__c', input.get('Transaction_Date__c'));
        	optionInput.put('input_Type__c', input.get('input_Type__c'));
          optionInput.put('CurrencyIsoCode', input.get('Custom_Currency__c'));
        	optionInput.put('Input_Beneficiary__c', input.get('Input_Beneficiary__c'));
        	optionInput.put('Reference_Number__c', input.get('Reference_Number__c'));
        	//input.Reference_Number__c='';
        }    	
    }
 
 	public static boolean isValidSfdcId(Id sfdcId){
 		String zSfdcId = '';
 		if(sfdcId!=null){
 			zSfdcId = sfdcId + '';
 		}
 		if(sfdcId==null || String.IsEmpty(zSfdcId)){
 			return false;
 		}
 		return true;
 	}
    
    
    
    
    public static String getValidationTextByFieldType(Schema.FieldSetMember f ){
		//if(f.getType()==Schema.DisplayType.String){
		if(f.getType()==Schema.DisplayType.DATE){
        return ': ' + System.Label.CM_Validation_Input_FieldShouldBeAValidDate;
		}
		if(f.getType()==Schema.DisplayType.PICKLIST){
        return ': ' + System.Label.CM_Validation_Input_FieldShouldBeAValidValue;
		}
		if(f.getType()==Schema.DisplayType.DOUBLE){
        return ': ' + System.Label.CM_Validation_Input_FieldShouldBeAValidNumber;
		}
    return ': ' + System.Label.CM_Validation_Input_FieldShouldNotBeBlank;
/*DATE
PICKLIST
DOUBLE
REFERENCE
*/
    }
    public static boolean getBoolean(String srcText){
        if(srcText.equalsIgnoreCase(Label.CM_Field_Value_Yes)){
            srcText = 'true';
        }
        if(srcText.equalsIgnoreCase(Label.CM_Field_Value_No)){
            srcText = 'false';
        }
        if(Utility.isValidText(srcText)){
            try{
                system.debug('****Decimal Src>>'+Utility.getValidText(srcText));
                return Boolean.valueOf(Utility.getValidText(srcText));
            }catch(Exception Ex){
                system.debug('****Decimal>>'+Ex);
            }
        }
        return false;
    }

    //Added by Rohit B on 30/Apr/2015 for Test User Creation
    public static User createTestUser(boolean isInsert){
      Account acc = new Account();
      acc.Name = 'testname';
      insert acc;
      
      Contact contact = new Contact();
      contact.AccountId =  acc.Id;
      contact.LastName = 'testlastname';
      insert contact;
      
      User testUser = new User();
      testUser.alias = 'testuser';
      testUser.Email = 'testuser@test123.com';
      testUser.EmailEncodingKey = 'ISO-8859-1';
      testUser.LanguageLocaleKey = 'en_US';
      testUser.LastName = 'Test User567';
      testUser.LocaleSidKey = 'en_AU';
      testUser.Account_Administrator__c = false;
      testUser.ProfileId = [SELECT Id FROM Profile WHERE Name LIKE 'Partner community - FX management tool' LIMIT 1].Id;
      testUser.TimeZoneSidKey = 'Australia/Sydney';
      testUser.UserName = 'testuser@travelex.com.au';
      testUser.ContactId = contact.Id;
      testUser.DefaultCurrencyIsoCode = 'INR';
      
      if(isInsert)
        insert testUser;
      return testUser;
    }
}