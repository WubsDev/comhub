public with sharing class AttachmentUpload {
	public Attachment attach{get;set;}
	public String retURL{get;set;}
	public AttachmentUpload(ApexPages.StandardController stdController){
		Id parentId = ApexPages.currentPage().getParameters().get('pid');
		retURL = ApexPages.currentPage().getParameters().get('retURL');
		Id attachId = ApexPages.currentPage().getParameters().get('id');
		if(attachId == null){
			attach = new Attachment(ParentId = parentId);
		}else{
			attach = [SELECT Id, Description, Name FROM Attachment WHERE Id = :attachId];
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
	public PageReference cancel(){		
    	PageReference pg = new PageReference(retURL);
    	pg.setRedirect(true);
    	return pg;
	}
}