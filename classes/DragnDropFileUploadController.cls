/**=====================================================================
 * Name: DragnDropFileUploadController
 * Description: Related to DragnDropFileUpload Section In InvoicesAndPaymentsTab & InsightsAndInputsTab
 * Created Date: Jan 15, 2015
 * Created By: Nishant Bansal (JDC)
 * 
 * Date Modified                Modified By                  Description of the update
 =====================================================================*/
 
global class DragnDropFileUploadController{
     
    public String parentId{get;set;} 
    public String typeInput{get;set;}
    public String sourcePageCtl{get;set;}
    public Attachment attachment {
    	get{
    		if (attachment == null)
            attachment = new Attachment();
            return attachment;
    	}set;
    }
    public Pagereference uploadFile(){
            attachment.ParentId=parentId;
            insert attachment;
            return null;
    }
    
    @RemoteAction
    global static String uploadFile(String parentId, String attachmentId, String fileName, String contentType, String base64BlobValue){
        /*
        parentId: The sfdc object Id this file will be attached to
        attachmentId: The record of the current Attachment file being processed
        fileName: Name of the attachment
        contentTye: Content Type of the file being attached
        base64BlobValue: Base64 encoded string of the file piece currently processing
        */
         List<Attachment> AttachmentList = new List<Attachment>();
        //If recordId is blank this is the first part of a multi piece upload
        if(attachmentId == '' || attachmentId == null){
          Attachment exitsingAttachment;
          System.debug('fileName===' + fileName);
          for(Attachment att : [Select id from Attachment where Name = :fileName AND parentId = :parentId limit 1]){
              exitsingAttachment = att;
          }
          if(exitsingAttachment != null){
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'{!$Label.CM_Alert_AttachmentAlreadyExistsWithSameName1}' + ' ' + attachment.name + ' ' + '{!$Label.CM_Alert_AttachmentAlreadyExistsWithSameName2}'));
	          return null;
          }
            Attachment att = new Attachment(
                ParentId = parentId,
                Body = EncodingUtil.Base64Decode(base64BlobValue),
                Name = fileName,
                ContentType = contentType
            );
            insert att;
            AttachmentList.add(att);
            return AttachmentList.get(0).id;
            
        }else{
            for(Attachment atm : [select Id, Body from Attachment where Id = :attachmentId]){
                //Take the body of the current attachment, convert to base64 string, append base64 value sent from page, then convert back to binary for the body
                update new Attachment(Id = attachmentId, Body = EncodingUtil.Base64Decode(EncodingUtil.Base64Encode(atm.Body) + base64BlobValue));
            }
            
            //Return the Id of the attachment we are currently processing
            return attachmentId;
        }
    }
    //Get cuttent page name
    private String getPageName(){
    	if(String.isEmpty(sourcePageCtl)){
    		return Utility.getVFPageName();
    	}
    	return sourcePageCtl;
    }
// To upload the file in InvoiceAndPayment Section Using the browse button    
      public PageReference upload1() {
      	System.debug('====+Anjali Attachment name==' + attachment.Name);
          Attachment exitsingAttachment;
          String accId = Utility.currentAccount;
          for(Attachment att : [Select id from Attachment where Name = :attachment.Name]){
              exitsingAttachment = att;
          }
          if(exitsingAttachment != null){
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CM_Alert_AttachmentAlreadyExistsWithSameName1 + ' ' + attachment.name + ' ' + System.Label.CM_Alert_AttachmentAlreadyExistsWithSameName2));
	          return null;
          }
      	attachment.OwnerId = Utility.loggedInUser.id;
	    attachment.ParentId = parentId; // the record the file is attached to
	    attachment.IsPrivate = false;
	    attachment.contentType= 'text;charset=UTF-8'; 	
        
	    try {
	        insert attachment;
	    }catch (DMLException e) {
	      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
	      return null;
	    } finally {
	    }
	    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
	    PageReference pr =  new PageReference('/apex/ParseAndDisplayCSVInvoicePage?attid='+attachment.id + '&aId='+accId+'&sourcePage='+getPageName());
	    pr.setredirect(true);
	    return pr;
      }
      
      
