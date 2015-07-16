/**=======================================================================================
 * Name: AutoFollowTheRecords_Test
 * Description: Test Class of AutoFollowTheRecords Class
 * Created Date: Apr 29, 2015
 * Created By: Rohit B. (Appirio)
 * 
 * Date Modified                Modified By                 	Description of the update
 * [Date]						[Developer Name]				[Short Description]
 ==========================================================================================*/

@isTest
private class AutoFollowTheRecords_Test {
	
	@isTest 
    static void test_method_one() {
		Account a = new Account();
        a.Name = 'Test Account';
        insert a;

        Set<Id> followIds = new set<Id>();
        followIds.add(a.Id);

        AutoFollowTheRecords.followRecords(followIds, userinfo.getUserId());

        List<EntitySubscription> lstEntitySubscription = [SELECT Id From EntitySubscription WHERE 
                                                              ParentId =: a.Id AND SubscriberId =: userinfo.getUserId()];
		
        //System.assert(lstEntitySubscription.size()>0);
	}	 
}