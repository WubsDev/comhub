/**
 * Appirio, Inc
 * Name             : AddAnotherInputCtrlTest
 * Created Date     : 23 March 2015 
 * Created By       : Shailendra Singh (Appirio)
 * Description      : Test class for AddAnotherInputCtrl
 */
@isTest
private class AddAnotherInputCtrlTest {

    static testMethod void myUnitTest() {
        System.currentPageReference().getParameters().put('sourcePage', 'InsightsAndInputTab');
        AddAnotherInputCtrl ctrl = new AddAnotherInputCtrl();
        ctrl.addAnotherInput();
        Pagereference ref = ctrl.finished();
        System.assertEquals(ref.getUrl(), '/apex/InsightsAndInputTab');
        
        System.currentPageReference().getParameters().put('sourcePage', null);
        ctrl = new AddAnotherInputCtrl();
    }
}