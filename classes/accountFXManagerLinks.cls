public with sharing class accountFXManagerLinks {

    User currentUser;
    Account acct;
    Boolean isDealer;

    public accountFXManagerLinks(ApexPages.StandardController stdController) {
        acct = (Account)stdController.getRecord();
        isDealer = false;
        currentUser = [SELECT Id, Profile.Name, UserRole.Name, Alias FROM User WHERE Id = :UserInfo.getUserId()];
        String dealerProfileVal = Label.Dealer_Profile;
        List<String> dealerProfileList = new List<String>();
        if(!String.isEmpty(dealerProfileVal)){
        	dealerProfileList = dealerProfileVal.split(',');
        }
        for(String profName : dealerProfileList){
        	if(currentUser.Profile.Name.toLowerCase().contains(profName.toLowerCase())){
        		isDealer = true;
        	}
        }

    }

    public PageReference inputsPage() {
    	PageReference page;
    	if(isDealer){
    		page = new PageReference('/apex/accountInputReportViewPage?scontrolCaching=1&aId=' + acct.Id);
    	}else{
    		page = new PageReference('/apex/portalAccountInput?scontrolCaching=1&id=' + acct.Id);
    	}
        page.setRedirect(true);
        return page;
    }

    public PageReference reportsPage() {
    	PageReference page;
    	if(isDealer){
    		page = new PageReference('/apex/accountNetExposureViewPage?aId=' + acct.Id);
    	}else{
    		page = new PageReference('/apex/portalCashFlowReport?aId=' + acct.Id);
    	}
        page.setRedirect(true);
        return page;
    }



}