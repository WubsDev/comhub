// 
// (c) 2014 Appirio, Inc.
//
// CMPFeedbackTriggerManager
// Used as handler class for trigger CMPFeedbackTrigger
//
// May 28, 2015    Ashish Goyal  			Original (Ref. T-399983)
// Modified : June 02, 2015    Ashish Goyal  			Ref. T-405363
//
public with sharing class CMPFeedbackTriggerManager {
	
	public static final String APPROVAL_COMMENTS = 'Submitting for approval';
	public static final String APPROVAL_STATUS = 'Promoted to Idea';
	
	public static void afterInsert(List<CMP_Feedback__c> newCMPList){	
		for(CMP_Feedback__c cmp : newCMPList){
			if(cmp.Submit_for_Approval__c){
				Approval.ProcessSubmitRequest req = createApprovalRequestForCMP(cmp);
				Approval.ProcessResult result = Approval.process(req);
				system.debug('------------------------------'+result);
			}
		}		
	}
	
	
	public static void afterUpdate(List<CMP_Feedback__c> newCMPList, Map<Id, CMP_Feedback__c> oldMap){	
		List<Idea> cmpToIdeaInsertList = new List<Idea>();
		Idea ideaObj;
		String communityId = '';
		Community comm = [SELECT Id FROM Community where Name =: Label.Community_Name];
		if(comm != null){
			communityId = comm.Id;
		}
		
		for(CMP_Feedback__c cmp : newCMPList){
			if(cmp.Approval_Status__c == APPROVAL_STATUS && oldMap.get(cmp.Id).Approval_Status__c != cmp.Approval_Status__c){
				ideaObj = new Idea();
				ideaObj.CMP_Feedback__c=cmp.id;
				ideaObj.Title = cmp.Title__c;			
				// ideaObj.Body = cmp.Objective__c;
				ideaObj.Body = 'As '+cmp.Voice__c+' I want '+cmp.Request__c+' so that '+cmp.Objective__c;
				ideaObj.Category = cmp.Category__c;
				ideaObj.Description__c = cmp.Description__c;
				ideaObj.Priority__c = cmp.Priority__c;
				ideaObj.Product_Area__c = cmp.Product_Area__c;
				ideaObj.CommunityId = communityId;
				cmpToIdeaInsertList.add(ideaObj);
			}
		}	
		if(cmpToIdeaInsertList.size() > 0){
			insert cmpToIdeaInsertList;
		}
	}
		
	
	public static void beforeInsert(List<CMP_Feedback__c> newCMPList){		
		for(CMP_Feedback__c cmp : newCMPList){
			if(!cmp.Submit_for_Approval__c){
				cmp.Submit_for_Approval__c = true;
			}
		}		
	}
	
	
	
	private static Approval.ProcessSubmitRequest createApprovalRequestForCMP(CMP_Feedback__c cmpObj){
		Id nextApproverId = cmpObj.OwnerId;
		Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
		req.setComments(APPROVAL_COMMENTS);
        req.setObjectId(cmpObj.Id);
        if(nextApproverId != null) {
            req.setNextApproverIds(new List<Id>{nextApproverId});
        }
        return req;
	}

}