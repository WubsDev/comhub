public with sharing class AttachmentUpload {
	Integer maxAttachAllowed = 5;
	public Attachment attach{get;set;}
	public String retURL{get;set;}
	public AttachmentUpload(ApexPages.StandardController stdController){
		Id parentId = ApexPages.currentPage().getParameters().get('pid');
		retURL = ApexPages.currentPage().getParameters().get('retURL');
		Id attachId = ApexPages.currentPage().getParameters().get('id');
		if(attachId == null){
			attach = new Attachment(ParentId = parentId);
		}else{
			attach = [SELECT Id, Description, Name FROM Attachment WHERE Id = :attachId order by CreatedDate];
		}
	}
	public PageReference save(){		
    	if((attach.Id == null && attach.body == null) || attach.Name == null){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Attachment is not uploaded.'));
    		return null;
    	}
    	upsert attach;
    	PageReference pg = new PageReference(retURL);
    	pg.setRedirect(true);
    	return pg;
	}
	//Keep last five version of document T-406227: Version Control
	public PageReference saveUptoFive(){		
    	if((attach.Id == null && attach.body == null) || attach.Name == null){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Attachment is not uploaded.'));
    		return null;
    	}
    	upsert attach;
    	List<Attachment>delAttachment = new List<Attachment>();
    	Integer attchCount =1;
 		for(Attachment delatt : [SELECT Id from Attachment WHERE ParentId =:attach.parentId order by createddate desc]){
 			if(attchCount> maxAttachAllowed){
 				delAttachment.add(delatt);
 			}
 			attchCount++;
 		}
 		if(delAttachment.size()> 0){
 			delete delAttachment;
 		}
    	PageReference pg = new PageReference(retURL);
    	pg.setRedirect(true);
    	return pg;
	}	
	public PageReference cancel(){		
    	PageReference pg = new PageReference(retURL);
    	pg.setRedirect(true);
    	return pg;
	}
}