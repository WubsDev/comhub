/**
 * Appirio, Inc
 * Name             : OpenLookupPopupBeneficiaryCtrlTest
 * Created Date     : 1 May 2015 
 * Created By       : Nikhil Sharma (Appirio)
 * Description      : Test class for OpenLookupPopupBeneficiaryCtrl
 */
@isTest
private class OpenLookupPopupBeneficiaryCtrlTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Account acc = new Account(name='test');
        insert acc;
        ApexPages.currentPage().getParameters().put('Object','Input_Beneficiary__c');
        ApexPages.currentPage().getParameters().put('fieldName','Name');
        ApexPages.currentPage().getParameters().put('fieldSetName','detail');
        ApexPages.currentPage().getParameters().put('aId', acc.Id);
        OpenLookupPopupBeneficiaryCtrl ctrl = new OpenLookupPopupBeneficiaryCtrl();
        ctrl.selectedObject = '';
     //   String str = ctrl.getFieldsForSelectedObject();
    }
}