// To upload the file in InsightsAndInputs Section Using the browse button     	  
	public PageReference uploadInput() {
		System.debug('====+Anjali Attachment name==' + attachment);
		String accId = Utility.currentAccount;
		if(parentId == null){
			parentId = accId;
		}
		Attachment exitsingAttachment;
		for(Attachment att : [Select id from Attachment where Name = :attachment.Name AND parentId = :parentId limit 1]){
			exitsingAttachment = att;
		}
		if(exitsingAttachment != null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.CM_Alert_AttachmentAlreadyExistsWithSameName1 + ' ' + attachment.name + ' ' + System.Label.CM_Alert_AttachmentAlreadyExistsWithSameName2));
		    return null;
		}
	  	attachment.OwnerId = UserInfo.getUserId();
	    attachment.ParentId = parentId; // the record the file is attached to
	    attachment.IsPrivate = false;
	    attachment.contentType= 'text;charset=UTF-8'; 
	
	    try {
	        insert attachment;
	    }catch (DMLException e) {
	      ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
	      return null;
	    } finally {
	    }
	    String pageName;
	    String invPageName;
	    String sitePrefix = Site.getPathPrefix();
	    system.debug('-------------Site.getPathPrefix()---------'+Site.getPathPrefix());
	    if(!String.isEmpty(sitePrefix)){
	    	pageName = 'ParseandDisplayCSVGeneric';
	    	invPageName = 'ParseAndDisplayCSVInvoicePage';
	    }else{
	    	pageName = 'ParseandDisplayCSVGenericFD';
	    	invPageName = 'ParseAndDisplayCSVInvoicePageFD';
	    }
	    
	    if(typeInput == 'Invoice') {
			PageReference pr =  new PageReference('/apex/'+invPageName+'?attid='+attachment.id + '&aId='+accId+'&sourcePage='+getPageName()+'&type='+typeInput);
    		pr.setredirect(true);
   			return pr;
		}else{
			PageReference pr =  new PageReference('/apex/'+pageName+'?attid='+attachment.id + '&aId='+accId+'&sourcePage='+getPageName()+'&type='+typeInput);
    		pr.setredirect(true);
   			return pr;
		}
	    /*
        if(typeInput == 'Purchase Order'  ||  typeInput == 'Forecast Outflow') {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
	    	PageReference pr =  new PageReference('/apex/ParseAndDisplayCSVInput?attid='+attachment.id + '&sourcePage='+getPageName()+'&type='+typeInput);
	    	pr.setredirect(true);
	    	return pr;
		}else 
            if (typeInput == 'Forecast Inflow') {
				PageReference pr =  new PageReference('/apex/ParseAndDisplayCSVInputIncoming?attid='+attachment.id + '&sourcePage='+getPageName()+'&type='+typeInput);
	    		pr.setredirect(true);
	    		return pr;
			}
	       else if(typeInput == 'Fixed Forward Contract - Other' || typeInput == 'Window Forward Contract - Other' ||typeInput == 'Option - Other' || typeInput == 'Option - WUBS') {
					PageReference pr =  new PageReference('/apex/ParseandDisplayCSVGeneric?attid='+attachment.id + '&sourcePage='+getPageName()+'&type='+typeInput);
		    		pr.setredirect(true);
	       			return pr;
	       }else if(typeInput == 'Invoice') {
					PageReference pr =  new PageReference('/apex/ParseAndDisplayCSVInvoicePage?attid='+attachment.id + '&sourcePage='+getPageName()+'&type='+typeInput);
		    		pr.setredirect(true);
	       			return pr;
	       }
	       */			
    	return null;
	}
}