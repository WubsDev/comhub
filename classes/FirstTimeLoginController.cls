// 
// (c) 2014 Appirio, Inc.
//
// FirstTimeLoginController
// Used as component Controller to show modal window for first time login
//
// 17 Apr, 2015    Ashish Goyal  Original (Ref. T-378076)
//
public with sharing class FirstTimeLoginController {
	
	public Boolean IsFirstTimeLogin {get; set;}
	
	public FirstTimeLoginController(){
		User testUser = [Select Id, First_Time_Login__c from User Where Id =: UserInfo.getUserId()];
		IsFirstTimeLogin = true;
		if(testUser.First_Time_Login__c != null){
			IsFirstTimeLogin = false;
		}
	}
	
	public void updateUser(){
		User testUser = [Select Id, First_Time_Login__c from User Where Id =: UserInfo.getUserId()];
		testUser.First_Time_Login__c = System.now();
		update testUser;
	}

}