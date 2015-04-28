public with sharing class accountFXManagerLinks {

    User currentUser;
    Account acct;

    public accountFXManagerLinks(ApexPages.StandardController stdController) {
        acct = (Account)stdController.getRecord();
        currentUser = [SELECT Id, Profile.Name, UserRole.Name, Alias FROM User WHERE Id = :UserInfo.getUserId()];

    }

    public PageReference inputsPage() {
        // PageReference page = new PageReference('/apex/portalAccountInput?scontrolCaching=1&id=' + acct.Id);
        PageReference page = new PageReference('/apex/accountInputReportViewPage?scontrolCaching=1&aId=' + acct.Id);
        page.setRedirect(true);
        return page;
    }

    public PageReference reportsPage() {
        // PageReference page = new PageReference('/apex/portalCashFlowReport?aId=' + acct.Id);
        PageReference page = new PageReference('/apex/accountNetExposureViewPage?aId=' + acct.Id);
        page.setRedirect(true);
        return page;
    }



}