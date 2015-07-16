/**=======================================================================================
 * Name: CustomLookupCtrl_Test
 * Description: Test Class of CustomLookupCtrl Class
 * Created Date: Apr 29, 2015
 * Created By: Rohit B. (Appirio)
 * 
 * Date Modified                Modified By                 	Description of the update
 * [Date]						[Developer Name]				[Short Description]
 ==========================================================================================*/

@isTest
private class CustomLookupCtrl_Test {
	
	@isTest static void test_method_one() {
		Input_Beneficiary__c ib = new Input_Beneficiary__c(Name = 'Test 1');
        insert ib;

		CustomLookupCtrl clc = new CustomLookupCtrl();
		clc.fieldName = 'Name';
		clc.objName = 'Input_Beneficiary__c';
		clc.selectedId = ib.Id;
		clc.currentRecord = Null;
		clc.selectedRecordName = '';
		clc.fieldPopulatingId = '';
		clc.fieldSetNameAPI = '';

		PageReference pr = clc.getSelectedRecord();

		System.assertEquals(clc.selectedRecordName, ib.Name);
	}	
}