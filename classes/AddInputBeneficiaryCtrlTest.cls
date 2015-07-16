/**
*/

@isTest
private class AddInputBeneficiaryCtrlTest {
	public static Input_Beneficiary__c inputBene;
	public static Account acc;
	
	static testMethod void myUnitTest() {
		createTestData();
		AddInputBeneficiaryCtrl inp = new AddInputBeneficiaryCtrl();
		inp.save();
		inp.cancel();
		
	}
	
	private static void createTestData(){
		
		inputBene = new Input_Beneficiary__c();
		inputBene.name = 'test';
		insert inputBene;
		
		acc = new Account();
		acc.name = 'test';
		//insert acc;
		
		
	}
}