public class PortalUserCurrency {
	public List<String> avlblCrncy{get; set;}
	public String selectedValue {get; set;}
	public User locUser{get;set;}
	public String closeUserPopup{get;set;}
    public Boolean isRecordShare {get; set;}
	public PortalUserCurrency() {
        initialize();
  }
  
  public void initialize(){
  	closeUserPopup = '';
    locUser = [SELECT Id,Name,Share_Records__c, DefaultCurrencyIsoCode from User where id =: UserInfo.getUserId()];
  	selectedValue = locUser.DefaultCurrencyIsoCode;
    // isRecordShare = locUser.Share_Records__c;
  	 	
  }  
  
  public List<SelectOption> getCurrencyList(){
    	return picklistValues('User','DefaultCurrencyIsoCode');    	
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
  public PageReference cancel(){
      PageReference homePg = new PageReference(Site.getBaseUrl()+'/apex/WuDashboard');
      homePg.setRedirect(true);
  		return homePg;
  }
  
  
  public void updateSharingPemissionOnRecord(){
    try{
        update locUser;
         ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.CM_Alert_SharingPermission_UpdatedSuccessfully));
         closeUserPopup = 'self.close();';
    }catch(Exception ex){
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CM_Alert_SharingPermission_UpdatedError + ' ' + ex.getMessage()));
    }
  }
  
  
  public void updateRecord(){
  	try{
  		 closeUserPopup='';
 		 locUser.DefaultCurrencyIsoCode = selectedValue;
 		 update locUser;
         ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.CM_Alert_Currency_UpdatedSuccessfully + ' "' + selectedValue + '".'));
 		 closeUserPopup = 'self.close();';
 		 
  	}
  	catch(Exception ex){
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CM_Alert_UnableToSaveErrorDetail + ' '  + ex.getMessage()));
  	}
  }


}